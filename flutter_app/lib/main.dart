import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'utils/routes.dart';
import 'services/api_service.dart';
import 'services/socket_service.dart';
import 'services/fcm_service.dart';
import 'services/local_notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/canteen_status_provider.dart';
import 'providers/favourite_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await ApiService.init();

  // Connect Socket.IO for real-time updates
  await SocketService.connect();

  try {
    await Firebase.initializeApp();
    await FcmService.init();
    LocalNotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase init error (non-fatal): $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CanteenStatusProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const GtecCanteenApp(),
    ),
  );
}

class GtecCanteenApp extends StatelessWidget {
  const GtecCanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GTEC Pure Veg Canteen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
