import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isLoading = false;

  // --- NEW: Global Stats State ---
  Map<String, String> _stats = {'orders': '-', 'sells': '-', 'points': '-'};

  User? get user => _user;
  bool get isLoading => _isLoading;
  Map<String, String> get stats => _stats; // Getter for UI

  // 1. Send OTP
  Future<dynamic> sendOtp(String mobile) async {
    _isLoading = true;
    notifyListeners();
    print("--- 1. STARTING SEND OTP ---");

    try {
      final response = await _apiService.post('/auth/send-otp', {
        'mobile': mobile,
      }, withToken: false);
      print("--- 3. SUCCESS ---");
      return response;
    } catch (e) {
      print("--- ERROR: $e ---");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Verify OTP & Fetch Full Profile + Stats
  Future<void> verifyOtp(String mobile, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Step A: Login
      final response = await _apiService.post('/auth/verify-otp', {
        'mobile': mobile,
        'otp': otp,
      }, withToken: false);

      final String token = response['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Step B: Fetch Full Profile immediately
      try {
        final profileResponse = await _apiService.get('/users/profile');
        if (profileResponse['user'] != null) {
          _user = User.fromJson(profileResponse['user'], token: token);
        } else {
          _user = User.fromJson(response['user'], token: token);
        }
      } catch (e) {
        print("Warning: Could not fetch profile: $e");
        _user = User.fromJson(response['user'], token: token);
      }

      // Step C: Fetch Stats immediately so they are ready for Profile Screen
      await fetchUserStats();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Auto Login (Profile + Stats)
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;

    final token = prefs.getString('token');

    try {
      final response = await _apiService.get('/users/profile');

      if (response['user'] != null) {
        _user = User.fromJson(response['user'], token: token);

        // Also fetch stats on auto-login!
        fetchUserStats();

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Auto-login failed: $e");
      await logout();
      return false;
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> updates,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.put('/users/profile', updates);

      // Refresh Profile
      final refreshResponse = await _apiService.get('/users/profile');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (refreshResponse['user'] != null) {
        _user = User.fromJson(refreshResponse['user'], token: token);
      }

      // Refresh Stats (Because updating profile gives points)
      await fetchUserStats();

      return response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Stats (Updates Global State)
  Future<Map<String, String>> fetchUserStats() async {
    try {
      final response = await _apiService.get('/users/stats');

      final orders = response['totalOrders']?.toString() ?? '0';
      final sales = response['totalSales']?.toString() ?? '0';
      final points = response['totalPoints']?.toString() ?? '0';

      // Update Global State
      _stats = {'orders': orders, 'sells': sales, 'points': points};

      notifyListeners(); // Tell UI to update immediately

      return _stats;
    } catch (e) {
      print("Error fetching stats: $e");
      return _stats; // Return existing stats on error
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    _stats = {'orders': '-', 'sells': '-', 'points': '-'}; // Reset stats
    notifyListeners();
  }
}
