import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/user_model.dart';
import 'package:recipe_app/data/repositories/user_repository.dart';
import 'package:recipe_app/data/services/auth_service.dart';

// Debug mode flag - set to true to use test user without Firebase
const bool kUseDebugUser = true;

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Current Firebase User Provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Current User Model Provider
// In debug mode with kUseDebugUser=true, returns a test user without Firebase
final currentUserModelProvider = StreamProvider<UserModel?>((ref) {
  // Debug mode bypass - return test user
  if (kDebugMode && kUseDebugUser) {
    return Stream.value(UserModel.debugTestUser);
  }

  // Production mode - use Firebase authentication
  final currentUser = ref.watch(currentUserProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final userRepository = ref.watch(userRepositoryProvider);
      return userRepository.getUserStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
