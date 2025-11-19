/// Utility class for converting cooking measurement units
class UnitConversion {
  // Volume conversions (to milliliters as base)
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

  // Weight conversions (to grams as base)
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

  /// Convert from one volume unit to another
  static double? convertVolume(double amount, String fromUnit, String toUnit) {
    final from = fromUnit.toLowerCase().trim();
    final to = toUnit.toLowerCase().trim();

    final fromML = _volumeToML[from];
    final toML = _volumeToML[to];

    if (fromML == null || toML == null) return null;

    final amountInML = amount * fromML;
    return amountInML / toML;
  }

  /// Convert from one weight unit to another
  static double? convertWeight(double amount, String fromUnit, String toUnit) {
    final from = fromUnit.toLowerCase().trim();
    final to = toUnit.toLowerCase().trim();

    final fromGrams = _weightToGrams[from];
    final toGrams = _weightToGrams[to];

    if (fromGrams == null || toGrams == null) return null;

    final amountInGrams = amount * fromGrams;
    return amountInGrams / toGrams;
  }

  /// Automatically convert between units (tries both volume and weight)
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

/// Extension on String to make amount parsing easier
extension AmountParsing on String {
  /// Try to parse a string amount like "1/2", "1.5", "2 1/4", etc.
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
