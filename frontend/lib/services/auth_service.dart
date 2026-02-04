import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
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
    for (int attempt = 0; attempt < 2; attempt++) {
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
        final isTimeout = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout;
        if (isTimeout && attempt == 0) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        print('Login error: $lastErrorMessage');
        return false;
      } catch (e) {
        lastErrorMessage = e.toString();
        print('Login error: $e');
        return false;
      }
    }
    return false;
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

  Future<bool> loginWithGoogle() async {
    lastErrorMessage = null;
    try {
      // Step 1: Sign in with Google via Supabase OAuth
      final supabase = Supabase.instance.client;
      
      // Check if Supabase is initialized by checking if we can access auth
      try {
        // Try to access auth - if Supabase isn't initialized, this will throw
        final _ = supabase.auth;
      } catch (e) {
        lastErrorMessage = 'Supabase is not configured. Please check your configuration.';
        return false;
      }

      // Initiate Google OAuth flow
      // This will open browser/OAuth flow and return when user completes or cancels
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.redirectUrl,
      );

      // Check if OAuth was successful by checking current session
      // Note: After OAuth completes, the deep link callback should update the session
      // We need to wait a moment for the session to be updated
      await Future.delayed(const Duration(milliseconds: 500));
      
      final session = supabase.auth.currentSession;
      
      if (session == null) {
        // User cancelled or OAuth didn't complete
        lastErrorMessage = 'Google sign-in was cancelled or failed';
        return false;
      }

      final accessToken = session.accessToken;
      
      // Step 2: Save Supabase token temporarily
      await _saveToken(accessToken);

      // Step 3: Call backend to sync profile
      final apiResponse = await _apiService.loginWithGoogle();

      if (apiResponse.statusCode == 200 && apiResponse.data != null) {
        final token = apiResponse.data['token'];
        final user = apiResponse.data['user'];
        if (token != null && user != null) {
          // Backend returns the same Supabase token (or a new one)
          await _saveToken(token.toString());
          await _saveUser(Map<String, dynamic>.from(user));
          return true;
        }
      }
      
      lastErrorMessage = _getMessage(apiResponse.data, 'Google login failed');
      return false;
    } on DioException catch (e) {
      lastErrorMessage = _errorMessage(e);
      print('Google login error: $lastErrorMessage');
      return false;
    } catch (e) {
      lastErrorMessage = e.toString();
      print('Google login error: $e');
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
        return 'Connection timeout. Server may be waking up—wait 30 seconds and try again.';
      case DioExceptionType.connectionError:
        return 'Cannot reach server. Try Wi‑Fi, or open the health URL in your phone\'s browser. If it fails there too, the network is blocking the server.';
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
