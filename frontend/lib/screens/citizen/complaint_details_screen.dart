import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/complaint_provider.dart';
import '../../utils/map_utils.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false)
          .fetchComplaint(widget.complaintId);
    });
  }

  Color _getStatusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s == 'open') return AppTheme.statusOrange;
    if (s == 'in-progress') return AppTheme.statusBlue;
    if (s == 'resolved') return AppTheme.statusGreen;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardBg = isDark ? AppTheme.surfaceCard : Colors.grey.shade200;
          final elevatedBg = isDark ? AppTheme.surfaceCardElevated : Colors.grey.shade300;
          final textSecondary = isDark ? AppTheme.textSecondary : Colors.grey.shade700;

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
          }

          final complaint = provider.selectedComplaint;
          if (complaint == null) {
            return const Center(child: Text('Complaint not found'));
          }

          final isResolved = (complaint['status'] ?? '').toString().toLowerCase() == 'resolved';
          final resolutionPhotos = complaint['resolution_photos'] as List?;
          final hasResolutionPhotos = resolutionPhotos != null && resolutionPhotos.isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Reported media
                if (complaint['photo_url'] != null || complaint['image_url'] != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reported media (tap for full size)',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _FullScreenImage(
                                  imageUrl: complaint['photo_url'] ?? complaint['image_url'],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              complaint['photo_url'] ?? complaint['image_url'],
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 220,
                                color: cardBg,
                                child: Icon(Icons.image_not_supported, size: 48, color: textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                complaint['transcript'] ?? 'No description',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: null,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(complaint['status'] ?? 'Open'),
                              backgroundColor: _getStatusColor(complaint['status']).withOpacity(0.25),
                              labelStyle: TextStyle(
                                color: _getStatusColor(complaint['status']),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      if (complaint['department'] != null)
                        Chip(
                          label: Text(complaint['department']),
                          backgroundColor: elevatedBg,
                        ),
                      const SizedBox(height: 16),
                      // Resolution proof (shown to citizens when resolved)
                      if (isResolved && hasResolutionPhotos) ...[
                        Text(
                          'Resolution proof',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...resolutionPhotos.map<Widget>((url) {
                          final s = url?.toString() ?? '';
                          if (s.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                s,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 180,
                                  color: cardBg,
                                  child: Icon(Icons.image_not_supported, size: 48, color: textSecondary),
                                ),
                              ),
                            ),
                          );
                        }),
                        if (complaint['resolution_notes'] != null &&
                            (complaint['resolution_notes'] as String).trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            complaint['resolution_notes'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                        if (complaint['resolved_at'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Resolved ${_formatDate(complaint['resolved_at'])}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                      // Location
                      InkWell(
                        onTap: () {
                          final lat = complaint['latitude'] ?? complaint['gps_lat'];
                          final lon = complaint['longitude'] ?? complaint['gps_long'];
                          if (lat != null && lon != null) {
                            MapUtils.openGoogleMaps(
                              (lat as num).toDouble(),
                              (lon as num).toDouble(),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: AppTheme.statusOrange, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: textSecondary,
                                      ),
                                    ),
                                    Text(
                                      () {
                                        final lat = complaint['latitude'] ?? complaint['gps_lat'];
                                        final lon = complaint['longitude'] ?? complaint['gps_long'];
                                        if (lat != null && lon != null) {
                                          return '${(lat as num).toDouble().toStringAsFixed(6)}, ${(lon as num).toDouble().toStringAsFixed(6)}';
                                        }
                                        return 'Location not available';
                                      }(),
                                      style: const TextStyle(color: AppTheme.primaryTeal),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 14, color: textSecondary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Consumer<ComplaintProvider>(
                            builder: (context, provider, _) {
                              final isUpvoted = provider.isUpvoted(widget.complaintId);
                              return IconButton(
                                icon: Icon(
                                  isUpvoted ? Icons.favorite : Icons.favorite_border,
                                  color: isUpvoted ? Colors.red : AppTheme.primaryTeal,
                                ),
                                onPressed: () async {
                                  final success = await provider.upvoteComplaint(widget.complaintId);
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isUpvoted ? 'Upvote removed' : 'Upvoted!'),
                                        backgroundColor: AppTheme.primaryTeal,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          Consumer<ComplaintProvider>(
                            builder: (context, provider, _) {
                              final complaint = provider.selectedComplaint;
                              return Text(
                                '${complaint?['upvote_count'] ?? 0} upvotes',
                                style: Theme.of(context).textTheme.bodyMedium,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Timeline',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _TimelineItem(
                        title: 'Created',
                        date: complaint['created_at'],
                        icon: Icons.add_circle,
                        color: AppTheme.statusBlue,
                      ),
                      if (complaint['status'] == 'In-Progress' || complaint['status'] == 'Resolved')
                        _TimelineItem(
                          title: 'In Progress',
                          date: complaint['created_at'],
                          icon: Icons.work,
                          color: AppTheme.statusOrange,
                        ),
                      if (complaint['status'] == 'Resolved')
                        _TimelineItem(
                          title: 'Resolved',
                          date: complaint['resolved_at'] ?? complaint['created_at'],
                          icon: Icons.check_circle,
                          color: AppTheme.statusGreen,
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final parsed = DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {
      return date.toString();
    }
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final dynamic date;
  final IconData icon;
  final Color color;

  const _TimelineItem({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    String dateStr = 'Unknown';
    if (date != null) {
      try {
        final parsed = DateTime.parse(date.toString());
        dateStr = DateFormat('MMM dd, yyyy HH:mm').format(parsed);
      } catch (e) {
        dateStr = date.toString();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.image_not_supported, size: 48, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
