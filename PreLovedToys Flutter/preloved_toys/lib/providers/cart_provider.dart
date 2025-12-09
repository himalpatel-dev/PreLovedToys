import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cart_model.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  // Calculate Totals (Sum of ALL items now)
  double get totalRupees {
    double total = 0;
    for (var item in _items) {
      if (!item.product.isPoints) {
        total += item.product.price; // Qty is always 1
      }
    }
    return total;
  }

  int get totalPoints {
    int total = 0;
    for (var item in _items) {
      if (item.product.isPoints) {
        total += item.product.price.toInt();
      }
    }
    return total;
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/cart');

      List<dynamic> dataList = [];
      if (response is List) {
        dataList = response;
      } else if (response['data'] != null) {
        dataList = response['data'];
      }

      _items = dataList.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      print("Error fetching cart: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove Item
  Future<void> removeFromCart(int cartId) async {
    // Optimistic remove
    final index = _items.indexWhere((item) => item.id == cartId);
    if (index == -1) return; // Guard clause

    final removedItem = _items[index];
    _items.removeAt(index);
    notifyListeners();

    try {
      // DELETE /api/cart/:id
      await _apiService.delete('/cart/$cartId');
    } catch (e) {
      // Revert if failed
      _items.insert(index, removedItem);
      notifyListeners();
      print("Error removing from cart: $e");
      rethrow;
    }
  }

  Future<void> addToCart(int productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post('/cart', {'productId': productId});
      await fetchCart();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
