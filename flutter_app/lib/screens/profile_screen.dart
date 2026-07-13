import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (user == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                user.email,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('My Favourites'),
                onTap: () => Navigator.pushNamed(context, AppRoutes.favourites),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('My Orders'),
                onTap: () => Navigator.pushNamed(context, AppRoutes.orders),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
