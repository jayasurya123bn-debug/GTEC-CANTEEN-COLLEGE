import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/canteen_status_provider.dart';
import '../providers/favourite_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/canteen_status_bar.dart';
import '../widgets/now_serving_banner.dart';
import '../widgets/category_chips.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/menu_grid_shimmer.dart';
import '../widgets/menu_search_delegate.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../utils/routes.dart';
import 'favourites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _HomeBody(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CanteenStatusProvider>(context, listen: false).fetchStatus();
      Provider.of<MenuProvider>(context, listen: false).fetchMenu();
      Provider.of<FavouriteProvider>(context, listen: false).fetchFavourites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.card.withOpacity(0.95),
              border: const Border(top: BorderSide(color: AppTheme.border, width: 1)),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              selectedItemColor: AppTheme.primaryGreen,
              unselectedItemColor: AppTheme.muted,
              onTap: (i) => setState(() => _selectedIndex = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_rounded),
                  label: 'Menu',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: 'Favourites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return CustomScrollView(
      slivers: [
        // ── Frosted glass AppBar ─────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.background.withOpacity(0.85),
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryGreen, width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: AppConstants.logoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.school_rounded,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GTEC Canteen',
                    style: GoogleFonts.poppins(
                      color: AppTheme.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Pure Veg 🌿',
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppTheme.white, size: 26),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MenuSearchDelegate(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.white, size: 26),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
            ),
            const SizedBox(width: 4),
          ],
        ),

        // ── Greeting ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.name?.split(' ').first ?? 'Student'} 👋',
                  style: GoogleFonts.poppins(
                    color: AppTheme.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'What\'s on the menu today?',
                  style: TextStyle(color: AppTheme.bodyText, fontSize: 14),
                ),
              ],
            ),
          ),
        ),

        // ── Canteen status bar ───────────────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: CanteenStatusBar()),

        // ── Broadcast banner ─────────────────────────────────────────────────
        const SliverToBoxAdapter(child: NowServingBanner()),

        // ── Hero Campus Banner ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: AppConstants.bannerUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppTheme.elevated),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.elevated,
                        child: const Center(
                          child: Icon(Icons.school_rounded,
                              color: AppTheme.primaryGreen, size: 60),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0xCC0D1117)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.fullName,
                            style: GoogleFonts.poppins(
                              color: AppTheme.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            '🌿 Pure Veg Campus Canteen',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Category Chips ───────────────────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const SliverToBoxAdapter(child: CategoryChips()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── "Today's Menu" heading ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Today's Menu",
              style: GoogleFonts.poppins(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // ── Menu Grid ────────────────────────────────────────────────────────
        Consumer<MenuProvider>(
          builder: (context, menuProvider, _) {
            if (menuProvider.isLoading) {
              return const SliverToBoxAdapter(child: MenuGridShimmer());
            }

            if (menuProvider.items.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        const Text('🌿', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text(
                          'No items found',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try a different category or pull to refresh.',
                          style: TextStyle(color: AppTheme.bodyText, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return MenuItemCard(
                      item: menuProvider.items[index],
                      animationIndex: index,
                    );
                  },
                  childCount: menuProvider.items.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
