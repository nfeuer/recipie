import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/user_model.dart';
import 'package:recipe_app/data/repositories/user_repository.dart';
import 'package:recipe_app/data/services/firebase_service.dart';
import 'package:recipe_app/data/services/auth_service.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';

// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// User Profile Provider - fetches a user by ID
final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserById(userId);
});

// User Profile Stream Provider - real-time updates
final userProfileStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserStream(userId);
});

// Current User Profile Provider
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  if (currentUser == null) {
    return Stream.value(null);
  }

  return userRepository.getUserStream(currentUser.uid);
});

// Followers List Provider
final followersProvider = FutureProvider.family<List<UserModel>, String>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final followerIds = await userRepository.getFollowers(userId);

  // Fetch user details for each follower
  final followers = <UserModel>[];
  for (final id in followerIds) {
    final user = await userRepository.getUserById(id);
    if (user != null) {
      followers.add(user);
    }
  }
  return followers;
});

// Following List Provider
final followingProvider = FutureProvider.family<List<UserModel>, String>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final followingIds = await userRepository.getFollowing(userId);

  // Fetch user details for each user being followed
  final following = <UserModel>[];
  for (final id in followingIds) {
    final user = await userRepository.getUserById(id);
    if (user != null) {
      following.add(user);
    }
  }
  return following;
});

// Is Following Provider - checks if current user follows another user
final isFollowingProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return false;

  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.isFollowing(currentUser.uid, userId);
});

// Search Users Provider
final searchUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];

  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.searchUsers(query);
});
