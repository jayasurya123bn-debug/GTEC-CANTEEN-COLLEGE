import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/favourite_provider.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/menu_grid_shimmer.dart';
import '../config/theme.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'My Favourites ❤️',
          style: GoogleFonts.poppins(
            color: AppTheme.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer2<FavouriteProvider, MenuProvider>(
        builder: (context, favProvider, menuProvider, _) {
          if (menuProvider.isLoading) {
            return const MenuGridShimmer();
          }

          final favItems = menuProvider.allItems
              .where((item) => favProvider.isFavourite(item.id))
              .toList();

          return RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () async {
              await Provider.of<MenuProvider>(context, listen: false).fetchMenu();
              await Provider.of<FavouriteProvider>(context, listen: false).fetchFavourites();
            },
            child: favItems.isEmpty
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🌿', style: TextStyle(fontSize: 64)),
                                const SizedBox(height: 16),
                                Text(
                                  'No favourites yet',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap the heart on dishes you love\nto save them here.',
                                  style: TextStyle(
                                    color: AppTheme.bodyText,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: favItems.length,
                    itemBuilder: (context, index) {
                      return MenuItemCard(
                        item: favItems[index],
                        animationIndex: index,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
