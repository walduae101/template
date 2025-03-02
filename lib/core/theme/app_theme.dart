import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Main theme class that provides the Material 3 theme for the application
class AppTheme {
  /// Light theme configuration using Material 3
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: AppTypography.textTheme,
      fontFamily: GoogleFonts.notoSans().fontFamily,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.secondary.withValues(
              red: AppColors.secondary.r,
              green: AppColors.secondary.g,
              blue: AppColors.secondary.b,
              alpha: 51.0, // 0.2 * 255
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.secondary.withValues(
              red: AppColors.secondary.r,
              green: AppColors.secondary.g,
              blue: AppColors.secondary.b,
              alpha: 51.0, // 0.2 * 255
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.secondary.withValues(
            red: AppColors.secondary.r,
            green: AppColors.secondary.g,
            blue: AppColors.secondary.b,
            alpha: 128.0, // 0.5 * 255
          ),
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.secondary,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.secondary.withValues(
          red: AppColors.secondary.r,
          green: AppColors.secondary.g,
          blue: AppColors.secondary.b,
          alpha: 51.0, // 0.2 * 255
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondary.withValues(
          red: AppColors.secondary.r,
          green: AppColors.secondary.g,
          blue: AppColors.secondary.b,
          alpha: 179.0, // 0.7 * 255
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTypography.textTheme.labelSmall,
        unselectedLabelStyle: AppTypography.textTheme.labelSmall,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.secondary.withValues(
          red: AppColors.secondary.r,
          green: AppColors.secondary.g,
          blue: AppColors.secondary.b,
          alpha: 128.0, // 0.5 * 255
        ),
        thickness: 1,
        space: 1,
      ),

      // Scaffold background color
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  /// Dark theme configuration - optional for future use
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      textTheme: AppTypography.textTheme,
      fontFamily: GoogleFonts.notoSans().fontFamily,

      // Dark mode configurations would go here
      // Currently using same settings as light with dark color scheme
      scaffoldBackgroundColor: AppColors.darkBackground,
    );
  }

  /// Light color scheme based on Material 3 with custom colors
  static final ColorScheme _lightColorScheme = ColorScheme.light(
    // Base colors
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primary.withValues(
      red: AppColors.primary.r,
      green: AppColors.primary.g,
      blue: AppColors.primary.b,
      alpha: 204.0, // 0.8 * 255
    ),
    onPrimaryContainer: AppColors.onPrimary,

    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondary.withValues(
      red: AppColors.secondary.r,
      green: AppColors.secondary.g,
      blue: AppColors.secondary.b,
      alpha: 204.0, // 0.8 * 255
    ),
    onSecondaryContainer: Colors.white,

    surface: AppColors.background,
    onSurface: AppColors.onBackground,

    error: Colors.red.shade700,
    onError: Colors.white,

    brightness: Brightness.light,
  );

  /// Dark color scheme based on Material 3 - optional for future use
  static final ColorScheme _darkColorScheme = ColorScheme(
    // Dark mode colors
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primary.withValues(
      red: AppColors.primary.r,
      green: AppColors.primary.g,
      blue: AppColors.primary.b,
      alpha: 179.0, // 0.7 * 255
    ),
    onPrimaryContainer: AppColors.onPrimary,

    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondary.withValues(
      red: AppColors.secondary.r,
      green: AppColors.secondary.g,
      blue: AppColors.secondary.b,
      alpha: 179.0, // 0.7 * 255
    ),
    onSecondaryContainer: Colors.white,

    surface: const Color(0xFF121212),
    onSurface: Colors.white,

    error: Colors.red.shade300,
    onError: Colors.white,

    brightness: Brightness.dark,
  );
}
