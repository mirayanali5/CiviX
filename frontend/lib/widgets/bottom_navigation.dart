import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  /// When true, second tab shows "Resolution" instead of "New Report" (Authority).
  final bool isAuthority;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAuthority = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A202C) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: isAuthority ? Icons.assignment_outlined : Icons.add_circle_outline,
                activeIcon: isAuthority ? Icons.assignment : Icons.add_circle,
                label: isAuthority ? 'Resolution' : 'New Report',
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'History',
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
