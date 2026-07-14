import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favourite_provider.dart';
import '../models/menu_item_model.dart';
import '../widgets/menu_item_card.dart';
import '../config/theme.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavouriteProvider>(context, listen: false).fetchFavourites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favourites')),
      body: Consumer<FavouriteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (provider.favourites.isEmpty) {
            return const Center(child: Text('No favourites yet. Add some 🌿 items!'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchFavourites(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.favourites.length,
              itemBuilder: (context, index) {
                // Favourites endpoint returns item join data
                final favData = provider.favourites[index];
                // Manually map join data to MenuItemModel for reuse of MenuItemCard
                final itemModel = MenuItemModel(
                  id: favData['item_id'],
                  categoryId: '', // dummy
                  name: favData['name'] ?? 'Unknown Item',
                  price: double.parse(favData['price']?.toString() ?? '0'),
                  imageUrl: favData['image_url'],
                  description: favData['description'],
                  dietaryTag: favData['dietary_tag'] ?? 'veg',
                  availability: favData['availability'] ?? 'sold_out',
                );

                return MenuItemCard(
                  item: itemModel,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.itemDetails,
                      arguments: itemModel,
                    );
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
