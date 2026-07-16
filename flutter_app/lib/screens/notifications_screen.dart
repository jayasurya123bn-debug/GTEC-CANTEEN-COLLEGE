import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/notification_provider.dart';
import '../config/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
            child: const Text('Mark all read', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (provider.notifications.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            child: ListView.separated(
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return ListTile(
                  tileColor: notification.isRead ? Colors.white : AppTheme.lightGreen.withOpacity(0.5),
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen,
                    child: Icon(Icons.notifications, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    notification.body,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
                    if (!notification.isRead) {
                      provider.markAsRead(notification.id);
                    }
                    if (notification.type == 'update_apk') {
                      final url = Uri.parse('https://gtec-canteen-college.vercel.app/download');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
