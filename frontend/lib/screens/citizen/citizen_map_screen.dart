import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import 'complaint_details_screen.dart';
import '../../utils/location_service.dart';

class CitizenMapScreen extends StatefulWidget {
  const CitizenMapScreen({super.key});

  @override
  State<CitizenMapScreen> createState() => _CitizenMapScreenState();
}

class _CitizenMapScreenState extends State<CitizenMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};

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
          builder: (context) => AlertDialog(
            title: const Text('GPS Required'),
            content: const Text('Please enable GPS to view the map.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
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
      }
      return;
    }

    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = position;
      });
    }

    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    await provider.fetchComplaints();
    _updateMarkers(provider.complaints);
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
            snippet: '${complaint['upvote_count'] ?? 0} upvotes',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ComplaintDetailsScreen(complaintId: complaint['id']),
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
        title: const Text('Complaints Map'),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
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
