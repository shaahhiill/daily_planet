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

  // The key used to store the theme preference on the device (like a label on a box).
  final String _key = 'theme_mode';

  /// Loads the saved theme preference from the device's local storage.
  /// If the user never set a preference, it defaults to following the device setting.
  Future<void> _loadThemeMode() async {
    // Open the device's local storage (like a small notepad saved on the phone).
    final prefs = await SharedPreferences.getInstance();

    // Read the previously saved value (e.g. "light", "dark", or "system").
    final savedMode = prefs.getString(_key);

    // Apply the saved preference, or fall back to system if nothing was saved.
    if (savedMode == 'light') {
      state = ThemeMode.light;  // Show the light (white) theme
    } else if (savedMode == 'dark') {
      state = ThemeMode.dark;   // Show the dark (black) theme
    } else {
      state = ThemeMode.system; // Follow whatever the device is set to
    }
  }

  /// Saves the current theme preference to the device's local storage
  /// so the choice is remembered the next time the app is opened.
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert the theme mode into a simple text string before saving.
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';

    await prefs.setString(_key, value); // Write the value to storage
  }

  /// Cycles the theme through: system → light → dark → system.
  /// This way the device preference is the default, and the user
  /// can override it or return to auto at any time.
  Future<void> toggleTheme() async {
    final ThemeMode newMode;
    if (state == ThemeMode.system) {
      newMode = ThemeMode.light;
    } else if (state == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else {
      newMode = ThemeMode.system; // back to following the device
    }
    state = newMode;
    await _saveThemeMode(newMode);
  }

  /// Resets the theme back to "system" mode.
  /// The app will then automatically match the device's dark/light setting.
  Future<void> setSystemTheme() async {
    state = ThemeMode.system;
    await _saveThemeMode(ThemeMode.system); // Save "system" as the preference
  }
}
