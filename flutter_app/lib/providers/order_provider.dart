import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  StreamSubscription? _sub;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    _initSocket();
  }

  void _initSocket() {
    _sub = SocketService.orderStream.listen((data) {
      // Update specific order
      final idx = _orders.indexWhere((o) => o.id == data['orderId']);
      if (idx != -1) {
        // Simple reload of all for ease, or update specific object
        fetchOrders();
      } else {
        fetchOrders();
      }
    });
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.client.get(ApiConfig.orders);
      List<dynamic> data = res.data['orders'];
      _orders = data.map((j) => OrderModel.fromJson(j)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> placeOrder(List<Map<String, dynamic>> items, String timeSlot, String notes) async {
    await ApiService.client.post(ApiConfig.orders, data: {
      'items': items,
      'time_slot': timeSlot,
      'notes': notes,
    });
    await fetchOrders();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
