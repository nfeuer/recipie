import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/rating_model.dart';
import 'package:recipe_app/data/repositories/rating_repository.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';

// Rating Repository Provider
final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository();
});

// Recipe Ratings Stream Provider
final recipeRatingsStreamProvider = StreamProvider.family<List<RatingModel>, String>((ref, recipeId) {
  final ratingRepository = ref.watch(ratingRepositoryProvider);
  return ratingRepository.getRecipeRatingsStream(recipeId);
});

// Recipe Rating Stats Provider
final recipeRatingStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, recipeId) async {
  final ratingRepository = ref.watch(ratingRepositoryProvider);
  return ratingRepository.getRecipeRatingStats(recipeId);
});

// User Rating for Recipe Provider
final userRatingForRecipeProvider = FutureProvider.family<RatingModel?, ({String recipeId, String userId})>((ref, params) async {
  final ratingRepository = ref.watch(ratingRepositoryProvider);
  return ratingRepository.getUserRatingForRecipe(params.recipeId, params.userId);
});

// Current User Rating for Recipe Provider
final currentUserRatingProvider = FutureProvider.family<RatingModel?, String>((ref, recipeId) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return null;

  final ratingRepository = ref.watch(ratingRepositoryProvider);
  return ratingRepository.getUserRatingForRecipe(recipeId, currentUser.uid);
});
