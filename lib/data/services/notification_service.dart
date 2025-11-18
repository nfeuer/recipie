import 'package:uuid/uuid.dart';
import 'package:recipe_app/data/models/notification_model.dart';
import 'package:recipe_app/data/repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository = NotificationRepository();

  // Create event invite notification
  Future<void> notifyEventInvite({
    required String recipientUserId,
    required String eventId,
    required String eventName,
    required String hostName,
  }) async {
    final notification = NotificationModel(
      notificationId: const Uuid().v4(),
      userId: recipientUserId,
      type: NotificationType.eventInvite,
      data: {
        'eventId': eventId,
        'eventName': eventName,
        'hostName': hostName,
      },
      message: '$hostName invited you to $eventName',
      createdAt: DateTime.now(),
    );

    await _repository.createNotification(notification);
  }

  // Create event reminder notification
  Future<void> notifyEventReminder({
    required String userId,
    required String eventId,
    required String eventName,
    required DateTime eventDate,
  }) async {
    final notification = NotificationModel(
      notificationId: const Uuid().v4(),
      userId: userId,
      type: NotificationType.eventReminder,
      data: {
        'eventId': eventId,
        'eventName': eventName,
        'eventDate': eventDate.toIso8601String(),
      },
      message: 'Reminder: $eventName is coming up!',
      createdAt: DateTime.now(),
    );

    await _repository.createNotification(notification);
  }

  // Create new recipe from followed user notification
  Future<void> notifyNewRecipeFromFollowed({
    required String recipientUserId,
    required String recipeId,
    required String recipeName,
    required String authorName,
  }) async {
    final notification = NotificationModel(
      notificationId: const Uuid().v4(),
      userId: recipientUserId,
      type: NotificationType.newRecipeFromFollowed,
      data: {
        'recipeId': recipeId,
        'recipeName': recipeName,
        'authorName': authorName,
      },
      message: '$authorName shared a new recipe: $recipeName',
      createdAt: DateTime.now(),
    );

    await _repository.createNotification(notification);
  }

  // Create comment notification
  Future<void> notifyComment({
    required String recipientUserId,
    required String recipeId,
    required String recipeName,
    required String commenterName,
  }) async {
    final notification = NotificationModel(
      notificationId: const Uuid().v4(),
      userId: recipientUserId,
      type: NotificationType.commentOnRecipe,
      data: {
        'recipeId': recipeId,
        'recipeName': recipeName,
        'commenterName': commenterName,
      },
      message: '$commenterName commented on your recipe: $recipeName',
      createdAt: DateTime.now(),
    );

    await _repository.createNotification(notification);
  }

  // Create "someone made your recipe" notification
  Future<void> notifySomeoneMadeRecipe({
    required String recipientUserId,
    required String recipeId,
    required String recipeName,
    required String makerName,
    required String postId,
  }) async {
    final notification = NotificationModel(
      notificationId: const Uuid().v4(),
      userId: recipientUserId,
      type: NotificationType.someoneMadeYourRecipe,
      data: {
        'recipeId': recipeId,
        'recipeName': recipeName,
        'makerName': makerName,
        'postId': postId,
      },
      message: '$makerName made your recipe: $recipeName',
      createdAt: DateTime.now(),
    );

    await _repository.createNotification(notification);
  }

  // Create recipe fork notification
  Future<void> notifyRecipeFork({
    required String recipientUserId,
    required String originalRecipeId,
    required String originalRecipeName,
    required String forkedRecipeId,
    required String forkerName,
  }) async {
    final notification = NotificationModel(
      notificationId: const Uuid().v4(),
      userId: recipientUserId,
      type: NotificationType.recipeForkCreated,
      data: {
        'originalRecipeId': originalRecipeId,
        'originalRecipeName': originalRecipeName,
        'forkedRecipeId': forkedRecipeId,
        'forkerName': forkerName,
      },
      message: '$forkerName forked your recipe: $originalRecipeName',
      createdAt: DateTime.now(),
    );

    await _repository.createNotification(notification);
  }

  // Create recipe request notification
  Future<void> notifyRecipeRequest({
    required String recipientUserId,
    required String recipeId,
    required String recipeName,
    required String requesterName,
    required String eventId,
  }) async {
    final notification = NotificationModel(
      notificationId: const Uuid().v4(),
      userId: recipientUserId,
      type: NotificationType.recipeRequested,
      data: {
        'recipeId': recipeId,
        'recipeName': recipeName,
        'requesterName': requesterName,
        'eventId': eventId,
      },
      message: '$requesterName requested your recipe: $recipeName',
      createdAt: DateTime.now(),
    );

    await _repository.createNotification(notification);
  }
}
