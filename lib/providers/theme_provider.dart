import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Provider that manages app theme mode (light/dark)
/// Persists user preference using SharedPreferences
/// Allows user to manually toggle between light and dark mode
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notifier class that handles theme mode changes
/// Loads saved preference on init and saves on change
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  // Start with dark mode as default
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  // SharedPreferences key for storing theme preference
  final String _key = 'theme_mode';

  /// Load saved theme preference from local storage
  /// Called automatically when provider is initialized
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_key);

    // Update state based on saved preference
    if (savedMode == 'light') {
      state = ThemeMode.light;
    } else if (savedMode == 'dark') {
      state = ThemeMode.dark;
    }
    // If no saved preference, keep default (dark)
  }

  /// Save theme preference to local storage
  /// Called automatically when user toggles theme
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.light ? 'light' : 'dark');
  }

  /// Toggle between light and dark mode
  /// Called when user taps the theme toggle button
  Future<void> toggleTheme() async {
    // Switch to opposite mode
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;

    // Persist the change
    await _saveThemeMode(newMode);
  }
}
