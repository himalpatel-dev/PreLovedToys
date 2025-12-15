import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class MyListingsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _listings = [];
  bool _isLoading = false;

  List<Product> get listings => _listings;
  bool get isLoading => _isLoading;

  Future<void> fetchMyListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/products/my-listings');

      List<dynamic> dataList = [];
      if (response is List) {
        dataList = response;
      } else if (response['data'] != null) {
        dataList = response['data'];
      }

      _listings = dataList.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ADD THIS DELETE FUNCTION ---
  Future<void> deleteListing(int id) async {
    // 1. Optimistic Update (Remove locally first)
    final originalList = List<Product>.from(_listings);
    _listings.removeWhere((item) => item.id == id);
    notifyListeners();

    try {
      // 2. Call API: DELETE /api/products/:id
      await _apiService.delete('/products/$id');
    } catch (e) {
      // 3. Revert if failed
      _listings = originalList;
      notifyListeners();
      rethrow;
    }
  }
}
