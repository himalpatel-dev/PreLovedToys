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
      //    _addresses.sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));
    } catch (e) {
      print("Error fetching addresses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  // 1. Set Default Address
  Future<void> setDefaultAddress(int id) async {
    // A. FIND OLD DEFAULT & NEW DEFAULT
    final oldDefaultIndex = _addresses.indexWhere((a) => a.isDefault);
    final newDefaultIndex = _addresses.indexWhere((a) => a.id == id);

    if (newDefaultIndex == -1) return; // Should not happen

    // B. UPDATE LOCALLY INSTANTLY
    // 1. Create a new list to modify
    final updatedList = List<Address>.from(_addresses);

    // 2. Unset old default
    if (oldDefaultIndex != -1) {
      final old = updatedList[oldDefaultIndex];
      updatedList[oldDefaultIndex] = Address(
        id: old.id,
        receiverName: old.receiverName,
        phoneNumber: old.phoneNumber,
        addressLine1: old.addressLine1,
        addressLine2: old.addressLine2,
        city: old.city,
        state: old.state,
        country: old.country,
        pincode: old.pincode,
        addressType: old.addressType,
        isDefault: false, // Turn off
      );
    }

    // 3. Set new default
    final newDef = updatedList[newDefaultIndex];
    updatedList[newDefaultIndex] = Address(
      id: newDef.id,
      receiverName: newDef.receiverName,
      phoneNumber: newDef.phoneNumber,
      addressLine1: newDef.addressLine1,
      addressLine2: newDef.addressLine2,
      city: newDef.city,
      state: newDef.state,
      country: newDef.country,
      pincode: newDef.pincode,
      addressType: newDef.addressType,
      isDefault: true, // Turn on
    );

    // 5. Apply & Update UI
    _addresses = updatedList;
    notifyListeners(); // SCREEN UPDATES HERE (INSTANTLY)

    // C. SEND TO SERVER (Background)
    try {
      await _apiService.put('/addresses/$id/set-default', {});
      // Success! We are already done. No need to fetchAddresses() again.
    } catch (e) {
      print("Error setting default (Reverting): $e");

      // OPTIONAL: Revert UI if server fails (Safety net)
      // For now, we assume success to keep it "lag-free".
      // If you want strict safety, you would undo step B here.
      fetchAddresses(); // Sync with real server state if it failed
    }
  }

  // 2. Delete Address (Already added in previous step, but ensuring it's correct)
  Future<void> deleteAddress(int id) async {
    // Optimistic Update: Remove locally first for instant feel
    final originalList = List<Address>.from(_addresses);
    _addresses.removeWhere((addr) => addr.id == id);
    notifyListeners();

    try {
      // DELETE /api/addresses/:id
      await _apiService.delete('/addresses/$id');
    } catch (e) {
      // Revert on error
      _addresses = originalList;
      notifyListeners();
      print("Error deleting address: $e");
      rethrow;
    }
  }

  Future<Address?> fetchDefaultAddress() async {
    try {
      // Assuming you have an endpoint for this, or we filter from the list
      // If backend has specific endpoint:
      final response = await _apiService.get('/addresses/default');
      return Address.fromJson(response);

      // OR if we just filter locally from existing list:
      // if (_addresses.isEmpty) await fetchAddresses();
      // return _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first);
    } catch (e) {
      print("Error fetching default address: $e");
      return null;
    }
  }
}
