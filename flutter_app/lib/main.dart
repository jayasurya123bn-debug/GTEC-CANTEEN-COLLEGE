import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'utils/routes.dart';
import 'services/api_service.dart';
import 'services/fcm_service.dart';
import 'services/local_notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/canteen_status_provider.dart';
import 'providers/favourite_provider.dart';
import 'providers/order_provider.dart';
import 'providers/review_provider.dart';
import 'providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await ApiService.init();
  
  try {
    // If you have configured google-services.json
    await Firebase.initializeApp();
    await FcmService.init();
    LocalNotificationService.initialize();
  } catch (e) {
    print("Firebase init error: $e");
    // Ignore firebase init for this demo if json isn't setup
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CanteenStatusProvider()),
        ChangeNotifierProvider(create: (_) => FavouriteProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
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
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
