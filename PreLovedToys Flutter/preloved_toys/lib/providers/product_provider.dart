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
      SnackBar(content: Text(e.toString()));
    } finally {
      _isLoading = false;
      notifyListeners(); // Tell UI to show the list
    }
  }

  // Helper: Get a single product by ID (Useful for Details Screen)
  Product findById(int id) {
    return _products.firstWhere((prod) => prod.id == id);
  }

  // Fetch Single Product Details
  Future<Product> fetchProductDetails(int id) async {
    try {
      // GET /api/products/:id
      final response = await _apiService.get('/products/$id');
      // The API returns the product object directly (based on your JSON)
      return Product.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Fetch products by subcategory
  Future<void> fetchProductsBySubcategory(int subcategoryId) async {
    _isLoading = true;
    _products =
        []; // Clear old products to avoid showing previous category data
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/products/sub-category/$subcategoryId',
      );

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
      _products = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new product
  Future<void> addProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.post('/products', productData);
      // Optionally refresh the list
      // await fetchProducts();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
