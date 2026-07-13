import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../config/api_config.dart';
import 'local_notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print("Handling a background message: ${message.messageId}");
}

class FcmService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _updateTokenOnServer(token);
      }

      // Listen to token refresh
      _fcm.onTokenRefresh.listen(_updateTokenOnServer);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          LocalNotificationService.display(message);
        }
      });
    }
  }

  static Future<void> _updateTokenOnServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('access_token') != null) {
        await ApiService.client.put(ApiConfig.fcmToken, data: {'fcm_token': token});
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}
