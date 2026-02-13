import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Manages app theme mode (light/dark) with persistence
/// Loads saved preference on startup, saves on toggle
/// Used in: main app, profile sheet
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Handles theme mode changes and persistence
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  final String _key = 'theme_mode';

  /// Loads saved theme preference from device storage
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_key);

    if (savedMode == 'light') {
      state = ThemeMode.light;
    } else if (savedMode == 'dark') {
      state = ThemeMode.dark;
    }
  }

  /// Saves theme preference to device storage
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.light ? 'light' : 'dark');
  }

  /// Toggles between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    await _saveThemeMode(newMode);
  }
}
