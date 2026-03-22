// import 'package:flutter/material.dart';
// import '../config/app_theme.dart';
// import 'citizen/citizen_login_screen.dart';
// import 'authority/authority_login_screen.dart';

// class RoleSelectionScreen extends StatelessWidget {
//   const RoleSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textPrimary = isDark ? AppTheme.textPrimary : Colors.black87;
//     final textSecondary = isDark ? AppTheme.textSecondary : Colors.grey.shade700;
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Welcome',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Please select your role to continue:',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: textSecondary,
//                 ),
//               ),
//               const SizedBox(height: 48),
//               _RoleCard(
//                 title: 'Citizen',
//                 subtitle: 'File Complaints & Track Status',
//                 icon: Icons.people_outline,
//                 color: AppTheme.primaryTeal,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const CitizenLoginScreen()),
//                   );
//                 },
//               ),
//               const SizedBox(height: 20),
//               _RoleCard(
//                 title: 'Authority',
//                 subtitle: 'Review, Verify & Resolve Issues',
//                 icon: Icons.shield_outlined,
//                 color: AppTheme.statusBlue,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AuthorityLoginScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _RoleCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _RoleCard({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardBg = isDark ? AppTheme.surfaceCard : Colors.white;
//     final textPrimary = isDark ? AppTheme.textPrimary : Colors.black87;
//     final textSecondary = isDark ? AppTheme.textSecondary : Colors.grey.shade700;
//     return Material(
//       color: cardBg,
//       borderRadius: BorderRadius.circular(16),
//       elevation: isDark ? 0 : 2,
//       shadowColor: isDark ? null : Colors.black26,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, size: 32, color: color),
//               ),
//               const SizedBox(width: 20),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.arrow_forward_ios, size: 16, color: color),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'citizen/citizen_login_screen.dart';
import 'authority/authority_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ───────── TOP SECTION (MOVED LOWER) ─────────
            const SizedBox(height: 90),

            Image.asset(
              'assets/images/knock_knock.png',
              height: 90,
            ),

            const SizedBox(height: 18),

            const Text(
              'Please select your role to continue:',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.black,
              ),
            ),

            // ───────── ROLE SELECTION (OPTICAL CENTER) ─────────
            const SizedBox(height: 80),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  // ───── Citizen ─────
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/citizen_icon.png',
                          height: 48,
                        ),
                        const SizedBox(height: 14),
                        _PrimaryButton(
                          text: 'Citizen',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CitizenLoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // ───── Authority ─────
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/authority_icon.png',
                          height: 48,
                        ),
                        const SizedBox(height: 14),
                        _PrimaryButton(
                          text: 'Authority',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AuthorityLoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ───────── BOTTOM PNG ─────────
            const Spacer(),

            Image.asset(
              'assets/images/role_bottom.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// PRIMARY BUTTON (MATCHES SPLASH)
class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F6BFF),
          elevation: 6,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
