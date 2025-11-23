/// Cooking Measurement Unit Conversion Utilities
///
/// This file provides comprehensive unit conversion utilities for recipe ingredients.
/// It supports both volume and weight measurements in metric and US customary systems.
///
/// Key features:
/// - Volume conversions (teaspoons, cups, liters, etc.)
/// - Weight conversions (grams, ounces, pounds, etc.)
/// - Automatic unit system detection
/// - Smart formatting with appropriate precision
/// - Convenient conversion to metric or US systems
/// - Amount parsing from various string formats (fractions, decimals, mixed numbers)
///
/// Conversion bases:
/// - Volume: milliliters (mL)
/// - Weight: grams (g)
///
/// Usage:
/// ```dart
/// // Convert specific units
/// final cups = UnitConversion.convertVolume(500, 'ml', 'cup'); // ~2.11 cups
///
/// // Auto-detect and convert
/// final result = UnitConversion.convert(2, 'cup', 'ml'); // 473.176 ml
///
/// // Convert to metric system
/// final metric = UnitConversion.convertToMetric(2, 'cup'); // "473.18 mL"
/// ```

/// Manages cooking measurement unit conversions between metric and US customary systems.
///
/// This class provides conversion utilities for both volume and weight measurements,
/// supporting common cooking units and providing user-friendly output formatting.
class UnitConversion {
  // -------------------------------------------------------------------------
  // Volume Conversion Tables
  // -------------------------------------------------------------------------

  /// Volume unit conversion factors (all relative to milliliters as base unit).
  ///
  /// Includes both metric (mL, L) and US customary (tsp, tbsp, cup, etc.) units.
  /// All values represent how many milliliters one unit equals.
  static const Map<String, double> _volumeToML = {
    // Metric
    'ml': 1.0,
    'milliliter': 1.0,
    'milliliters': 1.0,
    'l': 1000.0,
    'liter': 1000.0,
    'liters': 1000.0,

    // US customary
    'tsp': 4.92892,
    'teaspoon': 4.92892,
    'teaspoons': 4.92892,
    'tbsp': 14.7868,
    'tablespoon': 14.7868,
    'tablespoons': 14.7868,
    'fl oz': 29.5735,
    'fluid ounce': 29.5735,
    'fluid ounces': 29.5735,
    'cup': 236.588,
    'cups': 236.588,
    'pint': 473.176,
    'pints': 473.176,
    'quart': 946.353,
    'quarts': 946.353,
    'gallon': 3785.41,
    'gallons': 3785.41,
  };

  // -------------------------------------------------------------------------
  // Weight Conversion Tables
  // -------------------------------------------------------------------------

  /// Weight unit conversion factors (all relative to grams as base unit).
  ///
  /// Includes both metric (g, kg, mg) and US/Imperial (oz, lb) units.
  /// All values represent how many grams one unit equals.
  static const Map<String, double> _weightToGrams = {
    // Metric
    'g': 1.0,
    'gram': 1.0,
    'grams': 1.0,
    'kg': 1000.0,
    'kilogram': 1000.0,
    'kilograms': 1000.0,
    'mg': 0.001,
    'milligram': 0.001,
    'milligrams': 0.001,

    // US/Imperial
    'oz': 28.3495,
    'ounce': 28.3495,
    'ounces': 28.3495,
    'lb': 453.592,
    'pound': 453.592,
    'pounds': 453.592,
  };

  // -------------------------------------------------------------------------
  // Conversion Methods
  // -------------------------------------------------------------------------

  /// Converts a volume measurement from one unit to another.
  ///
  /// [amount] The numeric quantity to convert.
  /// [fromUnit] The source unit (e.g., "cup", "ml", "tsp").
  /// [toUnit] The target unit (e.g., "ml", "fl oz", "L").
  ///
  /// Returns the converted amount, or null if either unit is not recognized.
  /// Units are case-insensitive and whitespace is trimmed.
  ///
  /// Example:
  /// ```dart
  /// final ml = convertVolume(2, 'cup', 'ml'); // 473.176 ml
  /// ```
  static double? convertVolume(double amount, String fromUnit, String toUnit) {
    final from = fromUnit.toLowerCase().trim();
    final to = toUnit.toLowerCase().trim();

    final fromML = _volumeToML[from];
    final toML = _volumeToML[to];

    if (fromML == null || toML == null) return null;

    final amountInML = amount * fromML;
    return amountInML / toML;
  }

  /// Converts a weight measurement from one unit to another.
  ///
  /// [amount] The numeric quantity to convert.
  /// [fromUnit] The source unit (e.g., "lb", "g", "oz").
  /// [toUnit] The target unit (e.g., "g", "kg", "oz").
  ///
  /// Returns the converted amount, or null if either unit is not recognized.
  /// Units are case-insensitive and whitespace is trimmed.
  ///
  /// Example:
  /// ```dart
  /// final grams = convertWeight(1, 'lb', 'g'); // 453.592 grams
  /// ```
  static double? convertWeight(double amount, String fromUnit, String toUnit) {
    final from = fromUnit.toLowerCase().trim();
    final to = toUnit.toLowerCase().trim();

    final fromGrams = _weightToGrams[from];
    final toGrams = _weightToGrams[to];

    if (fromGrams == null || toGrams == null) return null;

    final amountInGrams = amount * fromGrams;
    return amountInGrams / toGrams;
  }

