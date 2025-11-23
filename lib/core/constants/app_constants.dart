/// Application Constants and Configuration
///
/// This file contains all constant values used throughout the Recipe & Event Platform.
/// It provides centralized configuration for Firebase collections, storage paths,
/// app metadata, and business logic constraints.
///
/// Key components:
/// - [FirebaseCollections]: Firestore collection names
/// - [StoragePaths]: Firebase Storage path generators
/// - [AppConstants]: App metadata, limits, and enumeration values

// ============================================================================
// FIREBASE COLLECTIONS
// ============================================================================

/// Firestore collection names used throughout the app.
///
/// This class provides a single source of truth for all Firestore collection
/// names to prevent typos and ensure consistency across the application.
///
/// Collections:
/// - users: User profile data
/// - recipes: Recipe documents
/// - events: Event documents
/// - following: User follow relationships
/// - shoppingLists: User shopping lists
/// - notifications: In-app notifications
/// - comments: Comments on recipes and events
/// - ratings: Recipe ratings
/// - madeIt: "I Made This" posts
/// - recipeRequests: Recipe creation requests (unused/future)
/// - activities: Activity feed items
class FirebaseCollections {
  static const String users = 'users';
  static const String recipes = 'recipes';
  static const String events = 'events';
  static const String following = 'following';
  static const String shoppingLists = 'shoppingLists';
  static const String notifications = 'notifications';
  static const String comments = 'comments';
  static const String ratings = 'ratings';
  static const String madeIt = 'madeIt';
  static const String recipeRequests = 'recipeRequests';
  static const String activities = 'activities';
}

// ============================================================================
// FIREBASE STORAGE PATHS
// ============================================================================

/// Generates Firebase Storage paths for uploaded files.
///
/// This class provides helper methods to generate consistent storage paths
/// for different types of uploaded content (profile pictures, recipe photos,
/// event photos).
///
/// Path structure:
/// - User profiles: users/{userId}/profile/{filename}
/// - Recipe photos: recipes/{recipeId}/{filename}
/// - Event photos: events/{eventId}/{filename}
class StoragePaths {
  /// Returns the storage path for user profile pictures.
  ///
  /// [userId] The unique identifier of the user.
  /// Returns: "users/{userId}/profile"
  static String userProfile(String userId) => 'users/$userId/profile';

  /// Returns the storage path for recipe photos.
  ///
  /// [recipeId] The unique identifier of the recipe.
  /// Returns: "recipes/{recipeId}"
  static String recipePhotos(String recipeId) => 'recipes/$recipeId';

  /// Returns the storage path for event photos.
  ///
  /// [eventId] The unique identifier of the event.
  /// Returns: "events/{eventId}"
  static String eventPhotos(String eventId) => 'events/$eventId';
}

// ============================================================================
// APPLICATION CONSTANTS
// ============================================================================

/// Core application constants, limits, and enumeration values.
///
/// This class centralizes all business logic constraints and configuration
/// values used throughout the app. It includes:
/// - App metadata (name, version)
/// - Content limits (photos, ingredients, steps, guests)
/// - Predefined enumeration lists (event types, dietary tags, cuisines, etc.)
///
/// These constants enforce consistency and enable easy configuration changes.
class AppConstants {
  // -------------------------------------------------------------------------
  // App Metadata
  // -------------------------------------------------------------------------

  /// The display name of the application.
  static const String appName = 'Recipe & Event Platform';

  /// Current version of the application.
  static const String appVersion = '1.0.0';

  // -------------------------------------------------------------------------
  // Content Limits
  // -------------------------------------------------------------------------

  /// Constraints on user-generated content to maintain performance and UX.

  /// Maximum number of photos that can be attached to a single recipe.
  static const int maxRecipePhotos = 10;

  /// Maximum number of photos that can be attached to a single event.
  static const int maxEventPhotos = 50;

  /// Maximum number of ingredients in a single recipe.
  static const int maxIngredients = 50;

  /// Maximum number of preparation steps in a single recipe.
  static const int maxSteps = 30;

  /// Maximum number of guests that can be invited to an event.
  static const int maxGuests = 200;

  // -------------------------------------------------------------------------
  // Event Types
  // -------------------------------------------------------------------------

  /// Predefined event type categories for organizing food-related events.
  static const List<String> eventTypes = [
    'Dinner Party',
    'Potluck',
    'BBQ',
    'Holiday Meal',
    'Brunch',
    'Cooking Class',
    'Food Festival',
    'Other',
  ];

  // -------------------------------------------------------------------------
  // Dietary Tags
  // -------------------------------------------------------------------------

  /// Dietary restriction and preference tags for recipes.
  ///
  /// These tags help users filter recipes based on their dietary needs
  /// and preferences (e.g., allergies, religious requirements, health goals).
  static const List<String> dietaryTags = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free',
    'Low-Carb',
    'Keto',
    'Paleo',
    'Halal',
    'Kosher',
  ];

  // -------------------------------------------------------------------------
  // Recipe Difficulties
  // -------------------------------------------------------------------------

  /// Recipe difficulty levels to indicate skill requirement.
  ///
  /// Helps users choose recipes appropriate for their cooking skill level.
  static const List<String> difficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];

  // -------------------------------------------------------------------------
  // Cuisine Types
  // -------------------------------------------------------------------------

  /// International cuisine type classifications for recipes.
  ///
  /// Allows users to browse and filter recipes by cultural/regional origin.
  static const List<String> cuisineTypes = [
    'Italian',
    'Mexican',
    'Chinese',
    'Japanese',
    'Indian',
    'Thai',
    'French',
    'Mediterranean',
    'American',
    'Korean',
    'Vietnamese',
    'Other',
  ];

  // -------------------------------------------------------------------------
  // Recipe Categories
  // -------------------------------------------------------------------------

  /// Recipe course/meal type categories.
  ///
  /// Classifies recipes by the meal course or food category
  /// (e.g., appetizer, main course, dessert).
  static const List<String> categories = [
    'Appetizer',
    'Main Course',
    'Side Dish',
    'Dessert',
    'Beverage',
    'Salad',
    'Soup',
    'Breakfast',
    'Snack',
  ];
}
