import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class DynamicLinkService {
  static const String _uriPrefix = 'https://recipeapp.page.link'; // Replace with your domain
  static const String _packageName = 'com.recipeplatform.recipeApp';
  static const String _iosBundleId = 'com.recipeplatform.recipeApp';

  /// Initialize dynamic links and handle incoming links
  Future<void> initialize({
    required Function(Uri deepLink) onLinkReceived,
  }) async {
    try {
      // Handle link that opened the app (app was terminated)
      final PendingDynamicLinkData? initialLink =
          await FirebaseDynamicLinks.instance.getInitialLink();

      if (initialLink != null) {
        final Uri deepLink = initialLink.link;
        if (kDebugMode) {
          print('Initial dynamic link: $deepLink');
        }
        onLinkReceived(deepLink);
      }

      // Handle link while app is running (foreground or background)
      FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData dynamicLinkData) {
          final Uri deepLink = dynamicLinkData.link;
          if (kDebugMode) {
            print('Dynamic link received: $deepLink');
          }
          onLinkReceived(deepLink);
        },
        onError: (error) {
          if (kDebugMode) {
            print('Dynamic link error: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing dynamic links: $e');
      }
    }
  }

  /// Create dynamic link for a recipe
  Future<String> createRecipeLink({
    required String recipeId,
    required String recipeTitle,
    String? imageUrl,
  }) async {
    try {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: _uriPrefix,
        link: Uri.parse('https://recipeapp.com/recipe/$recipeId'),
        androidParameters: AndroidParameters(
          packageName: _packageName,
          minimumVersion: 1,
        ),
        iosParameters: IOSParameters(
          bundleId: _iosBundleId,
          minimumVersion: '1.0.0',
          appStoreId: '123456789', // Replace with actual App Store ID
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: recipeTitle,
          description: 'Check out this recipe on Recipe Platform!',
          imageUrl: imageUrl != null ? Uri.parse(imageUrl) : null,
        ),
      );

      final ShortDynamicLink shortLink =
          await FirebaseDynamicLinks.instance.buildShortLink(parameters);

      return shortLink.shortUrl.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating recipe link: $e');
      }
      // Fallback to web URL
      return 'https://recipeapp.com/recipe/$recipeId';
    }
  }

  /// Create dynamic link for an event
  Future<String> createEventLink({
    required String eventId,
    required String eventTitle,
    String? imageUrl,
  }) async {
    try {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: _uriPrefix,
        link: Uri.parse('https://recipeapp.com/event/$eventId'),
        androidParameters: AndroidParameters(
          packageName: _packageName,
          minimumVersion: 1,
        ),
        iosParameters: IOSParameters(
          bundleId: _iosBundleId,
          minimumVersion: '1.0.0',
          appStoreId: '123456789', // Replace with actual App Store ID
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: eventTitle,
          description: 'Join this event on Recipe Platform!',
          imageUrl: imageUrl != null ? Uri.parse(imageUrl) : null,
        ),
      );

      final ShortDynamicLink shortLink =
          await FirebaseDynamicLinks.instance.buildShortLink(parameters);

      return shortLink.shortUrl.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating event link: $e');
      }
      // Fallback to web URL
      return 'https://recipeapp.com/event/$eventId';
    }
  }

  /// Create dynamic link for a user profile
  Future<String> createUserProfileLink({
    required String userId,
    required String userName,
    String? avatarUrl,
  }) async {
    try {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: _uriPrefix,
        link: Uri.parse('https://recipeapp.com/user/$userId'),
        androidParameters: AndroidParameters(
          packageName: _packageName,
          minimumVersion: 1,
        ),
        iosParameters: IOSParameters(
          bundleId: _iosBundleId,
          minimumVersion: '1.0.0',
          appStoreId: '123456789', // Replace with actual App Store ID
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: userName,
          description: 'Follow $userName on Recipe Platform!',
          imageUrl: avatarUrl != null ? Uri.parse(avatarUrl) : null,
        ),
      );

      final ShortDynamicLink shortLink =
          await FirebaseDynamicLinks.instance.buildShortLink(parameters);

      return shortLink.shortUrl.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile link: $e');
      }
      // Fallback to web URL
      return 'https://recipeapp.com/user/$userId';
    }
  }

  /// Share a recipe using dynamic link
  Future<void> shareRecipe({
    required String recipeId,
    required String recipeTitle,
    String? imageUrl,
  }) async {
    try {
      final link = await createRecipeLink(
        recipeId: recipeId,
        recipeTitle: recipeTitle,
        imageUrl: imageUrl,
      );

      await Share.share(
        'Check out this recipe: $recipeTitle\n$link',
        subject: recipeTitle,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing recipe: $e');
      }
    }
  }

  /// Share an event using dynamic link
  Future<void> shareEvent({
    required String eventId,
    required String eventTitle,
    String? imageUrl,
  }) async {
    try {
      final link = await createEventLink(
        eventId: eventId,
        eventTitle: eventTitle,
        imageUrl: imageUrl,
      );

      await Share.share(
        'Join this event: $eventTitle\n$link',
        subject: eventTitle,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing event: $e');
      }
    }
  }

  /// Share a user profile using dynamic link
  Future<void> shareUserProfile({
    required String userId,
    required String userName,
    String? avatarUrl,
  }) async {
    try {
      final link = await createUserProfileLink(
        userId: userId,
        userName: userName,
        avatarUrl: avatarUrl,
      );

      await Share.share(
        'Follow $userName on Recipe Platform!\n$link',
        subject: 'Follow $userName',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing user profile: $e');
      }
    }
  }

  /// Parse deep link and extract type and ID
  Map<String, String>? parseDeepLink(Uri deepLink) {
    try {
      // Expected format: https://recipeapp.com/{type}/{id}
      final pathSegments = deepLink.pathSegments;

      if (pathSegments.length >= 2) {
        return {
          'type': pathSegments[0], // 'recipe', 'event', or 'user'
          'id': pathSegments[1],   // The ID
        };
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing deep link: $e');
      }
      return null;
    }
  }
}