  /// Automatically detects unit type and converts between units.
  ///
  /// [amount] The numeric quantity to convert.
  /// [fromUnit] The source unit.
  /// [toUnit] The target unit.
  ///
  /// Returns the converted amount, or null if units are incompatible or not recognized.
  ///
  /// This method tries volume conversion first, then weight conversion.
  /// Use this when you're not sure if the units are volume or weight.
  ///
  /// Example:
  /// ```dart
  /// final result = convert(2, 'cup', 'ml'); // Works! Returns 473.176
  /// final invalid = convert(2, 'cup', 'g'); // Returns null (incompatible types)
  /// ```
  static double? convert(double amount, String fromUnit, String toUnit) {
    // Try volume first
    final volumeResult = convertVolume(amount, fromUnit, toUnit);
    if (volumeResult != null) return volumeResult;

    // Try weight
    final weightResult = convertWeight(amount, fromUnit, toUnit);
    if (weightResult != null) return weightResult;

    return null;
  }

  /// Check if a unit is a volume unit
  static bool isVolumeUnit(String unit) {
    return _volumeToML.containsKey(unit.toLowerCase().trim());
  }

  /// Check if a unit is a weight unit
  static bool isWeightUnit(String unit) {
    return _weightToGrams.containsKey(unit.toLowerCase().trim());
  }

  /// Get all supported volume units
  static List<String> get volumeUnits => _volumeToML.keys.toList();

  /// Get all supported weight units
  static List<String> get weightUnits => _weightToGrams.keys.toList();

  /// Format a converted value to a readable string
  static String formatAmount(double amount, {int decimals = 2}) {
    if (amount == amount.toInt()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(decimals);
  }

  /// Convert to metric system (volume to ml/l, weight to g/kg)
  static String? convertToMetric(double amount, String unit) {
    final unitLower = unit.toLowerCase().trim();

    if (isVolumeUnit(unitLower)) {
      final ml = convertVolume(amount, unitLower, 'ml');
      if (ml == null) return null;

      if (ml >= 1000) {
        return '${formatAmount(ml / 1000)} L';
      } else {
        return '${formatAmount(ml)} mL';
      }
    }

    if (isWeightUnit(unitLower)) {
      final grams = convertWeight(amount, unitLower, 'g');
      if (grams == null) return null;

      if (grams >= 1000) {
        return '${formatAmount(grams / 1000)} kg';
      } else {
        return '${formatAmount(grams)} g';
      }
    }

    return null;
  }

  /// Convert to US customary system
  static String? convertToUS(double amount, String unit) {
    final unitLower = unit.toLowerCase().trim();

    if (isVolumeUnit(unitLower)) {
      final ml = convertVolume(amount, unitLower, 'ml');
      if (ml == null) return null;

      // Convert to most appropriate US unit
      if (ml >= 3785) {
        return '${formatAmount(ml / 3785.41)} gallons';
      } else if (ml >= 946) {
        return '${formatAmount(ml / 946.353)} quarts';
      } else if (ml >= 473) {
        return '${formatAmount(ml / 473.176)} pints';
      } else if (ml >= 237) {
        return '${formatAmount(ml / 236.588)} cups';
      } else if (ml >= 30) {
        return '${formatAmount(ml / 29.5735)} fl oz';
      } else if (ml >= 14.8) {
        return '${formatAmount(ml / 14.7868)} tbsp';
      } else {
        return '${formatAmount(ml / 4.92892)} tsp';
      }
    }

    if (isWeightUnit(unitLower)) {
      final grams = convertWeight(amount, unitLower, 'g');
      if (grams == null) return null;

      if (grams >= 454) {
        return '${formatAmount(grams / 453.592)} lbs';
      } else {
        return '${formatAmount(grams / 28.3495)} oz';
      }
    }

    return null;
  }
}

// ============================================================================
// STRING EXTENSION FOR AMOUNT PARSING
// ============================================================================

/// Extension on String to parse cooking measurement amounts.
///
/// Provides a convenient method to parse various amount formats commonly
/// used in recipes (fractions, decimals, mixed numbers).
extension AmountParsing on String {
  /// Parses a string amount into a numeric value.
  ///
  /// Supports multiple formats:
  /// - Simple fractions: "1/2" → 0.5
  /// - Decimals: "1.5" → 1.5
  /// - Mixed numbers: "2 1/4" → 2.25
  /// - Whole numbers: "3" → 3.0
  ///
  /// Returns the parsed value, or null if the string cannot be parsed.
  ///
  /// Example:
  /// ```dart
  /// "1/2".tryParseAmount();     // 0.5
  /// "2 1/4".tryParseAmount();   // 2.25
  /// "1.5".tryParseAmount();     // 1.5
  /// "invalid".tryParseAmount(); // null
  /// ```
  double? tryParseAmount() {
    final trimmed = trim();
    if (trimmed.isEmpty) return null;

    // Handle fractions like "1/2"
    if (trimmed.contains('/')) {
      final parts = trimmed.split('/');
      if (parts.length == 2) {
        final numerator = double.tryParse(parts[0].trim());
        final denominator = double.tryParse(parts[1].trim());
        if (numerator != null && denominator != null && denominator != 0) {
          return numerator / denominator;
        }
      }
    }

    // Handle mixed numbers like "1 1/2"
    if (trimmed.contains(' ')) {
      final parts = trimmed.split(' ');
      if (parts.length == 2) {
        final whole = double.tryParse(parts[0].trim());
        final fraction = parts[1].tryParseAmount();
        if (whole != null && fraction != null) {
          return whole + fraction;
        }
      }
    }

    // Handle regular decimals
    return double.tryParse(trimmed);
  }
}
