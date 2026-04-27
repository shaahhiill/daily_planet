import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Registration screen for new users using Firebase Authentication
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Text field controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false; // Track registration progress
  String? _errorMessage; // Display errors to user

  @override
  void dispose() {
    // Clean up all controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle registration with Firebase Authentication
  Future<void> _register() async {
    // Validate that password and confirm password match
    // This check happens before calling Firebase
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return; // Exit early if passwords don't match
    }
    // Set loading state and clear any previous errors
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Get auth service from provider
      final authService = ref.read(authServiceProvider);
      // Create new user account with Firebase
      // Note: Name is collected but not currently stored in Firebase
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate back to login screen on successful registration
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Display error message if registration fails
      setState(() => _errorMessage = e.toString());
    } finally {
      // Reset loading state (only if widget still mounted)
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark; // Check theme

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Daily Planet logo at top of registration screen
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/daily_planet_logo.png',
                  width: 260,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join Daily Planet and stay informed',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Full name input field
              _buildTextField(context, 'Full Name', Icons.person_outlined,
                  _nameController, isDark),
              const SizedBox(height: 16),
              // Email input field
              _buildTextField(context, 'Email', Icons.email_outlined,
                  _emailController, isDark),
              const SizedBox(height: 16),
              // Password input field (obscured)
              _buildTextField(context, 'Password', Icons.lock_outlined,
                  _passwordController, isDark,
                  isPassword: true),
              const SizedBox(height: 16),
              // Confirm password field (must match password)
              _buildTextField(context, 'Confirm Password', Icons.lock_outlined,
                  _confirmPasswordController, isDark,
                  isPassword: true),
              const SizedBox(height: 12),
              // Show error message if registration fails or passwords don't match
              if (_errorMessage != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorMessage!,
                    style:
                        const TextStyle(color: Color(0xFFE53935), fontSize: 13),
                  ),
                ),
              const SizedBox(height: 28),
              // Sign Up button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _register, // Disable while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935), // Brand red
                    disabledBackgroundColor:
                        const Color(0xFFE53935).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  // Show spinner while loading, otherwise show "Sign Up" text
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('Sign Up',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              // Link back to login screen for existing users
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 14),
                  ),
                  // Tappable "Login" text
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Go back to login
                    child: const Text(
                      'Login',
                      style: TextStyle(
                          color: Color(0xFFE53935), // Brand red
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build styled text field for form inputs
  Widget _buildTextField(BuildContext context, String label, IconData icon,
      TextEditingController controller, bool isDark,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword, // Hide text for password fields
      style:
          TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        prefixIcon: Icon(icon, color: isDark ? Colors.white38 : Colors.black38),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        // Red border when field is focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
