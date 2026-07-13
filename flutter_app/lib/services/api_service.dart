import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));

  static Future<void> init() async {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refresh_token');
          if (refreshToken != null) {
            try {
              // Attempt refresh
              final res = await Dio().post(
                '${ApiConfig.baseUrl}${ApiConfig.refresh}',
                data: {'refreshToken': refreshToken},
              );
              final newToken = res.data['accessToken'];
              await prefs.setString('access_token', newToken);
              
              // Retry request
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final retryRes = await Dio().fetch(e.requestOptions);
              return handler.resolve(retryRes);
            } catch (err) {
              // Refresh failed, logout
              await prefs.clear();
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  static Dio get client => _dio;
}
