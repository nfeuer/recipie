# Architecture Documentation

## Overview

The Recipe & Event Platform is a full-featured Flutter mobile application built using **Clean Architecture** principles. This document provides a comprehensive overview of the application's architecture, design patterns, and code organization.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Layer Breakdown](#layer-breakdown)
3. [Directory Structure](#directory-structure)
4. [Design Patterns](#design-patterns)
5. [State Management](#state-management)
6. [Navigation](#navigation)
7. [Data Flow](#data-flow)
8. [Firebase Integration](#firebase-integration)
9. [Code Organization Best Practices](#code-organization-best-practices)

---

## Architecture Overview

The application follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (UI, Screens, Widgets, Providers, State Management)        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│    (Models, Repositories, Services, Business Logic)          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       CORE LAYER                             │
│     (Configuration, Constants, Utilities, Helpers)           │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    FIREBASE BACKEND                          │
│  (Firestore, Auth, Storage, FCM, Dynamic Links, Analytics)  │
└─────────────────────────────────────────────────────────────┘
```

### Key Principles

- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Rule**: Dependencies point inward (Presentation → Data → Core)
- **Testability**: Business logic is isolated and testable
- **Scalability**: Easy to add new features without affecting existing code

---

## Layer Breakdown

### 1. Presentation Layer (`lib/presentation/`)

**Responsibility**: User interface and user interaction handling

**Components**:
- **Screens** (`screens/`): Full-page UI components
- **Widgets** (`widgets/`): Reusable UI components
- **Providers** (`providers/`): State management using Riverpod

**Characteristics**:
- No direct Firebase calls
- Uses providers to access data
- Reactive to state changes
- Platform-agnostic UI code

**Example Flow**:
```dart
Screen → Provider → Repository → Firebase
   ↓
Widget ← State Update ← Stream/Future
```

### 2. Data Layer (`lib/data/`)

**Responsibility**: Data access, business logic, and external service integration

**Components**:
- **Models** (`models/`): Data structures with serialization
- **Repositories** (`repositories/`): Data access abstraction
- **Services** (`services/`): Complex business logic and integrations

**Characteristics**:
- Single source of truth for data operations
- Handles Firebase interactions
- Implements caching and offline support
- Error handling and data validation

**Key Differences**:
- **Repositories**: CRUD operations for specific entities (User, Recipe, Event)
- **Services**: Cross-cutting concerns (Auth, Storage, Notifications, Analytics)

### 3. Core Layer (`lib/core/`)

**Responsibility**: Shared utilities, constants, and configuration

**Components**:
- **Config** (`config/`): Firebase initialization, app configuration
- **Constants** (`constants/`): App-wide constants, themes, collections
- **Utils** (`utils/`): Helper functions, converters, validators

**Characteristics**:
- No business logic
- Pure functions and constants
- Reusable across the entire app
- No dependencies on other layers

---

## Directory Structure

```
lib/
├── main.dart                              # App entry point & initialization
│
├── core/                                  # Core utilities and configuration
│   ├── config/
│   │   └── firebase_config.dart          # Firebase initialization
│   ├── constants/
│   │   ├── app_constants.dart            # App constants & enums
│   │   └── app_theme.dart                # Theme & styling
│   └── utils/
│       ├── ingredient_scaling.dart       # Recipe scaling utilities
│       └── unit_conversion.dart          # Measurement conversions
│
├── data/                                  # Data layer
│   ├── models/                           # Data models (10 files)
│   │   ├── user_model.dart               # User profile data
│   │   ├── recipe_model.dart             # Recipe data & ingredients
│   │   ├── event_model.dart              # Event data & guest lists
│   │   ├── shopping_list_model.dart      # Shopping list data
│   │   ├── notification_model.dart       # In-app notifications
│   │   ├── activity_model.dart           # Activity feed items
│   │   ├── comment_model.dart            # Comments data
│   │   ├── rating_model.dart             # Rating data
│   │   ├── made_it_model.dart            # "I Made This" posts
│   │   └── recipe_collection_model.dart  # Recipe collections
│   │
│   ├── repositories/                     # Data access (10 files)
│   │   ├── user_repository.dart          # User CRUD operations
│   │   ├── recipe_repository.dart        # Recipe CRUD operations
│   │   ├── event_repository.dart         # Event CRUD operations
│   │   ├── shopping_list_repository.dart # Shopping list operations
│   │   ├── notification_repository.dart  # Notification operations
│   │   ├── activity_repository.dart      # Activity feed operations
│   │   ├── comment_repository.dart       # Comment operations
│   │   ├── rating_repository.dart        # Rating operations
│   │   ├── made_it_repository.dart       # Made-it post operations
│   │   └── recipe_collection_repository.dart # Collection operations
│   │
│   └── services/                         # Business logic (7 files)
│       ├── auth_service.dart             # Authentication logic
│       ├── storage_service.dart          # File upload/download
│       ├── notification_service.dart     # Notification creation
│       ├── push_notification_service.dart # FCM integration
│       ├── dynamic_link_service.dart     # Deep linking
│       ├── analytics_service.dart        # Analytics tracking
│       └── offline_cache_service.dart    # Offline data caching
│
└── presentation/                          # Presentation layer
    ├── providers/                        # Riverpod providers (14 files)
    │   ├── auth_providers.dart           # Auth state providers
    │   ├── recipe_providers.dart         # Recipe state & operations
    │   ├── event_providers.dart          # Event state & operations
    │   ├── user_providers.dart           # User profile providers
    │   ├── notification_providers.dart   # Notification providers
    │   ├── activity_providers.dart       # Activity feed providers
    │   ├── comment_providers.dart        # Comment providers
    │   ├── rating_providers.dart         # Rating providers
    │   ├── made_it_providers.dart        # Made-it post providers
    │   ├── shopping_list_providers.dart  # Shopping list providers
    │   ├── collection_providers.dart     # Collection providers
    │   ├── analytics_providers.dart      # Analytics providers
    │   ├── dynamic_link_providers.dart   # Dynamic link providers
    │   └── theme_provider.dart           # Theme state provider
    │
    ├── screens/                          # UI screens (26 files)
    │   ├── splash_screen.dart            # Initial loading screen
    │   ├── auth/                         # Authentication screens
    │   │   ├── login_screen.dart
    │   │   └── signup_screen.dart
    │   ├── home/                         # Home/dashboard
    │   │   └── home_screen.dart
    │   ├── recipes/                      # Recipe management
    │   │   ├── recipes_screen.dart
    │   │   ├── recipe_detail_screen.dart
    │   │   ├── create_recipe_screen.dart
    │   │   ├── edit_recipe_screen.dart
    │   │   ├── fork_recipe_screen.dart
    │   │   └── cooking_mode_screen.dart
    │   ├── events/                       # Event management
    │   │   ├── events_screen.dart
    │   │   ├── event_detail_screen.dart
    │   │   ├── create_event_screen.dart
    │   │   └── edit_event_screen.dart
    │   ├── profile/                      # User profiles
    │   │   ├── user_profile_screen.dart
    │   │   ├── edit_profile_screen.dart
    │   │   ├── followers_screen.dart
    │   │   └── search_users_screen.dart
    │   ├── feed/                         # Activity feed
    │   │   └── activity_feed_screen.dart
    │   ├── notifications/                # Notifications
    │   │   └── notifications_screen.dart
    │   ├── shopping_list/                # Shopping lists
    │   │   ├── shopping_lists_screen.dart
    │   │   ├── shopping_list_detail_screen.dart
    │   │   └── create_shopping_list_screen.dart
    │   ├── search/                       # Advanced search
    │   │   └── advanced_search_screen.dart
    │   ├── made_it/                      # Made-it posts
    │   │   └── create_made_it_post_screen.dart
    │   └── premium/                      # Premium features
    │       └── premium_screen.dart
    │
    └── widgets/                          # Reusable widgets (8 files)
        ├── recipe_card.dart              # Recipe preview card
        ├── event_card.dart               # Event preview card
        ├── activity_item.dart            # Activity feed item
        ├── comments_section.dart         # Comments UI component
        ├── ratings_section.dart          # Ratings UI component
        ├── made_it_posts_section.dart    # Made-it posts section
        ├── ingredient_scaling_widget.dart # Ingredient scaling UI
        └── premium_feature_gate.dart     # Premium feature restriction
```

---

## Design Patterns

### 1. Repository Pattern

**Purpose**: Abstracts data sources and provides a clean API for data access

**Implementation**:
```dart
class RecipeRepository {
  final FirebaseFirestore _firestore;

  // CRUD operations
  Future<void> createRecipe(RecipeModel recipe) { }
  Future<RecipeModel?> getRecipe(String id) { }
  Future<void> updateRecipe(RecipeModel recipe) { }
  Future<void> deleteRecipe(String id) { }

  // Queries
  Stream<List<RecipeModel>> getUserRecipes(String userId) { }
  Stream<List<RecipeModel>> getPublicRecipes() { }
}
```

**Benefits**:
- Centralized data access logic
- Easy to mock for testing
- Swappable data sources
- Consistent error handling

### 2. Provider Pattern (Riverpod)

**Purpose**: Dependency injection and state management

**Implementation**:
```dart
// Provider declaration
final recipeRepositoryProvider = Provider((ref) => RecipeRepository());

// State provider
final recipeListProvider = StreamProvider.family<List<RecipeModel>, String>(
  (ref, userId) {
    final repository = ref.read(recipeRepositoryProvider);
    return repository.getUserRecipes(userId);
  },
);

// Usage in widgets
final recipes = ref.watch(recipeListProvider(userId));
```

**Benefits**:
- Automatic dependency injection
- Reactive state updates
- Easy testing with overrides
- Compile-time safety

### 3. Factory Pattern

**Purpose**: Object creation and serialization/deserialization

**Implementation**:
```dart
class RecipeModel {
  // Constructor
  const RecipeModel({required this.id, ...});

  // Factory from Firestore
  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'],
      // ...
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // ...
    };
  }
}
```

### 4. Singleton Pattern

**Purpose**: Single instance of services throughout app lifecycle

**Implementation**:
```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Service methods...
}
```

---

## State Management

### Riverpod 3.0

The app uses **Riverpod** for state management, providing:

**Provider Types Used**:

1. **Provider**: Immutable dependencies (repositories, services)
2. **StateProvider**: Simple mutable state
3. **StreamProvider**: Real-time data from Firestore
4. **FutureProvider**: Async data fetching
5. **StateNotifierProvider**: Complex state management

**Example State Flow**:
```dart
// 1. User taps "Create Recipe" button
onPressed: () {
  ref.read(recipeRepositoryProvider).createRecipe(recipe);
}

// 2. Repository saves to Firestore
await _firestore.collection('recipes').add(recipe.toMap());

// 3. StreamProvider detects change
Stream<List<RecipeModel>> getUserRecipes(String userId) {
  return _firestore
    .collection('recipes')
    .where('authorId', isEqualTo: userId)
    .snapshots()
    .map((snapshot) => ...);
}

// 4. UI automatically rebuilds
final recipes = ref.watch(recipeListProvider);
```

**Benefits**:
- Automatic cache management
- Subscription lifecycle management
- Granular rebuilds (only affected widgets update)
- DevTools integration

---

## Navigation

### Go Router 17.0

The app uses **Go Router** for declarative routing and deep linking support.

**Route Structure**:
```dart
GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) {
        final recipeId = state.params['id']!;
        return RecipeDetailScreen(recipeId: recipeId);
      },
    ),
    // ... more routes
  ],
  redirect: (context, state) {
    // Auth guard logic
  },
);
```

**Features**:
- Type-safe navigation
- Deep linking support (Firebase Dynamic Links)
- Query parameters
- Nested navigation
- Redirect/guards for authentication

---

## Data Flow

### Real-time Data Flow (Firestore Streams)

```
User Action (UI)
    ↓
