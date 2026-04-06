// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../config/app_theme.dart';
// import '../../providers/auth_provider.dart';
// import '../../services/api_service.dart';
// import '../role_selection_screen.dart';
// import 'authority_dashboard_screen.dart';

// class AuthorityLoginScreen extends StatefulWidget {
//   const AuthorityLoginScreen({super.key});

//   @override
//   State<AuthorityLoginScreen> createState() => _AuthorityLoginScreenState();
// }

// class _AuthorityLoginScreenState extends State<AuthorityLoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _connecting = true;
//   bool _showSkip = false;

//   @override
//   void initState() {
//     super.initState();
//     _warmUpServer();
//     Future.delayed(const Duration(seconds: 15), () {
//       if (mounted && _connecting) setState(() => _showSkip = true);
//     });
//   }

//   Future<void> _warmUpServer() async {
//     final ok = await ApiService().checkHealth(timeout: const Duration(seconds: 90));
//     if (mounted) setState(() => _connecting = false);
//   }

//   void _skipConnecting() {
//     setState(() => _connecting = false);
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final success = await authProvider.authorityLogin(
//       email: _emailController.text.trim(),
//       password: _passwordController.text,
//     );

//     if (success && mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Login Successful'),
//           backgroundColor: AppTheme.primaryTeal,
//         ),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const AuthorityDashboardScreen()),
//       );
//     } else if (mounted) {
//       final msg = authProvider.lastErrorMessage?.isNotEmpty == true
//           ? authProvider.lastErrorMessage!
//           : 'Login failed. Authority accounts are created by admin.';
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(msg),
//           backgroundColor: const Color(0xFFEF4444),
//           duration: const Duration(seconds: 5),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_connecting) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Login')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 24),
//               const Text('Connecting to server…', style: TextStyle(fontSize: 16)),
//               const SizedBox(height: 8),
//               const Text(
//                 'First time may take up to a minute (server waking up).',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//               if (_showSkip) ...[
//                 const SizedBox(height: 24),
//                 TextButton(
//                   onPressed: _skipConnecting,
//                   child: const Text('Continue anyway'),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 24),
//               Text(
//                 'Login',
//                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.textPrimary,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Access the Complaint Resolution Dashboard.',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: AppTheme.textSecondary,
//                 ),
//               ),
//               const SizedBox(height: 32),
//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   labelText: 'Username (e.g., Department ID)',
//                   hintText: 'Enter your ID or Email',
//                   prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email or ID';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: _obscurePassword,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
//                       color: AppTheme.textSecondary,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 28),
//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _handleLogin,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.statusBlue,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('LOG IN'),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               TextButton.icon(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
//                   );
//                 },
//                 icon: const Icon(Icons.arrow_back, size: 18, color: AppTheme.textSecondary),
//                 label: const Text(
//                   'Back to Citizen Access',
//                   style: TextStyle(color: AppTheme.textSecondary),
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
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../role_selection_screen.dart';
import 'authority_dashboard_screen.dart';

class AuthorityLoginScreen extends StatefulWidget {
  const AuthorityLoginScreen({super.key});

  @override
  State<AuthorityLoginScreen> createState() => _AuthorityLoginScreenState();
}

class _AuthorityLoginScreenState extends State<AuthorityLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _connecting = true;
  bool _showSkip = false;

  // ── Brand tokens ──────────────────────────────────────────────────────────
  static const Color _brandBlue  = Color(0xFF3B8BF5);
  static const Color _scaffoldBg = Color(0xFFFFFFFF);
  static const double _pillPeek  = 0.0; // LOG IN pill sits inside card bottom

  @override
  void initState() {
    super.initState();
    _warmUpServer();
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _connecting) setState(() => _showSkip = true);
    });
  }

  Future<void> _warmUpServer() async {
    final ok = await ApiService().checkHealth(timeout: const Duration(seconds: 90));
    if (mounted) setState(() => _connecting = false);
  }

  void _skipConnecting() => setState(() => _connecting = false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Login logic (unchanged) ───────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.authorityLogin(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthorityDashboardScreen()),
      );
    } else if (mounted) {
      final msg = authProvider.lastErrorMessage?.isNotEmpty == true
          ? authProvider.lastErrorMessage!
          : 'Login failed. Authority accounts are created by admin.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // ── Warm-up screen ────────────────────────────────────────────────────────
  Widget _buildConnectingScreen() {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _brandBlue),
            const SizedBox(height: 24),
            const Text(
              'Connecting to server…',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'First time may take up to a minute\n(server waking up).',
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (_showSkip) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: _skipConnecting,
                child: const Text('Continue anyway',
                    style: TextStyle(fontFamily: 'Poppins', color: _brandBlue)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Main build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_connecting) return _buildConnectingScreen();

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = authProvider.isLoading;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: _scaffoldBg,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Greeting ──────────────────────────────────
                          const Text(
                            'Ready to make a difference?',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF888888),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 4),

                          // ── Title ─────────────────────────────────────
                          const Text(
                            'Authority\nPortal',
                            style: TextStyle(
                              fontFamily: 'EncodeSansSemiExpanded',
                              fontSize: 46,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              color: Color(0xFF111111),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // ── Subtitle ──────────────────────────────────
                          const Text(
                            'Access the Complaint Resolution Dashboard',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF555555),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 28),

                          // ── Login card ────────────────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFB8DFFB),
                                  Color(0xFF8ECFF7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Username label + hint inline
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: const [
                                    Text(
                                      'Username',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '(e.g., Department ID)',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                _PillTextField(
                                  controller: _emailController,
                                  hintText: '1947452DGFF',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Please enter your email or ID';
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Password label
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                _PillTextField(
                                  controller: _passwordController,
                                  hintText: '• • • • • • • • • • • • • • • •',
                                  obscureText: _obscurePassword,
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 14),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.remove_red_eye_outlined
                                            : Icons.visibility_off_outlined,
                                        color: const Color(0xFF5599DD),
                                        size: 21,
                                      ),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Please enter your password';
                                    return null;
                                  },
                                ),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Forgot password feature coming soon')),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.only(top: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'forgot password?',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // ── LOG IN pill button (inside card bottom) ──
                                Center(
                                  child: SizedBox(
                                    width: 160,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _brandBlue,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            _brandBlue.withOpacity(0.55),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                      ),
                                      child: Text(
                                        isLoading ? 'Logging in…' : 'LOG IN',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Back to Citizen Access ────────────────────
                          TextButton.icon(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RoleSelectionScreen()),
                            ),
                            icon: const Icon(
                              Icons.reply_rounded, // ↩ arrow matching mockup
                              size: 20,
                              color: Color(0xFF555555),
                            ),
                            label: const Text(
                              'Back to Citizen Access',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Loading overlay ───────────────────────────────────────────
            if (isLoading)
              const ModalBarrier(color: Colors.black26, dismissible: false),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill text field — shared style identical to CitizenLoginScreen
// ─────────────────────────────────────────────────────────────────────────────
class _PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _PillTextField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Color(0xFF1A1A1A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide:
              const BorderSide(color: Color(0xFF3B8BF5), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}