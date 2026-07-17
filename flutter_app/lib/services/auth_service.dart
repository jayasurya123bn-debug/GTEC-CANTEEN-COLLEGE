import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiService.client.post(ApiConfig.login, data: {
      'email': email,
      'password': password,
    });
    return res.data;
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String department, String year, String section) async {
    final res = await ApiService.client.post(ApiConfig.register, data: {
      'name': name,
      'email': email,
      'password': password,
      'department': department,
      'year': year,
      'section': section,
    });
    return res.data;
  }

  static Future<void> updateProfile(String name, String phone, [String? password]) async {
    final Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
    };
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }
    await ApiService.client.put(ApiConfig.profile, data: data);
  }

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<void> logout() async {
    try {
      await ApiService.client.post(ApiConfig.logout);
    } catch (e) {
      // Ignore
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  static Future<UserModel?> getMe() async {
    try {
      final res = await ApiService.client.get(ApiConfig.me);
      return UserModel.fromJson(res.data['user']);
    } catch (e) {
      return null;
    }
  }
}
