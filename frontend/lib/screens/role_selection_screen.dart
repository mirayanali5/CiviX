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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final topGap = screenHeight < 700 ? 36.0 : 90.0;
            final logoHeight = screenHeight < 700 ? 72.0 : 90.0;
            final introGap = screenHeight < 700 ? 12.0 : 18.0;
            final roleSectionGap = screenHeight < 700 ? 40.0 : 80.0;
            final iconHeight = screenHeight < 700 ? 42.0 : 48.0;
            final bottomImageHeight = screenHeight < 700 ? 185.0 : 260.0;

            return Column(
              children: [
                SizedBox(height: topGap),
                Image.asset(
                  'assets/images/knock_knock.png',
                  height: logoHeight,
                ),
                SizedBox(height: introGap),
                const Text(
                  'Please select your role to continue:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: roleSectionGap),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/citizen_icon.png',
                              height: iconHeight,
                            ),
                            const SizedBox(height: 14),
                            _PrimaryButton(
                              text: 'Citizen',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CitizenLoginScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/authority_icon.png',
                              height: iconHeight,
                            ),
                            const SizedBox(height: 14),
                            _PrimaryButton(
                              text: 'Authority',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AuthorityLoginScreen(),
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
                const Spacer(),
                Image.asset(
                  'assets/images/role_bottom.png',
                  height: bottomImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
            );
          },
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
