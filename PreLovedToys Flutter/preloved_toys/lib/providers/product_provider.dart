import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  bool _isLoading = false;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // Fetch all active products
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners(); // Tell UI to show spinner

    try {
      // Calls GET /api/products
      // Based on your backend, this returns a List of products or { "rows": [...] }
      // depending on how you implemented pagination.
      // I am assuming it returns a standard List or { data: List } based on standard Sequelize.

      final response = await _apiService.get('/products');

      // Handle if response is a List directly OR inside a 'rows'/'data' key
      List<dynamic> dataList = [];
      if (response is List) {
        dataList = response;
      } else if (response['rows'] != null) {
        dataList = response['rows'];
      } else if (response['data'] != null) {
        dataList = response['data'];
      }

      _products = dataList.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      print("Error fetching products: $e");
      // You could store an error message string here to show in UI
    } finally {
      _isLoading = false;
      notifyListeners(); // Tell UI to show the list
    }
  }

  // Helper: Get a single product by ID (Useful for Details Screen)
  Product findById(int id) {
    return _products.firstWhere((prod) => prod.id == id);
  }
}
