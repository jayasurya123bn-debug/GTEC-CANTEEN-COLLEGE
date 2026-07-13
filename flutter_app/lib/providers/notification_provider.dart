import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.client.get(ApiConfig.notifications);
      List<dynamic> data = res.data['notifications'];
      _notifications = data.map((j) => NotificationModel.fromJson(j)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = NotificationModel(
        id: _notifications[idx].id,
        title: _notifications[idx].title,
        body: _notifications[idx].body,
        isRead: true,
        createdAt: _notifications[idx].createdAt,
      );
      notifyListeners();
    }
    await ApiService.client.patch('${ApiConfig.notifications}/$id/read');
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = NotificationModel(
        id: _notifications[i].id,
        title: _notifications[i].title,
        body: _notifications[i].body,
        isRead: true,
        createdAt: _notifications[i].createdAt,
      );
    }
    notifyListeners();
    await ApiService.client.patch('${ApiConfig.notifications}/read-all');
  }
}
