import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 120),  // Render free-tier cold start can take 30–60s
      receiveTimeout: const Duration(seconds: 120),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          final tokenPreview = token.length > 20 ? '${token.substring(0, 20)}...' : token;
          print('🔑 Sending request to ${options.path} with token: $tokenPreview');
        } else {
          print('⚠️  No auth token found for request to ${options.path}');
          // Check if this is an authenticated endpoint
          final authEndpoints = ['/users/', '/complaints/', '/auth/me'];
          final needsAuth = authEndpoints.any((endpoint) => options.path.contains(endpoint));
          if (needsAuth) {
            print('   ⚠️  This endpoint requires authentication but no token is available');
          }
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          print('❌ 401 Unauthorized for ${error.requestOptions.path}');
          print('   Response: ${error.response?.data}');
          print('   Headers sent: ${error.requestOptions.headers.containsKey('Authorization') ? 'Yes' : 'No'}');
        }
        handler.next(error);
      },
    ));
  }

  /// Fire-and-forget ping to wake Render (free tier cold start).
  void pingHealth() {
    _dio.get('/health').catchError((_) {});
  }

  /// Awaitable health check. Use when login screen opens to pre-warm server before user taps Login.
  /// Returns true if server responded within [timeout]. Default 90s to cover Render cold start.
  Future<bool> checkHealth({Duration timeout = const Duration(seconds: 90)}) async {
    try {
      final r = await _dio.get('/health').timeout(timeout);
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Auth endpoints
  Future<Response> signup({
    required String name,
    required String email,
    required String password,
    required String accountType,
  }) async {
    return await _dio.post('/auth/signup', data: {
      'name': name,
      'email': email,
      'password': password,
      'account_type': accountType,
    });
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> authorityLogin({
    required String email,
    required String password,
  }) async {
    return await _dio.post('/auth/authority/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> loginWithGoogle() async {
    return await _dio.post('/auth/login/google');
  }

  Future<Response> getCurrentUser() async {
    return await _dio.get('/auth/me');
  }

  // Complaint endpoints
  Future<Response> createComplaint({
    required File photo,
    File? audio,
    String? description,
    required double lat,
    required double lon,
    List<String>? tags,
  }) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photo.path),
      if (audio != null) 'audio': await MultipartFile.fromFile(
        audio!.path,
        filename: 'recording.ogg',
        contentType: MediaType('audio', 'ogg'),
      ),
      if (description != null && description.isNotEmpty) 'description': description,
      'gps_lat': lat.toString(),
      'gps_long': lon.toString(),
      if (tags != null) 'tags': tags.join(','),
    });

    return await _dio.post('/complaints', data: formData);
  }

  Future<Response> getComplaints({
    String? status,
    String? department,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    return await _dio.get('/complaints', queryParameters: {
      if (status != null) 'status': status,
      if (department != null) 'department': department,
      if (search != null) 'search': search,
      'limit': limit,
      'offset': offset,
    });
  }

  Future<Response> getComplaint(String id) async {
    return await _dio.get('/complaints/$id');
  }

  Future<Response> upvoteComplaint(String id) async {
    return await _dio.post('/complaints/$id/upvote');
  }

  // User endpoints
  Future<Response> getDashboardStats() async {
    return await _dio.get('/users/dashboard');
  }

  Future<Response> getMyComplaints({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    return await _dio.get('/users/my-complaints', queryParameters: {
      if (status != null) 'status': status,
      'limit': limit,
      'offset': offset,
    });
  }

  Future<Response> getUserProfile() async {
    return await _dio.get('/users/profile');
  }

  // Authority endpoints
  Future<Response> getAuthorityDashboard() async {
    return await _dio.get('/authority/dashboard');
  }

  Future<Response> getDepartmentComplaints({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    return await _dio.get('/authority/complaints', queryParameters: {
      if (status != null) 'status': status,
      'limit': limit,
      'offset': offset,
    });
  }

  Future<Response> getComplaintForResolution(String id) async {
    return await _dio.get('/authority/complaints/$id');
  }

  Future<Response> updateComplaintStatus(String id, String status) async {
    return await _dio.patch('/authority/complaints/$id/status', data: {
      'status': status,
    });
  }

  Future<Response> resolveComplaint({
    required String id,
    required List<File> photos,
    String? notes,
  }) async {
    final formData = FormData.fromMap({
      if (notes != null) 'notes': notes,
    });

    for (var photo in photos) {
      formData.files.add(MapEntry(
        'photos',
        await MultipartFile.fromFile(photo.path),
      ));
    }

    return await _dio.post('/authority/complaints/$id/resolve', data: formData);
  }

  Future<Response> getResolutionHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _dio.get('/authority/history', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
  }
}
