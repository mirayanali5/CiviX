// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'permission_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 2), () {
//       if (mounted) {
//         try {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (_) => const PermissionScreen()),
//           );
//         } catch (e) {
//           print('Error navigating from splash: $e');
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.blue.shade700,
//               Colors.blue.shade400,
//             ],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.gavel,
//                 size: 100,
//                 color: Colors.white,
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'CiviX',
//                 style: TextStyle(
//                   fontSize: 48,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 2,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'Civic Complaint System',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.white70,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'permission_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// ───────── CENTER CONTENT (OPTICAL CENTER) ─────────
          Expanded(
            child: Transform.translate(
              offset: Offset(0, screenHeight * 0.10), // visual center
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _TopIcon('assets/images/icon_streetlight.png'),
                          _TopIcon('assets/images/icon_building.png'),
                          _TopIcon('assets/images/icon_trash.png'),
                          _TopIcon('assets/images/icon_water.png'),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // App logo
                      const Text(
                        'CiviX',
                        style: TextStyle(
                          fontFamily: 'EncodeSansSemiExpanded',
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Color(0xFF000000),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Shining CTA button
                      ShimmerButton(
                        text: 'Get started!',
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PermissionScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// ───────── CITY ILLUSTRATION ─────────
          Image.asset(
            'assets/images/city_illustration.png',
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// ICON WIDGET (VISUAL NORMALIZATION)
class _TopIcon extends StatelessWidget {
  final String path;
  const _TopIcon(this.path);

  @override
  Widget build(BuildContext context) {
    final bool isStreetLight = path.contains('streetlight');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Opacity(
        opacity: 0.85,
        child: Image.asset(
          path,
          width: isStreetLight ? 32 : 28,
          height: isStreetLight ? 32 : 28,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// SHINING CTA BUTTON (PREMIUM, SUBTLE)
class ShimmerButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const ShimmerButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + 2 * _controller.value, -1),
              end: Alignment(1.0 + 2 * _controller.value, 1),
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.45),
                Colors.white.withOpacity(0.15),
              ],
              stops: const [0.3, 0.5, 0.7],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: SizedBox(
        width: 220,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            elevation: 6,
            shadowColor: const Color(0xFF2196F3).withOpacity(0.35),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
