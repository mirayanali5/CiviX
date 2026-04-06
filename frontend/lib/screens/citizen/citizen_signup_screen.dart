// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import 'citizen_dashboard_screen.dart';

// class CitizenSignupScreen extends StatefulWidget {
//   const CitizenSignupScreen({super.key});

//   @override
//   State<CitizenSignupScreen> createState() => _CitizenSignupScreenState();
// }

// class _CitizenSignupScreenState extends State<CitizenSignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = Tex tEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   String _accountType = 'private'; // Default private

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleSignup() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_passwordController.text != _confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Passwords do not match')),
//       );
//       return;
//     }

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final success = await authProvider.signup(
//       name: _nameController.text.trim(),
//       email: _emailController.text.trim(),
//       password: _passwordController.text,
//       accountType: _accountType,
//     );

//     if (success && mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const CitizenDashboardScreen()),
//       );
//     } else if (mounted) {
//       final msg = authProvider.lastErrorMessage ?? 'Signup failed. Please try again.';
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Account'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 20),
//               const Text(
//                 'Join CiviX',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   prefixIcon: Icon(Icons.person),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   prefixIcon: Icon(Icons.email),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!value.contains('@')) {
//                     return 'Please enter a valid email';
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
//                   prefixIcon: const Icon(Icons.lock),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                   border: const OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 obscureText: _obscureConfirmPassword,
//                 decoration: InputDecoration(
//                   labelText: 'Confirm Password',
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscureConfirmPassword = !_obscureConfirmPassword;
//                       });
//                     },
//                   ),
//                   border: const OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please confirm your password';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Account Type',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               RadioListTile<String>(
//                 title: const Text('Private'),
//                 subtitle: const Text('Your name will be hidden'),
//                 value: 'private',
//                 groupValue: _accountType,
//                 onChanged: (value) {
//                   setState(() {
//                     _accountType = value!;
//                   });
//                 },
//               ),
//               RadioListTile<String>(
//                 title: const Text('Public'),
//                 subtitle: const Text('Your name will be visible'),
//                 value: 'public',
//                 groupValue: _accountType,
//                 onChanged: (value) {
//                   setState(() {
//                     _accountType = value!;
//                   });
//                 },
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _handleSignup,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text('Create Account'),
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
import '../../providers/auth_provider.dart';
import 'citizen_dashboard_screen.dart';

class CitizenSignupScreen extends StatefulWidget {
  const CitizenSignupScreen({super.key});

  @override
  State<CitizenSignupScreen> createState() => _CitizenSignupScreenState();
}

class _CitizenSignupScreenState extends State<CitizenSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _accountType = 'private';

  static const Color _brandBlue  = Color(0xFF3B8BF5);
  static const Color _scaffoldBg = Color(0xFFFFFFFF);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Signup logic — UNCHANGED ──────────────────────────────────────────────
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      accountType: _accountType,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CitizenDashboardScreen()),
      );
    } else if (mounted) {
      final msg =
          authProvider.lastErrorMessage ?? 'Signup failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        horizontal: 32, vertical: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Quote ───────────────────────────────────────
                          const Text(
                            '"Good things begin with a single tap."',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF999999),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 10),

                          // ── Title — centered ────────────────────────────
                          const Text(
                            'Create\nAccount',
                            style: TextStyle(
                              fontFamily: 'EncodeSansSemiExpanded',
                              fontSize: 46,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              color: Color(0xFF111111),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 28),

                          // ── Card — constrained width, not edge-to-edge ──
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFB8DFFB),
                                    Color(0xFF8ECFF7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B8BF5)
                                        .withOpacity(0.15),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Name
                                  _InlineLabel(
                                    bold: 'Name',
                                    light: '(Serves as your display name)',
                                  ),
                                  const SizedBox(height: 7),
                                  _PillTextField(
                                    controller: _nameController,
                                    hintText: 'Name',
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Please enter your name';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Email
                                  const _BoldLabel(label: 'Email'),
                                  const SizedBox(height: 7),
                                  _PillTextField(
                                    controller: _emailController,
                                    hintText: 'email@gmail.com',
                                    keyboardType: TextInputType.emailAddress,
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
                                  const _BoldLabel(label: 'Password'),
                                  const SizedBox(height: 7),
                                  _PillTextField(
                                    controller: _passwordController,
                                    hintText: '• • • • • • • • • • • • • •',
                                    obscureText: _obscurePassword,
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 14),
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
                                        return 'Please enter a password';
                                      if (v.length < 6)
                                        return 'Password must be at least 6 characters';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // Confirm Password
                                  const _BoldLabel(label: 'Confirm Password'),
                                  const SizedBox(height: 7),
                                  _PillTextField(
                                    controller: _confirmPasswordController,
                                    hintText: '• • • • • • • • • • • • • •',
                                    obscureText: _obscureConfirmPassword,
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() =>
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 14),
                                        child: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.remove_red_eye_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color(0xFF5599DD),
                                          size: 21,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Please confirm your password';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 22),

                                  // Divider before account type
                                  Divider(
                                    color: Colors.white.withOpacity(0.5),
                                    thickness: 1,
                                  ),

                                  const SizedBox(height: 14),

                                  // Account Type
                                  const _BoldLabel(label: 'Account Type'),
                                  const SizedBox(height: 8),
                                  _AccountTypeRadio(
                                    label: 'Public Account',
                                    subtitle: 'Your name will be visible',
                                    value: 'public',
                                    groupValue: _accountType,
                                    onChanged: (v) =>
                                        setState(() => _accountType = v!),
                                  ),
                                  const SizedBox(height: 4),
                                  _AccountTypeRadio(
                                    label: 'Private Account',
                                    subtitle: 'Your name will be hidden',
                                    value: 'private',
                                    groupValue: _accountType,
                                    onChanged: (v) =>
                                        setState(() => _accountType = v!),
                                  ),

                                  const SizedBox(height: 24),

                                  // Submit
                                  Center(
                                    child: SizedBox(
                                      width: 160,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed:
                                            isLoading ? null : _handleSignup,
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
                                          isLoading ? 'Creating…' : 'Submit',
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
                          ),

                          const SizedBox(height: 28),
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
// Label: bold + smaller grey inline hint
// ─────────────────────────────────────────────────────────────────────────────
class _InlineLabel extends StatelessWidget {
  final String bold;
  final String light;
  const _InlineLabel({required this.bold, required this.light});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(bold,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            )),
        const SizedBox(width: 6),
        Flexible(
          child: Text(light,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF555555),
              )),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Simple bold field label
// ─────────────────────────────────────────────────────────────────────────────
class _BoldLabel extends StatelessWidget {
  final String label;
  const _BoldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Radio row with subtitle
// ─────────────────────────────────────────────────────────────────────────────
class _AccountTypeRadio extends StatelessWidget {
  final String label;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _AccountTypeRadio({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.55)
              : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF3B8BF5).withOpacity(0.6)
                : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Radio<String>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: const Color(0xFF3B8BF5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ],
        ),
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