import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pre_order_item_model.dart';
import '../models/meal_slot_model.dart';
import '../models/token_receipt_model.dart';
import '../services/pre_order_service.dart';
import '../services/socket_service.dart';

class PreOrderProvider with ChangeNotifier {
  // ─── State ─────────────────────────────────────────────────────────────────
  List<PreOrderItemModel> _availableItems = [];
  MealSlotModel? _currentSlot;
  final Map<String, int> _cart = {}; // menuItemId → quantity
  int _nowServingToken = 0;
  bool _isLoading = false;
  bool _isPlacingOrder = false;
  String? _error;
  String? _lastPickupTime;
  String? _lastNotes;

  // ─── Socket subscriptions ──────────────────────────────────────────────────
  StreamSubscription? _soldOutSub;
  StreamSubscription? _capacitySub;
  StreamSubscription? _nowServingSub;
  StreamSubscription? _tokenGeneratedSub;

  // ─── Getters ───────────────────────────────────────────────────────────────
  List<PreOrderItemModel> get availableItems => _availableItems;
  MealSlotModel? get currentSlot => _currentSlot;
  Map<String, int> get cart => Map.unmodifiable(_cart);
  int get nowServingToken => _nowServingToken;
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;

  int get cartTotalItems => _cart.values.fold(0, (a, b) => a + b);

  double get cartTotalAmount {
    double total = 0;
    for (final entry in _cart.entries) {
      final item = _availableItems.firstWhere(
        (i) => i.id == entry.key,
        orElse: () => _availableItems.first,
      );
      total += item.price * entry.value;
    }
    return total;
  }

  /// Projected token range if order is placed right now.
  (int start, int end) get projectedTokenRange {
    final current = _currentSlot?.currentTokenNumber ?? 0;
    final total   = cartTotalItems;
    if (total == 0) return (0, 0);
    return (current + 1, current + total);
  }

  int get estimatedWaitMinutes {
    final end = projectedTokenRange.$2;
    if (end == 0 || _nowServingToken == 0) return end * 2;
    return (end - _nowServingToken).clamp(0, 9999) * 2;
  }

  bool get cartHasSoldOutItems => _cart.keys.any((id) {
    final item = _availableItems.firstWhere(
      (i) => i.id == id,
      orElse: () => _availableItems.first,
    );
    return !item.isPreOrderable;
  });

  List<PreOrderItemModel> get cartSoldOutItems => _cart.keys
      .map((id) => _availableItems.firstWhere(
            (i) => i.id == id,
            orElse: () => _availableItems.first,
          ))
      .where((i) => !i.isPreOrderable)
      .toList();

  // ─── Constructor ───────────────────────────────────────────────────────────
  PreOrderProvider() {
    _listenToSocket();
  }

  // ─── Socket listeners ──────────────────────────────────────────────────────
  void _listenToSocket() {
    _soldOutSub = SocketService.preOrderSoldOutStream.listen((data) {
      final itemId   = data['itemId'] as String?;
      if (itemId == null) return;
      _updateItemCapacity(itemId, 0, 'sold_out');
      // If item is in cart, notify user via snackbar (provider emits state)
      notifyListeners();
    });

    _capacitySub = SocketService.preOrderCapacityStream.listen((data) {
      final itemId    = data['itemId'] as String?;
      final remaining = data['remaining'] as int?;
      final status    = data['status'] as String?;
      if (itemId == null || remaining == null || status == null) return;
      _updateItemCapacity(itemId, remaining, status);
      notifyListeners();
    });

    _nowServingSub = SocketService.nowServingStream.listen((data) {
      final token = data['tokenNumber'] as int?;
      if (token != null) {
        _nowServingToken = token;
        notifyListeners();
      }
    });

    _tokenGeneratedSub = SocketService.tokenGeneratedStream.listen((data) {
      // Handled in placeOrder() — receipt navigation done there
      notifyListeners();
    });
  }

  void _updateItemCapacity(String itemId, int remaining, String status) {
    _availableItems = _availableItems.map((item) {
      if (item.id == itemId) {
        return item.copyWithCapacity(remaining: remaining, status: status);
      }
      return item;
    }).toList();
  }

