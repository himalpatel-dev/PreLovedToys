import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/favorite_model.dart';

class FavoriteProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Favorite> _favorites = [];
  // We keep a set of IDs for ultra-fast lookup (Is product 123 a favorite?)
  Set<int> _favoriteProductIds = {};

  bool _isLoading = false;

  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;

  // Helper: Check if a product is favorited
  bool isFavorite(int productId) {
    return _favoriteProductIds.contains(productId);
  }

  Future<void> fetchFavorites() async {
    // Only show loading on initial fetch if list is empty
    if (_favorites.isEmpty) _isLoading = true;
    // notifyListeners(); // Optional: Commented out to prevent flickering on silent refresh

    try {
      final response = await _apiService.get('/favorites/my-favorites');

      List<dynamic> dataList = [];
      if (response is List) {
        dataList = response;
      } else if (response['data'] != null) {
        dataList = response['data'];
      }

      _favorites = dataList.map((item) => Favorite.fromJson(item)).toList();

      // Update ID Set
      _favoriteProductIds = _favorites
          .map((fav) => fav.product.id)
          .toSet(); // Note: adjusting to map product.id not fav.id
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final isFav = isFavorite(productId);

    // 1. Optimistic Update (Update UI instantly)
    if (isFav) {
      _favoriteProductIds.remove(productId);
      // Also remove from the list to keep "My Favorites" screen in sync
      _favorites.removeWhere((f) => f.product.id == productId);
    } else {
      _favoriteProductIds.add(productId);
      // We can't add to _favorites list easily because we don't have the full Product object here.
      // That's okay, we will fetch fresh data in the background.
    }
    notifyListeners(); // Update UI red heart

    // 2. Server Call
    try {
      if (isFav) {
        // DELETE /api/favorites/:productId
        await _apiService.delete('/favorites/$productId');
      } else {
        // POST /api/favorites { productId: 123 }
        await _apiService.post('/favorites', {'productId': productId});
      }

      // 3. Sync (Fetch fresh list to ensure data integrity)
      await fetchFavorites();
    } catch (e) {
      if (isFav) {
        _favoriteProductIds.add(productId);
      } else {
        _favoriteProductIds.remove(productId);
      }
      notifyListeners();
    }
  }
}
