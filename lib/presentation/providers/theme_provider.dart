import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Mode State
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_key);

    if (savedMode != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  Future<void> toggleTheme(Brightness currentBrightness) async {
    // If currently in system mode, switch to opposite of current brightness
    // If in light/dark mode, toggle to the opposite
    if (state == ThemeMode.system) {
      await setThemeMode(
        currentBrightness == Brightness.light
            ? ThemeMode.dark
            : ThemeMode.light,
      );
    } else {
      await setThemeMode(
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );
    }
  }
}
