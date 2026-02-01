import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';

  /// Last error message from login/signup (e.g. from API or network).
  String? lastErrorMessage;

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String accountType,
  }) async {
    lastErrorMessage = null;
    try {
      final response = await _apiService.signup(
        name: name,
        email: email,
        password: password,
        accountType: accountType,
      );

      if (response.statusCode == 201 && response.data != null) {
        final token = response.data['token'];
        final user = response.data['user'];
        if (token != null && user != null) {
          await _saveToken(token.toString());
          await _saveUser(Map<String, dynamic>.from(user));
          return true;
        }
      }
      lastErrorMessage = _getMessage(response.data, 'Signup failed');
      return false;
    } on DioException catch (e) {
      lastErrorMessage = _errorMessage(e);
      print('Signup error: $lastErrorMessage');
      return false;
    } catch (e) {
      lastErrorMessage = e.toString();
      print('Signup error: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    lastErrorMessage = null;
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        final user = response.data['user'];
        if (token != null && user != null) {
          await _saveToken(token.toString());
          await _saveUser(Map<String, dynamic>.from(user));
          return true;
        }
      }
      lastErrorMessage = _getMessage(response.data, 'Login failed');
      return false;
    } on DioException catch (e) {
      lastErrorMessage = _errorMessage(e);
      print('Login error: $lastErrorMessage');
      return false;
    } catch (e) {
      lastErrorMessage = e.toString();
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> authorityLogin({
    required String email,
    required String password,
  }) async {
    lastErrorMessage = null;
    try {
      final response = await _apiService.authorityLogin(
        email: email,
        password: password,
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        final user = response.data['user'];
        if (token != null && user != null) {
          await _saveToken(token.toString());
          await _saveUser(Map<String, dynamic>.from(user));
          return true;
        }
      }
      lastErrorMessage = _getMessage(response.data, 'Login failed');
      return false;
    } on DioException catch (e) {
      lastErrorMessage = _errorMessage(e);
      print('Authority login error: $lastErrorMessage');
      return false;
    } catch (e) {
      lastErrorMessage = e.toString();
      print('Authority login error: $e');
      return false;
    }
  }

  static String _getMessage(dynamic data, String fallback) {
    if (data == null) return fallback;
    if (data is Map) {
      if (data['error'] != null) return data['error'].toString();
      if (data['message'] != null) return data['message'].toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return fallback;
  }

  static String _errorMessage(DioException e) {
    final data = e.response?.data;
    final apiMsg = _getMessage(data, '');
    if (apiMsg.isNotEmpty) return apiMsg;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Check network and try again.';
      case DioExceptionType.connectionError:
        return 'Cannot reach server. Ensure backend is running and phone is on same Wi‑Fi. Set your PC IP in lib/config/api_config.dart';
      default:
        return e.response?.statusCode == 401
            ? 'Invalid email or password.'
            : (e.message?.isNotEmpty == true ? e.message! : 'Network error. Please try again.');
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
