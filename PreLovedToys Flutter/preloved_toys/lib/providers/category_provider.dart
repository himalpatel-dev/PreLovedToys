import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart'; // Import the new model

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Category> _categories = [];
  List<SubCategory> _subCategories = []; // List to store subcategories

  bool _isLoading = false;
  bool _isSubLoading = false; // Separate loading state for subcategories

  List<Category> get categories => _categories;
  List<SubCategory> get subCategories => _subCategories;
  bool get isLoading => _isLoading;
  bool get isSubLoading => _isSubLoading;

  // Fetch Main Categories (Keep existing logic)
  Future<void> fetchCategories() async {
    _isLoading = true;
    // notifyListeners(); // Optional: depend on where you call this to avoid rebuild loops

    try {
      final response = await _apiService.get(
        '/categories',
      ); // Verify your category endpoint
      _categories = (response as List)
          .map((i) => Category.fromJson(i))
          .toList();
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NEW: Fetch Subcategories ---
  Future<void> fetchSubCategories(int categoryId) async {
    _isSubLoading = true;
    _subCategories = []; // Clear previous data instantly for better UX
    notifyListeners();

    try {
      // GET /api/master/subcategoriesByCategory/:id
      final response = await _apiService.get(
        '/master/subcategoriesByCategory/$categoryId',
      );
      _subCategories = (response as List)
          .map((i) => SubCategory.fromJson(i))
          .toList();
    } catch (e) {
      print("Error fetching subcategories: $e");
    } finally {
      _isSubLoading = false;
      notifyListeners();
    }
  }
}
