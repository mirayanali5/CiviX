import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../services/permission_service.dart';
import 'role_selection_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isLoading = true;
  bool _gpsEnabled = false;
  Map<String, bool> _permissions = {};
  bool _hasRequested = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });

    // Check GPS first (most critical - app cannot start without it)
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    
    setState(() {
      _gpsEnabled = locationEnabled;
      _isLoading = false;
    });

    if (!locationEnabled) {
      // GPS is off - show prompt, don't proceed
      return;
    }

    // GPS is on, now request other permissions
    if (!_hasRequested) {
      await _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _hasRequested = true;
    });

    // Request all permissions
    final results = await PermissionService.requestAllPermissions();

    setState(() {
      _permissions = results;
      _isLoading = false;
    });

    // Check if we can proceed (GPS enabled + location permission)
    if (results['locationEnabled'] == true && results['location'] == true) {
      // Wait a moment then navigate
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _navigateToApp();
      }
    }
  }

  Future<void> _enableGPS() async {
    final enabled = await Geolocator.openLocationSettings();
    if (enabled || mounted) {
      // Wait a moment for GPS to enable
      await Future.delayed(const Duration(seconds: 1));
      await _checkPermissions();
    }
  }

  void _navigateToApp() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Checking permissions...'),
            ],
          ),
        ),
      );
    }

    // GPS is not enabled - BLOCK APP START
    if (!_gpsEnabled) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_off,
                  size: 100,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'GPS Required',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CiviX cannot start without GPS enabled.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'GPS is required to tag complaint locations accurately. Please enable location services to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  onPressed: _enableGPS,
                  icon: const Icon(Icons.settings, size: 24),
                  label: const Text(
                    'Enable GPS in Settings',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _checkPermissions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('I\'ve Enabled GPS'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // GPS is enabled, show permission status
    final locationGranted = _permissions['location'] ?? false;
    final cameraGranted = _permissions['camera'] ?? false;
    final micGranted = _permissions['microphone'] ?? false;

    // If location is not granted yet, request it
    if (!locationGranted && !_hasRequested) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestPermissions();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Permissions Required',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'CiviX needs the following permissions to function properly:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              _PermissionItem(
                icon: Icons.location_on,
                title: 'Location',
                description: 'To tag complaint locations (Required)',
                granted: locationGranted,
                required: true,
              ),
              const SizedBox(height: 12),
              _PermissionItem(
                icon: Icons.camera_alt,
                title: 'Camera',
                description: 'To take photos of complaints',
                granted: cameraGranted,
              ),
              const SizedBox(height: 12),
              _PermissionItem(
                icon: Icons.mic,
                title: 'Microphone',
                description: 'To record audio descriptions',
                granted: micGranted,
              ),
              const SizedBox(height: 32),
              if (!locationGranted)
                ElevatedButton(
                  onPressed: _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text(
                    'Grant Permissions',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _navigateToApp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: const Text(
                    'Continue to App',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final bool required;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          icon,
          color: granted ? Colors.green : Colors.orange,
          size: 32,
        ),
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (required) ...[
              const SizedBox(width: 8),
              const Text(
                '(Required)',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(description),
        trailing: Icon(
          granted ? Icons.check_circle : Icons.cancel,
          color: granted ? Colors.green : Colors.red,
          size: 28,
        ),
      ),
    );
  }
}
