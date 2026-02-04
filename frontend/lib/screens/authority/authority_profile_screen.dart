import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/role_selection_screen.dart';
import '../../services/api_service.dart';

class AuthorityProfileScreen extends StatefulWidget {
  const AuthorityProfileScreen({super.key});

  @override
  State<AuthorityProfileScreen> createState() => _AuthorityProfileScreenState();
}

class _AuthorityProfileScreenState extends State<AuthorityProfileScreen> {
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
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _profile = response.data['user'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _profile = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _profile = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                    'Manage your profile and app preferences.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppTheme.textSecondary : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_profile != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceCard : Colors.grey.shade100,
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
                                backgroundColor: (isDark ? AppTheme.statusBlue : Colors.blue.shade100),
                                child: Text(
                                  (_profile!['name'] ?? 'A').toString().isNotEmpty
                                      ? (_profile!['name'] as String)[0].toUpperCase()
                                      : 'A',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.blue.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Authority User',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (_profile!['department'] != null &&
                                        _profile!['department'].toString().trim().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppTheme.surfaceCardElevated : Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _profile!['department'].toString(),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
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
                            value: _profile!['name'] ?? 'N/A',
                            isDark: isDark,
                          ),
                          _ProfileRow(
                            label: 'Email',
                            value: _profile!['email'] ?? 'N/A',
                            isDark: isDark,
                          ),
                          if (_profile!['department'] != null)
                            _ProfileRow(
                              label: 'Department',
                              value: _profile!['department'].toString(),
                              isDark: isDark,
                            ),
                          _ProfileRow(
                            label: 'Role',
                            value: (_profile!['role'] ?? 'authority').toString().toUpperCase(),
                            isDark: isDark,
                          ),
                          _ProfileRow(
                            label: 'Account Type',
                            value: (_profile!['account_type'] ?? 'private').toString().toUpperCase(),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  if (_profile == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Could not load profile.',
                          style: TextStyle(
                            color: isDark ? AppTheme.textSecondary : Colors.grey,
                          ),
                        ),
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
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ThemeChip(
                              label: 'Light',
                              isSelected: themeProvider.themeMode == ThemeMode.light,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ThemeChip(
                              label: 'Dark',
                              isSelected: themeProvider.themeMode == ThemeMode.dark,
                              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                        );
                      },
                      icon: Icon(Icons.swap_horiz, color: isDark ? AppTheme.statusOrange : Colors.orange),
                      label: Text(
                        'Switch to Citizen Login',
                        style: TextStyle(color: isDark ? AppTheme.statusOrange : Colors.orange),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: isDark ? AppTheme.statusOrange : Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      icon: Icon(Icons.logout, size: 20, color: isDark ? AppTheme.textSecondary : Colors.grey),
                      label: Text(
                        'Logout',
                        style: TextStyle(color: isDark ? AppTheme.textSecondary : Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _ProfileRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppTheme.textSecondary : Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: isSelected ? primary.withOpacity(0.2) : (isDark ? AppTheme.surfaceCard : Colors.grey.shade200),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primary : (isDark ? AppTheme.textPrimary : Colors.black87),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
