# API & Services Documentation

## Overview

This document provides comprehensive documentation for all repositories and services in the Recipe & Event Platform. These components form the data access layer and business logic layer of the application.

## Table of Contents

1. [Repositories vs Services](#repositories-vs-services)
2. [Repositories](#repositories)
   - [UserRepository](#userrepository)
   - [RecipeRepository](#reciperepository)
   - [EventRepository](#eventrepository)
   - [CommentRepository](#commentrepository)
   - [RatingRepository](#ratingrepository)
   - [MadeItRepository](#madeitrepository)
   - [ShoppingListRepository](#shoppinglistrepository)
   - [NotificationRepository](#notificationrepository)
   - [ActivityRepository](#activityrepository)
   - [RecipeCollectionRepository](#recipecollectionrepository)
3. [Services](#services)
   - [AuthService](#authservice)
   - [StorageService](#storageservice)
   - [NotificationService](#notificationservice)
   - [PushNotificationService](#pushnotificationservice)
   - [DynamicLinkService](#dynamiclinkservice)
   - [AnalyticsService](#analyticsservice)
   - [OfflineCacheService](#offlinecacheservice)
4. [Error Handling](#error-handling)
5. [Best Practices](#best-practices)

---

## Repositories vs Services

### Repositories
- **Purpose**: CRUD operations for specific data entities
- **Pattern**: Repository pattern with Firestore
- **Naming**: `{Entity}Repository` (e.g., `UserRepository`)
- **Location**: `lib/data/repositories/`
- **Characteristics**:
  - Entity-specific (one repository per model)
  - Firestore collection access
  - CRUD methods (create, read, update, delete)
  - Query methods
  - Stream-based real-time data

### Services
- **Purpose**: Cross-cutting concerns and business logic
- **Pattern**: Service layer pattern
- **Naming**: `{Function}Service` (e.g., `AuthService`)
- **Location**: `lib/data/services/`
- **Characteristics**:
  - Application-wide functionality
  - Third-party integrations (Firebase Auth, FCM, etc.)
  - Complex business logic
  - Singleton pattern (usually)

---

## Repositories

### UserRepository

**File**: `lib/data/repositories/user_repository.dart`

#### Purpose
Manages user profile data in Firestore.

#### Key Methods

##### `createUser(UserModel user)`
Creates a new user profile document.
- **Parameters**: `user` - User profile data
- **Returns**: `Future<void>`
- **Throws**: `FirebaseException` on failure
- **Usage**: Called after Firebase Auth registration

##### `getUser(String userId)`
Retrieves a user profile by ID.
- **Parameters**: `userId` - User's unique identifier
- **Returns**: `Future<UserModel?>`
- **Returns null**: If user doesn't exist

##### `getUserStream(String userId)`
Real-time stream of user profile updates.
- **Parameters**: `userId` - User's unique identifier
- **Returns**: `Stream<UserModel?>`
- **Usage**: Subscribe to profile changes in UI

##### `updateUser(UserModel user)`
Updates an existing user profile.
- **Parameters**: `user` - Updated user data
- **Returns**: `Future<void>`
- **Validates**: User must exist

##### `deleteUser(String userId)`
Deletes a user profile.
- **Parameters**: `userId` - User's unique identifier
- **Returns**: `Future<void>`
- **Note**: Does not delete Firebase Auth account

##### `searchUsers(String query)`
Searches users by display name.
- **Parameters**: `query` - Search query string
- **Returns**: `Future<List<UserModel>>`
- **Filters**: Case-insensitive search on `displayName`

##### `followUser(String followerId, String followedId)`
Creates a follow relationship.
- **Parameters**:
  - `followerId` - User who is following
  - `followedId` - User being followed
- **Returns**: `Future<void>`
- **Side effects**: Updates follower/following counts

##### `unfollowUser(String followerId, String followedId)`
Removes a follow relationship.
- **Parameters**:
  - `followerId` - User who is unfollowing
  - `followedId` - User being unfollowed
- **Returns**: `Future<void>`
- **Side effects**: Updates follower/following counts

##### `getFollowers(String userId)`
Gets list of users following this user.
- **Parameters**: `userId` - User's unique identifier
- **Returns**: `Stream<List<UserModel>>`

##### `getFollowing(String userId)`
Gets list of users this user follows.
- **Parameters**: `userId` - User's unique identifier
- **Returns**: `Stream<List<UserModel>>`

##### `isFollowing(String followerId, String followedId)`
Checks if a follow relationship exists.
- **Parameters**:
  - `followerId` - Potential follower
  - `followedId` - Potentially followed user
- **Returns**: `Future<bool>`

---

### RecipeRepository

**File**: `lib/data/repositories/recipe_repository.dart`

#### Purpose
Manages recipe documents and queries.

#### Key Methods

##### `createRecipe(RecipeModel recipe)`
Creates a new recipe.
- **Parameters**: `recipe` - Recipe data
- **Returns**: `Future<String>` - Created recipe ID
- **Side effects**: Increments user's recipe count

##### `getRecipe(String recipeId)`
Retrieves a recipe by ID.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Future<RecipeModel?>`

##### `getRecipeStream(String recipeId)`
Real-time stream of recipe updates.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Stream<RecipeModel?>`

##### `updateRecipe(RecipeModel recipe)`
Updates an existing recipe.
- **Parameters**: `recipe` - Updated recipe data
- **Returns**: `Future<void>`
- **Validates**: User must be recipe author

##### `deleteRecipe(String recipeId)`
Deletes a recipe and related data.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Future<void>`
- **Side effects**:
  - Deletes associated comments, ratings
  - Decrements user's recipe count
  - Deletes photos from Storage

##### `getUserRecipes(String userId)`
Gets all recipes by a user.
- **Parameters**: `userId` - User identifier
- **Returns**: `Stream<List<RecipeModel>>`
- **Sorted**: By creation date (newest first)

##### `getPublicRecipes({int limit = 20})`
Gets public recipes with pagination.
- **Parameters**: `limit` - Max number of recipes (default: 20)
- **Returns**: `Stream<List<RecipeModel>>`
- **Filters**: Only public recipes
- **Sorted**: By creation date (newest first)

##### `getRecipesByCategory(String category)`
Gets recipes in a specific category.
- **Parameters**: `category` - Recipe category
- **Returns**: `Stream<List<RecipeModel>>`

##### `getRecipesByCuisine(String cuisineType)`
Gets recipes of a specific cuisine.
- **Parameters**: `cuisineType` - Cuisine type
- **Returns**: `Stream<List<RecipeModel>>`

##### `searchRecipes(String query, {filters})`
Advanced recipe search with filters.
- **Parameters**:
  - `query` - Search query
  - `category` - Optional category filter
  - `cuisineType` - Optional cuisine filter
  - `dietaryTags` - Optional dietary restriction filters
  - `maxPrepTime` - Optional max preparation time
  - `difficulty` - Optional difficulty filter
- **Returns**: `Future<List<RecipeModel>>`

##### `forkRecipe(RecipeModel originalRecipe, String userId)`
Creates a copy of a recipe (fork).
- **Parameters**:
  - `originalRecipe` - Recipe to fork
  - `userId` - ID of user creating the fork
- **Returns**: `Future<String>` - New recipe ID
- **Side effects**:
  - Sets `forkedFromId` on new recipe
  - Increments `forkCount` on original

##### `likeRecipe(String recipeId, String userId)`
Adds a like to a recipe.
- **Parameters**:
  - `recipeId` - Recipe identifier
  - `userId` - User who liked
- **Returns**: `Future<void>`
- **Side effects**: Increments `likeCount`

##### `unlikeRecipe(String recipeId, String userId)`
Removes a like from a recipe.
- **Parameters**:
  - `recipeId` - Recipe identifier
  - `userId` - User who unliked
- **Returns**: `Future<void>`
- **Side effects**: Decrements `likeCount`

---

### EventRepository

**File**: `lib/data/repositories/event_repository.dart`

#### Purpose
Manages event documents and RSVP functionality.

#### Key Methods

##### `createEvent(EventModel event)`
Creates a new event.
- **Parameters**: `event` - Event data
- **Returns**: `Future<String>` - Created event ID
- **Side effects**: Increments user's event count

##### `getEvent(String eventId)`
Retrieves an event by ID.
- **Parameters**: `eventId` - Event identifier
- **Returns**: `Future<EventModel?>`

##### `getEventStream(String eventId)`
Real-time stream of event updates.
- **Parameters**: `eventId` - Event identifier
- **Returns**: `Stream<EventModel?>`

##### `updateEvent(EventModel event)`
Updates an existing event.
- **Parameters**: `event` - Updated event data
- **Returns**: `Future<void>`
- **Validates**: User must be event creator

##### `deleteEvent(String eventId)`
Deletes an event.
- **Parameters**: `eventId` - Event identifier
- **Returns**: `Future<void>`
- **Side effects**:
  - Decrements user's event count
  - Notifies guests of cancellation

##### `getUserEvents(String userId)`
Gets all events created by a user.
- **Parameters**: `userId` - User identifier
- **Returns**: `Stream<List<EventModel>>`

##### `getUpcomingEvents({int limit = 20})`
Gets upcoming public events.
- **Parameters**: `limit` - Max number of events
- **Returns**: `Stream<List<EventModel>>`
- **Filters**: Only future events
- **Sorted**: By event date (soonest first)

##### `getAttendingEvents(String userId)`
Gets events a user is attending.
- **Parameters**: `userId` - User identifier
- **Returns**: `Stream<List<EventModel>>`
- **Filters**: Where user RSVP'd "Going" or "Maybe"

##### `updateRSVP(String eventId, String userId, String status)`
Updates a user's RSVP status.
- **Parameters**:
  - `eventId` - Event identifier
  - `userId` - User identifier
  - `status` - RSVP status: "Going", "Maybe", "Declined"
- **Returns**: `Future<void>`
- **Side effects**: Updates event's guest list

##### `inviteGuests(String eventId, List<String> userIds)`
Invites users to an event.
- **Parameters**:
  - `eventId` - Event identifier
  - `userIds` - List of user IDs to invite
- **Returns**: `Future<void>`
- **Side effects**: Creates notifications for invitees

##### `removeGuest(String eventId, String userId)`
Removes a guest from an event.
- **Parameters**:
  - `eventId` - Event identifier
  - `userId` - User to remove
- **Returns**: `Future<void>`

---

### CommentRepository

**File**: `lib/data/repositories/comment_repository.dart`

#### Purpose
Manages comments on recipes and events.

#### Key Methods

##### `createComment(CommentModel comment)`
Creates a new comment.
- **Parameters**: `comment` - Comment data
- **Returns**: `Future<String>` - Created comment ID
- **Side effects**:
  - Increments target's comment count
  - Creates notification for target author

##### `getComment(String commentId)`
Retrieves a comment by ID.
- **Parameters**: `commentId` - Comment identifier
- **Returns**: `Future<CommentModel?>`

##### `getCommentsForTarget(String targetType, String targetId)`
Gets all comments for a recipe or event.
- **Parameters**:
  - `targetType` - "recipe" or "event"
  - `targetId` - Target identifier
- **Returns**: `Stream<List<CommentModel>>`
- **Sorted**: By creation date (newest first)

##### `updateComment(CommentModel comment)`
Updates an existing comment.
- **Parameters**: `comment` - Updated comment data
- **Returns**: `Future<void>`
- **Validates**: User must be comment author

##### `deleteComment(String commentId)`
Deletes a comment.
- **Parameters**: `commentId` - Comment identifier
- **Returns**: `Future<void>`
- **Side effects**: Decrements target's comment count

##### `likeComment(String commentId, String userId)`
Adds a like to a comment.
- **Parameters**:
  - `commentId` - Comment identifier
  - `userId` - User who liked
- **Returns**: `Future<void>`

##### `unlikeComment(String commentId, String userId)`
Removes a like from a comment.
- **Parameters**:
  - `commentId` - Comment identifier
  - `userId` - User who unliked
- **Returns**: `Future<void>`

---

### RatingRepository

**File**: `lib/data/repositories/rating_repository.dart`

#### Purpose
Manages recipe ratings (1-5 stars).

#### Key Methods

##### `createOrUpdateRating(RatingModel rating)`
Creates or updates a rating.
- **Parameters**: `rating` - Rating data
- **Returns**: `Future<void>`
- **Note**: One rating per user per recipe
- **Side effects**: Updates recipe's average rating

##### `getRating(String userId, String recipeId)`
Gets a user's rating for a recipe.
- **Parameters**:
  - `userId` - User identifier
  - `recipeId` - Recipe identifier
- **Returns**: `Future<RatingModel?>`

##### `getRecipeRatings(String recipeId)`
Gets all ratings for a recipe.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Stream<List<RatingModel>>`

##### `deleteRating(String userId, String recipeId)`
Deletes a rating.
- **Parameters**:
  - `userId` - User identifier
  - `recipeId` - Recipe identifier
- **Returns**: `Future<void>`
- **Side effects**: Updates recipe's average rating

##### `calculateAverageRating(String recipeId)`
Recalculates a recipe's average rating.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Future<double>`
- **Usage**: Called after rating changes

---

### MadeItRepository

**File**: `lib/data/repositories/made_it_repository.dart`

#### Purpose
Manages "I Made This" posts where users share their cooking results.

#### Key Methods

##### `createMadeItPost(MadeItModel post)`
Creates a new "I Made This" post.
- **Parameters**: `post` - Post data
- **Returns**: `Future<String>` - Created post ID
- **Side effects**:
  - Increments recipe's `madeItCount`
  - Creates activity feed item

##### `getMadeItPost(String postId)`
Retrieves a post by ID.
- **Parameters**: `postId` - Post identifier
- **Returns**: `Future<MadeItModel?>`

##### `getUserMadeItPosts(String userId)`
Gets all posts by a user.
- **Parameters**: `userId` - User identifier
- **Returns**: `Stream<List<MadeItModel>>`

##### `getRecipeMadeItPosts(String recipeId)`
Gets all posts for a recipe.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Stream<List<MadeItModel>>`

##### `updateMadeItPost(MadeItModel post)`
Updates a post.
- **Parameters**: `post` - Updated post data
- **Returns**: `Future<void>`

##### `deleteMadeItPost(String postId)`
Deletes a post.
- **Parameters**: `postId` - Post identifier
- **Returns**: `Future<void>`
- **Side effects**: Decrements recipe's `madeItCount`

##### `likeMadeItPost(String postId, String userId)`
Adds a like to a post.
- **Parameters**:
  - `postId` - Post identifier
  - `userId` - User who liked
- **Returns**: `Future<void>`

---

### ShoppingListRepository

**File**: `lib/data/repositories/shopping_list_repository.dart`

#### Purpose
Manages shopping lists generated from recipes.

#### Key Methods

##### `createShoppingList(ShoppingListModel list)`
Creates a new shopping list.
- **Parameters**: `list` - Shopping list data
- **Returns**: `Future<String>` - Created list ID

##### `getShoppingList(String listId)`
Retrieves a shopping list by ID.
- **Parameters**: `listId` - List identifier
- **Returns**: `Future<ShoppingListModel?>`

##### `getUserShoppingLists(String userId)`
Gets all shopping lists for a user.
- **Parameters**: `userId` - User identifier
- **Returns**: `Stream<List<ShoppingListModel>>`

##### `updateShoppingList(ShoppingListModel list)`
Updates a shopping list.
- **Parameters**: `list` - Updated list data
- **Returns**: `Future<void>`

##### `deleteShoppingList(String listId)`
Deletes a shopping list.
- **Parameters**: `listId` - List identifier
- **Returns**: `Future<void>`

##### `generateFromRecipes(List<String> recipeIds, String userId)`
Generates a shopping list from multiple recipes.
- **Parameters**:
  - `recipeIds` - List of recipe IDs
  - `userId` - User identifier
- **Returns**: `Future<ShoppingListModel>`
- **Logic**: Consolidates duplicate ingredients

##### `toggleItemChecked(String listId, String itemId)`
Toggles an item's checked status.
- **Parameters**:
  - `listId` - List identifier
  - `itemId` - Item identifier
- **Returns**: `Future<void>`

---

### NotificationRepository

**File**: `lib/data/repositories/notification_repository.dart`

#### Purpose
Manages in-app notifications.

#### Key Methods

##### `createNotification(NotificationModel notification)`
Creates a new notification.
- **Parameters**: `notification` - Notification data
- **Returns**: `Future<String>` - Created notification ID

##### `getUserNotifications(String userId)`
Gets all notifications for a user.
- **Parameters**: `userId` - User identifier
- **Returns**: `Stream<List<NotificationModel>>`
- **Sorted**: By creation date (newest first)

##### `getUnreadCount(String userId)`
Gets count of unread notifications.
- **Parameters**: `userId` - User identifier
- **Returns**: `Future<int>`

##### `markAsRead(String notificationId)`
Marks a notification as read.
- **Parameters**: `notificationId` - Notification identifier
- **Returns**: `Future<void>`

##### `markAllAsRead(String userId)`
Marks all user notifications as read.
- **Parameters**: `userId` - User identifier
- **Returns**: `Future<void>`

##### `deleteNotification(String notificationId)`
Deletes a notification.
- **Parameters**: `notificationId` - Notification identifier
- **Returns**: `Future<void>`

---

### ActivityRepository

**File**: `lib/data/repositories/activity_repository.dart`

#### Purpose
Manages activity feed showing actions by followed users.

#### Key Methods

##### `createActivity(ActivityModel activity)`
Creates a new activity item.
- **Parameters**: `activity` - Activity data
- **Returns**: `Future<String>` - Created activity ID

##### `getActivityFeed(String userId, {int limit = 20})`
Gets activity feed for a user.
- **Parameters**:
  - `userId` - User identifier
  - `limit` - Max items (default: 20)
- **Returns**: `Stream<List<ActivityModel>>`
- **Filters**: Only activities from followed users
- **Sorted**: By creation date (newest first)

##### `getUserActivities(String userId)`
Gets all activities by a specific user.
- **Parameters**: `userId` - User identifier
- **Returns**: `Stream<List<ActivityModel>>`

##### `deleteActivity(String activityId)`
Deletes an activity item.
- **Parameters**: `activityId` - Activity identifier
- **Returns**: `Future<void>`

---

### RecipeCollectionRepository

**File**: `lib/data/repositories/recipe_collection_repository.dart`

#### Purpose
Manages user-created recipe collections/folders.

#### Key Methods

##### `createCollection(RecipeCollectionModel collection)`
Creates a new collection.
- **Parameters**: `collection` - Collection data
- **Returns**: `Future<String>` - Created collection ID

##### `getCollection(String collectionId)`
Retrieves a collection by ID.
- **Parameters**: `collectionId` - Collection identifier
- **Returns**: `Future<RecipeCollectionModel?>`

##### `getUserCollections(String userId)`
Gets all collections for a user.
- **Parameters**: `userId` - User identifier
- **Returns**: `Stream<List<RecipeCollectionModel>>`

##### `updateCollection(RecipeCollectionModel collection)`
Updates a collection.
- **Parameters**: `collection` - Updated collection data
- **Returns**: `Future<void>`

##### `deleteCollection(String collectionId)`
Deletes a collection.
- **Parameters**: `collectionId` - Collection identifier
- **Returns**: `Future<void>`

##### `addRecipeToCollection(String collectionId, String recipeId)`
Adds a recipe to a collection.
- **Parameters**:
  - `collectionId` - Collection identifier
  - `recipeId` - Recipe identifier
- **Returns**: `Future<void>`

##### `removeRecipeFromCollection(String collectionId, String recipeId)`
Removes a recipe from a collection.
- **Parameters**:
  - `collectionId` - Collection identifier
  - `recipeId` - Recipe identifier
- **Returns**: `Future<void>`

---

## Services

### AuthService

**File**: `lib/data/services/auth_service.dart`

#### Purpose
Manages Firebase Authentication.

#### Key Methods

##### `signUpWithEmail(String email, String password, String displayName)`
Creates a new account with email/password.
- **Parameters**:
  - `email` - User's email
  - `password` - User's password
  - `displayName` - User's display name
- **Returns**: `Future<User>`
- **Side effects**: Creates user profile in Firestore

##### `signInWithEmail(String email, String password)`
Signs in with email/password.
- **Parameters**:
  - `email` - User's email
  - `password` - User's password
- **Returns**: `Future<User>`

##### `signInWithGoogle()`
Signs in with Google account.
- **Returns**: `Future<User>`
- **Side effects**: Creates user profile if first time

##### `signOut()`
Signs out current user.
- **Returns**: `Future<void>`

##### `getCurrentUser()`
Gets currently authenticated user.
- **Returns**: `User?`

##### `authStateChanges()`
Stream of authentication state changes.
- **Returns**: `Stream<User?>`
- **Usage**: Listen for login/logout events

##### `resetPassword(String email)`
Sends password reset email.
- **Parameters**: `email` - User's email
- **Returns**: `Future<void>`

##### `updateProfile({String? displayName, String? photoURL})`
Updates user's auth profile.
- **Parameters**:
  - `displayName` - New display name (optional)
  - `photoURL` - New photo URL (optional)
- **Returns**: `Future<void>`

---

### StorageService

**File**: `lib/data/services/storage_service.dart`

#### Purpose
Manages Firebase Storage file uploads/downloads.

#### Key Methods

##### `uploadProfilePicture(String userId, File imageFile)`
Uploads a user's profile picture.
- **Parameters**:
  - `userId` - User identifier
  - `imageFile` - Image file to upload
- **Returns**: `Future<String>` - Download URL
- **Constraints**: Max 5MB

##### `uploadRecipePhoto(String recipeId, File imageFile)`
Uploads a recipe photo.
- **Parameters**:
  - `recipeId` - Recipe identifier
  - `imageFile` - Image file to upload
- **Returns**: `Future<String>` - Download URL
- **Constraints**: Max 10MB

##### `uploadEventPhoto(String eventId, File imageFile)`
Uploads an event photo.
- **Parameters**:
  - `eventId` - Event identifier
  - `imageFile` - Image file to upload
- **Returns**: `Future<String>` - Download URL
- **Constraints**: Max 10MB

##### `uploadMadeItPhoto(String postId, File imageFile)`
Uploads a "Made It" post photo.
- **Parameters**:
  - `postId` - Post identifier
  - `imageFile` - Image file to upload
- **Returns**: `Future<String>` - Download URL

##### `deleteFile(String fileUrl)`
Deletes a file from Storage.
- **Parameters**: `fileUrl` - Full download URL
- **Returns**: `Future<void>`

##### `deleteRecipePhotos(String recipeId)`
Deletes all photos for a recipe.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Future<void>`

---

### NotificationService

**File**: `lib/data/services/notification_service.dart`

#### Purpose
Creates in-app notifications for user actions.

#### Key Methods

##### `notifyFollow(String followerId, String followedId)`
Notifies user of new follower.
- **Parameters**:
  - `followerId` - ID of follower
  - `followedId` - ID of followed user
- **Returns**: `Future<void>`

##### `notifyLike(String likerId, String targetType, String targetId)`
Notifies user of a like.
- **Parameters**:
  - `likerId` - User who liked
  - `targetType` - "recipe", "event", "made_it", etc.
  - `targetId` - Target identifier
- **Returns**: `Future<void>`

##### `notifyComment(String commenterId, String targetType, String targetId)`
Notifies user of a comment.
- **Parameters**:
  - `commenterId` - User who commented
  - `targetType` - "recipe" or "event"
  - `targetId` - Target identifier
- **Returns**: `Future<void>`

##### `notifyRating(String raterId, String recipeId)`
Notifies user of a recipe rating.
- **Parameters**:
  - `raterId` - User who rated
  - `recipeId` - Recipe identifier
- **Returns**: `Future<void>`

##### `notifyMadeIt(String userId, String recipeId)`
Notifies recipe author of "Made It" post.
- **Parameters**:
  - `userId` - User who made it
  - `recipeId` - Recipe identifier
- **Returns**: `Future<void>`

##### `notifyFork(String forkerId, String recipeId)`
Notifies recipe author of fork.
- **Parameters**:
  - `forkerId` - User who forked
  - `recipeId` - Original recipe identifier
- **Returns**: `Future<void>`

##### `notifyEventInvite(String eventId, List<String> userIds)`
Notifies users of event invitation.
- **Parameters**:
  - `eventId` - Event identifier
  - `userIds` - List of invited user IDs
- **Returns**: `Future<void>`

---

### PushNotificationService

**File**: `lib/data/services/push_notification_service.dart`

#### Purpose
Manages Firebase Cloud Messaging (FCM) push notifications.

#### Key Methods

##### `initialize()`
Initializes FCM and requests permissions.
- **Returns**: `Future<void>`
- **Side effects**: Requests notification permissions

##### `getToken()`
Gets the FCM device token.
- **Returns**: `Future<String?>`
- **Usage**: Store token in user document

##### `subscribeToTopic(String topic)`
Subscribes device to a topic.
- **Parameters**: `topic` - Topic name
- **Returns**: `Future<void>`
- **Example topics**: "all_users", "recipe_updates"

##### `unsubscribeFromTopic(String topic)`
Unsubscribes device from a topic.
- **Parameters**: `topic` - Topic name
- **Returns**: `Future<void>`

##### `onMessage()`
Stream of foreground messages.
- **Returns**: `Stream<RemoteMessage>`
- **Usage**: Handle notifications while app is open

##### `onMessageOpenedApp()`
Stream of messages that opened the app.
- **Returns**: `Stream<RemoteMessage>`
- **Usage**: Handle deep links from notifications

---

### DynamicLinkService

**File**: `lib/data/services/dynamic_link_service.dart`

#### Purpose
Manages Firebase Dynamic Links for deep linking and sharing.

#### Key Methods

##### `createRecipeLink(String recipeId)`
Creates a shareable link for a recipe.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Future<String>` - Short dynamic link URL
- **Usage**: Share recipes on social media

##### `createEventLink(String eventId)`
Creates a shareable link for an event.
- **Parameters**: `eventId` - Event identifier
- **Returns**: `Future<String>` - Short dynamic link URL

##### `createUserProfileLink(String userId)`
Creates a shareable link for a user profile.
- **Parameters**: `userId` - User identifier
- **Returns**: `Future<String>` - Short dynamic link URL

##### `handleDynamicLink(PendingDynamicLinkData linkData)`
Processes an incoming dynamic link.
- **Parameters**: `linkData` - Link data from Firebase
- **Returns**: `Future<void>`
- **Side effects**: Navigates to appropriate screen

##### `getInitialLink()`
Gets link that opened the app.
- **Returns**: `Future<PendingDynamicLinkData?>`
- **Usage**: Call on app startup

##### `onLink()`
Stream of dynamic links while app is running.
- **Returns**: `Stream<PendingDynamicLinkData>`
- **Usage**: Handle links while app is active

---

### AnalyticsService

**File**: `lib/data/services/analytics_service.dart`

#### Purpose
Tracks user behavior with Firebase Analytics.

#### Key Methods

##### `logEvent(String name, {Map<String, dynamic>? parameters})`
Logs a custom analytics event.
- **Parameters**:
  - `name` - Event name
  - `parameters` - Optional event parameters
- **Returns**: `Future<void>`

##### `logRecipeView(String recipeId)`
Logs a recipe view event.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Future<void>`

##### `logRecipeCreate(String recipeId)`
Logs recipe creation.
- **Parameters**: `recipeId` - Created recipe ID
- **Returns**: `Future<void>`

##### `logEventView(String eventId)`
Logs an event view.
- **Parameters**: `eventId` - Event identifier
- **Returns**: `Future<void>`

##### `logSearch(String query, String category)`
Logs a search query.
- **Parameters**:
  - `query` - Search term
  - `category` - Search category
- **Returns**: `Future<void>`

##### `logShare(String contentType, String contentId)`
Logs content sharing.
- **Parameters**:
  - `contentType` - "recipe", "event", etc.
  - `contentId` - Content identifier
- **Returns**: `Future<void>`

##### `setUserId(String userId)`
Sets the user ID for analytics.
- **Parameters**: `userId` - User identifier
- **Returns**: `Future<void>`

##### `setUserProperty(String name, String value)`
Sets a user property.
- **Parameters**:
  - `name` - Property name
  - `value` - Property value
- **Returns**: `Future<void>`

---

### OfflineCacheService

**File**: `lib/data/services/offline_cache_service.dart`

#### Purpose
Manages offline data caching for better performance.

#### Key Methods

##### `initialize()`
Initializes cache storage.
- **Returns**: `Future<void>`

##### `cacheRecipe(RecipeModel recipe)`
Caches a recipe locally.
- **Parameters**: `recipe` - Recipe to cache
- **Returns**: `Future<void>`

##### `getCachedRecipe(String recipeId)`
Retrieves a cached recipe.
- **Parameters**: `recipeId` - Recipe identifier
- **Returns**: `Future<RecipeModel?>`

##### `cacheUserProfile(UserModel user)`
Caches a user profile.
- **Parameters**: `user` - User to cache
- **Returns**: `Future<void>`

##### `getCachedUserProfile(String userId)`
Retrieves a cached user profile.
- **Parameters**: `userId` - User identifier
- **Returns**: `Future<UserModel?>`

##### `clearCache()`
Clears all cached data.
- **Returns**: `Future<void>`

##### `getCacheSize()`
Gets total cache size in bytes.
- **Returns**: `Future<int>`

---

## Error Handling

### Common Error Types

#### FirebaseException
```dart
try {
  await repository.createRecipe(recipe);
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    // Handle permission error
  } else if (e.code == 'unavailable') {
    // Handle offline error
  }
}
```

#### Common Firebase Error Codes
- `permission-denied`: Security rules blocked operation
- `unavailable`: No network connection
- `not-found`: Document doesn't exist
- `already-exists`: Duplicate document
- `deadline-exceeded`: Operation timeout
- `resource-exhausted`: Quota exceeded

### Best Practices

1. **Always Handle Errors**: Wrap Firebase calls in try-catch blocks
2. **User-Friendly Messages**: Convert error codes to readable messages
3. **Retry Logic**: Implement retry for transient failures
4. **Offline Support**: Handle offline gracefully
5. **Logging**: Log errors for debugging (but not sensitive data)

---

## Best Practices

### Repository Usage

1. **Use Streams for Real-time Data**:
```dart
// Good
final recipes = ref.watch(recipeListProvider);

// Bad - doesn't update
final recipes = await repository.getUserRecipes(userId);
```

2. **Handle Null Returns**:
```dart
final user = await repository.getUser(userId);
if (user == null) {
  // Handle user not found
}
```

3. **Use Batch Operations**:
```dart
// Good - atomic operation
await FirebaseFirestore.instance.runTransaction((transaction) async {
  transaction.update(recipeRef, {'likeCount': FieldValue.increment(1)});
  transaction.set(likeRef, {'userId': userId, 'recipeId': recipeId});
});

// Bad - not atomic
await repository.incrementLikeCount(recipeId);
await repository.createLike(userId, recipeId);
```

### Service Usage

1. **Singleton Services**:
```dart
// Service should be singleton
final authService = AuthService(); // Same instance every time
```

2. **Dispose Resources**:
```dart
// Clean up subscriptions
final subscription = repository.getUserRecipes(userId).listen((recipes) {
  // Handle updates
});

// Later
await subscription.cancel();
```

3. **Combine Services**:
```dart
// Good - coordinated operations
await storageService.uploadRecipePhoto(recipeId, image);
final photoUrl = await storageService.getDownloadUrl(path);
await recipeRepository.addPhotoUrl(recipeId, photoUrl);
```

---

**Last Updated**: 2025-11-22
**API Version**: 1.0
**Total Repositories**: 10
**Total Services**: 7
