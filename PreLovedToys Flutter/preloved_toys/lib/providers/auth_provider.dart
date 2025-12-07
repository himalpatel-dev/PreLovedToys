import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  // 1. Send OTP
  Future<dynamic> sendOtp(String mobile) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Capture the response here
      final response = await _apiService.post('/auth/send-otp', {
        'mobile': mobile,
      }, withToken: false);

      return response; // <--- RETURN THE DATA TO THE UI
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Verify OTP & Login
  Future<void> verifyOtp(String mobile, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/verify-otp', {
        'mobile': mobile,
        'otp': otp,
      }, withToken: false);

      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      _user = User.fromJson(userData, token: token);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Check if already logged in
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;
    return true;
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Calls PUT /api/profile
      final response = await _apiService.put('/users/profile', updates);

      // Backend returns: { message: '...', user: { ...updated user... }, pointsCredited: 20 }
      final updatedUserData = response['user'];

      // We need to preserve the token because the response might not send it back
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Update local user state
      if (updatedUserData != null) {
        _user = User.fromJson(updatedUserData, token: token);
      }

      return response; // Return full response to showing points toast
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Delete the JWT
    _user = null; // Clear user from memory
    notifyListeners(); // Update UI
  }

  Future<Map<String, String>> fetchUserStats() async {
    try {
      // Calls GET /api/user/stats
      final response = await _apiService.get('/users/stats');

      // Backend returns: { "totalOrders": 12, "totalSales": 5, "totalPoints": 500 }

      // Parse safely (handle int, string, or null)
      final orders = response['totalOrders']?.toString() ?? '0';
      final sales = response['totalSales']?.toString() ?? '0';
      final points = response['totalPoints']?.toString() ?? '0';

      return {'orders': orders, 'sells': sales, 'points': points};
    } catch (e) {
      print("Error fetching stats: $e");
      return {
        'orders': '-', // Show '-' on error so user knows it failed
        'sells': '-',
        'points': '-',
      };
    }
  }
}
