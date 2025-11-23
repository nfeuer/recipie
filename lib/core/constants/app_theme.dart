/// Application Theme and Styling Configuration
///
/// This file defines the complete visual design system for the Recipe & Event Platform.
/// It provides both light and dark theme configurations with a cohesive color palette
/// and consistent styling for all UI components.
///
/// Key features:
/// - Custom color palette (terracotta and sage green)
/// - Light and dark theme variants
/// - Consistent component styling (buttons, cards, inputs, etc.)
/// - Predefined spacing and border radius values
/// - Material 3 design system
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   ...
/// )
/// ```
import 'package:flutter/material.dart';

/// Manages application-wide theming and visual design.
///
/// This class provides complete theme configurations for both light and dark modes,
/// along with reusable color, spacing, and radius constants.
class AppTheme {
  // -------------------------------------------------------------------------
  // Color Palette
  // -------------------------------------------------------------------------

  /// Brand and UI colors used throughout the application.

  /// Primary brand color - warm terracotta (#D4846A)
  static const Color primaryColor = Color(0xFFD4846A);

  /// Secondary accent color - sage green (#8B9D83)
  static const Color secondaryColor = Color(0xFF8B9D83);

  /// Main background color - off-white (#FAF9F6)
  static const Color backgroundColor = Color(0xFFFAF9F6);

  /// Surface color for cards and elevated components - pure white
  static const Color surfaceColor = Colors.white;

  /// Error state color - red (#D32F2F)
  static const Color errorColor = Color(0xFFD32F2F);

  /// Success state color - green (#388E3C)
  static const Color successColor = Color(0xFF388E3C);

  /// Primary text color - dark blue-gray (#2C3E50)
  static const Color textPrimaryColor = Color(0xFF2C3E50);

  /// Secondary text color - medium gray (#7F8C8D)
  static const Color textSecondaryColor = Color(0xFF7F8C8D);

  // -------------------------------------------------------------------------
  // Light Theme
  // -------------------------------------------------------------------------

  /// Complete light theme configuration with Material 3 design.
  ///
  /// Includes styling for all major UI components including app bars,
  /// cards, buttons, inputs, and text styles.
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: secondaryColor.withOpacity(0.1),
      selectedColor: secondaryColor,
      labelStyle: const TextStyle(color: textPrimaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondaryColor,
      ),
    ),
  );

  // -------------------------------------------------------------------------
  // Dark Theme
  // -------------------------------------------------------------------------

  /// Complete dark theme configuration with Material 3 design.
  ///
  /// Provides a dark mode alternative with adjusted colors for better
  /// readability in low-light conditions. Maintains brand colors while
  /// using dark backgrounds and surfaces.
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: const Color(0xFF1E1E1E),
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: secondaryColor.withOpacity(0.2),
      selectedColor: secondaryColor,
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.white70,
      ),
    ),
  );

  // -------------------------------------------------------------------------
  // Spacing Constants
  // -------------------------------------------------------------------------

  /// Consistent spacing values for padding and margins throughout the app.

  /// Small spacing - 8dp
  static const double paddingSmall = 8.0;

  /// Medium spacing - 16dp (most common)
  static const double paddingMedium = 16.0;

  /// Large spacing - 24dp
  static const double paddingLarge = 24.0;

  /// Extra large spacing - 32dp
  static const double paddingXLarge = 32.0;

  // -------------------------------------------------------------------------
  // Border Radius Constants
  // -------------------------------------------------------------------------

  /// Consistent border radius values for rounded corners throughout the app.

  /// Small radius - 4dp (subtle rounding)
  static const double radiusSmall = 4.0;

  /// Medium radius - 8dp (standard buttons and inputs)
  static const double radiusMedium = 8.0;

  /// Large radius - 12dp (cards and containers)
  static const double radiusLarge = 12.0;

  /// Extra large radius - 16dp (chips and special elements)
  static const double radiusXLarge = 16.0;
}
