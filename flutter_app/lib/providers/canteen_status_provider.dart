import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';

class CanteenStatusProvider with ChangeNotifier {
  bool _isOpen         = false;
  String _busyness     = 'Low';
  String? _broadcast;
  bool _isLoading      = true;
  StreamSubscription? _statusSub;
  StreamSubscription? _broadcastSub;

  bool    get isOpen    => _isOpen;
  String  get busyness  => _busyness;
  String? get broadcast => _broadcast;
  bool    get isLoading => _isLoading;

  CanteenStatusProvider() {
    _initSocket();
  }

  void _initSocket() {
    _statusSub = SocketService.canteenStatusStream.listen((data) {
      _isOpen    = data['is_open'] ?? _isOpen;
      _busyness  = data['busyness_level'] ?? data['busyness'] ?? _busyness;
      notifyListeners();
    });
    _broadcastSub = SocketService.broadcastStream.listen((data) {
      _broadcast = data['message']?.toString();
      notifyListeners();
    });
  }

  Future<void> fetchStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.client.get(ApiConfig.canteenStatus);
      final data = res.data;
      _isOpen   = data['is_open'] ?? false;
      _busyness = data['busyness_level'] ?? data['busyness'] ?? 'Low';
      _broadcast = data['broadcast_message'];
    } catch (e) {
      // Silently handle status fetch failure
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _broadcastSub?.cancel();
    super.dispose();
  }
}
