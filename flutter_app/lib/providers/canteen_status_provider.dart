import 'dart:async';
import 'package:flutter/material.dart';
import '../models/canteen_status_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';

class CanteenStatusProvider with ChangeNotifier {
  CanteenStatusModel? _status;
  StreamSubscription? _sub;

  CanteenStatusModel? get status => _status;

  CanteenStatusProvider() {
    _initSocket();
  }

  void _initSocket() {
    _sub = SocketService.canteenStatusStream.listen((data) {
      _status = CanteenStatusModel.fromJson(data);
      notifyListeners();
    });
  }

  Future<void> fetchStatus() async {
    try {
      final res = await ApiService.client.get(ApiConfig.canteenStatus);
      _status = CanteenStatusModel.fromJson(res.data);
      notifyListeners();
    } catch (e) {
      print('Error fetching canteen status: $e');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
