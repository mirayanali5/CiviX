import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/api_service.dart';
import '../../utils/location_service.dart';
import 'authority_resolution_screen.dart';

class AuthorityMapScreen extends StatefulWidget {
  const AuthorityMapScreen({super.key});

  @override
  State<AuthorityMapScreen> createState() => _AuthorityMapScreenState();
}

class _AuthorityMapScreenState extends State<AuthorityMapScreen> {
  final ApiService _apiService = ApiService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  Future<void> _loadMap() async {
    // Check GPS first
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
              'GPS must be enabled to view the map. Please enable location services.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await LocationService.openLocationSettings();
                  Navigator.of(context).pop();
                  // Retry after opening settings
                  await Future.delayed(const Duration(seconds: 1));
                  _loadMap();
                },
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = position;
      });
    }

    try {
      final response = await _apiService.getDepartmentComplaints();
      if (response.statusCode == 200) {
        setState(() {
          _complaints = List<Map<String, dynamic>>.from(response.data['complaints']);
          _updateMarkers(_complaints);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Load map error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarkers(List<Map<String, dynamic>> complaints) {
    setState(() {
      _markers = complaints
          .where((c) => c['gps_lat'] != null && c['gps_long'] != null)
          .map((complaint) {
        return Marker(
          markerId: MarkerId(complaint['id']),
          position: LatLng(
            complaint['gps_lat'],
            complaint['gps_long'],
          ),
          infoWindow: InfoWindow(
            title: complaint['transcript'] ?? 'Complaint',
            snippet: '${complaint['upvote_count'] ?? 0} upvotes - ${complaint['status']}',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AuthorityResolutionScreen(complaintId: complaint['id']),
              ),
            );
          },
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Complaints Map'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(child: Text('Location not available'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 13,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
    );
  }
}
