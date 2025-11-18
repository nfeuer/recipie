import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get user stream
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(FirebaseCollections.users)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // Create user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Follow user
  Future<void> followUser(String followerId, String followedId) async {
    try {
      final batch = _firestore.batch();

      // Add to follower's following list
      batch.set(
        _firestore
            .collection(FirebaseCollections.following)
            .doc(followerId)
            .collection('userFollowing')
            .doc(followedId),
        {'timestamp': FieldValue.serverTimestamp()},
      );

      // Add to followed user's followers list
      batch.set(
        _firestore
            .collection(FirebaseCollections.following)
            .doc(followedId)
            .collection('userFollowers')
            .doc(followerId),
        {'timestamp': FieldValue.serverTimestamp()},
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  // Unfollow user
  Future<void> unfollowUser(String followerId, String followedId) async {
    try {
      final batch = _firestore.batch();

      // Remove from follower's following list
      batch.delete(
        _firestore
            .collection(FirebaseCollections.following)
            .doc(followerId)
            .collection('userFollowing')
            .doc(followedId),
      );

      // Remove from followed user's followers list
      batch.delete(
        _firestore
            .collection(FirebaseCollections.following)
            .doc(followedId)
            .collection('userFollowers')
            .doc(followerId),
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  // Get followers
  Future<List<String>> getFollowers(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.following)
          .doc(userId)
          .collection('userFollowers')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  // Get following
  Future<List<String>> getFollowing(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.following)
          .doc(userId)
          .collection('userFollowing')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  // Check if following
  Future<bool> isFollowing(String followerId, String followedId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.following)
          .doc(followerId)
          .collection('userFollowing')
          .doc(followedId)
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check following status: $e');
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.users)
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
