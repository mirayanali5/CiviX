import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../utils/location_service.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/complaint_success_dialog.dart';
import 'citizen_dashboard_screen.dart';

class LodgeComplaintScreen extends StatefulWidget {
  const LodgeComplaintScreen({super.key});

  @override
  State<LodgeComplaintScreen> createState() => _LodgeComplaintScreenState();
}

class _LodgeComplaintScreenState extends State<LodgeComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final ApiService _apiService = ApiService();
  final AudioRecorder _audioRecorder = AudioRecorder();

  File? _photo;
  File? _audioFile;
  Position? _position;
  bool _isRecording = false;
  bool _isSubmitting = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocation();
  }

  Future<void> _checkAndRequestLocation() async {
    // Check if location services are enabled
    final isEnabled = await LocationService.getCurrentLocation();
    if (isEnabled == null) {
      // GPS is not enabled or permission denied
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('GPS Required'),
            content: const Text(
              'GPS must be enabled to lodge a complaint. Please enable location services in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  Navigator.of(context).pop();
                  _getCurrentLocation();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagsController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    // First check if GPS is enabled
    final gpsEnabled = await LocationService.isLocationServiceEnabled();
    if (!gpsEnabled) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.location_off, color: Colors.red),
                SizedBox(width: 8),
                Text('GPS Required'),
              ],
            ),
            content: const Text(
              'GPS must be enabled to lodge a complaint. Please enable location services in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await LocationService.openLocationSettings();
                  Navigator.of(context).pop();
                  // Retry after opening settings
                  await Future.delayed(const Duration(seconds: 1));
                  _getCurrentLocation();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // GPS is enabled, get location
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _position = position;
      });
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Please grant location permission to tag complaint locations.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _photo = File(image.path);
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      // Check microphone permission
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required for audio recording')),
          );
        }
        return;
      }

      // Get app documents directory for storing audio
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      
      setState(() {
        _isRecording = true;
        _audioPath = path;
      });
    } catch (e) {
      print('Recording error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _audioFile = File(path);
        });
      }
    } catch (e) {
      print('Stop recording error: $e');
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate mandatory fields
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo is mandatory')),
      );
      return;
    }

    if (_position == null) {
      // Check if GPS is enabled
      final gpsEnabled = await LocationService.isLocationServiceEnabled();
      if (!gpsEnabled) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('GPS Required'),
            content: const Text(
              'GPS must be enabled to submit a complaint. Please enable location services.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await LocationService.openLocationSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please get GPS coordinates first')),
        );
      }
      return;
    }

    // Validate description or audio
    if (_descriptionController.text.trim().isEmpty && _audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Either description or audio recording is required')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final tags = _tagsController.text.trim().isNotEmpty
          ? _tagsController.text.split(',').map((e) => e.trim()).toList()
          : null;

      final response = await _apiService.createComplaint(
        photo: _photo!,
        audio: _audioFile,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        lat: _position!.latitude,
        lon: _position!.longitude,
        tags: tags,
      );

      if (mounted) {
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = response.data;
          
          if (data['merged'] == true) {
            // Show duplicate modal
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Duplicate Complaint'),
                content: Text(data['message'] ?? 'A similar complaint already exists.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            // Show success dialog with complaint details
            final complaintData = data['complaint'] ?? data;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => ComplaintSuccessDialog(
                complaint: complaintData,
              ),
            );
            // Navigate after dialog closes
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const CitizenDashboardScreen()),
                );
              }
            });
          }
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        final msg = e.response?.data is Map && e.response!.data!['error'] != null
            ? e.response!.data!['error'] as String
            : e.message ?? 'Request failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $msg'), duration: const Duration(seconds: 5)),
        );
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
        title: const Text('Lodge Complaint'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Section
              const Text(
                'Photo *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _photo == null
                  ? ElevatedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    )
                  : Stack(
                      children: [
                        Image.file(_photo!, height: 200, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _photo = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),
              // GPS Section
              const Text(
                'GPS Coordinates *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _position == null
                  ? ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Get Location'),
                    )
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _position != null
                                    ? '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}'
                                    : 'Getting location...',
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _getCurrentLocation,
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              // Description Section
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Audio Section
              const Text(
                'Audio Recording',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRecording ? _stopRecording : _startRecording,
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                      label: Text(_isRecording ? 'Stop Recording' : 'Record Audio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording ? Colors.red : null,
                      ),
                    ),
                  ),
                  if (_audioFile != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text('Recorded'),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              // Tags Section
              const Text(
                'Tags (comma-separated)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  hintText: 'e.g., urgent, road, pothole',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              // Submit Button
              ElevatedButton(
                onPressed: (_photo != null && _position != null && !_isSubmitting)
                    ? _submitComplaint
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
