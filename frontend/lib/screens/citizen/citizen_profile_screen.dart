import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
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
  bool _isUpdatingAccountType = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Check if user is authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      print('⚠️  User not authenticated - cannot load profile');
      setState(() {
        _isLoading = false;
        _profile = null;
      });
      return;
    }
    
    try {
      final response = await _apiService.getUserProfile();
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _profile = response.data['user'];
          _isLoading = false;
        });
        print('✅ Profile loaded: ${_profile?['email']}');
      } else {
        print('⚠️  Profile response status: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Load profile error: $e');
      if (e.toString().contains('401')) {
        print('   Authentication failed - token may be invalid or expired');
        print('   Try logging out and logging back in');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  bool get _isPublicAccount {
    final v = (_profile?['account_type'] ?? 'private').toString().trim().toLowerCase();
    return v == 'public';
  }

  Future<void> _setAccountType({required bool isPublic}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || _profile == null) return;

    setState(() {
      _isUpdatingAccountType = true;
    });

    try {
      final target = isPublic ? 'public' : 'private';
      final response = await _apiService.updateAccountType(accountType: target);
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _profile = response.data['user'] ?? _profile;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not update account type. Please try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update account type: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAccountType = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surfaceCard : Colors.grey.shade100;
    final textPrimary = isDark ? AppTheme.textPrimary : Colors.black87;
    final textSecondary = isDark ? AppTheme.textSecondary : Colors.grey.shade700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your profile, permissions, and app preferences.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_profile != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceCard : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppTheme.statusOrange.withOpacity(0.3),
                                child: Text(
                                  (_profile!['name'] ?? 'C')[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.statusOrange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Citizen User',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'ID: User#${() { final id = _profile!['id']?.toString() ?? ''; return id.length >= 8 ? id.substring(0, 8) : id.isNotEmpty ? id : '—'; }()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _ProfileRow(
                            label: 'Name',
                            value: _profile!['name']?.toString().trim().isNotEmpty == true
                                ? _profile!['name'].toString()
                                : 'N/A',
                          ),
                          _ProfileRow(
                            label: 'Email',
                            value: _profile!['email']?.toString().trim().isNotEmpty == true
                                ? _profile!['email'].toString()
                                : 'N/A',
                          ),
                          _ProfileRow(
                            label: 'Account Type',
                            value: (_profile!['account_type'] ?? 'private').toString().toUpperCase(),
                            valueChip: true,
                          ),
                        ],
                      ),
                    ),
                  if (_profile != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceCard : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                      child: SwitchListTile(
                        value: _isPublicAccount,
                        onChanged: _isUpdatingAccountType ? null : (v) => _setAccountType(isPublic: v),
                        title: Text(
                          'Public account',
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          _isPublicAccount
                              ? 'Your name will be visible on the dashboard.'
                              : 'You will appear as Anonymous on the dashboard.',
                          style: TextStyle(color: textSecondary),
                        ),
                        secondary: _isUpdatingAccountType
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                              )
                            : Icon(
                                _isPublicAccount ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppTheme.primaryTeal,
                              ),
                        activeColor: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Media Permissions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Control access for reporting features.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDark ? null : [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      children: [
                        FutureBuilder<bool>(
                          future: _checkPermission(Permission.camera),
                          builder: (_, snapshot) => _PermissionItem(
                            icon: Icons.camera_alt_outlined,
                            label: 'Camera Access',
                            granted: snapshot.data ?? false,
                          ),
                        ),
                        FutureBuilder<bool>(
                          future: _checkPermission(Permission.microphone),
                          builder: (_, snapshot) => _PermissionItem(
                            icon: Icons.mic_none_outlined,
                            label: 'Microphone Access',
                            granted: snapshot.data ?? false,
                          ),
                        ),
                        FutureBuilder<bool>(
                          future: _checkPermission(Permission.location),
                          builder: (_, snapshot) => _PermissionItem(
                            icon: Icons.location_on_outlined,
                            label: 'GPS Location',
                            granted: snapshot.data ?? false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: _ThemeChip(
                              label: 'System',
                              isSelected: themeProvider.themeMode == ThemeMode.system,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ThemeChip(
                              label: 'Light',
                              isSelected: themeProvider.themeMode == ThemeMode.light,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ThemeChip(
                              label: 'Dark',
                              isSelected: themeProvider.themeMode == ThemeMode.dark,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'App Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                        );
                      },
                      icon: const Icon(Icons.swap_horiz, color: AppTheme.statusOrange),
                      label: const Text(
                        'Switch to Authority Login',
                        style: TextStyle(color: AppTheme.statusOrange),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.statusOrange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () async {
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                          );
                        }
                      },
                      icon: Icon(Icons.logout, color: textSecondary),
                      label: Text(
                        'Back to Dashboard',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueChip;

  const _ProfileRow({
    required this.label,
    required this.value,
    this.valueChip = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? AppTheme.textSecondary : Colors.grey.shade700;
    final valueColor = isDark ? AppTheme.textPrimary : Colors.black87;
    final chipBg = isDark ? AppTheme.surfaceCardElevated : Colors.grey.shade300;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
            ),
          ),
          if (valueChip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: valueColor,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
              ),
            ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppTheme.textSecondary : Colors.grey.shade700;
    final titleColor = isDark ? AppTheme.textPrimary : Colors.black87;
    final trailingColor = granted ? AppTheme.statusGreen : (isDark ? AppTheme.textSecondary : Colors.grey.shade700);
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        label,
        style: TextStyle(color: titleColor, fontSize: 15),
      ),
      trailing: Text(
        granted ? 'Enabled' : 'Disabled',
        style: TextStyle(
          color: trailingColor,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    
    // Selected: use primary color with better visibility
    // Unselected: use subtle background to distinguish from scaffold
    final selectedBg = isDark 
        ? primary.withOpacity(0.3) 
        : primary.withOpacity(0.15);
    final unselectedBg = isDark 
        ? AppTheme.surfaceCard 
        : Colors.grey.shade200;
    
    return Material(
      color: isSelected ? selectedBg : unselectedBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primary.withOpacity(0.5),
                    width: 1.5,
                  ),
                )
              : null,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? primary 
                    : (isDark ? AppTheme.textSecondary : Colors.grey.shade700),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

