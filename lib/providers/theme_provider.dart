// These imports bring in the tools needed for state management,
// saving data on the device, and Flutter's built-in theme system.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// This creates a global "theme provider" that any part of the app can listen to.
// It tells the app whether to show light mode, dark mode, or follow the device setting.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// This class is responsible for tracking and changing the theme.
// It holds the current theme mode and provides functions to change it.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {

  // When the app starts, we begin with "system" mode (follow the device setting)
  // and immediately check if the user had previously chosen a different mode.
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  // Keys used to store preferences on the device (like labels on boxes).
  final String _key = 'theme_mode';
  final String _userSetKey = 'theme_user_set'; // Tracks if the user manually chose a theme

  /// Loads the saved theme preference from the device's local storage.
  /// Only applies a saved mode if the user explicitly toggled it themselves.
  /// Otherwise, defaults to system (follows device dark/light setting).
  Future<void> _loadThemeMode() async {
    // Open the device's local storage (like a small notepad saved on the phone).
    final prefs = await SharedPreferences.getInstance();

    // Check if the user has ever manually selected a theme.
    final userExplicitlySet = prefs.getBool(_userSetKey) ?? false;

    if (!userExplicitlySet) {
      // User never manually chose — always follow the device's setting.
      state = ThemeMode.system;
      return;
    }

    // Read the previously saved value (e.g. "light" or "dark").
    final savedMode = prefs.getString(_key);

    if (savedMode == 'light') {
      state = ThemeMode.light;  // Show the light (white) theme
    } else if (savedMode == 'dark') {
      state = ThemeMode.dark;   // Show the dark (black) theme
    } else {
      state = ThemeMode.system; // Fall back to system if something unexpected is stored
    }
  }

  /// Saves the current theme preference to the device's local storage
  /// so the choice is remembered the next time the app is opened.
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert the theme mode into a simple text string before saving.
    final value = mode == ThemeMode.light ? 'light' : 'dark';
    await prefs.setString(_key, value);      // Save the theme value
    await prefs.setBool(_userSetKey, true);  // Mark that the user made a manual choice
  }

  /// Switches the theme between light and dark when the user taps the toggle.
  /// If the app is currently on system/dark → switch to light, and vice versa.
  Future<void> toggleTheme() async {
    // If on light → go dark. If on system or dark → go light.
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;               // Update the current theme immediately
    await _saveThemeMode(newMode); // Save the choice so it persists after restart
  }

  /// Resets the theme back to "system" mode.
  /// The app will then automatically match the device's dark/light setting.
  Future<void> setSystemTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userSetKey, false); // Clear the manual-choice flag
    await prefs.remove(_key);               // Remove the saved value
    state = ThemeMode.system;               // Follow the device again
  }
}
