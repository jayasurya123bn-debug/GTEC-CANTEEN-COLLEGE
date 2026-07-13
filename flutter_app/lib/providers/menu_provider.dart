import 'dart:async';
import 'package:flutter/material.dart';
import '../models/menu_category_model.dart';
import '../models/menu_item_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';

class MenuProvider with ChangeNotifier {
  List<MenuCategoryModel> _categories = [];
  bool _isLoading = false;
  StreamSubscription? _menuSub;

  List<MenuCategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  MenuProvider() {
    _initSocket();
  }

  void _initSocket() {
    _menuSub = SocketService.menuUpdateStream.listen((data) {
      // Delta update or refetch
      // For simplicity, just refetch
      fetchMenu();
    });
  }

  Future<void> fetchMenu() async {
    if (_categories.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final res = await ApiService.client.get(ApiConfig.menu);
      List<dynamic> data = res.data;
      _categories = data.map((json) => MenuCategoryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching menu: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _menuSub?.cancel();
    super.dispose();
  }
}
