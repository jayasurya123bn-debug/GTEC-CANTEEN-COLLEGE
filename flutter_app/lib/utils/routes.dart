import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/favourites_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/item_details_screen.dart';
import '../screens/pre_order_screen.dart';
import '../screens/my_tokens_screen.dart';

class AppRoutes {
  static const String splash        = '/';
  static const String login         = '/login';
  static const String register      = '/register';
  static const String home          = '/home';
  static const String favourites    = '/favourites';
  static const String orders        = '/orders';
  static const String profile       = '/profile';
  static const String notifications = '/notifications';
  static const String itemDetails   = '/item-details';
  static const String preOrder      = '/pre-order';
  static const String myTokens      = '/my-tokens';

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
      case profile:
        return _slideRoute(const ProfileScreen());
      case favourites:
        return _slideRoute(const FavouritesScreen());
      case orders:
        return _slideRoute(const OrdersScreen());
      case notifications:
        return _slideRoute(const NotificationsScreen());
      case preOrder:
        return _slideRoute(const PreOrderScreen());
      case myTokens:
        return _slideRoute(const MyTokensScreen());
      case itemDetails:
        final args = settings.arguments;
        return _slideRoute(ItemDetailsScreen(item: args as dynamic));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
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
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
