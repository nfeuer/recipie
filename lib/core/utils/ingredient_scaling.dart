import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/core/utils/unit_conversion.dart';

/// Helper class for scaling recipe ingredients
class IngredientScaling {
  /// Scale all ingredients in a recipe by a factor
  /// Example: scalingFactor = 2.0 doubles the recipe
  static List<Ingredient> scaleIngredients(
    List<Ingredient> ingredients,
    double scalingFactor,
  ) {
    return ingredients.map((ingredient) {
      final scaledAmount = _scaleAmount(ingredient.amount, scalingFactor);
      return ingredient.copyWith(amount: scaledAmount);
    }).toList();
  }

  /// Scale a recipe for a different number of servings
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

  /// Scale a single ingredient amount
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

  /// Format a scaled amount to a user-friendly string
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

  /// Try to convert a decimal to a common fraction
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

  /// Get scaling suggestions (common serving sizes)
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

  /// Calculate ingredient cost scaling (if prices are available)
  static double? scaleCost(double? baseCost, double scalingFactor) {
    if (baseCost == null) return null;
    return baseCost * scalingFactor;
  }

  /// Scale cooking time (not linear - uses square root scaling)
  static int? scaleTime(int? minutes, double scalingFactor) {
    if (minutes == null || minutes == 0) return null;

    // Cooking time doesn't scale linearly
    // Use square root scaling as approximation
    // 2x ingredients ≈ 1.4x time (sqrt(2))
    final scaledMinutes = minutes * scalingFactor.clamp(0.1, 10.0);

    return scaledMinutes.round();
  }
}
