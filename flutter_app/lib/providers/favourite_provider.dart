import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class FavouriteProvider with ChangeNotifier {
  final Set<String> _favouriteIds = {};
  bool _isLoading = false;

  Set<String> get favouriteIds => _favouriteIds;
  bool get isLoading           => _isLoading;

  bool isFavourite(String itemId) => _favouriteIds.contains(itemId);

  Future<void> fetchFavourites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.client.get(ApiConfig.favourites);
      final List<dynamic> data = res.data;
      _favouriteIds.clear();
      for (final item in data) {
        final id = item['menu_item_id']?.toString() ?? item['id']?.toString();
        if (id != null) _favouriteIds.add(id);
      }
    } catch (e) {
      // Silently fail — favourites are a convenience feature
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavourite(String itemId) async {
    final isCurrentlyFav = _favouriteIds.contains(itemId);

    // Optimistic update
    if (isCurrentlyFav) {
      _favouriteIds.remove(itemId);
    } else {
      _favouriteIds.add(itemId);
    }
    notifyListeners();

    try {
      if (isCurrentlyFav) {
        await ApiService.client.delete('${ApiConfig.favourites}/$itemId');
      } else {
        await ApiService.client.post('${ApiConfig.favourites}/$itemId');
      }
    } catch (e) {
      // Rollback on failure
      if (isCurrentlyFav) {
        _favouriteIds.add(itemId);
      } else {
        _favouriteIds.remove(itemId);
      }
      notifyListeners();
    }
  }
}
