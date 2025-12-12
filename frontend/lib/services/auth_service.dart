import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String accountType,
  }) async {
    try {
      final response = await _apiService.signup(
        name: name,
        email: email,
        password: password,
        accountType: accountType,
      );

      if (response.statusCode == 201) {
        await _saveToken(response.data['token']);
        await _saveUser(response.data['user']);
        return true;
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        await _saveToken(response.data['token']);
        await _saveUser(response.data['user']);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> authorityLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.authorityLogin(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        await _saveToken(response.data['token']);
        await _saveUser(response.data['user']);
        return true;
      }
      return false;
    } catch (e) {
      print('Authority login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        // Parse JSON string to Map
        return Map<String, dynamic>.from(json.decode(userJson));
      } catch (e) {
        // Fallback: try to get from API
        try {
          final response = await _apiService.getCurrentUser();
          if (response.statusCode == 200) {
            final user = response.data['user'];
            await _saveUser(user);
            return user;
          }
        } catch (e2) {
          return null;
        }
      }
    }
    return null;
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    // Store user as JSON string
    await prefs.setString(_userKey, json.encode(user));
  }
}
