import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_navigation.dart';
import 'authority_map_screen.dart';
import 'authority_resolution_screen.dart';
import 'authority_history_screen.dart';
import 'authority_profile_screen.dart';
import '../../utils/map_utils.dart';

class AuthorityDashboardScreen extends StatefulWidget {
  const AuthorityDashboardScreen({super.key});

  @override
  State<AuthorityDashboardScreen> createState() => _AuthorityDashboardScreenState();
}

class _AuthorityDashboardScreenState extends State<AuthorityDashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statsResponse = await _apiService.getAuthorityDashboard();
      if (statsResponse.statusCode == 200) {
        setState(() {
          _stats = statsResponse.data['stats'];
        });
      }

      final complaintsResponse = await _apiService.getDepartmentComplaints();
      if (complaintsResponse.statusCode == 200) {
        final data = complaintsResponse.data;
        setState(() {
          _complaints = data != null && data['complaints'] != null
              ? List<Map<String, dynamic>>.from(data['complaints'])
              : [];
        });
      } else {
        setState(() {
          _complaints = [];
        });
      }
    } catch (e) {
      print('Load dashboard error: $e');
      setState(() {
        _complaints = [];
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authority Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthorityMapScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthorityHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthorityProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    if (_stats != null) _buildStatsCards(),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Department Complaints',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    _buildComplaintsList(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          switch (index) {
            case 0:
              // Dashboard - already here
              break;
            case 1:
              // New Report - not applicable for authority
              break;
            case 2:
              // History
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthorityHistoryScreen()),
              );
              break;
            case 3:
              // Settings
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthorityProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Open',
              value: _stats!['open']?.toString() ?? '0',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'In Progress',
              value: _stats!['in_progress']?.toString() ?? '0',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Resolved',
              value: _stats!['resolved']?.toString() ?? '0',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList() {
    if (_complaints.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('No complaints found')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _complaints.length,
      itemBuilder: (context, index) {
        final complaint = _complaints[index];
        return _ComplaintCard(
          complaint: complaint,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AuthorityResolutionScreen(complaintId: complaint['id']),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onTap;

  const _ComplaintCard({
    required this.complaint,
    required this.onTap,
  });

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Open':
        return Colors.orange;
      case 'In-Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(
                      complaint['status'] ?? 'Open',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: _getStatusColor(complaint['status']).withOpacity(0.2),
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${complaint['id'].toString().substring(0, 8)}...',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (complaint['image_url'] != null || complaint['photo_url'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    complaint['image_url'] ?? complaint['photo_url'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                complaint['description'] ?? complaint['transcript'] ?? complaint['translated_text'] ?? 'No description',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (complaint['department'] != null)
                Chip(
                  label: Text(
                    complaint['department'],
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.thumb_up, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('${complaint['upvote_count'] ?? 0}'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      final lat = complaint['latitude'] ?? complaint['gps_lat'];
                      final lon = complaint['longitude'] ?? complaint['gps_long'];
                      if (lat != null && lon != null) {
                        MapUtils.openGoogleMaps(lat, lon);
                      }
                    },
                    icon: const Icon(Icons.location_on, size: 16),
                    label: Text(
                      () {
                        final lat = complaint['latitude'] ?? complaint['gps_lat'];
                        final lon = complaint['longitude'] ?? complaint['gps_long'];
                        if (lat != null && lon != null) {
                          return '${(lat as num).toDouble().toStringAsFixed(4)}, ${(lon as num).toDouble().toStringAsFixed(4)}';
                        }
                        return 'Location not available';
                      }(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
