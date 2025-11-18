import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/data/models/made_it_model.dart';

class MadeItRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create "I Made This" post
  Future<void> createPost(MadeItModel post) async {
    try {
      await _firestore
          .collection(FirebaseCollections.madeIt)
          .doc(post.postId)
          .set(post.toFirestore());
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Get posts for a recipe (stream)
  Stream<List<MadeItModel>> getRecipePostsStream(String recipeId) {
    return _firestore
        .collection(FirebaseCollections.madeIt)
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MadeItModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get user's posts (stream)
  Stream<List<MadeItModel>> getUserPostsStream(String userId) {
    return _firestore
        .collection(FirebaseCollections.madeIt)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MadeItModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get single post
  Future<MadeItModel?> getPost(String postId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.madeIt)
          .doc(postId)
          .get();

      if (!doc.exists) return null;
      return MadeItModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  // Update post
  Future<void> updatePost(MadeItModel post) async {
    try {
      await _firestore
          .collection(FirebaseCollections.madeIt)
          .doc(post.postId)
          .update(post.toFirestore());
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.madeIt)
          .doc(postId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Toggle like on a post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final docRef = _firestore
          .collection(FirebaseCollections.madeIt)
          .doc(postId);

      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('Post not found');
      }

      final post = MadeItModel.fromFirestore(doc);
      List<String> updatedLikes = List.from(post.likes);

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

  // Get posts from followed users (for feed)
  Stream<List<MadeItModel>> getFeedPostsStream(List<String> userIds) {
    if (userIds.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection(FirebaseCollections.madeIt)
        .where('userId', whereIn: userIds)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MadeItModel.fromFirestore(doc))
          .toList();
    });
  }
}
