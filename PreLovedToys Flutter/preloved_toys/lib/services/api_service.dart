import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  // 1. Modified to accept a boolean flag
  Future<Map<String, String>> _getHeaders(bool withToken) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // Only attach token if explicitly asked
    if (withToken) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // 2. Updated POST to take an optional argument
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool withToken = true,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');

    // Pass the flag here
    final headers = await _getHeaders(withToken);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      // This catches network errors (like wrong IP/Port)
      throw Exception('Network Error: $e');
    }
  }

  // ... (keep get and _processResponse as they were) ...
  // Make sure to update 'get' to use _getHeaders(true) as well if you change the signature.
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders(true); // Default to true for GET
    final response = await http.get(url, headers: headers);
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode} ${response.body}');
    }
  }

  // Generic PUT Request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders(true); // Always needs token

    print("PUT Request to: $url");
    print("Data: $data");

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // Generic DELETE Request
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders(true); // Delete needs auth

    print("DELETE Request to: $url");

    try {
      final response = await http.delete(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
}
