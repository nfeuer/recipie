import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/activity_model.dart';
import 'package:recipe_app/data/repositories/activity_repository.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/user_providers.dart';

// Activity Repository Provider
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

// Feed Stream Provider - shows activities from users the current user follows
final feedStreamProvider = StreamProvider<List<ActivityModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) {
    return Stream.value([]);
  }

  // Get list of users the current user is following
  final followingFuture = ref.watch(followingProvider(currentUser.uid).future);

  return Stream.fromFuture(followingFuture).asyncExpand((following) {
    final followingIds = following.map((user) => user.uid).toList();

    // Add current user's ID to also show their own activities
    if (!followingIds.contains(currentUser.uid)) {
      followingIds.add(currentUser.uid);
    }

    final activityRepository = ref.watch(activityRepositoryProvider);
    return activityRepository.getFeedStream(followingIds);
  });
});

// User Activities Stream Provider - shows a specific user's activities
final userActivitiesStreamProvider = StreamProvider.family<List<ActivityModel>, String>((ref, userId) {
  final activityRepository = ref.watch(activityRepositoryProvider);
  return activityRepository.getUserActivitiesStream(userId);
});

// Recipe Activities Stream Provider - shows activities related to a specific recipe
final recipeActivitiesStreamProvider = StreamProvider.family<List<ActivityModel>, String>((ref, recipeId) {
  final activityRepository = ref.watch(activityRepositoryProvider);
  return activityRepository.getRecipeActivitiesStream(recipeId);
});

// Recent Activities Provider - public feed of recent activities
final recentActivitiesProvider = FutureProvider<List<ActivityModel>>((ref) {
  final activityRepository = ref.watch(activityRepositoryProvider);
  return activityRepository.getRecentActivities();
});
