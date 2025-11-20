import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/data/repositories/recipe_repository.dart';
import 'package:recipe_app/data/services/storage_service.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';

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
  // Debug mode bypass - return test recipes for debug user
  if (kDebugMode && kUseDebugUser && userId == 'debug-test-user-123') {
    return _getDebugRecipes();
  }

  final recipeRepository = ref.watch(recipeRepositoryProvider);
  return recipeRepository.getUserRecipes(userId);
});

// Debug recipes for testing
List<RecipeModel> _getDebugRecipes() {
  final now = DateTime.now();
  return [
    RecipeModel(
      recipeId: 'debug-recipe-1',
      authorId: 'debug-test-user-123',
      title: 'Classic Margherita Pizza',
      description: 'A simple and delicious pizza with fresh mozzarella, tomatoes, and basil.',
      ingredients: [
        Ingredient(name: 'Pizza dough', amount: '1', unit: 'ball'),
        Ingredient(name: 'Tomato sauce', amount: '1/2', unit: 'cup'),
        Ingredient(name: 'Fresh mozzarella', amount: '8', unit: 'oz'),
        Ingredient(name: 'Fresh basil', amount: '10', unit: 'leaves'),
        Ingredient(name: 'Olive oil', amount: '2', unit: 'tbsp'),
      ],
      steps: [
        RecipeStep(order: 0, instruction: 'Preheat oven to 475°F (245°C).'),
        RecipeStep(order: 1, instruction: 'Roll out pizza dough on a floured surface.'),
        RecipeStep(order: 2, instruction: 'Spread tomato sauce evenly over the dough.'),
        RecipeStep(order: 3, instruction: 'Add torn mozzarella pieces on top.'),
        RecipeStep(order: 4, instruction: 'Bake for 12-15 minutes until crust is golden.'),
        RecipeStep(order: 5, instruction: 'Top with fresh basil and drizzle with olive oil.'),
      ],
      prepTime: 20,
      cookTime: 15,
      servings: 4,
      difficulty: 'Medium',
      dietaryTags: ['vegetarian'],
      tags: ['italian', 'pizza', 'dinner'],
      privacy: RecipePrivacy.public,
      createdAt: now,
      updatedAt: now,
    ),
    RecipeModel(
      recipeId: 'debug-recipe-2',
      authorId: 'debug-test-user-123',
      title: 'Quinoa Buddha Bowl',
      description: 'A healthy and colorful bowl packed with nutrients.',
      ingredients: [
        Ingredient(name: 'Quinoa', amount: '1', unit: 'cup'),
        Ingredient(name: 'Chickpeas', amount: '1', unit: 'can'),
        Ingredient(name: 'Sweet potato', amount: '1', unit: 'large'),
        Ingredient(name: 'Kale', amount: '2', unit: 'cups'),
        Ingredient(name: 'Tahini', amount: '3', unit: 'tbsp'),
        Ingredient(name: 'Lemon juice', amount: '2', unit: 'tbsp'),
      ],
      steps: [
        RecipeStep(order: 0, instruction: 'Cook quinoa according to package instructions.'),
        RecipeStep(order: 1, instruction: 'Roast diced sweet potato at 400°F for 25 minutes.'),
        RecipeStep(order: 2, instruction: 'Sauté kale until wilted.'),
        RecipeStep(order: 3, instruction: 'Drain and rinse chickpeas.'),
        RecipeStep(order: 4, instruction: 'Mix tahini and lemon juice for dressing.'),
        RecipeStep(order: 5, instruction: 'Assemble bowl with all ingredients and drizzle with dressing.'),
      ],
      prepTime: 15,
      cookTime: 30,
      servings: 2,
      difficulty: 'Easy',
      dietaryTags: ['vegan', 'gluten-free', 'healthy'],
      tags: ['bowl', 'lunch', 'healthy'],
      privacy: RecipePrivacy.public,
      createdAt: now,
      updatedAt: now,
    ),
    RecipeModel(
      recipeId: 'debug-recipe-3',
      authorId: 'debug-test-user-123',
      title: 'Chocolate Chip Cookies',
      description: 'Soft and chewy cookies with plenty of chocolate chips.',
      ingredients: [
        Ingredient(name: 'Butter', amount: '1', unit: 'cup'),
        Ingredient(name: 'Brown sugar', amount: '1', unit: 'cup'),
        Ingredient(name: 'White sugar', amount: '1/2', unit: 'cup'),
        Ingredient(name: 'Eggs', amount: '2', unit: 'large'),
        Ingredient(name: 'Vanilla extract', amount: '2', unit: 'tsp'),
        Ingredient(name: 'All-purpose flour', amount: '2 1/4', unit: 'cups'),
        Ingredient(name: 'Baking soda', amount: '1', unit: 'tsp'),
        Ingredient(name: 'Salt', amount: '1', unit: 'tsp'),
        Ingredient(name: 'Chocolate chips', amount: '2', unit: 'cups'),
      ],
      steps: [
        RecipeStep(order: 0, instruction: 'Preheat oven to 375°F (190°C).'),
        RecipeStep(order: 1, instruction: 'Cream together butter and sugars until fluffy.'),
        RecipeStep(order: 2, instruction: 'Beat in eggs and vanilla.'),
        RecipeStep(order: 3, instruction: 'Mix flour, baking soda, and salt in a separate bowl.'),
        RecipeStep(order: 4, instruction: 'Gradually blend dry ingredients into butter mixture.'),
        RecipeStep(order: 5, instruction: 'Stir in chocolate chips.'),
        RecipeStep(order: 6, instruction: 'Drop rounded tablespoons onto baking sheets.'),
        RecipeStep(order: 7, instruction: 'Bake for 9-11 minutes until golden brown.'),
      ],
      prepTime: 15,
      cookTime: 10,
      servings: 48,
      difficulty: 'Easy',
      dietaryTags: ['vegetarian'],
      tags: ['dessert', 'cookies', 'baking'],
      privacy: RecipePrivacy.public,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

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