Provider Method Call
    ↓
Repository Method
    ↓
Firestore Operation (Create/Update/Delete)
    ↓
Firestore Triggers Change Event
    ↓
Repository Stream Emits New Data
    ↓
StreamProvider Notifies Listeners
    ↓
UI Rebuilds Automatically
```

### One-time Data Fetch

```
User Action (UI)
    ↓
Provider Method Call
    ↓
Repository Method (Future)
    ↓
Firestore Get Operation
    ↓
Data Returned
    ↓
FutureProvider Caches Result
    ↓
UI Displays Data
```

---

## Firebase Integration

### Services Used

1. **Firebase Authentication**
   - Email/Password authentication
   - Google Sign-In
   - User session management
   - Location: `lib/data/services/auth_service.dart`

2. **Cloud Firestore**
   - Real-time NoSQL database
   - Collections: users, recipes, events, comments, ratings, etc.
   - Security rules: `firestore.rules`

3. **Firebase Storage**
   - Image uploads (profile pictures, recipe photos, event photos)
   - Security rules: `storage.rules`
   - Location: `lib/data/services/storage_service.dart`

4. **Firebase Cloud Messaging (FCM)**
   - Push notifications
   - Location: `lib/data/services/push_notification_service.dart`

5. **Firebase Dynamic Links**
   - Deep linking for recipes and events
   - Social sharing
   - Location: `lib/data/services/dynamic_link_service.dart`

6. **Firebase Analytics**
   - User behavior tracking
   - Event logging
   - Location: `lib/data/services/analytics_service.dart`

7. **Firebase Crashlytics**
   - Error reporting
   - Crash analytics

### Firestore Data Model

See [DATA_MODELS.md](DATA_MODELS.md) for detailed schema documentation.

**Collection Structure**:
```
firestore
├── users/{userId}
├── recipes/{recipeId}
├── events/{eventId}
├── comments/{commentId}
├── ratings/{ratingId}
├── madeIt/{postId}
├── shoppingLists/{listId}
├── notifications/{notificationId}
├── activities/{activityId}
└── following/{relationshipId}
```

---

## Code Organization Best Practices

### 1. File Naming
- Use snake_case for file names
- Suffix with type: `_model.dart`, `_repository.dart`, `_service.dart`, `_screen.dart`, `_provider.dart`

### 2. Class Organization
```dart
class ExampleClass {
  // 1. Static constants
  static const String CONSTANT = 'value';

