import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _complaints = [];
  Map<String, dynamic>? _selectedComplaint;
  bool _isLoading = false;

  List<Map<String, dynamic>> _myComplaints = [];
  Set<String> _upvotedComplaintIds = {}; // Track upvoted complaints
  
  List<Map<String, dynamic>> get complaints => _complaints;
  List<Map<String, dynamic>> get myComplaints => _myComplaints;
  Map<String, dynamic>? get selectedComplaint => _selectedComplaint;
  bool get isLoading => _isLoading;
  bool _isLoadingMy = false;
  bool get isLoadingMy => _isLoadingMy;
  
  bool isUpvoted(String complaintId) => _upvotedComplaintIds.contains(complaintId);

  Future<void> fetchMyComplaints({String? status}) async {
    _isLoadingMy = true;
    notifyListeners();
    try {
      final response = await _apiService.getMyComplaints(status: status);
      if (response.statusCode == 200 && response.data != null && response.data['complaints'] != null) {
        _myComplaints = List<Map<String, dynamic>>.from(response.data['complaints']);
        print('✅ Loaded ${_myComplaints.length} complaints for user');
      } else {
        print('⚠️  My complaints response status: ${response.statusCode}');
        if (response.statusCode == 401) {
          print('   User not authenticated - please log in');
        }
        _myComplaints = [];
      }
    } catch (e) {
      print('❌ Fetch my complaints error: $e');
      if (e.toString().contains('401')) {
        print('   Authentication failed - token may be invalid or expired');
        print('   Try logging out and logging back in');
      }
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
      // Optimistically update UI
      if (!_upvotedComplaintIds.contains(id)) {
        _upvotedComplaintIds.add(id);
        // Update local complaint upvote count
        _updateComplaintUpvoteCount(id, 1);
        notifyListeners();
      }
      
      final response = await _apiService.upvoteComplaint(id);
      if (response.statusCode == 200) {
        print('✅ Upvote successful for complaint $id');
        // Refresh complaint to get updated data
        await fetchComplaint(id);
        // Refresh complaints list if needed
        await fetchComplaints();
        return true;
      } else {
        print('⚠️  Upvote response status: ${response.statusCode}');
        if (response.statusCode == 400 && response.data?['error'] == 'Already upvoted') {
          // Already upvoted - keep the optimistic update
          print('   Already upvoted - keeping UI state');
          return true;
        }
        // Revert optimistic update on failure
        _upvotedComplaintIds.remove(id);
        _updateComplaintUpvoteCount(id, -1);
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Upvote error: $e');
      if (e.toString().contains('401')) {
        print('   Authentication failed - token may be invalid or expired');
      }
      // Revert optimistic update on error
      _upvotedComplaintIds.remove(id);
      _updateComplaintUpvoteCount(id, -1);
      notifyListeners();
      return false;
    }
  }
  
  void _updateComplaintUpvoteCount(String id, int delta) {
    // Helper to safely parse upvote_count (can be int, string, or null)
    int _parseUpvoteCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? 0;
      }
      if (value is num) return value.toInt();
      return 0;
    }
    
    // Update in complaints list
    final index = _complaints.indexWhere((c) => c['id']?.toString() == id);
    if (index != -1) {
      final currentCount = _parseUpvoteCount(_complaints[index]['upvote_count']);
      _complaints[index]['upvote_count'] = (currentCount + delta).clamp(0, double.infinity).toInt();
    }
    
    // Update in selected complaint
    if (_selectedComplaint != null && _selectedComplaint!['id']?.toString() == id) {
      final currentCount = _parseUpvoteCount(_selectedComplaint!['upvote_count']);
      _selectedComplaint!['upvote_count'] = (currentCount + delta).clamp(0, double.infinity).toInt();
    }
    
    // Update in my complaints
    final myIndex = _myComplaints.indexWhere((c) => c['id']?.toString() == id);
    if (myIndex != -1) {
      final currentCount = _parseUpvoteCount(_myComplaints[myIndex]['upvote_count']);
      _myComplaints[myIndex]['upvote_count'] = (currentCount + delta).clamp(0, double.infinity).toInt();
    }
  }

  void clearSelectedComplaint() {
    _selectedComplaint = null;
    notifyListeners();
  }
}
