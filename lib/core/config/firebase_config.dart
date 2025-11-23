/// Firebase Configuration and Initialization
///
/// This file handles the initialization of Firebase services for the Recipe & Event Platform.
/// It configures Firebase for multiple platforms (Web, Android, iOS) and initializes
/// push notification services.
///
/// Key responsibilities:
/// - Platform-specific Firebase initialization
/// - Firebase options configuration for Web, Android, and iOS
/// - Push notification service initialization
///
/// Usage:
/// ```dart
/// await FirebaseConfig.initialize();
/// ```
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:recipe_app/data/services/push_notification_service.dart';

/// Manages Firebase initialization and configuration for all supported platforms.
///
/// This class provides a centralized way to initialize Firebase with the correct
/// configuration options based on the current platform (Web, Android, iOS).
class FirebaseConfig {
  /// Initializes Firebase and required services.
  ///
  /// This method must be called before using any Firebase services in the app.
  /// It performs the following steps:
  /// 1. Initializes Firebase with platform-specific options
  /// 2. Sets up push notification service
  ///
  /// Throws an exception if Firebase initialization fails.
  /// Push notification errors are caught and logged in debug mode.
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: _getFirebaseOptions(),
    );

    // Initialize push notifications for FCM (Firebase Cloud Messaging)
    try {
      final pushNotificationService = PushNotificationService();
      await pushNotificationService.initialize();
    } catch (e) {
      // Non-fatal error: app can continue without push notifications
      if (kDebugMode) {
        print('Error initializing push notifications: $e');
      }
    }
  }

  /// Returns platform-specific Firebase configuration options.
  ///
  /// This method detects the current platform and returns the appropriate
  /// Firebase configuration (API keys, project ID, etc.).
  ///
  /// Supported platforms:
  /// - Web: Browser-based configuration
  /// - Android: Android app configuration
  /// - iOS: iOS app configuration
  ///
  /// Returns [FirebaseOptions] configured for the current platform.
  /// Defaults to Web configuration if platform is not recognized.
  ///
  /// Note: Replace placeholder values (YOUR_*_KEY) with actual Firebase
  /// project credentials from the Firebase Console.
  static FirebaseOptions _getFirebaseOptions() {
    if (kIsWeb) {
      // Web configuration
      return const FirebaseOptions(
        apiKey: 'YOUR_WEB_API_KEY',
        appId: 'YOUR_WEB_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
        authDomain: 'YOUR_AUTH_DOMAIN',
        storageBucket: 'YOUR_STORAGE_BUCKET',
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android configuration
      return const FirebaseOptions(
        apiKey: 'YOUR_ANDROID_API_KEY',
        appId: 'YOUR_ANDROID_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
        storageBucket: 'YOUR_STORAGE_BUCKET',
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS configuration
      return const FirebaseOptions(
        apiKey: 'YOUR_IOS_API_KEY',
        appId: 'YOUR_IOS_APP_ID',
        messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
        projectId: 'YOUR_PROJECT_ID',
        storageBucket: 'YOUR_STORAGE_BUCKET',
        iosBundleId: 'com.recipeplatform.recipeApp',
      );
    }

    // Default to web configuration
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
      storageBucket: 'YOUR_STORAGE_BUCKET',
    );
  }
}
