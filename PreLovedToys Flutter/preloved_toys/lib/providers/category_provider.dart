import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart'; // Import the new model

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  List<SubCategory> _allSubCategories = []; // Store ALL subcategories
  List<SubCategory> _subCategories = []; // List to store filtered subcategories

  bool _isLoading = false;
  bool _isSubLoading = false; // Separate loading state for subcategories

  List<Category> get categories => _categories;
  List<SubCategory> get subCategories => _subCategories;
  bool get isLoading => _isLoading;
  bool get isSubLoading => _isSubLoading;

  // Fetch Main Categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Fetch from API
      final response = await _apiService.get('/master/categories');
      _categories = (response as List)
          .map((i) => Category.fromJson(i))
          .toList();

      // Also fetch all subcategories upfront
      await fetchAllSubCategories();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch ALL Subcategories upfront
  Future<void> fetchAllSubCategories() async {
    try {
      final response = await _apiService.get('/master/subcategories');
      _allSubCategories = (response as List)
          .map((i) => SubCategory.fromJson(i))
          .toList();
    } catch (e) {
      debugPrint("Error fetching all subcategories: $e");
    }
  }

  // Filter Subcategories locally
  void fetchSubCategories(int categoryId) {
    // No loading state needed as it's instant filtering
    _subCategories = _allSubCategories
        .where((sub) => sub.categoryId == categoryId)
        .toList();
    notifyListeners();
  }
}
