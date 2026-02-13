import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'widgets/app_shell.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

/// App entry point - initializes Firebase and starts the app
void main() async {
  // Required for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Wrap app in ProviderScope for Riverpod state management
  runApp(const ProviderScope(child: DailyPlanetApp()));
}

/// Root widget of the Daily Planet news app
class DailyPlanetApp extends ConsumerWidget {
  const DailyPlanetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch authentication state to determine which screen to show
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Daily Planet', // App name shown in task switcher
      debugShowCheckedModeBanner: false, // Hide debug banner in top-right
      themeMode:
          ref.watch(themeModeProvider), // Watch theme mode (light/dark/system)
      theme: _buildTheme(Brightness.light), // Light theme configuration
      darkTheme: _buildTheme(Brightness.dark), // Dark theme configuration
      // Route to appropriate screen based on auth state
      home: authState.when(
        // User is logged in: show main app
        data: (user) => user != null ? const AppShell() : const LoginScreen(),
        // Still checking auth state: show loading spinner
        loading: () => const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.red))),
        // Auth check failed: show login screen
        error: (error, stack) => const LoginScreen(),
      ),
    );
  }

  /// Build theme configuration for light or dark mode
  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      // App background color
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      // Color scheme for Material components
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: const Color(0xFFE53935), // Red theme color
        onPrimary: Colors.white, // Text on primary color
        secondary: const Color(0xFFE53935), // Secondary accent color
        onSecondary: Colors.white,
        error: Colors.red, // Error state color
        onError: Colors.white,
        surface:
            isDark ? const Color(0xFF1A1A1A) : Colors.white, // Card backgrounds
        onSurface: isDark ? Colors.white : Colors.black, // Text on surfaces
      ),
      // Text styles for different text types
      textTheme: TextTheme(
        // Large display text (e.g., page headers)
        displayLarge: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28),
        // Medium headlines (e.g., section titles)
        headlineMedium: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22),
        // Large titles (e.g., article titles)
        titleLarge: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18),
        // Large body text (e.g., article content)
        bodyLarge: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.85)
                : Colors.black.withOpacity(0.85),
            fontSize: 16),
        // Medium body text (e.g., descriptions)
        bodyMedium: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : Colors.black.withOpacity(0.6),
            fontSize: 14),
        // Small body text (e.g., metadata, timestamps)
        bodySmall: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.4)
                : Colors.black.withOpacity(0.4),
            fontSize: 12),
      ),
    );
  }
}
