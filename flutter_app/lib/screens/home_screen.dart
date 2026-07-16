import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/canteen_status_provider.dart';
import '../providers/favourite_provider.dart';
import '../providers/pre_order_provider.dart';
import '../widgets/gtec_app_bar.dart';
import '../widgets/gtec_banner.dart';
import '../widgets/canteen_status_banner.dart';
import '../widgets/now_serving_banner.dart';
import '../utils/routes.dart';
import '../widgets/menu_item_card.dart';
import '../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CanteenStatusProvider>(context, listen: false).fetchStatus();
      Provider.of<MenuProvider>(context, listen: false).fetchMenu();
      Provider.of<FavouriteProvider>(context, listen: false).fetchFavourites();
      // Refresh slot status for NowServingBanner
      Provider.of<PreOrderProvider>(context, listen: false).refreshSlotStatus();
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
                // Now Serving banner — shows when a meal slot is active
                const SliverToBoxAdapter(child: NowServingBanner()),
                const SliverToBoxAdapter(child: GtecBanner()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'All',
                              ...menuProvider.categories.map((c) => c.category)
                            ].map((categoryName) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(categoryName),
                                  selected: _selectedCategory == categoryName,
                                  selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = categoryName;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...menuProvider.categories.map((category) {
                  final filteredItems = category.items.where((item) {
                    final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                        (item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
                    final matchesCategory = _selectedCategory == 'All' || category.category == _selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredItems.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

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
                              final item = filteredItems[index];
                              return MenuItemCard(
                                item: item,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.itemDetails,
                                    arguments: item,
                                  );
                                },
                              );
                            },
                            childCount: filteredItems.length,
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
