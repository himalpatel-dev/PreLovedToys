import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Address> _addresses = [];
  bool _isLoading = false;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;

  Future<void> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/addresses/my-addresses');

      List<dynamic> dataList = [];
      if (response is List) {
        dataList = response;
      } else if (response['data'] != null) {
        dataList = response['data'];
      }

      _addresses = dataList.map((item) => Address.fromJson(item)).toList();

      // Sort: Default address first
      _addresses.sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));
    } catch (e) {
      print("Error fetching addresses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Placeholder for "Set as Default" logic
  Future<void> setDefaultAddress(int id) async {
    // API Call would go here...
    print("Setting address $id as default");
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    _isLoading = true;
    notifyListeners();

    try {
      // POST /api/addresses
      await _apiService.post('/addresses', addressData);

      // Refresh the list immediately
      await fetchAddresses();
    } catch (e) {
      print("Error adding address: $e");
      rethrow; // Pass error to UI to show snackbar
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 1. Get Single Address (Optional if you pass the object directly, but good to have)
  Future<Address> fetchAddressById(int id) async {
    try {
      final response = await _apiService.get('/addresses/$id');
      // Adjust based on response format like { "address": ... } or direct object
      final data = response['address'] ?? response;
      return Address.fromJson(data);
    } catch (e) {
      print("Error fetching address details: $e");
      rethrow;
    }
  }

  // 2. Update Address
  Future<void> updateAddress(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      // PUT /api/addresses/:id
      await _apiService.put('/addresses/$id', updates);

      // Refresh list to show changes
      await fetchAddresses();
    } catch (e) {
      print("Error updating address: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Delete Address
  Future<void> deleteAddress(int id) async {
    // Optimistic Update: Remove locally first for speed
    final originalList = List<Address>.from(_addresses);
    _addresses.removeWhere((addr) => addr.id == id);
    notifyListeners();

    try {
      // DELETE /api/addresses/:id
      await _apiService.delete('/addresses/$id');
      // No need to fetch if delete was successful, we already removed it.
    } catch (e) {
      // Revert on error
      _addresses = originalList;
      notifyListeners();
      print("Error deleting address: $e");
      rethrow;
    }
  }
}
