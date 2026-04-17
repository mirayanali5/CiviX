import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'citizen_signup_screen.dart';
import 'citizen_dashboard_screen.dart';

class CitizenLoginScreen extends StatefulWidget {
  const CitizenLoginScreen({super.key});

  @override
  State<CitizenLoginScreen> createState() => _CitizenLoginScreenState();
}

class _CitizenLoginScreenState extends State<CitizenLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _connecting = true;
  bool _showSkip = false;

  static const Color _brandBlue  = Color(0xFF3B8BF5);
  static const Color _scaffoldBg = Color(0xFFFFFFFF);
  static const double _pillPeek  = 22.0;

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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const CitizenDashboardScreen()));
    } else if (mounted) {
      final msg = authProvider.lastErrorMessage?.isNotEmpty == true
          ? authProvider.lastErrorMessage!
          : 'Login failed. Create an account first if you have not signed up.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
      ));
    }
  }

  Future<void> _handleGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithGoogle();
    if (success && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const CitizenDashboardScreen()));
    } else if (mounted) {
      final msg = authProvider.lastErrorMessage?.isNotEmpty == true
          ? authProvider.lastErrorMessage!
          : 'Google login failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
      ));
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
            const Text('Connecting to server…',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'First time may take up to a minute\n(server waking up).',
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 12, color: Colors.black),
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
                  // ← vertically centers the scrollable content
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Greeting ────────────────────────────────────
                          const Text(
                            'Hello there, Responsible Samaritan!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF888888),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 4),

                          // ── Title + PNG smiley ──────────────────────────
                          SizedBox(
                            width: double.infinity,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                const Text(
                                  'Citizen\nPortal',
                                  style: TextStyle(
                                    fontFamily: 'EncodeSansSemiExpanded',
                                    fontSize: 46,
                                    fontWeight: FontWeight.w700,
                                    height: 1.05,
                                    color: Color(0xFF111111),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                // PNG smiley — bottom-right of "Portal"
                                Positioned(
                                  right: 10,
                                  bottom: -2,
                                  child: Image.asset(
                                    'assets/images/smiley.png',
                                    width: 62,
                                    height: 62,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Gap = card margin minus pill peek so spacing is tight
                          const SizedBox(height: 26 + _pillPeek),

                          // ── Login card ──────────────────────────────────
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Card body
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Username
                                    const _FieldLabel(label: 'Username'),
                                    const SizedBox(height: 7),
                                    _PillTextField(
                                      controller: _emailController,
                                      hintText: 'email@gmail.com',
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.isEmpty)
                                          return 'Please enter your email';
                                        if (!v.contains('@'))
                                          return 'Please enter a valid email';
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Password
                                    const _FieldLabel(label: 'Password'),
                                    const SizedBox(height: 7),
                                    _PillTextField(
                                      controller: _passwordController,
                                      hintText:
                                          '• • • • • • • • • • • • • • • •',
                                      obscureText: _obscurePassword,
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 14),
                                          child: Icon(
                                            _obscurePassword
                                                ? Icons
                                                    .remove_red_eye_outlined
                                                : Icons
                                                    .visibility_off_outlined,
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
                                        onPressed: () => ScaffoldMessenger
                                                .of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Forgot password feature coming soon'))),
                                        style: TextButton.styleFrom(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize
                                              .shrinkWrap,
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

                                    if (isLoading)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          'Connecting… First time may take up to a minute.',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 11,
                                              color: Colors.black),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                    const SizedBox(height: 18),

                                    // Submit button
                                    Center(
                                      child: SizedBox(
                                        width: 160,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : _handleLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _brandBlue,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor:
                                                _brandBlue.withOpacity(0.55),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                          ),
                                          child: Text(
                                            isLoading
                                                ? 'Logging in…'
                                                : 'Submit',
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // "LOG IN" pill — overlaps card top edge
                              Positioned(
                                top: -_pillPeek,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 36, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: _brandBlue,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Text(
                                      'LOG IN',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // ── Google login (black pill) ───────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleGoogleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF111111),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    const Color(0xFF111111).withOpacity(0.55),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Local PNG → network SVG → fallback icon
                                  Image.asset(
                                    'assets/images/google_logo.png',
                                    height: 22,
                                    width: 22,
                                    errorBuilder: (_, __, ___) =>
                                        Image.network(
                                      'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                      height: 22,
                                      width: 22,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.login,
                                              size: 22,
                                              color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isLoading
                                        ? 'Signing in…'
                                        : 'Login with google',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Create account ──────────────────────────────
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const CitizenSignupScreen()),
                            ),
                            child: const Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: Color(0xFF666666),
                                ),
                                children: [
                                  TextSpan(
                                      text: "Don't have an account yet?\n"),
                                  TextSpan(
                                    text: 'Create an account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
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

            // Loading overlay
            if (isLoading)
              const ModalBarrier(color: Colors.black26, dismissible: false),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Field label
// ─────────────────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill text field
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