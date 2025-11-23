/// Recipe Ingredient Scaling Utilities
///
/// This file provides utilities for scaling recipe ingredients based on serving size.
/// It handles:
/// - Proportional ingredient amount scaling
/// - Fractional amount formatting (1/2, 3/4, etc.)
/// - Cooking time approximation
/// - Cost scaling
/// - Serving size suggestions
///
/// Key features:
/// - Smart fraction conversion for readable amounts
/// - Non-linear time scaling (cooking time doesn't scale proportionally)
/// - Flexible amount parsing (supports "1/2", "1.5", "2 1/4" formats)
///
/// Usage:
/// ```dart
/// final scaledRecipe = IngredientScaling.scaleRecipe(recipe, newServings: 8);
/// final suggestions = IngredientScaling.getScalingSuggestions(currentServings);
/// ```
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/core/utils/unit_conversion.dart';

/// Provides utilities for scaling recipe ingredients proportionally.
///
/// This class handles the mathematical scaling of recipe ingredients when
/// changing serving sizes, ensuring amounts are displayed in user-friendly
/// formats (fractions when appropriate).
class IngredientScaling {
  /// Scales all ingredients in a list by the given factor.
  ///
  /// [ingredients] The original list of ingredients to scale.
  /// [scalingFactor] The multiplier (e.g., 2.0 doubles all amounts, 0.5 halves them).
  ///
  /// Returns a new list of ingredients with scaled amounts.
  ///
  /// Example:
  /// ```dart
  /// // Double a recipe
  /// final doubled = scaleIngredients(ingredients, 2.0);
  /// ```
  static List<Ingredient> scaleIngredients(
    List<Ingredient> ingredients,
    double scalingFactor,
  ) {
    return ingredients.map((ingredient) {
      final scaledAmount = _scaleAmount(ingredient.amount, scalingFactor);
      return ingredient.copyWith(amount: scaledAmount);
    }).toList();
  }

  /// Scales an entire recipe to a new serving size.
  ///
  /// [recipe] The original recipe to scale.
  /// [newServings] The target number of servings.
  ///
  /// Returns a new [RecipeModel] with scaled ingredients and updated serving count.
  /// If either the original or new servings is 0, returns the recipe unchanged.
  ///
  /// Example:
  /// ```dart
  /// // Scale a 4-serving recipe to 8 servings
  /// final scaled = scaleRecipe(recipe, 8);
  /// ```
  static RecipeModel scaleRecipe(RecipeModel recipe, int newServings) {
    if (recipe.servings == 0 || newServings == 0) {
      return recipe; // Can't scale if servings is 0
    }

    final scalingFactor = newServings / recipe.servings;

    final scaledIngredients = scaleIngredients(
      recipe.ingredients,
      scalingFactor,
    );

    return recipe.copyWith(
      ingredients: scaledIngredients,
      servings: newServings,
    );
  }

  /// Scales a single ingredient amount string.
  ///
  /// [amount] The original amount as a string (e.g., "1/2", "1.5", "2 1/4").
  /// [factor] The scaling multiplier.
  ///
  /// Returns the scaled amount as a formatted string.
  /// If the amount can't be parsed, returns the original string unchanged.
  ///
  /// This method is internal and handles the parsing, scaling, and
  /// re-formatting of individual ingredient amounts.
  static String _scaleAmount(String? amount, double factor) {
    if (amount == null || amount.isEmpty) return '';

    // Try to parse the amount
    final parsedAmount = amount.tryParseAmount();

    if (parsedAmount == null) {
      // Can't parse, return original
      return amount;
    }

    final scaled = parsedAmount * factor;

    // Format the scaled amount
    return _formatScaledAmount(scaled);
  }

