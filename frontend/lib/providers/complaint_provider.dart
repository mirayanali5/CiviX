import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _complaints = [];
  Map<String, dynamic>? _selectedComplaint;
  bool _isLoading = false;

  List<Map<String, dynamic>> _myComplaints = [];
  List<Map<String, dynamic>> get complaints => _complaints;
  List<Map<String, dynamic>> get myComplaints => _myComplaints;
  Map<String, dynamic>? get selectedComplaint => _selectedComplaint;
  bool get isLoading => _isLoading;
  bool _isLoadingMy = false;
  bool get isLoadingMy => _isLoadingMy;

  Future<void> fetchMyComplaints({String? status}) async {
    _isLoadingMy = true;
    notifyListeners();
    try {
      final response = await _apiService.getMyComplaints(status: status);
      if (response.statusCode == 200 && response.data != null && response.data['complaints'] != null) {
        _myComplaints = List<Map<String, dynamic>>.from(response.data['complaints']);
      } else {
        _myComplaints = [];
      }
    } catch (e) {
      _myComplaints = [];
    }
    _isLoadingMy = false;
    notifyListeners();
  }

  Future<void> fetchComplaints({
    String? status,
    String? department,
    String? search,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getComplaints(
        status: status,
        department: department,
        search: search,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['complaints'] != null) {
          _complaints = List<Map<String, dynamic>>.from(data['complaints']);
        } else {
          _complaints = [];
        }
      } else {
        _complaints = [];
      }
    } catch (e) {
      print('Fetch complaints error: $e');
      _complaints = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchComplaint(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getComplaint(id);
      if (response.statusCode == 200) {
        _selectedComplaint = response.data['complaint'];
      }
    } catch (e) {
      print('Fetch complaint error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> upvoteComplaint(String id) async {
    try {
      final response = await _apiService.upvoteComplaint(id);
      if (response.statusCode == 200) {
        // Refresh complaint
        await fetchComplaint(id);
        return true;
      }
      return false;
    } catch (e) {
      print('Upvote error: $e');
      return false;
    }
  }

  void clearSelectedComplaint() {
    _selectedComplaint = null;
    notifyListeners();
  }
}
