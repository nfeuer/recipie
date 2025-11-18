import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/notification_model.dart';
import 'package:recipe_app/data/repositories/notification_repository.dart';
import 'package:recipe_app/data/services/notification_service.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';

// Notification Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// User Notifications Stream Provider
final userNotificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUserNotificationsStream(currentUser.uid);
});

// Unread Notification Count Stream Provider
final unreadNotificationCountProvider = StreamProvider<int>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) {
    return Stream.value(0);
  }

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCountStream(currentUser.uid);
});
