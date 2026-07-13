import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    _plugin.initialize(settings: initSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      const NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          'gtec_canteen',
          'GTEC Canteen Notifications',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF2E7D32), // primaryGreen
        ),
      );

      await _plugin.show(
        id: id,
        title: message.notification?.title,
        body: message.notification?.body,
        notificationDetails: details,
      );
    } on Exception catch (e) {
      print('Notification Error: $e');
    }
  }
}
