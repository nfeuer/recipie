import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/data/repositories/recipe_repository.dart';
import 'package:recipe_app/data/services/storage_service.dart';

// Recipe Repository Provider
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository();
});

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// User Recipes Provider
final userRecipesProvider = FutureProvider.family<List<RecipeModel>, String>((ref, userId) async {
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getUserRecipes(userId);
});

// All Recipes Provider (for search/filtering)
final allRecipesProvider = FutureProvider<List<RecipeModel>>((ref) async {
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getPublicRecipes(limit: 100);
});

// Public Recipes Provider
final publicRecipesProvider = FutureProvider<List<RecipeModel>>((ref) async {
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getPublicRecipes(limit: 20);
});

// Trending Recipes Provider
final trendingRecipesProvider = FutureProvider<List<RecipeModel>>((ref) async {
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getTrendingRecipes(limit: 20);
});

// Top Rated Recipes Provider
final topRatedRecipesProvider = FutureProvider<List<RecipeModel>>((ref) async {
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getTopRatedRecipes(limit: 20);
});

// Single Recipe Provider
final recipeProvider = StreamProvider.family<RecipeModel?, String>((ref, recipeId) {
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getRecipeStream(recipeId);
});

// Recipe Search Provider
final recipeSearchProvider = FutureProvider.family<List<RecipeModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.searchRecipes(query);
});

// Recipe Forks Provider
final recipeForksProvider = FutureProvider.family<List<RecipeModel>, String>((ref, recipeId) async {
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getRecipeForks(recipeId);
});

// Dietary Tags Filter Provider
final recipesbyDietaryTagsProvider = FutureProvider.family<List<RecipeModel>, List<String>>((ref, tags) async {
  if (tags.isEmpty) return [];
  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getRecipesByDietaryTags(tags, limit: 20);
});
