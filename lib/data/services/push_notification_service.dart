import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/core/constants/app_constants.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize push notifications
  Future<void> initialize() async {
    try {
      // Request permission (iOS only, Android auto-grants)
      final settings = await _requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (kDebugMode) {
          print('User granted notification permission');
        }

        // Get FCM token
        final token = await _messaging.getToken();
        if (token != null && kDebugMode) {
          print('FCM Token: $token');
        }

        // Setup handlers
        _setupHandlers();

        // Setup background handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      } else {
        if (kDebugMode) {
          print('User declined notification permission');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing push notifications: $e');
      }
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Setup message handlers
  void _setupHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background message tap (app opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle initial message if app was terminated
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });

    // Listen to token refresh
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message: ${message.messageId}');
      print('Notification: ${message.notification?.title}');
      print('Data: ${message.data}');
    }

    // The notification will be displayed automatically by the system
    // We can also trigger local handling here if needed
  }

  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('App opened from notification: ${message.messageId}');
      print('Data: ${message.data}');
    }

    // Navigate to relevant screen based on notification data
    // This would typically use a navigation service or router
    final data = message.data;
    final type = data['type'] as String?;
    final targetId = data['targetId'] as String?;

    if (type != null && targetId != null) {
      // TODO: Implement navigation based on type and targetId
      // Examples:
      // - 'recipe' -> Navigate to RecipeDetailScreen(recipeId: targetId)
      // - 'event' -> Navigate to EventDetailScreen(eventId: targetId)
      // - 'user' -> Navigate to UserProfileScreen(userId: targetId)
    }
  }

  /// Handle token refresh
  void _handleTokenRefresh(String newToken) async {
    if (kDebugMode) {
      print('FCM token refreshed: $newToken');
    }
    // Update token in user document
    // This is handled in saveFCMToken method
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  /// Save FCM token to user document
  Future<void> saveFCMToken(String userId) async {
    try {
      final token = await getToken();
      if (token != null) {
        await _firestore
            .collection(FirebaseCollections.users)
            .doc(userId)
            .update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          print('FCM token saved for user: $userId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }

  /// Remove FCM token from user document (on logout)
  Future<void> removeFCMToken(String userId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(userId)
          .update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });

      if (kDebugMode) {
        print('FCM token removed for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing FCM token: $e');
      }
    }
  }

  /// Delete FCM token locally
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      if (kDebugMode) {
        print('FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting FCM token: $e');
      }
    }
  }

  /// Subscribe to topic (for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
    }
  }
}
