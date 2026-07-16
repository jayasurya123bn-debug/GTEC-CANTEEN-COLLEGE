import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppTheme.darkGreen),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final allItems = menuProvider.categories.expand((c) => c.items).toList();
    
    final results = allItems.where((item) {
      final nameLower = item.name.toLowerCase();
      final descLower = item.description?.toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower) || descLower.contains(queryLower);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No items found.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return MenuItemCard(
          item: item,
          onTap: () {
            close(context, null);
            Navigator.pushNamed(
              context,
              AppRoutes.itemDetails,
              arguments: item,
            );
          },
        );
      },
    );
  }
}
