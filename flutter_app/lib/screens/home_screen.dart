import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/canteen_status_provider.dart';
import '../providers/favourite_provider.dart';
import '../providers/pre_order_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gtec_app_bar.dart';
import '../widgets/canteen_status_banner.dart';
import '../utils/routes.dart';
import '../widgets/menu_item_card.dart';
import '../config/theme.dart';
import '../models/menu_item_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CanteenStatusProvider>(context, listen: false).fetchStatus();
      Provider.of<MenuProvider>(context, listen: false).fetchMenu();
      Provider.of<FavouriteProvider>(context, listen: false).fetchFavourites();
      Provider.of<PreOrderProvider>(context, listen: false).refreshSlotStatus();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    String lower = categoryName.toLowerCase();
    if (lower.contains('snack')) return Icons.fastfood;
    if (lower.contains('beverage') || lower.contains('drink')) return Icons.local_cafe;
    if (lower.contains('south')) return Icons.rice_bowl;
    if (lower.contains('north')) return Icons.restaurant;
    if (lower.contains('tiffin')) return Icons.breakfast_dining;
    return Icons.restaurant_menu;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GtecAppBar(),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (menuProvider.categories.isEmpty) {
            return const Center(child: Text('No menu items available right now.'));
          }

          // Flatten items for Popular/Recent
          final allItems = menuProvider.categories.expand((c) => c.items).toList();
          
          // Popular (top rated)
          final popularItems = List<MenuItemModel>.from(allItems)
            ..sort((a, b) => b.avgRating.compareTo(a.avgRating));
          
          // Recent (reverse order)
          final recentItems = List<MenuItemModel>.from(allItems.reversed);

          return RefreshIndicator(
            onRefresh: () => menuProvider.fetchMenu(),
            color: AppTheme.primaryGreen,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CanteenStatusBanner(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning ${user?.name ?? 'Student'}!',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Enjoy Pure Veg Delights Today',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        
                        // Circular Categories
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: menuProvider.categories.length,
                            itemBuilder: (context, index) {
                              final cat = menuProvider.categories[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 24.0),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 65,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(cat.category),
                                        color: AppTheme.primaryGreen,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      cat.category,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Popular Items Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Popular Items',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View all', style: TextStyle(color: AppTheme.primaryGreen)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Popular Items List (Horizontal)
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: popularItems.length > 5 ? 5 : popularItems.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 300,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: MenuItemCard(
                                    item: popularItems[index],
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.itemDetails,
                                        arguments: popularItems[index],
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recent Items Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Additions',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View all', style: TextStyle(color: AppTheme.primaryGreen)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Recent Items List (Vertical)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentItems.length > 5 ? 5 : recentItems.length,
                          itemBuilder: (context, index) {
                            return MenuItemCard(
                              item: recentItems[index],
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.itemDetails,
                                  arguments: recentItems[index],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
