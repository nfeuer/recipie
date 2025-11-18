// Firebase Collections
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

// Firebase Storage Paths
class StoragePaths {
  static String userProfile(String userId) => 'users/$userId/profile';
  static String recipePhotos(String recipeId) => 'recipes/$recipeId';
  static String eventPhotos(String eventId) => 'events/$eventId';
}

// App Constants
class AppConstants {
  static const String appName = 'Recipe & Event Platform';
  static const String appVersion = '1.0.0';

  // Limits
  static const int maxRecipePhotos = 10;
  static const int maxEventPhotos = 50;
  static const int maxIngredients = 50;
  static const int maxSteps = 30;
  static const int maxGuests = 200;

  // Event Types
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

  // Dietary Tags
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

  // Recipe Difficulties
  static const List<String> difficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];

  // Cuisine Types
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

  // Recipe Categories
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
