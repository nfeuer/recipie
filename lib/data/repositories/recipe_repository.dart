import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/data/models/recipe_model.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create recipe
  Future<String> createRecipe(RecipeModel recipe) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseCollections.recipes)
          .add(recipe.toFirestore());

      // Update the recipe with its ID
      await docRef.update({'recipeId': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create recipe: $e');
    }
  }

  // Get recipe by ID
  Future<RecipeModel?> getRecipeById(String recipeId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.recipes)
          .doc(recipeId)
          .get();

      if (!doc.exists) return null;
      return RecipeModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get recipe: $e');
    }
  }

  // Get recipe stream
  Stream<RecipeModel?> getRecipeStream(String recipeId) {
    return _firestore
        .collection(FirebaseCollections.recipes)
        .doc(recipeId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return RecipeModel.fromFirestore(doc);
    });
  }

  // Update recipe
  Future<void> updateRecipe(RecipeModel recipe) async {
    try {
      await _firestore
          .collection(FirebaseCollections.recipes)
          .doc(recipe.recipeId)
          .update(recipe.toFirestore());
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  // Delete recipe
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.recipes)
          .doc(recipeId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  // Get user recipes
  Future<List<RecipeModel>> getUserRecipes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.recipes)
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user recipes: $e');
    }
  }

  // Get public recipes
  Future<List<RecipeModel>> getPublicRecipes({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.recipes)
          .where('privacy', isEqualTo: 'public')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get public recipes: $e');
    }
  }

  // Get recipes by dietary tags
  Future<List<RecipeModel>> getRecipesByDietaryTags(
    List<String> tags, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.recipes)
          .where('privacy', isEqualTo: 'public')
          .where('dietaryTags', arrayContainsAny: tags)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get recipes by dietary tags: $e');
    }
  }

  // Search recipes
  Future<List<RecipeModel>> searchRecipes(String query) async {
    try {
      // Note: Firestore doesn't support full-text search.
      // In production, use Algolia or similar service
      final snapshot = await _firestore
          .collection(FirebaseCollections.recipes)
          .where('privacy', isEqualTo: 'public')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search recipes: $e');
    }
  }

  // Fork recipe
  Future<String> forkRecipe({
    required RecipeModel originalRecipe,
    required String newAuthorId,
    required RecipeModel modifiedRecipe,
  }) async {
    try {
      // Create new recipe with parent reference
      final forkedRecipe = modifiedRecipe.copyWith(
        parentRecipeId: originalRecipe.recipeId,
        attributionChain: [
          ...originalRecipe.attributionChain,
          originalRecipe.authorId,
        ],
      );

      final recipeId = await createRecipe(forkedRecipe);

      // Update parent recipe fork count
      await _firestore
          .collection(FirebaseCollections.recipes)
          .doc(originalRecipe.recipeId)
          .update({
        'forkCount': FieldValue.increment(1),
      });

      return recipeId;
    } catch (e) {
      throw Exception('Failed to fork recipe: $e');
    }
  }

  // Get recipe forks
  Future<List<RecipeModel>> getRecipeForks(String recipeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.recipes)
          .where('parentRecipeId', isEqualTo: recipeId)
          .where('privacy', isEqualTo: 'public')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get recipe forks: $e');
    }
  }

  // Increment made it count
  Future<void> incrementMadeItCount(String recipeId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.recipes)
          .doc(recipeId)
          .update({
        'madeItCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment made it count: $e');
    }
  }

  // Update recipe rating
  Future<void> updateRecipeRating({
    required String recipeId,
    required String userId,
    required double rating,
  }) async {
    try {
      // Add/update user rating
      await _firestore
          .collection(FirebaseCollections.recipes)
          .doc(recipeId)
          .collection(FirebaseCollections.ratings)
          .doc(userId)
          .set({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Calculate average rating
      final ratingsSnapshot = await _firestore
          .collection(FirebaseCollections.recipes)
          .doc(recipeId)
          .collection(FirebaseCollections.ratings)
          .get();

      final ratings = ratingsSnapshot.docs
          .map((doc) => (doc.data()['rating'] as num).toDouble())
          .toList();

      final averageRating =
          ratings.reduce((a, b) => a + b) / ratings.length;

      // Update recipe average rating
      await _firestore
          .collection(FirebaseCollections.recipes)
          .doc(recipeId)
          .update({'averageRating': averageRating});
    } catch (e) {
      throw Exception('Failed to update recipe rating: $e');
    }
  }

  // Get trending recipes
  Future<List<RecipeModel>> getTrendingRecipes({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.recipes)
          .where('privacy', isEqualTo: 'public')
          .orderBy('forkCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get trending recipes: $e');
    }
  }

  // Get top rated recipes
  Future<List<RecipeModel>> getTopRatedRecipes({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.recipes)
          .where('privacy', isEqualTo: 'public')
          .where('averageRating', isGreaterThan: 4.0)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get top rated recipes: $e');
    }
  }
}
