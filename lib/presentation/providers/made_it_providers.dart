import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/made_it_model.dart';
import 'package:recipe_app/data/repositories/made_it_repository.dart';

// Made It Repository Provider
final madeItRepositoryProvider = Provider<MadeItRepository>((ref) {
  return MadeItRepository();
});

// Recipe Posts Stream Provider - all "I Made This" posts for a recipe
final recipePostsStreamProvider = StreamProvider.family<List<MadeItModel>, String>((ref, recipeId) {
  final madeItRepository = ref.watch(madeItRepositoryProvider);
  return madeItRepository.getRecipePostsStream(recipeId);
});

// User Posts Stream Provider - all "I Made This" posts by a user
final userPostsStreamProvider = StreamProvider.family<List<MadeItModel>, String>((ref, userId) {
  final madeItRepository = ref.watch(madeItRepositoryProvider);
  return madeItRepository.getUserPostsStream(userId);
});

// Single Post Provider
final madeItPostProvider = FutureProvider.family<MadeItModel?, String>((ref, postId) async {
  final madeItRepository = ref.watch(madeItRepositoryProvider);
  return madeItRepository.getPost(postId);
});
