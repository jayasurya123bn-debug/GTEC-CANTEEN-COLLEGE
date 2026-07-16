import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/menu_item_model.dart';
import '../providers/menu_provider.dart';
import '../utils/routes.dart';
import '../config/theme.dart';
import 'menu_item_card.dart';

class MenuSearchDelegate extends SearchDelegate<MenuItemModel?> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.card,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.poppins(color: AppTheme.muted, fontSize: 15),
        border: InputBorder.none,
      ),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.poppins(color: AppTheme.white, fontSize: 15),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search pure veg dishes...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: AppTheme.bodyText),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 18),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return Container(
        color: AppTheme.background,
        child: const Center(
          child: Text(
            '🌿 Type to search the menu...',
            style: TextStyle(color: AppTheme.bodyText, fontSize: 14),
          ),
        ),
      );
    }

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final lq = query.toLowerCase();
    final results = menuProvider.allItems.where((item) {
      return item.name.toLowerCase().contains(lq) ||
          (item.description?.toLowerCase().contains(lq) ?? false) ||
          item.categoryName.toLowerCase().contains(lq);
    }).toList();

    if (results.isEmpty) {
      return Container(
        color: AppTheme.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'No dishes found',
                style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Try searching "Idli", "Dosa", or "Juice"',
                style: const TextStyle(color: AppTheme.bodyText, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppTheme.background,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          return MenuItemCard(
            item: results[index],
            animationIndex: index,
          );
        },
      ),
    );
  }
}
