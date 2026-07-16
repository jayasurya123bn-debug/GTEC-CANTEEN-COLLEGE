import 'dart:async';
import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';

class MenuProvider with ChangeNotifier {
  List<MenuItemModel> _allItems = [];
  List<MenuItemModel> _filteredItems = [];
  bool _isLoading = false;
  String? _selectedCategory;
  String? _errorMessage;
  StreamSubscription? _menuSub;

  List<MenuItemModel> get items       => _filteredItems;
  List<MenuItemModel> get allItems    => _allItems;
  bool get isLoading                  => _isLoading;
  String? get selectedCategory        => _selectedCategory;
  String? get errorMessage            => _errorMessage;

  List<String> get categories {
    final seen = <String>{};
    final cats = <String>[];
    for (final item in _allItems) {
      if (seen.add(item.categoryName)) {
        cats.add(item.categoryName);
      }
    }
    return cats;
  }

  MenuProvider() {
    _initSocket();
  }

  void _initSocket() {
    _menuSub = SocketService.menuUpdateStream.listen((data) {
      final itemId      = data['id']?.toString() ?? data['item_id']?.toString();
      final newAvail    = data['availability']?.toString();

      if (itemId != null && newAvail != null) {
        // Real-time delta update — no full refetch needed
        _allItems = _allItems.map((item) {
          if (item.id == itemId) return item.copyWith(availability: newAvail);
          return item;
        }).toList();
        _applyFilter();
        notifyListeners();
      } else {
        // Fallback: full refetch for item added/deleted
        fetchMenu();
      }
    });
  }

  Future<void> fetchMenu() async {
    if (_allItems.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final res = await ApiService.client.get(ApiConfig.menu);
      final List<dynamic> data = res.data;
      final List<MenuItemModel> newItems = [];

      for (final categoryJson in data) {
        final categoryName = categoryJson['category']?.toString() ?? '';
        final itemsList = categoryJson['items'] as List? ?? [];
        for (final itemJson in itemsList) {
          newItems.add(MenuItemModel.fromJson(
            Map<String, dynamic>.from(itemJson),
            categoryName: categoryName,
          ));
        }
      }

      _allItems = newItems;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load menu. Pull to refresh.';
    }

    _isLoading = false;
    _applyFilter();
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      _filteredItems = List.from(_allItems);
    } else {
      _filteredItems = _allItems
          .where((item) => item.categoryName == _selectedCategory)
          .toList();
    }
  }

  @override
  void dispose() {
    _menuSub?.cancel();
    super.dispose();
  }
}
