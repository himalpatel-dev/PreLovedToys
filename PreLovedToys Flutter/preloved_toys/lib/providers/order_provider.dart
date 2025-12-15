import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Calls GET /api/orders
      final response = await _apiService.get('/orders');

      List<dynamic> dataList = [];
      if (response is List) {
        dataList = response;
      } else if (response['orders'] != null) {
        dataList = response['orders'];
      }

      _orders = dataList.map((item) => OrderModel.fromJson(item)).toList();

      // Sort by newest first
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> placeOrder(int addressId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // POST /api/orders
      // Body: { "address": addressId }
      final body = {"address": addressId};

      await _apiService.post('/orders', body);

      // You might want to clear the cart locally here if the backend doesn't do it automatically,
      // or fetch the cart again to show it's empty.
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