  // ─── Data fetching ─────────────────────────────────────────────────────────
  Future<void> fetchAvailableItems({String? mealSlot}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await PreOrderService.getAvailableItems(mealSlot: mealSlot);
      _availableItems = result['items'] as List<PreOrderItemModel>;
      _currentSlot    = result['slot'] as MealSlotModel?;
    } catch (e) {
      _error = 'Failed to load pre-order items: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSlotStatus() async {
    try {
      final result = await PreOrderService.getSlotStatus();
      final slot = result['slot'] as MealSlotModel?;
      if (slot != null) {
        _currentSlot = slot;
        _nowServingToken = slot.nowServing;
        notifyListeners();
      }
    } catch (_) {}
  }

  // ─── Cart operations ───────────────────────────────────────────────────────
  /// Returns false if item is sold_out (caller should show snackbar).
  bool addToCart(String itemId) {
    final item = _availableItems.firstWhere(
      (i) => i.id == itemId,
      orElse: () => _availableItems.first,
    );

    if (!item.isPreOrderable) {
      return false; // sold out
    }

    final current = _cart[itemId] ?? 0;
    if (current < 20) {
      _cart[itemId] = current + 1;
      notifyListeners();
    }
    return true;
  }

  void removeFromCart(String itemId) {
    _cart.remove(itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int qty) {
    if (qty < 1) {
      removeFromCart(itemId);
      return;
    }
    if (qty > 20) qty = 20;
    _cart[itemId] = qty;
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _lastPickupTime = null;
    _lastNotes = null;
    notifyListeners();
  }

  // ─── Place order ───────────────────────────────────────────────────────────
  /// Returns the TokenReceiptModel on success, throws on failure.
  Future<TokenReceiptModel> placeOrder({
    String? pickupTime,
    String? notes,
  }) async {
    if (_currentSlot == null) throw Exception('No active meal slot');
    if (_cart.isEmpty) throw Exception('Cart is empty');
    if (cartHasSoldOutItems) {
      throw Exception('Some items in your cart are now sold out. Remove them first.');
    }

    _isPlacingOrder = true;
    _lastPickupTime = pickupTime;
    _lastNotes      = notes;
    notifyListeners();

    try {
      final items = _cart.entries.map((e) => {
        'menu_item_id': e.key,
        'quantity':     e.value,
      }).toList();

      final response = await PreOrderService.createPreOrder(
        mealSlot:   _currentSlot!.slotName,
        items:      items,
        notes:      notes,
        pickupTime: pickupTime,
      );

      final orderId = response['order']['id'] as String;

      // Fetch full receipt data
      final receipt = await PreOrderService.getTokenReceipt(orderId);

      // Update local slot token count
      if (_currentSlot != null) {
        _currentSlot = MealSlotModel(
          id:                   _currentSlot!.id,
          slotName:             _currentSlot!.slotName,
          startTime:            _currentSlot!.startTime,
          endTime:              _currentSlot!.endTime,
          currentTokenNumber:   receipt.tokenEnd,
          nowServing:           _currentSlot!.nowServing,
          isActive:             _currentSlot!.isActive,
          date:                 _currentSlot!.date,
        );
      }

      clearCart();
      return receipt;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  // ─── Pickup time slots ────────────────────────────────────────────────────
  /// Returns a list of 30-minute pickup time slots within the current meal slot.
  List<String> get availablePickupTimes {
    final slot = _currentSlot;
    if (slot == null) return [];

    final times = <String>[];
    final startParts = slot.startTime.split(':');
    final endParts   = slot.endTime.split(':');

    int h = int.parse(startParts[0]);
    int m = int.parse(startParts[1]);
    final endH = int.parse(endParts[0]);
    final endM = int.parse(endParts[1]);
    final endTotal = endH * 60 + endM;

    while (h * 60 + m <= endTotal) {
      times.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
      m += 30;
      if (m >= 60) { h++; m -= 60; }
    }

    return times;
  }

  // ─── Dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _soldOutSub?.cancel();
    _capacitySub?.cancel();
    _nowServingSub?.cancel();
    _tokenGeneratedSub?.cancel();
    super.dispose();
  }
}
