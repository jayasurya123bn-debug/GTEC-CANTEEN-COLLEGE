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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.card,
        title: const Text('Notifications', style: TextStyle(color: AppTheme.white)),
        iconTheme: const IconThemeData(color: AppTheme.white),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
            child: const Text('Mark all read', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (provider.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchNotifications(),
              color: AppTheme.primaryGreen,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('🔔', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('No notifications', style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text('You\'re all caught up!', style: TextStyle(color: AppTheme.bodyText, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            color: AppTheme.primaryGreen,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return Container(
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? AppTheme.card
                        : AppTheme.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: notification.isRead
                          ? AppTheme.border
                          : AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                      child: const Icon(Icons.notifications_rounded, color: AppTheme.primaryGreen, size: 20),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      notification.body,
                      style: const TextStyle(color: AppTheme.bodyText, fontSize: 12),
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
