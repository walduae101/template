import 'package:flutter/material.dart';

/// Class that defines all the color constants used in the application
class AppColors {
  /// Primary color - Gold (#C9AE5D)
  static const Color primary = Color(0xFFC9AE5D);

  /// Text color on primary - White
  static const Color onPrimary = Color(0xFF3F0707);

  /// Secondary color - Dark Gray (#404040)
  static const Color secondary = Color(0xFF404040);

  /// Background color - Deep Heritage Red (#3F0707)
  static const Color background = Color(0xFF3F0707);

  /// Dark background color for dark theme
  static const Color darkBackground = Color(0xFF1A0303);

  /// Text color on background - White (#FFFFFF)
  static const Color onBackground = Color(0xFFFFFFFF);

  /// Error color
  static const Color error = Color(0xFFB00020);

  /// Success color
  static const Color success = Color(0xFF388E3C);

  /// Warning color
  static const Color warning = Color(0xFFF57C00);

  /// Info color
  static const Color info = Color(0xFF1976D2);

  /// Lighter shade of primary for backgrounds
  static Color lightPrimary = primary.withValues(
    red: primary.r,
    green: primary.g,
    blue: primary.b,
    alpha: 26.0,
  );

  /// Surface colors - slightly different shade of background for cards and surfaces
  static const Color surface = Color(0xFFFFFFFF);

  /// Light gray for dividers, borders, etc.
  static const Color lightGray = Color(0xFFE0E0E0);

  /// Medium gray for disabled elements
  static const Color mediumGray = Color(0xFFBDBDBD);
}
