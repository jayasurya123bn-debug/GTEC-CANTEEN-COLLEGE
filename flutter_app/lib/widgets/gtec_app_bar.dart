import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../utils/routes.dart';
import '../providers/notification_provider.dart';
import '../config/theme.dart';
import 'menu_search_delegate.dart';

class GtecAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GtecAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          CachedNetworkImage(
            imageUrl: AppConstants.logoUrl,
            height: 32,
            width: 32,
            errorWidget: (context, url, error) => const Icon(Icons.school),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConstants.shortName, style: TextStyle(fontSize: 16)),
              Text('Pure Veg Canteen', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.normal)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 28),
          onPressed: () {
            showSearch(
              context: context,
              delegate: MenuSearchDelegate(),
            );
          },
        ),
        Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_none, size: 28),
                  if (provider.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${provider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
