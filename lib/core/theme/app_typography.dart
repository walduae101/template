import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Class that defines typography styles using Material 3 guidelines
class AppTypography {
  /// Main text theme for the application
  static TextTheme get textTheme {
    return TextTheme(
      // Display styles
      displayLarge: _getTextStyle(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        height: 1.12,
      ),
      displayMedium: _getTextStyle(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        height: 1.16,
      ),
      displaySmall: _getTextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        height: 1.22,
      ),

      // Headline styles
      headlineLarge: _getTextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.25,
      ),
      headlineMedium: _getTextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.29,
      ),
      headlineSmall: _getTextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.33,
      ),

      // Title styles
      titleLarge: _getTextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        height: 1.27,
      ),
      titleMedium: _getTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      titleSmall: _getTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.1,
      ),

      // Body styles
      bodyLarge: _getTextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      bodyMedium: _getTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.25,
      ),
      bodySmall: _getTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.4,
      ),

      // Label styles
      labelLarge: _getTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.1,
      ),
      labelMedium: _getTextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.5,
      ),
      labelSmall: _getTextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.45,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Helper function to create TextStyle with Noto Sans font (supports Arabic & English)
  static TextStyle _getTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.notoSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.onBackground,
    );
  }

  /// Alternative Arabic font (Tajawal - excellent for Arabic)
  static TextStyle getArabicStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.tajawal(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.onBackground,
    );
  }
}
