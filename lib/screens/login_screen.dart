import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

/// Login screen with email/password authentication using Firebase
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Text field controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Track login progress
  String? _errorMessage; // Display errors to user

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login with Firebase Authentication
  Future<void> _login() async {
    // Set loading state and clear any previous errors
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Get auth service from provider
      final authService = ref.read(authServiceProvider);
      // Attempt login with trimmed email and password
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // On success, auth state listener in main.dart navigates to home
    } catch (e) {
      // Display error message if login fails
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
              // Daily Planet logo at top of login screen
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
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to stay updated with the latest news',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildTextField(
                context,
                'Email',
                Icons.email_outlined,
                _emailController,
                isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context,
                'Password',
                Icons.lock_outlined,
                _passwordController,
                isDark,
                isPassword: true,
              ),
              const SizedBox(height: 12),
              // Show error message if login fails
              if (_errorMessage != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFE53935), // Red error text
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : _login, // Disable while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935), // Red theme color
                    disabledBackgroundColor:
                        const Color(0xFFE53935).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading // Show spinner or text
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Link to registration screen for new users
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  // Tappable "Sign Up" text
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFFE53935), // Brand red
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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

  // Build styled text field for email/password input
  Widget _buildTextField(
    BuildContext context,
    String label,
    IconData icon,
    TextEditingController controller,
    bool isDark, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword, // Hide text for password fields
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 15,
      ),
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
          borderSide: const BorderSide(
            color: Color(0xFFE53935), // Brand red
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
