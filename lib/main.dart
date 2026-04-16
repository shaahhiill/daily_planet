// Daily Planet - Main Entry Point
// This file initializes the app and configures themes, routing, and Firebase
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'widgets/app_shell.dart';
import 'screens/login_screen.dart';

// Main Function - App Initialization

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase for user authentication
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  // Launch app with Riverpod state management
  runApp(
    const ProviderScope(
      child: DailyPlanetApp(),
    ),
  );
}

// Main App Widget - Theme & Routing Configuration
class DailyPlanetApp extends ConsumerWidget {
  const DailyPlanetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers for theme mode and authentication state
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Daily Planet',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // Light Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFE53935), // Red brand color
          secondary: const Color(0xFF1976D2),
          surface: const Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
      ),

      // Dark Theme Configuration
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE53935), // Red brand color
          secondary: const Color(0xFF42A5F5),
          surface: const Color(0xFF111111),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // Authentication-Based Routing
      // Shows login screen if not authenticated, main app if authenticated
      home: authState.when(
        // User is authenticated -> show main app, otherwise show login
        data: (user) => user != null ? const AppShell() : const LoginScreen(),

        // Loading state - checking authentication
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE53935),
            ),
          ),
        ),

        // Error state - show error with retry option
        error: (error, stack) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(authStateProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
