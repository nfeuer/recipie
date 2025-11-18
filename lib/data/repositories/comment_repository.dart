import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/data/models/comment_model.dart';

class CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create comment
  Future<void> createComment(CommentModel comment) async {
    try {
      await _firestore
          .collection(FirebaseCollections.comments)
          .doc(comment.commentId)
          .set(comment.toFirestore());
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  // Get comments for a recipe (stream)
  Stream<List<CommentModel>> getRecipeCommentsStream(String recipeId) {
    return _firestore
        .collection(FirebaseCollections.comments)
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get comments for a recipe (future)
  Future<List<CommentModel>> getRecipeComments(String recipeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.comments)
          .where('recipeId', isEqualTo: recipeId)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  // Update comment
  Future<void> updateComment(CommentModel comment) async {
    try {
      await _firestore
          .collection(FirebaseCollections.comments)
          .doc(comment.commentId)
          .update(comment.toFirestore());
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  // Delete comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.comments)
          .doc(commentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  // Like/unlike comment
  Future<void> toggleLike(String commentId, String userId) async {
    try {
      final docRef = _firestore
          .collection(FirebaseCollections.comments)
          .doc(commentId);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('Comment not found');
      }

      final comment = CommentModel.fromFirestore(doc);
      List<String> updatedLikes = List.from(comment.likes);

      if (updatedLikes.contains(userId)) {
        updatedLikes.remove(userId);
      } else {
        updatedLikes.add(userId);
      }

      await docRef.update({'likes': updatedLikes});
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Delete all comments for a recipe
  Future<void> deleteRecipeComments(String recipeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.comments)
          .where('recipeId', isEqualTo: recipeId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete recipe comments: $e');
    }
  }
}
