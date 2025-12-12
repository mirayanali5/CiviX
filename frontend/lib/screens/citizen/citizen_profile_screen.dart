import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/auth_provider.dart';
import '../../screens/role_selection_screen.dart';
import '../../services/api_service.dart';

class CitizenProfileScreen extends StatefulWidget {
  const CitizenProfileScreen({super.key});

  @override
  State<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends State<CitizenProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await _apiService.getUserProfile();
      if (response.statusCode == 200) {
        setState(() {
          _profile = response.data['user'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Load profile error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_profile != null) ...[
                    _ProfileItem(
                      icon: Icons.person,
                      label: 'Name',
                      value: _profile!['name'] ?? 'N/A',
                    ),
                    _ProfileItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: _profile!['email'] ?? 'N/A',
                    ),
                    _ProfileItem(
                      icon: Icons.lock,
                      label: 'Account Type',
                      value: _profile!['account_type'] ?? 'private',
                    ),
                    _ProfileItem(
                      icon: Icons.description,
                      label: 'Total Complaints',
                      value: '${_profile!['total_complaints'] ?? 0}',
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to my complaints
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('My Complaints feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View My Complaints'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Permissions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<bool>(
                    future: _checkPermission(Permission.camera),
                    builder: (context, snapshot) {
                      return _PermissionItem(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        granted: snapshot.data ?? false,
                      );
                    },
                  ),
                  FutureBuilder<bool>(
                    future: _checkPermission(Permission.microphone),
                    builder: (context, snapshot) {
                      return _PermissionItem(
                        icon: Icons.mic,
                        label: 'Microphone',
                        granted: snapshot.data ?? false,
                      );
                    },
                  ),
                  FutureBuilder<bool>(
                    future: _checkPermission(Permission.location),
                    builder: (context, snapshot) {
                      return _PermissionItem(
                        icon: Icons.location_on,
                        label: 'GPS Location',
                        granted: snapshot.data ?? false,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Switch to Authority Login'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton.icon(
                        onPressed: () async {
                          await authProvider.logout();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool granted;

  const _PermissionItem({
    required this.icon,
    required this.label,
    required this.granted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Icon(
          granted ? Icons.check_circle : Icons.cancel,
          color: granted ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
