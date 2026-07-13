import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../models/menu_item_model.dart';

class FavouriteProvider with ChangeNotifier {
  List<dynamic> _favourites = []; // We will store full item data for fav screen
  Set<String> _favouriteIds = {};
  bool _isLoading = false;

  List<dynamic> get favourites => _favourites;
  bool get isLoading => _isLoading;

  bool isFavourited(String id) => _favouriteIds.contains(id);

  Future<void> fetchFavourites() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.client.get(ApiConfig.favourites);
      _favourites = res.data['favourites'];
      _favouriteIds = _favourites.map<String>((f) => f['item_id'].toString()).toSet();
    } catch (e) {
      print('Error fetching favourites: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavourite(String itemId) async {
    final bool currentlyFavourited = isFavourited(itemId);
    
    // Optimistic Update
    if (currentlyFavourited) {
      _favouriteIds.remove(itemId);
      _favourites.removeWhere((f) => f['item_id'] == itemId);
    } else {
      _favouriteIds.add(itemId);
    }
    notifyListeners();

    try {
      if (currentlyFavourited) {
        await ApiService.client.delete('${ApiConfig.favourites}/$itemId');
      } else {
        await ApiService.client.post('${ApiConfig.favourites}/$itemId');
        // We refetch to get the full item data for the fav screen
        fetchFavourites();
      }
    } catch (e) {
      // Revert on failure
      if (currentlyFavourited) {
        _favouriteIds.add(itemId);
      } else {
        _favouriteIds.remove(itemId);
      }
      notifyListeners();
      throw Exception('Failed to update favourite');
    }
  }
}
