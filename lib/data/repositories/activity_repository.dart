import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/data/models/activity_model.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create activity
  Future<void> createActivity(ActivityModel activity) async {
    try {
      await _firestore
          .collection(FirebaseCollections.activities)
          .doc(activity.activityId)
          .set(activity.toFirestore());
    } catch (e) {
      throw Exception('Failed to create activity: $e');
    }
  }

  // Get activity stream for a user's feed (activities from users they follow)
  Stream<List<ActivityModel>> getFeedStream(List<String> followingIds) {
    if (followingIds.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection(FirebaseCollections.activities)
        .where('userId', whereIn: followingIds)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get user's own activities
  Stream<List<ActivityModel>> getUserActivitiesStream(String userId) {
    return _firestore
        .collection(FirebaseCollections.activities)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get activities for a specific recipe
  Stream<List<ActivityModel>> getRecipeActivitiesStream(String recipeId) {
    return _firestore
        .collection(FirebaseCollections.activities)
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get recent activities (public feed)
  Future<List<ActivityModel>> getRecentActivities({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.activities)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ActivityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent activities: $e');
    }
  }

  // Delete activity
  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.activities)
          .doc(activityId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  // Delete all activities for a user
  Future<void> deleteUserActivities(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.activities)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user activities: $e');
    }
  }

  // Delete all activities for a recipe
  Future<void> deleteRecipeActivities(String recipeId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.activities)
          .where('recipeId', isEqualTo: recipeId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete recipe activities: $e');
    }
  }
}