  // 2. Instance variables
  final String id;
  final String name;

  // 3. Constructor
  const ExampleClass({required this.id, required this.name});

  // 4. Factory constructors
  factory ExampleClass.fromMap(Map<String, dynamic> map) { }

  // 5. Public methods
  void publicMethod() { }

  // 6. Private methods
  void _privateMethod() { }

  // 7. Overrides (copyWith, toString, ==, hashCode)
  ExampleClass copyWith({String? name}) { }
}
```

### 3. Import Organization
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:io';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

// 4. Local imports (absolute paths)
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/data/repositories/recipe_repository.dart';
```

### 4. Error Handling
```dart
try {
  await repository.createRecipe(recipe);
} on FirebaseException catch (e) {
  // Handle Firebase-specific errors
  print('Firebase error: ${e.code} - ${e.message}');
} catch (e) {
  // Handle general errors
  print('Error: $e');
}
```

### 5. Null Safety
- Use null-aware operators: `?.`, `??`, `!`
- Declare nullable types explicitly: `String?`
- Use `required` for mandatory parameters
- Avoid `late` initialization where possible

---

## Performance Considerations

1. **Firestore Queries**: Use indexes for complex queries (see `firestore.indexes.json`)
2. **Image Caching**: Uses `cached_network_image` for efficient image loading
3. **Pagination**: Implement pagination for large lists
4. **Optimistic Updates**: Update UI before Firestore confirmation
5. **Offline Support**: Firestore offline persistence enabled

