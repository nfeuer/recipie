import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get Firebase Analytics observer for navigation tracking
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// Set user properties
  Future<void> setUserProperties({
    required String userId,
    String? userType,
  }) async {
    try {
      await _analytics.setUserId(id: userId);
      if (userType != null) {
        await _analytics.setUserProperty(name: 'user_type', value: userType);
      }
      if (kDebugMode) {
        print('Analytics: User properties set for $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user properties: $e');
      }
    }
  }

  /// Clear user data (on logout)
  Future<void> clearUser() async {
    try {
      await _analytics.setUserId(id: null);
      if (kDebugMode) {
        print('Analytics: User data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing user data: $e');
      }
    }
  }

  // ==================== Recipe Events ====================

  /// Log recipe creation
  Future<void> logRecipeCreated({
    required String recipeId,
    required String category,
    required String difficulty,
    required int prepTime,
    required int cookTime,
    int? ingredientCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'recipe_created',
        parameters: {
          'recipe_id': recipeId,
          'category': category,
          'difficulty': difficulty,
          'prep_time': prepTime,
          'cook_time': cookTime,
          'total_time': prepTime + cookTime,
          if (ingredientCount != null) 'ingredient_count': ingredientCount,
        },
      );
      if (kDebugMode) {
        print('Analytics: Recipe created - $recipeId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging recipe created: $e');
      }
    }
  }

  /// Log recipe viewed
  Future<void> logRecipeViewed({
    required String recipeId,
    required String category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'recipe_viewed',
        parameters: {
          'recipe_id': recipeId,
          'category': category,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging recipe viewed: $e');
      }
    }
  }

  /// Log recipe edited
  Future<void> logRecipeEdited({
    required String recipeId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'recipe_edited',
        parameters: {
          'recipe_id': recipeId,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging recipe edited: $e');
      }
    }
  }

  /// Log recipe deleted
  Future<void> logRecipeDeleted({
    required String recipeId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'recipe_deleted',
        parameters: {
          'recipe_id': recipeId,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging recipe deleted: $e');
      }
    }
  }

  /// Log recipe forked
  Future<void> logRecipeForked({
    required String originalRecipeId,
    required String newRecipeId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'recipe_forked',
        parameters: {
          'original_recipe_id': originalRecipeId,
          'new_recipe_id': newRecipeId,
        },
      );
      if (kDebugMode) {
        print('Analytics: Recipe forked - $originalRecipeId -> $newRecipeId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging recipe forked: $e');
      }
    }
  }

  /// Log recipe shared
  Future<void> logRecipeShared({
    required String recipeId,
    String? method,
  }) async {
    try {
      await _analytics.logShare(
        contentType: 'recipe',
        itemId: recipeId,
        method: method ?? 'unknown',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging recipe shared: $e');
      }
    }
  }

  // ==================== Event Events ====================

  /// Log event creation
  Future<void> logEventCreated({
    required String eventId,
    required int guestCount,
    required int recipeCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'event_created',
        parameters: {
          'event_id': eventId,
          'guest_count': guestCount,
          'recipe_count': recipeCount,
        },
      );
      if (kDebugMode) {
        print('Analytics: Event created - $eventId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging event created: $e');
      }
    }
  }

  /// Log event viewed
  Future<void> logEventViewed({
    required String eventId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'event_viewed',
        parameters: {
          'event_id': eventId,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging event viewed: $e');
      }
    }
  }

  /// Log event RSVP
  Future<void> logEventRsvp({
    required String eventId,
    required String status, // 'going', 'maybe', 'declined'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'event_rsvp',
        parameters: {
          'event_id': eventId,
          'rsvp_status': status,
        },
      );
      if (kDebugMode) {
        print('Analytics: Event RSVP - $eventId: $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging event RSVP: $e');
      }
    }
  }

  /// Log event shared
  Future<void> logEventShared({
    required String eventId,
    String? method,
  }) async {
    try {
      await _analytics.logShare(
        contentType: 'event',
        itemId: eventId,
        method: method ?? 'unknown',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging event shared: $e');
      }
    }
  }

  // ==================== Social Events ====================

  /// Log user followed
  Future<void> logUserFollowed({
    required String followedUserId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'user_followed',
        parameters: {
          'followed_user_id': followedUserId,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging user followed: $e');
      }
    }
  }

  /// Log user unfollowed
  Future<void> logUserUnfollowed({
    required String unfollowedUserId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'user_unfollowed',
        parameters: {
          'unfollowed_user_id': unfollowedUserId,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging user unfollowed: $e');
      }
    }
  }

  /// Log comment posted
  Future<void> logCommentPosted({
    required String recipeId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'comment_posted',
        parameters: {
          'recipe_id': recipeId,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging comment posted: $e');
      }
    }
  }

  /// Log recipe rated
  Future<void> logRecipeRated({
    required String recipeId,
    required double rating,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'recipe_rated',
        parameters: {
          'recipe_id': recipeId,
          'rating': rating,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging recipe rated: $e');
      }
    }
  }

  /// Log "Made It" post created
  Future<void> logMadeItPostCreated({
    required String recipeId,
    required String postId,
    int? photoCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'made_it_post_created',
        parameters: {
          'recipe_id': recipeId,
          'post_id': postId,
          if (photoCount != null) 'photo_count': photoCount,
        },
      );
      if (kDebugMode) {
        print('Analytics: Made It post created - $postId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging made it post: $e');
      }
    }
  }

  // ==================== Shopping List Events ====================

  /// Log shopping list created
  Future<void> logShoppingListCreated({
    required String listId,
    required bool isGenerated,
    int? itemCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'shopping_list_created',
        parameters: {
          'list_id': listId,
          'is_generated': isGenerated,
          if (itemCount != null) 'item_count': itemCount,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging shopping list created: $e');
      }
    }
  }

  /// Log shopping list item checked
  Future<void> logShoppingListItemChecked({
    required String listId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'shopping_list_item_checked',
        parameters: {
          'list_id': listId,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging shopping list item checked: $e');
      }
    }
  }

  // ==================== Search Events ====================

  /// Log search performed
  Future<void> logSearch({
    required String searchTerm,
    int? resultCount,
  }) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
        numberOfNights: resultCount, // Using this field to store result count
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging search: $e');
      }
    }
  }

  /// Log advanced search used
  Future<void> logAdvancedSearchUsed({
    int? filterCount,
    int? resultCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'advanced_search_used',
        parameters: {
          if (filterCount != null) 'filter_count': filterCount,
          if (resultCount != null) 'result_count': resultCount,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging advanced search: $e');
      }
    }
  }

  // ==================== Authentication Events ====================

  /// Log sign up
  Future<void> logSignUp({
    required String method, // 'email', 'google'
  }) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      if (kDebugMode) {
        print('Analytics: Sign up - $method');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging sign up: $e');
      }
    }
  }

  /// Log login
  Future<void> logLogin({
    required String method, // 'email', 'google'
  }) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      if (kDebugMode) {
        print('Analytics: Login - $method');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging login: $e');
      }
    }
  }

  // ==================== Screen View Events ====================

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging screen view: $e');
      }
    }
  }

  // ==================== Custom Events ====================

  /// Log custom event
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error logging custom event: $e');
      }
    }
  }
}
