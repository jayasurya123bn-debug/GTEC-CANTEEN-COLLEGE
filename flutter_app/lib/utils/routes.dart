import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/item_details_screen.dart';
import '../screens/notifications_screen.dart';
import '../models/menu_item_model.dart';

class AppRoutes {
  static const String splash        = '/';
  static const String login         = '/login';
  static const String register      = '/register';
  static const String home          = '/home';
  static const String profile       = '/profile';
  static const String favourites    = '/favourites';
  static const String notifications = '/notifications';
  static const String itemDetails   = '/item-details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return _slideRoute(const LoginScreen());
      case register:
        return _slideRoute(const RegisterScreen());
      case home:
        return _slideRoute(const HomeScreen());
      case notifications:
        return _slideRoute(const NotificationsScreen());
      case itemDetails:
        final item = settings.arguments as MenuItemModel;
        return _slideRoute(ItemDetailScreen(item: item));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: const Color(0xFF0D1117),
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
