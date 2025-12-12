import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  /// Request all required permissions on app startup
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = {
      'camera': false,
      'microphone': false,
      'location': false,
      'locationEnabled': false,
    };

    // Request camera permission
    final cameraStatus = await Permission.camera.request();
    results['camera'] = cameraStatus.isGranted;

    // Request microphone permission
    final micStatus = await Permission.microphone.request();
    results['microphone'] = micStatus.isGranted;

    // Request location permission
    final locationStatus = await Permission.location.request();
    results['location'] = locationStatus.isGranted;

    // Check if location services are enabled
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    results['locationEnabled'] = locationEnabled;

    return results;
  }

  /// Check if GPS/location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open location settings to enable GPS
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Check if all critical permissions are granted
  static Future<bool> hasCriticalPermissions() async {
    final camera = await Permission.camera.isGranted;
    final location = await Permission.location.isGranted;
    final locationEnabled = await Geolocator.isLocationServiceEnabled();

    // Location is critical - must be enabled
    return location && locationEnabled;
  }

  /// Get permission status
  static Future<Map<String, PermissionStatus>> getPermissionStatus() async {
    return {
      'camera': await Permission.camera.status,
      'microphone': await Permission.microphone.status,
      'location': await Permission.location.status,
    };
  }

  /// Request specific permission
  static Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }
}
