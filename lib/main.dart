import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'widgets/app_shell.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: DailyPlanetApp()));
}

class DailyPlanetApp extends ConsumerWidget {
  const DailyPlanetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Daily Planet',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(themeModeProvider),
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: authState.when(
        data: (user) => user != null ? const AppShell() : const LoginScreen(),
        loading: () => const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.red))),
        error: (error, stack) => const LoginScreen(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: const Color(0xFFE53935),
        onPrimary: Colors.white,
        secondary: const Color(0xFFE53935),
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
        onBackground: isDark ? Colors.white : Colors.black,
        surface: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        onSurface: isDark ? Colors.white : Colors.black,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28),
        headlineMedium: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22),
        titleLarge: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18),
        bodyLarge: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.85)
                : Colors.black.withOpacity(0.85),
            fontSize: 16),
        bodyMedium: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : Colors.black.withOpacity(0.6),
            fontSize: 14),
        bodySmall: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.4)
                : Colors.black.withOpacity(0.4),
            fontSize: 12),
      ),
    );
  }
}
