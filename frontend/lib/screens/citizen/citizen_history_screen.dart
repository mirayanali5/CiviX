import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/complaint_provider.dart';
import '../../utils/map_utils.dart';
import '../../widgets/full_screen_image_viewer.dart';
import 'complaint_details_screen.dart';

/// History / Report Archive: complaints made only by the current user.
class CitizenHistoryScreen extends StatefulWidget {
  const CitizenHistoryScreen({super.key});

  @override
  State<CitizenHistoryScreen> createState() => _CitizenHistoryScreenState();
}

class _CitizenHistoryScreenState extends State<CitizenHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).fetchMyComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Archive'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            Provider.of<ComplaintProvider>(context, listen: false).fetchMyComplaints(),
        color: Theme.of(context).colorScheme.primary,
        child: Consumer<ComplaintProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingMy) {
              return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryTeal));
            }
            if (provider.myComplaints.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64,
                        color: isDark ? AppTheme.textSecondary : Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No reports yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark ? AppTheme.textSecondary : Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your submitted reports will appear here.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppTheme.textSecondary : Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Your submitted reports in chronological order.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppTheme.textSecondary : Colors.grey,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ...provider.myComplaints.map(
                  (c) => _HistoryComplaintCard(
                    complaint: c,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComplaintDetailsScreen(
                          complaintId: c['id']?.toString() ?? '',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HistoryComplaintCard extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onTap;

  const _HistoryComplaintCard({
    required this.complaint,
    required this.onTap,
  });

  Color _statusColor(String? status, BuildContext context) {
    final s = (status ?? '').toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (s == 'Open') return AppTheme.statusOrange;
    if (s == 'In-Progress') return AppTheme.statusBlue;
    if (s == 'Resolved') return AppTheme.statusGreen;
    return isDark ? AppTheme.textSecondary : Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = complaint['status'] ?? 'Open';
    final imageUrl = complaint['photo_url'] ?? complaint['image_url'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceCard : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: (isDark ? AppTheme.surfaceCardElevated : Colors.grey.shade300),
                      child: Text(
                        'You',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textPrimary : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Posted ${_timeAgo(complaint['created_at'])} | ID: ${complaint['id'] != null ? (complaint['id'] as String).length >= 8 ? (complaint['id'] as String).substring(0, 8) : complaint['id'] : '—'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.textSecondary : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status, context).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toString().toUpperCase().replaceAll('-', '-'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(status, context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (imageUrl != null && imageUrl.toString().isNotEmpty)
                  GestureDetector(
                    onTap: () => FullScreenImageViewer.open(
                      context,
                      NetworkImage(imageUrl.toString()),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl.toString(),
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 140,
                          color: isDark ? AppTheme.surfaceCardElevated : Colors.grey.shade300,
                          child: Icon(Icons.image_not_supported,
                              color: isDark ? AppTheme.textSecondary : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                if (imageUrl != null && imageUrl.toString().isNotEmpty) const SizedBox(height: 10),
                Text(
                  complaint['transcript'] ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14,
                        color: isDark ? AppTheme.textSecondary : Colors.grey),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.textSecondary : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.favorite_border,
                        size: 16,
                        color: isDark ? AppTheme.textSecondary : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${complaint['upvote_count'] ?? 0} Upvotes',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.textSecondary : Colors.grey,
                      ),
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
}
