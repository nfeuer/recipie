import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/data/models/rating_model.dart';

class RatingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update rating
  Future<void> setRating(RatingModel rating) async {
    try {
      await _firestore
          .collection(FirebaseCollections.ratings)
          .doc(rating.ratingId)
          .set(rating.toFirestore());
    } catch (e) {
      throw Exception('Failed to set rating: $e');
    }
  }

  // Get rating by user for a recipe
  Future<RatingModel?> getUserRatingForRecipe(String recipeId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.ratings)
          .where('recipeId', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return RatingModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get user rating: $e');
    }
  }

  // Get all ratings for a recipe (stream)
  Stream<List<RatingModel>> getRecipeRatingsStream(String recipeId) {
    return _firestore
        .collection(FirebaseCollections.ratings)
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RatingModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all ratings for a recipe (future)
  Future<List<RatingModel>> getRecipeRatings(String recipeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.ratings)
          .where('recipeId', isEqualTo: recipeId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RatingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get ratings: $e');
    }
  }

  // Calculate average rating for a recipe
  Future<Map<String, dynamic>> getRecipeRatingStats(String recipeId) async {
    try {
      final ratings = await getRecipeRatings(recipeId);

      if (ratings.isEmpty) {
        return {
          'average': 0.0,
          'count': 0,
          'distribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      final sum = ratings.fold<int>(0, (sum, rating) => sum + rating.rating);
      final average = sum / ratings.length;

      final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final rating in ratings) {
        distribution[rating.rating] = (distribution[rating.rating] ?? 0) + 1;
      }

      return {
        'average': average,
        'count': ratings.length,
        'distribution': distribution,
      };
    } catch (e) {
      throw Exception('Failed to get rating stats: $e');
    }
  }

  // Delete rating
  Future<void> deleteRating(String ratingId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.ratings)
          .doc(ratingId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete rating: $e');
    }
  }

  // Delete all ratings for a recipe
  Future<void> deleteRecipeRatings(String recipeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.ratings)
          .where('recipeId', isEqualTo: recipeId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete recipe ratings: $e');
    }
  }
}
