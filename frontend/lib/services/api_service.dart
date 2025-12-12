import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IMPORTANT: Change this to your computer's IP address for mobile testing
  // Format: http://YOUR_IP_ADDRESS:8080/api
  // Example: http://192.168.1.100:8080/api
  // 
  // To find your IP:
  // Windows: ipconfig (look for IPv4 Address)
  // Mac/Linux: ifconfig or ip addr show
  static const String baseUrl = 'http://192.168.0.107:8080/api'; // TODO: Replace YOUR_IP_ADDRESS with your computer's IP
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
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
      if (audio != null) 'audio': await MultipartFile.fromFile(audio.path),
      if (description != null) 'description': description,
      'gps_lat': lat,
      'gps_long': lon,
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
