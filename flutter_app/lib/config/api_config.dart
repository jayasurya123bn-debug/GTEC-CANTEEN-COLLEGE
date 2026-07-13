class ApiConfig {
  static const String baseUrl = 'https://gtec-canteen-college.onrender.com/api/v1';
  static const String socketUrl = 'https://gtec-canteen-college.onrender.com';
  
  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String fcmToken = '/auth/fcm-token';
  
  static const String canteenStatus = '/canteen/status';
  
  static const String menu = '/menu';
  static const String menuCategories = '/menu/categories';
  
  static const String favourites = '/favourites';
  static const String orders = '/orders';
  static const String reviews = '/reviews';
  static const String notifications = '/notifications';
}
