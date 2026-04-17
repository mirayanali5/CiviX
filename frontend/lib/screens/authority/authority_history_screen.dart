import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/full_screen_image_viewer.dart';

class AuthorityHistoryScreen extends StatefulWidget {
  const AuthorityHistoryScreen({super.key});

  @override
  State<AuthorityHistoryScreen> createState() => _AuthorityHistoryScreenState();
}

class _AuthorityHistoryScreenState extends State<AuthorityHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _resolutions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await _apiService.getResolutionHistory();
      if (response.statusCode == 200) {
        setState(() {
          _resolutions = List<Map<String, dynamic>>.from(response.data['resolutions']);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Load history error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final parsed = DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy HH:mm').format(parsed);
    } catch (e) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolution History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resolutions.isEmpty
              ? const Center(child: Text('No resolutions found'))
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    itemCount: _resolutions.length,
                    itemBuilder: (context, index) {
                      final resolution = _resolutions[index];
                      final afterPhotos = (resolution['images'] is List)
                          ? (resolution['images'] as List)
                              .map((e) => e?.toString() ?? '')
                              .where((url) => url.isNotEmpty)
                              .toList()
                          : <String>[];
                      final fallbackAfterPhoto = resolution['photo_url']?.toString() ?? '';
                      if (afterPhotos.isEmpty && fallbackAfterPhoto.isNotEmpty) {
                        afterPhotos.add(fallbackAfterPhoto);
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(resolution['resolved_at']),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Before Image
                              if (resolution['before_photo'] != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Before:',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => FullScreenImageViewer.open(
                                        context,
                                        NetworkImage(resolution['before_photo']),
                                      ),
                                      child: Image.network(
                                        resolution['before_photo'],
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 12),
                              // After Images
                              if (afterPhotos.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'After:',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    ...afterPhotos.map(
                                      (photoUrl) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: GestureDetector(
                                          onTap: () => FullScreenImageViewer.open(
                                            context,
                                            NetworkImage(photoUrl),
                                          ),
                                          child: Image.network(
                                            photoUrl,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (resolution['notes'] != null && resolution['notes'].toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Notes: ${resolution['notes']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
