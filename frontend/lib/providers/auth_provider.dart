import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _lastErrorMessage;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  /// Last error from login/signup/authorityLogin (e.g. "Invalid email or password", "Cannot reach server").
  String? get lastErrorMessage => _lastErrorMessage;

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _user = await _authService.getUser();
      }
    } catch (e) {
      print('Auth check error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String accountType,
  }) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.signup(
        name: name,
        email: email,
        password: password,
        accountType: accountType,
      );
      _lastErrorMessage = _authService.lastErrorMessage;
      if (success) {
        _user = await _authService.getUser();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _lastErrorMessage = _authService.lastErrorMessage ?? e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(
        email: email,
        password: password,
      );
      _lastErrorMessage = _authService.lastErrorMessage;
      if (!success && (_lastErrorMessage == null || _lastErrorMessage!.isEmpty)) {
        _lastErrorMessage = 'Invalid email or password, or create an account first.';
      }
      if (success) {
        _user = await _authService.getUser();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _lastErrorMessage = _authService.lastErrorMessage ?? e.toString();
      if (_lastErrorMessage == null || _lastErrorMessage!.isEmpty) {
        _lastErrorMessage = 'Login failed. Check network and try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> authorityLogin({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.authorityLogin(
        email: email,
        password: password,
      );
      _lastErrorMessage = _authService.lastErrorMessage;
      if (success) {
        _user = await _authService.getUser();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _lastErrorMessage = _authService.lastErrorMessage ?? e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
