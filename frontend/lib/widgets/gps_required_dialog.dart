import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GPSRequiredDialog extends StatelessWidget {
  final VoidCallback? onSettingsOpened;

  const GPSRequiredDialog({super.key, this.onSettingsOpened});

  static Future<void> show(BuildContext context, {VoidCallback? onSettingsOpened}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GPSRequiredDialog(onSettingsOpened: onSettingsOpened),
    );
  }

  Future<void> _openSettings() async {
    await Geolocator.openLocationSettings();
    if (onSettingsOpened != null) {
      onSettingsOpened!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.location_off, color: Colors.red, size: 28),
          SizedBox(width: 12),
          Text('GPS Required'),
        ],
      ),
      content: const Text(
        'CiviX requires GPS to be enabled to tag complaint locations accurately.\n\n'
        'Please enable location services in your device settings to continue.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await _openSettings();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.settings),
          label: const Text('Open Settings'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }
}
