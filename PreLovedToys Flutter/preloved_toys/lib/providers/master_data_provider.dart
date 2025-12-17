import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/master_data_model.dart';

class MasterDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AgeGroup> _ageGroups = [];
  List<Gender> _genders = [];
  List<ColorItem> _colors = [];
  List<MaterialItem> _materials = [];

  // Static list for conditions as they are usually fixed enums
  final List<ConditionItem> _conditions = [
    ConditionItem(id: 'New', name: 'New'),
    ConditionItem(id: 'Like New', name: 'Like New'),
    ConditionItem(id: 'Good', name: 'Good'),
    ConditionItem(id: 'Fair', name: 'Fair'),
    ConditionItem(id: 'Poor', name: 'Poor'),
  ];

  bool _isLoading = false;

  List<AgeGroup> get ageGroups => _ageGroups;
  List<Gender> get genders => _genders;
  List<ColorItem> get colors => _colors;
  List<MaterialItem> get materials => _materials;
  List<ConditionItem> get conditions => _conditions;
  bool get isLoading => _isLoading;

  Future<void> fetchMasterData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Age Groups
      final ageData = await _apiService.get('/master/age-groups');
      _ageGroups = (ageData as List).map((i) => AgeGroup.fromJson(i)).toList();

      // 2. Genders
      final genderData = await _apiService.get('/master/genders');
      _genders = (genderData as List).map((i) => Gender.fromJson(i)).toList();

      // 3. Colors
      final colorData = await _apiService.get('/master/colors');
      _colors = (colorData as List).map((i) => ColorItem.fromJson(i)).toList();

      // 4. Materials
      final materialData = await _apiService.get('/master/materials');
      _materials = (materialData as List)
          .map((i) => MaterialItem.fromJson(i))
          .toList();
    } catch (e) {
      debugPrint("Error fetching master data: $e");
      // Keep empty or show error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
