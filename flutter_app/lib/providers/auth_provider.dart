import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token != null) {
      _user = await AuthService.getMe();
      if (_user != null) {
        await SocketService.connect();
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  String _extractError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        return data['message'] ?? data['error'] ?? 'Network error occurred';
      }
      return e.message ?? 'Network error occurred';
    }
    return e.toString().replaceAll('Exception: ', '');
  }

  Future<void> login(String email, String password) async {
    try {
      final data = await AuthService.login(email, password);
      await AuthService.saveTokens(data['accessToken'], data['refreshToken']);
      _user = UserModel.fromJson(data['user']);
      await SocketService.connect();
      notifyListeners();
    } catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> register(
      String name, String email, String password, String department, String year, String section) async {
    try {
      await AuthService.register(name, email, password, department, year, section);
      // After register, perform login automatically or let user login
      await login(email, password);
    } catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> updateProfile(String name, String phone, [String? password]) async {
    try {
      await AuthService.updateProfile(name, phone, password);
      await refreshUser();
    } catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    SocketService.disconnect();
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final updatedUser = await AuthService.getMe();
    if (updatedUser != null) {
      _user = updatedUser;
      notifyListeners();
    }
  }
}
