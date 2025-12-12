import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
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
  Map<String, BitmapDescriptor> _customIcons = {};

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  Future<void> _loadMap() async {
    try {
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
        // Set default position if GPS is off
        setState(() {
          _currentPosition = Position(
            latitude: 17.3850,
            longitude: 78.4867,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        });
      } else {
        final position = await LocationService.getCurrentLocation();
        if (position != null) {
          setState(() {
            _currentPosition = position;
          });
        } else {
          // Set default position if location unavailable
          setState(() {
            _currentPosition = Position(
              latitude: 17.3850,
              longitude: 78.4867,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );
          });
        }
      }

      final provider = Provider.of<ComplaintProvider>(context, listen: false);
      await provider.fetchComplaints();
      await _updateMarkers(provider.complaints);
    } catch (e) {
      print('Map load error: $e');
      // Set default position on error
      setState(() {
        _currentPosition = Position(
          latitude: 17.3850,
          longitude: 78.4867,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      });
    }
  }

  Future<BitmapDescriptor> _createMarkerIcon(String imageUrl) async {
    // Check cache first
    if (_customIcons.containsKey(imageUrl)) {
      return _customIcons[imageUrl]!;
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Uint8List imageData = response.bodyBytes;
        
        // Decode and resize image to thumbnail size (100x100)
        final img.Image? originalImage = img.decodeImage(imageData);
        if (originalImage != null) {
          // Resize to thumbnail (100x100 for map marker)
          final img.Image resizedImage = img.copyResize(
            originalImage,
            width: 100,
            height: 100,
            interpolation: img.Interpolation.linear,
          );
          
          // Convert back to bytes (PNG format)
          final Uint8List resizedBytes = Uint8List.fromList(
            img.encodePng(resizedImage),
          );
          
          final BitmapDescriptor icon = BitmapDescriptor.fromBytes(resizedBytes);
          _customIcons[imageUrl] = icon;
          return icon;
        }
      }
    } catch (e) {
      print('Error loading marker image: $e');
    }

    // Return default icon if image fails
    return BitmapDescriptor.defaultMarker;
  }

  Future<void> _updateMarkers(List<Map<String, dynamic>> complaints) async {
    final Set<Marker> newMarkers = {};

    for (final complaint in complaints) {
      final lat = complaint['latitude'] ?? complaint['gps_lat'];
      final lon = complaint['longitude'] ?? complaint['gps_long'];
      
      if (lat == null || lon == null) continue;

      final imageUrl = complaint['image_url'] ?? complaint['photo_url'];
      BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

      // Try to use complaint image as marker icon
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          icon = await _createMarkerIcon(imageUrl);
        } catch (e) {
          print('Error creating custom icon: $e');
        }
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(complaint['id'].toString()),
          position: LatLng(
            (lat as num).toDouble(),
            (lon as num).toDouble(),
          ),
          icon: icon,
          infoWindow: InfoWindow(
            title: complaint['transcript'] ?? complaint['description'] ?? 'Complaint',
            snippet: '${complaint['upvote_count'] ?? 0} upvotes',
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ComplaintDetailsScreen(complaintId: complaint['id'].toString()),
              ),
            );
          },
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
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
          : _markers.isEmpty && _currentPosition != null
              ? GoogleMap(
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
                )
              : _markers.isNotEmpty
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _markers.first.position,
                        zoom: 13,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    )
                  : GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(17.3850, 78.4867), // Default to Hyderabad
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
