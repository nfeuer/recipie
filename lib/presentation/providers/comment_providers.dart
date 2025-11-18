import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/comment_model.dart';
import 'package:recipe_app/data/repositories/comment_repository.dart';

// Comment Repository Provider
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});

// Recipe Comments Stream Provider
final recipeCommentsStreamProvider = StreamProvider.family<List<CommentModel>, String>((ref, recipeId) {
  final commentRepository = ref.watch(commentRepositoryProvider);
  return commentRepository.getRecipeCommentsStream(recipeId);
});

// Recipe Comments Future Provider
final recipeCommentsProvider = FutureProvider.family<List<CommentModel>, String>((ref, recipeId) async {
  final commentRepository = ref.watch(commentRepositoryProvider);
  return commentRepository.getRecipeComments(recipeId);
});
