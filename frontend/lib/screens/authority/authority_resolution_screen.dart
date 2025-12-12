import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../utils/map_utils.dart';
import 'authority_dashboard_screen.dart';

class AuthorityResolutionScreen extends StatefulWidget {
  final String complaintId;

  const AuthorityResolutionScreen({super.key, required this.complaintId});

  @override
  State<AuthorityResolutionScreen> createState() => _AuthorityResolutionScreenState();
}

class _AuthorityResolutionScreenState extends State<AuthorityResolutionScreen> {
  final ApiService _apiService = ApiService();
  final _notesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Map<String, dynamic>? _complaint;
  List<File> _resolutionPhotos = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComplaint();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaint() async {
    try {
      final response = await _apiService.getComplaintForResolution(widget.complaintId);
      if (response.statusCode == 200) {
        setState(() {
          _complaint = response.data['complaint'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Load complaint error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickResolutionPhoto() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _resolutionPhotos.add(File(image.path));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _resolutionPhotos.removeAt(index);
    });
  }

  Future<void> _updateStatus(String status) async {
    try {
      await _apiService.updateComplaintStatus(widget.complaintId, status);
      await _loadComplaint();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  Future<void> _submitResolution() async {
    if (_resolutionPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one resolution photo is required')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _apiService.resolveComplaint(
        id: widget.complaintId,
        photos: _resolutionPhotos,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Complaint resolved successfully!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthorityDashboardScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Resolution'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _complaint == null
              ? const Center(child: Text('Complaint not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Complaint Details
                      if (_complaint!['image_url'] != null || _complaint!['photo_url'] != null)
                        Image.network(
                          _complaint!['image_url'] ?? _complaint!['photo_url'],
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _complaint!['description'] ?? _complaint!['transcript'] ?? _complaint!['translated_text'] ?? 'No description',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_complaint!['department'] != null)
                        Chip(label: Text(_complaint!['department'])),
                      const SizedBox(height: 16),
                      // Status Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _updateStatus('open'),
                              child: const Text('Mark Open'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitResolution,
                              child: const Text('Resolve'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // GPS
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('Location'),
                          subtitle: Text(
                            () {
                              final lat = _complaint!['latitude'] ?? _complaint!['gps_lat'];
                              final lon = _complaint!['longitude'] ?? _complaint!['gps_long'];
                              if (lat != null && lon != null) {
                                return '${(lat as num).toDouble().toStringAsFixed(6)}, ${(lon as num).toDouble().toStringAsFixed(6)}';
                              }
                              return 'Location not available';
                            }(),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            final lat = _complaint!['latitude'] ?? _complaint!['gps_lat'];
                            final lon = _complaint!['longitude'] ?? _complaint!['gps_long'];
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
                      // Resolution Photos
                      const Text(
                        'Resolution Photos *',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._resolutionPhotos.asMap().entries.map((entry) {
                            return Stack(
                              children: [
                                Image.file(
                                  entry.value,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _removePhoto(entry.key),
                                  ),
                                ),
                              ],
                            );
                          }),
                          if (_resolutionPhotos.length < 5)
                            InkWell(
                              onTap: _pickResolutionPhoto,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add_photo_alternate),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Notes
                      const Text(
                        'Notes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Add resolution notes...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Submit Button
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitResolution,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text('Mark as Resolved'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
