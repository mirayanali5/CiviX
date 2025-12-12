import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_navigation.dart';
import 'lodge_complaint_screen.dart';
import 'complaint_details_screen.dart';
import 'citizen_map_screen.dart';
import 'citizen_profile_screen.dart';
import '../../utils/map_utils.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _stats;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final response = await _apiService.getDashboardStats();
      if (response.statusCode == 200) {
        setState(() {
          _stats = response.data;
        });
      }
    } catch (e) {
      print('Load dashboard error: $e');
    }

    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    await complaintProvider.fetchComplaints();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      case 1:
        // New Report
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LodgeComplaintScreen()),
        ).then((_) {
          // Refresh dashboard when returning
          _loadDashboard();
        });
        break;
      case 2:
        // History - navigate to profile/history
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CitizenProfileScreen()),
        );
        break;
      case 3:
        // Settings - navigate to profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CitizenProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CiviX Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CitizenMapScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Stats Cards
              if (_stats != null) _buildStatsCards(),
              const SizedBox(height: 16),
              // New Complaint Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LodgeComplaintScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text('New Complaint'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search complaints...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _loadDashboard();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _loadDashboard();
                  },
                ),
              ),
              // Complaints List
              _buildComplaintsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Open',
              value: _stats!['open_complaints']?.toString() ?? '0',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Resolved',
              value: _stats!['resolved_complaints']?.toString() ?? '0',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Total',
              value: _stats!['total_complaints']?.toString() ?? '0',
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList() {
    return Consumer<ComplaintProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.complaints.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text('No complaints found'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.complaints.length,
          itemBuilder: (context, index) {
            final complaint = provider.complaints[index];
            return _ComplaintCard(
              complaint: complaint,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComplaintDetailsScreen(complaintId: complaint['id']),
                  ),
                );
              },
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

  String _getReporterName() {
    if (complaint['is_my_complaint'] == true) {
      return 'You';
    }
    if (complaint['account_type'] == 'private' || complaint['reporter_name'] == null) {
      return 'Anonymous';
    }
    return complaint['reporter_name'];
  }

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
                    _getReporterName(),
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
                complaint['transcript'] ?? 'No description',
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
