import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_navigation.dart';
import 'lodge_complaint_screen.dart';
import 'complaint_details_screen.dart';
import 'citizen_map_screen.dart';
import 'citizen_profile_screen.dart';
import 'citizen_history_screen.dart';
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
    // Check if user is authenticated before loading stats
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    
    // Load dashboard stats (requires auth - may fail if not logged in)
    if (isAuthenticated) {
      try {
        final response = await _apiService.getDashboardStats();
        if (response.statusCode == 200 && response.data != null) {
          setState(() {
            _stats = response.data;
          });
          print('✅ Dashboard stats loaded');
        }
      } catch (e) {
        print('⚠️  Load dashboard stats error: $e');
        // Don't set _stats to null - keep previous stats if any
        // This allows dashboard to work even if stats fail
      }
    } else {
      print('ℹ️  User not authenticated - skipping dashboard stats');
    }

    // Load complaints (works without auth - shows public complaints)
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
        // History - my complaints only
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CitizenHistoryScreen()),
        );
        break;
      case 3:
        // Settings
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
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
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
        color: AppTheme.primaryTeal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_stats != null) _buildStatsCards(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LodgeComplaintScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 22),
                    label: const Text('FILE NEW COMPLAINT'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Nearby Open Complaints (Trending)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Upvote issues that matter most to you to increase visibility.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildComplaintsList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildStatsCards() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Report Metrics',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isDark ? AppTheme.textSecondary : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Open',
                  value: _stats!['open_complaints']?.toString() ?? '0',
                  color: AppTheme.statusOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Resolved',
                  value: _stats!['resolved_complaints']?.toString() ?? '0',
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Total',
                  value: _stats!['total_complaints']?.toString() ?? '0',
                  color: isDark ? AppTheme.surfaceCardElevated : Colors.grey.shade700,
                ),
              ),
            ],
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
            child: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
          );
        }

        if (provider.complaints.isEmpty) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No complaints found',
                style: TextStyle(
                  color: isDark ? AppTheme.textSecondary : Colors.grey.shade700,
                ),
              ),
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
              onUpvote: () async {
                final success = await provider.upvoteComplaint(complaint['id']);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Upvoted!'),
                      backgroundColor: AppTheme.primaryTeal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  await provider.fetchComplaints();
                }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTotalCard = color == AppTheme.surfaceCardElevated || (!isDark && color == Colors.grey.shade700);
    final bgColor = isTotalCard
        ? (isDark ? AppTheme.surfaceCard : Colors.grey.shade200)
        : color.withOpacity(0.2);
    final valueColor = isTotalCard
        ? (isDark ? AppTheme.textPrimary : Colors.black87)
        : color;
    final titleColor = isTotalCard
        ? (isDark ? AppTheme.textSecondary : Colors.grey.shade700)
        : color;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: titleColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onTap;
  final VoidCallback? onUpvote;

  const _ComplaintCard({
    required this.complaint,
    required this.onTap,
    this.onUpvote,
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
    final s = (status ?? '').toString();
    if (s == 'Open') return AppTheme.statusOrange;
    if (s == 'In-Progress') return AppTheme.statusBlue;
    if (s == 'Resolved') return AppTheme.statusGreen;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surfaceCard : Colors.white;
    final elevatedBg = isDark ? AppTheme.surfaceCardElevated : Colors.grey.shade200;
    final textPrimary = isDark ? AppTheme.textPrimary : Colors.black87;
    final textSecondary = isDark ? AppTheme.textSecondary : Colors.grey.shade700;
    final status = complaint['status'] ?? 'Open';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: elevatedBg,
                      child: Text(
                        _getReporterName().isNotEmpty ? _getReporterName()[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getReporterName(),
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase().replaceAll('-', '-'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Posted ${complaint['created_at'] != null ? _timeAgo(complaint['created_at']) : '?'} | ID: ${complaint['id'] != null ? (complaint['id'] as String).length >= 8 ? (complaint['id'] as String).substring(0, 8) : complaint['id'] : '—'}',
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
                const SizedBox(height: 10),
                if (complaint['photo_url'] != null || complaint['image_url'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        complaint['photo_url'] ?? complaint['image_url'],
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: elevatedBg,
                          child: Icon(Icons.image_not_supported,
                              color: textSecondary),
                        ),
                      ),
                    ),
                  ),
                Text(
                  complaint['transcript'] ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (complaint['department'] != null) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      complaint['department'],
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: elevatedBg,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        () {
                          final lat = complaint['latitude'] ?? complaint['gps_lat'];
                          final lon = complaint['longitude'] ?? complaint['gps_long'];
                          if (lat != null && lon != null) {
                            return '${(lat as num).toDouble().toStringAsFixed(4)}...';
                          }
                          return 'Location not available';
                        }(),
                        style: TextStyle(fontSize: 12, color: textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Consumer<ComplaintProvider>(
                      builder: (context, provider, _) {
                        final isUpvoted = provider.isUpvoted(complaint['id']?.toString() ?? '');
                        return InkWell(
                          onTap: onUpvote,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUpvoted ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: isUpvoted ? Colors.red : AppTheme.primaryTeal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${complaint['upvote_count'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUpvoted ? Colors.red : AppTheme.primaryTeal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(dynamic date) {
    if (date == null) return '?';
    try {
      final d = DateTime.parse(date.toString());
      final diff = DateTime.now().difference(d);
      if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
      if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
      return 'Just now';
    } catch (_) {
      return '?';
    }
  }
}
