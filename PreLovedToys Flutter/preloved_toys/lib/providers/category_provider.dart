import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart'; // Import the new model
import '../data/static_data.dart'; // Import StaticData

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

  // Fetch Main Categories
  Future<void> fetchCategories({bool isLoadFromDb = true}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (isLoadFromDb) {
        // Fetch from API
        final response = await _apiService.get('/master/categories');
        _categories = (response as List)
            .map((i) => Category.fromJson(i))
            .toList();
      } else {
        // Fetch from Static Data
        // Map StaticData to Category model
        // Note: StaticData uses 'icon' but model uses 'image'
        _categories = StaticData.categories.map((data) {
          return Category(
            id: data['id'],
            name: data['name'],
            image: data['image'], // Map icon to image
            isActive: true,
          );
        }).toList();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- NEW: Fetch Subcategories ---
  Future<void> fetchSubCategories(
    int categoryId, {
    bool isLoadFromDb = true,
  }) async {
    _isSubLoading = true;
    _subCategories = []; // Clear previous data instantly for better UX
    notifyListeners();

    try {
      if (isLoadFromDb) {
        // GET /api/master/subcategoriesByCategory/:id
        final response = await _apiService.get(
          '/master/subcategoriesByCategory/$categoryId',
        );
        _subCategories = (response as List)
            .map((i) => SubCategory.fromJson(i))
            .toList();
      } else {
        // Static Mode: Fetch from StaticData
        final staticSubCats = StaticData.subCategories.where((sub) {
          return sub['categoryId'] == categoryId;
        }).toList();

        _subCategories = staticSubCats.map((data) {
          return SubCategory.fromJson(data);
        }).toList();
      }
    } catch (e) {
      print("Error fetching subcategories: $e");
    } finally {
      _isSubLoading = false;
      notifyListeners();
    }
  }
}
