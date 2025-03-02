import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

/// Theme mode state notifier to manage theme changes
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  /// Toggle between light and dark themes
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// Set specific theme mode
  void setTheme(ThemeMode themeMode) {
    state = themeMode;
  }
}

/// Provider for theme mode (light/dark)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Provider for theme data based on current theme mode
final themeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  switch (themeMode) {
    case ThemeMode.dark:
      return AppTheme.darkTheme();
    case ThemeMode.light:
    default:
      return AppTheme.lightTheme();
  }
});
