import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Calls GET /api/categories (Adjust endpoint if needed)
      final response = await _apiService.get(
        '/master/categories',
      ); // OR '/master/categories'

      List<dynamic> dataList = [];
      if (response is List) {
        dataList = response;
      } else if (response['data'] != null) {
        dataList = response['data'];
      }
      _categories = dataList.map((item) => Category.fromJson(item)).toList();
    } catch (e) {
      SnackBar(content: Text(e.toString()));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
