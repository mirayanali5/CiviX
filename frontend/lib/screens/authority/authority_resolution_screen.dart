import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../utils/location_service.dart';
import '../../utils/map_utils.dart';
import '../../widgets/full_screen_image_viewer.dart';
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
  static const double _maxResolutionDistanceMeters = 30.0;

  Map<String, dynamic>? _complaint;
  List<File> _resolutionPhotos = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  bool get _canEditComplaint {
    final status = (_complaint?['status'] ?? '').toString().toLowerCase();
    return status == 'open';
  }

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
    if (!_canEditComplaint) return;
    final complaintLat = _parseCoordinate(_complaint?['latitude'] ?? _complaint?['gps_lat']);
    final complaintLon = _parseCoordinate(_complaint?['longitude'] ?? _complaint?['gps_long']);

    if (complaintLat == null || complaintLon == null) {
      await _showLocationWarningDialog(
        title: 'Complaint Location Missing',
        message: 'This complaint does not have a valid location. Resolution photos cannot be uploaded.',
      );
      return;
    }

    final currentPosition = await LocationService.getCurrentLocation();
    if (currentPosition == null) {
      await _showLocationWarningDialog(
        title: 'Current Location Unavailable',
        message:
            'Unable to fetch your current location. Please enable GPS and location permission, then try again.',
      );
      return;
    }

    final distanceMeters = LocationService.calculateDistance(
      complaintLat,
      complaintLon,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    if (distanceMeters > _maxResolutionDistanceMeters) {
      await _showLocationWarningDialog(
        title: 'Outside Allowed Area',
        message:
            'Resolution photo was not uploaded because your current location is ${distanceMeters.toStringAsFixed(1)}m away from the complaint location. You must be within 30m to upload.',
      );
      return;
    }

    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _resolutionPhotos.add(File(image.path));
      });
    }
  }

  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  Future<void> _showLocationWarningDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _removePhoto(int index) {
    if (!_canEditComplaint) return;
    setState(() {
      _resolutionPhotos.removeAt(index);
    });
  }

  Future<void> _updateStatus(String status) async {
    if (!_canEditComplaint) return;
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
    if (!_canEditComplaint) {
      return;
    }
    if (_resolutionPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one resolution photo is required')),
      );
      return;
    }

    final complaintLat = _parseCoordinate(_complaint?['latitude'] ?? _complaint?['gps_lat']);
    final complaintLon = _parseCoordinate(_complaint?['longitude'] ?? _complaint?['gps_long']);

    if (complaintLat == null || complaintLon == null) {
      await _showLocationWarningDialog(
        title: 'Complaint Location Missing',
        message: 'This complaint does not have a valid location. Resolution cannot be uploaded.',
      );
      return;
    }

    final currentPosition = await LocationService.getCurrentLocation();
    if (currentPosition == null) {
      await _showLocationWarningDialog(
        title: 'Current Location Unavailable',
        message:
            'Unable to fetch your current location. Please enable GPS and location permission, then try again.',
      );
      return;
    }

    final distanceMeters = LocationService.calculateDistance(
      complaintLat,
      complaintLon,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    if (distanceMeters > _maxResolutionDistanceMeters) {
      await _showLocationWarningDialog(
        title: 'Outside Allowed Area',
        message:
            'Resolution photo was not uploaded because your current location is ${distanceMeters.toStringAsFixed(1)}m away from the complaint location. You must be within 10m to upload.',
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
                      if (!_canEditComplaint)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.2)),
                          ),
                          child: const Text(
                            'This complaint is resolved. You can only view details.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      if (!_canEditComplaint) const SizedBox(height: 16),
                      // Complaint Details
                      if (_complaint!['image_url'] != null || _complaint!['photo_url'] != null)
                        GestureDetector(
                          onTap: () => FullScreenImageViewer.open(
                            context,
                            NetworkImage(_complaint!['image_url'] ?? _complaint!['photo_url']),
                          ),
                          child: Image.network(
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
                              onPressed: _canEditComplaint ? () => _updateStatus('open') : null,
                              child: const Text('Mark Open'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _canEditComplaint ? _submitResolution : null,
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
                              final lat = _parseCoordinate(_complaint!['latitude'] ?? _complaint!['gps_lat']);
                              final lon = _parseCoordinate(_complaint!['longitude'] ?? _complaint!['gps_long']);
                              if (lat != null && lon != null) {
                                return '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
                              }
                              return 'Location not available';
                            }(),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            final lat = _parseCoordinate(_complaint!['latitude'] ?? _complaint!['gps_lat']);
                            final lon = _parseCoordinate(_complaint!['longitude'] ?? _complaint!['gps_long']);
                            if (lat != null && lon != null) {
                              MapUtils.openGoogleMaps(
                                lat,
                                lon,
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
                                GestureDetector(
                                  onTap: () => FullScreenImageViewer.open(
                                    context,
                                    FileImage(entry.value),
                                  ),
                                  child: Image.file(
                                    entry.value,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: _canEditComplaint
                                        ? () => _removePhoto(entry.key)
                                        : null,
                                  ),
                                ),
                              ],
                            );
                          }),
                          if (_canEditComplaint && _resolutionPhotos.length < 5)
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
                        enabled: _canEditComplaint,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Add resolution notes...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Submit Button
                      ElevatedButton(
                        onPressed: (_isSubmitting || !_canEditComplaint) ? null : _submitResolution,
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
