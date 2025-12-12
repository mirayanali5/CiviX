import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../utils/map_utils.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaint = provider.selectedComplaint;
          if (complaint == null) {
            return const Center(child: Text('Complaint not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo
                if (complaint['photo_url'] != null)
                  Image.network(
                    complaint['photo_url'],
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 64),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status
                      Chip(
                        label: Text(complaint['status'] ?? 'Open'),
                        backgroundColor: _getStatusColor(complaint['status']).withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      // Title/Description
                      Text(
                        complaint['transcript'] ?? 'No description',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Department
                      if (complaint['department'] != null)
                        Chip(
                          label: Text(complaint['department']),
                        ),
                      const SizedBox(height: 16),
                      // Transcripts
                      if (complaint['transcript_translated'] != null &&
                          complaint['transcript_translated'] != complaint['transcript'])
                        ExpansionTile(
                          title: const Text('Audio Transcript'),
                          children: [
                            ListTile(
                              title: const Text('Original'),
                              subtitle: Text(complaint['transcript'] ?? ''),
                            ),
                            ListTile(
                              title: const Text('Translated'),
                              subtitle: Text(complaint['transcript_translated'] ?? ''),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      // Tags
                      if (complaint['tags'] != null && (complaint['tags'] as List).isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: (complaint['tags'] as List)
                              .map((tag) => Chip(label: Text(tag)))
                              .toList(),
                        ),
                      const SizedBox(height: 16),
                      // GPS Coordinates
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Location'),
                          subtitle: Text(
                            () {
                              final lat = complaint['latitude'] ?? complaint['gps_lat'];
                              final lon = complaint['longitude'] ?? complaint['gps_long'];
                              if (lat != null && lon != null) {
                                return '${(lat as num).toDouble().toStringAsFixed(6)}, ${(lon as num).toDouble().toStringAsFixed(6)}';
                              }
                              return 'Location not available';
                            }(),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
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
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Upvotes
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up),
                            onPressed: () async {
                              final success = await provider.upvoteComplaint(widget.complaintId);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Upvoted!')),
                                );
                              }
                            },
                          ),
                          Text('${complaint['upvote_count'] ?? 0} upvotes'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Timeline
                      const Text(
                        'Timeline',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _TimelineItem(
                        title: 'Created',
                        date: complaint['created_at'],
                        icon: Icons.add_circle,
                        color: Colors.blue,
                      ),
                      if (complaint['status'] == 'In-Progress' || complaint['status'] == 'Resolved')
                        _TimelineItem(
                          title: 'In Progress',
                          date: complaint['created_at'], // Use actual in-progress date if available
                          icon: Icons.work,
                          color: Colors.orange,
                        ),
                      if (complaint['status'] == 'Resolved')
                        _TimelineItem(
                          title: 'Resolved',
                          date: complaint['created_at'], // Use actual resolved date if available
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
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