---

## Testing Strategy

### Unit Tests
- Test business logic in services and repositories
- Mock Firestore with fake data
- Test utility functions

### Widget Tests
- Test individual widgets
- Test user interactions
- Mock providers

### Integration Tests
- Test complete user flows
- Test Firebase integration
- Test navigation

---

## Development Workflow

1. **Feature Development**:
   - Create model if needed
   - Create/update repository
   - Create provider
   - Build UI screen/widget
   - Add navigation route

2. **State Management**:
   - Use StreamProvider for real-time data
   - Use FutureProvider for one-time fetches
   - Use StateNotifierProvider for complex state

3. **Firestore Operations**:
   - Always use repositories
   - Never call Firestore directly from UI
   - Handle errors appropriately

---

## Resources

- **Flutter**: https://flutter.dev
- **Riverpod**: https://riverpod.dev
- **Go Router**: https://pub.dev/packages/go_router
- **Firebase**: https://firebase.google.com/docs
- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

---

## Next Steps for Developers

1. Read [QUICKSTART.md](QUICKSTART.md) for setup instructions
2. Review [DATA_MODELS.md](DATA_MODELS.md) for database schema
3. Check [API.md](API.md) for service/repository documentation
4. Explore `lib/presentation/screens/` for UI examples
5. Run the app and experiment!

---

**Last Updated**: 2025-11-22
**Architecture Version**: 1.0
**Flutter Version**: 3.x
**Dart Version**: 3.10+
