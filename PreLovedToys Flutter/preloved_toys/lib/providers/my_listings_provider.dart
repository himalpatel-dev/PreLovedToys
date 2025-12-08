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
      // Calls GET /api/products/my-listings
      final response = await _apiService.get('/products/my-listings');

      List<dynamic> dataList = [];
      if (response is List) {
        dataList = response;
      } else if (response['data'] != null) {
        dataList = response['data'];
      }

      _listings = dataList.map((item) => Product.fromJson(item)).toList();

      // Sort by newest first
      // Assuming your Product model has a createdAt field, if not, skip sorting or add it to model
      // _listings.sort((a, b) => b.id.compareTo(a.id));
    } catch (e) {
      print("Error fetching my listings: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
