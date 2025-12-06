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
}