  /// Formats a scaled decimal amount into a user-friendly string.
  ///
  /// [amount] The numeric amount to format.
  ///
  /// Returns a formatted string using appropriate precision:
  /// - Very small amounts (< 0.01): 3 decimal places
  /// - Fractional amounts (< 1): Common fractions (1/2, 1/4, etc.) or 2 decimals
  /// - Small amounts (< 10): 1 decimal place
  /// - Large amounts (>= 10): Rounded to nearest integer
  ///
  /// This makes amounts more readable in recipe contexts.
  static String _formatScaledAmount(double amount) {
    // Round to reasonable precision
    if (amount < 0.01) {
      return amount.toStringAsFixed(3);
    } else if (amount < 1) {
      // Try to convert to common fractions
      return _toFraction(amount) ?? amount.toStringAsFixed(2);
    } else if (amount < 10) {
      // Show one decimal place
      return amount.toStringAsFixed(1);
    } else {
      // Round to nearest integer for large amounts
      return amount.round().toString();
    }
  }

  /// Attempts to convert a decimal value to a common fraction string.
  ///
  /// [decimal] The decimal value to convert (e.g., 0.5, 0.25).
  ///
  /// Returns a fraction string (e.g., "1/2", "3/4") if the decimal closely
  /// matches a common cooking fraction (within 0.01 tolerance).
  /// Returns null if no close match is found.
  ///
  /// Supported fractions: 1/8, 1/4, 1/3, 3/8, 1/2, 5/8, 2/3, 3/4, 7/8
  static String? _toFraction(double decimal) {
    final commonFractions = <double, String>{
      0.125: '1/8',
      0.25: '1/4',
      0.333: '1/3',
      0.375: '3/8',
      0.5: '1/2',
      0.625: '5/8',
      0.666: '2/3',
      0.75: '3/4',
      0.875: '7/8',
    };

    // Find closest fraction within 0.01 tolerance
    for (final entry in commonFractions.entries) {
      if ((decimal - entry.key).abs() < 0.01) {
        return entry.value;
      }
    }

    return null;
  }

  /// Generates a list of suggested serving sizes for recipe scaling.
  ///
  /// [currentServings] The current number of servings in the recipe.
  ///
  /// Returns a sorted list of suggested serving sizes including:
  /// - Half the current servings (if > 2)
  /// - The current servings
  /// - 2x and 3x the current servings
  /// - Common serving sizes (2, 4, 6, 8, 10, 12)
  ///
  /// Useful for providing quick scaling options in the UI.
  static List<int> getScalingSuggestions(int currentServings) {
    final suggestions = <int>{};

    // Add halves and doubles
    if (currentServings > 2) {
      suggestions.add((currentServings / 2).round());
    }
    suggestions.add(currentServings);
    suggestions.add(currentServings * 2);
    suggestions.add(currentServings * 3);

    // Add common serving sizes
    suggestions.addAll([2, 4, 6, 8, 10, 12]);

    // Sort and remove duplicates
    final sorted = suggestions.toList()..sort();

    return sorted;
  }

  /// Scales recipe cost proportionally to serving size.
  ///
  /// [baseCost] The original recipe cost (may be null if unavailable).
  /// [scalingFactor] The scaling multiplier.
  ///
  /// Returns the scaled cost, or null if base cost is not available.
  ///
  /// Cost scales linearly with serving size (2x servings = 2x cost).
  static double? scaleCost(double? baseCost, double scalingFactor) {
    if (baseCost == null) return null;
    return baseCost * scalingFactor;
  }

  /// Scales cooking time using non-linear approximation.
  ///
  /// [minutes] The original cooking time in minutes.
  /// [scalingFactor] The scaling multiplier.
  ///
  /// Returns the estimated scaled cooking time, or null if time is not available.
  ///
  /// **Important**: Cooking time does NOT scale linearly with ingredients.
  /// This method uses direct scaling as an approximation, but in reality,
  /// cooking time typically follows square root scaling:
  /// - 2x ingredients ≈ 1.4x time (sqrt(2))
  /// - 4x ingredients ≈ 2x time (sqrt(4))
  ///
  /// The scaling factor is clamped between 0.1 and 10.0 for safety.
  ///
  /// Note: This is a rough estimate. Users should monitor their food and
  /// adjust timing as needed.
  static int? scaleTime(int? minutes, double scalingFactor) {
    if (minutes == null || minutes == 0) return null;

    // Cooking time doesn't scale linearly in reality, but we use
    // direct scaling as a simple approximation for user convenience
    final scaledMinutes = minutes * scalingFactor.clamp(0.1, 10.0);

    return scaledMinutes.round();
  }
}
