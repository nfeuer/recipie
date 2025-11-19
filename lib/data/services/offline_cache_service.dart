import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/data/models/user_model.dart';

/// Service for caching data offline
class OfflineCacheService {
  static const String _recipeCachePrefix = 'cached_recipe_';
  static const String _userCachePrefix = 'cached_user_';
  static const String _savedRecipesKey = 'saved_recipes_offline';
  static const String _recentRecipesKey = 'recent_recipes';
  static const int _maxRecentRecipes = 50;

  // Cache a recipe for offline access
  Future<void> cacheRecipe(RecipeModel recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_recipeCachePrefix${recipe.recipeId}';

    // Convert recipe to JSON string
    final jsonString = jsonEncode(recipe.toFirestore());
    await prefs.setString(key, jsonString);

    // Add to recent recipes list
    await _addToRecentRecipes(recipe.recipeId);
  }

  // Get cached recipe
  Future<RecipeModel?> getCachedRecipe(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_recipeCachePrefix$recipeId';
    final jsonString = prefs.getString(key);

    if (jsonString == null) return null;

    try {
      jsonDecode(jsonString) as Map<String, dynamic>;
      // Note: This is a simplified version - RecipeModel needs a fromJson constructor
      // For now, return null as placeholder
      return null; // TODO: Implement RecipeModel.fromJson
    } catch (e) {
      return null;
    }
  }

  // Save recipe for offline (user explicitly saved)
  Future<void> saveRecipeOffline(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_savedRecipesKey) ?? [];

    if (!saved.contains(recipeId)) {
      saved.add(recipeId);
      await prefs.setStringList(_savedRecipesKey, saved);
    }
  }

  // Remove recipe from offline saved list
  Future<void> unsaveRecipeOffline(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_savedRecipesKey) ?? [];

    saved.remove(recipeId);
    await prefs.setStringList(_savedRecipesKey, saved);
  }

  // Get all saved recipe IDs
  Future<List<String>> getSavedRecipeIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedRecipesKey) ?? [];
  }

  // Get all saved recipes
  Future<List<RecipeModel>> getSavedRecipes() async {
    final savedIds = await getSavedRecipeIds();
    final recipes = <RecipeModel>[];

    for (final id in savedIds) {
      final recipe = await getCachedRecipe(id);
      if (recipe != null) {
        recipes.add(recipe);
      }
    }

    return recipes;
  }

  // Check if recipe is saved offline
  Future<bool> isRecipeSavedOffline(String recipeId) async {
    final savedIds = await getSavedRecipeIds();
    return savedIds.contains(recipeId);
  }

  // Add to recent recipes (for auto-caching)
  Future<void> _addToRecentRecipes(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(_recentRecipesKey) ?? [];

    // Remove if already exists (will re-add at front)
    recent.remove(recipeId);

    // Add to front
    recent.insert(0, recipeId);

    // Limit size
    if (recent.length > _maxRecentRecipes) {
      // Remove oldest and clear their cache
      final toRemove = recent.sublist(_maxRecentRecipes);
      for (final id in toRemove) {
        await clearRecipeCache(id);
      }
      recent.removeRange(_maxRecentRecipes, recent.length);
    }

    await prefs.setStringList(_recentRecipesKey, recent);
  }

  // Get recent recipe IDs
  Future<List<String>> getRecentRecipeIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentRecipesKey) ?? [];
  }

  // Clear specific recipe cache
  Future<void> clearRecipeCache(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_recipeCachePrefix$recipeId';
    await prefs.remove(key);
  }

  // Clear all recipe caches
  Future<void> clearAllRecipeCaches() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_recipeCachePrefix)) {
        await prefs.remove(key);
      }
    }

    await prefs.remove(_recentRecipesKey);
    await prefs.remove(_savedRecipesKey);
  }

  // Cache user profile
  Future<void> cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_userCachePrefix${user.uid}';
    final jsonString = jsonEncode(user.toFirestore());
    await prefs.setString(key, jsonString);
  }

  // Get cached user
  Future<UserModel?> getCachedUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_userCachePrefix$userId';
    final jsonString = prefs.getString(key);

    if (jsonString == null) return null;

    try {
      jsonDecode(jsonString) as Map<String, dynamic>;
      // Note: This would need a fromJson constructor in UserModel
      // For now, this is a placeholder
      return null; // TODO: Implement UserModel.fromJson
    } catch (e) {
      return null;
    }
  }

  // Get cache size (number of cached recipes)
  Future<int> getCacheSize() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys.where((key) => key.startsWith(_recipeCachePrefix)).length;
  }

  // Get total cache storage estimate (in bytes)
  Future<int> getCacheStorageSize() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    int totalSize = 0;

    for (final key in keys) {
      if (key.startsWith(_recipeCachePrefix) ||
          key.startsWith(_userCachePrefix)) {
        final value = prefs.getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }
    }

    return totalSize;
  }
}
