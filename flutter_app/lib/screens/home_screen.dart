import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/canteen_status_provider.dart';
import '../providers/favourite_provider.dart';
import '../widgets/gtec_app_bar.dart';
import '../widgets/gtec_banner.dart';
import '../widgets/canteen_status_banner.dart';
import '../widgets/menu_item_card.dart';
import '../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      appBar: const GtecAppBar(),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (menuProvider.categories.isEmpty) {
            return const Center(child: Text('No menu items available right now.'));
          }

          return RefreshIndicator(
            onRefresh: () => menuProvider.fetchMenu(),
            color: AppTheme.primaryGreen,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: CanteenStatusBanner()),
                const SliverToBoxAdapter(child: GtecBanner()),
                ...menuProvider.categories.map((category) {
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _CategoryHeaderDelegate(category.category),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = category.items[index];
                              return MenuItemCard(
                                item: item,
                                onTap: () {
                                  // Navigate to item details page (TODO)
                                },
                              );
                            },
                            childCount: category.items.length,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
      // TODO: Add bottom navigation bar
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  _CategoryHeaderDelegate(this.title);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.darkGreen,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
