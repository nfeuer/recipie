# Data Models Documentation

## Overview

This document provides comprehensive documentation for all data models used in the Recipe & Event Platform. Each model represents a specific entity in the application with clearly defined properties, relationships, and validation rules.

## Table of Contents

1. [Model Conventions](#model-conventions)
2. [User Model](#user-model)
3. [Recipe Model](#recipe-model)
4. [Event Model](#event-model)
5. [Comment Model](#comment-model)
6. [Rating Model](#rating-model)
7. [Made It Model](#made-it-model)
8. [Shopping List Model](#shopping-list-model)
9. [Notification Model](#notification-model)
10. [Activity Model](#activity-model)
11. [Recipe Collection Model](#recipe-collection-model)
12. [Firestore Collection Structure](#firestore-collection-structure)

---

## Model Conventions

All models in this application follow these conventions:

### Standard Structure
```dart
class ModelName {
  // Properties
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor
  const ModelName({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  // Serialization
  factory ModelName.fromMap(Map<String, dynamic> map) { }
  Map<String, dynamic> toMap() { }

  // Utility methods
  ModelName copyWith({...}) { }
}
```

### Common Patterns

1. **Timestamps**: All models include `createdAt` and `updatedAt` timestamps
2. **IDs**: All models have a unique `id` field (String)
3. **Serialization**: All models support `fromMap()` and `toMap()` for Firestore
4. **Immutability**: Models are immutable with `const` constructors
5. **CopyWith**: All models support `copyWith()` for creating modified copies

---

## User Model

**File**: `lib/data/models/user_model.dart`
**Collection**: `users`

### Description
Represents a user's profile information and account metadata.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique user identifier (matches Firebase Auth UID) |
| `email` | String | Yes | User's email address |
| `displayName` | String | Yes | User's display name |
| `bio` | String? | No | Short biography/description |
| `photoUrl` | String? | No | Profile picture URL (from Firebase Storage) |
| `createdAt` | DateTime | Yes | Account creation timestamp |
| `updatedAt` | DateTime | Yes | Last profile update timestamp |
| `followerCount` | int | Yes | Number of users following this user |
| `followingCount` | int | Yes | Number of users this user follows |
| `recipeCount` | int | Yes | Total number of recipes created |
| `eventCount` | int | Yes | Total number of events created |
| `isPrivate` | bool | Yes | Whether the profile is private (default: false) |

### Relationships
- **One-to-Many**: User → Recipes (via `authorId`)
- **One-to-Many**: User → Events (via `creatorId`)
- **Many-to-Many**: User ↔ User (via `following` collection)

### Example
```dart
UserModel(
  id: 'user_123',
  email: 'chef@example.com',
  displayName: 'Chef Julia',
  bio: 'Home cook sharing family recipes',
  photoUrl: 'https://storage.googleapis.com/...',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  followerCount: 152,
  followingCount: 89,
  recipeCount: 23,
  eventCount: 5,
  isPrivate: false,
)
```

---

## Recipe Model

**File**: `lib/data/models/recipe_model.dart`
**Collection**: `recipes`

### Description
Represents a recipe with ingredients, instructions, and metadata.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique recipe identifier |
| `title` | String | Yes | Recipe title/name |
| `description` | String | Yes | Brief description of the recipe |
| `authorId` | String | Yes | User ID of recipe creator |
| `authorName` | String | Yes | Display name of creator (denormalized) |
| `authorPhotoUrl` | String? | No | Creator's photo URL (denormalized) |
| `photoUrls` | List\<String\> | Yes | List of recipe photo URLs (max 10) |
| `ingredients` | List\<Ingredient\> | Yes | List of ingredients (max 50) |
| `steps` | List\<RecipeStep\> | Yes | Cooking instructions (max 30) |
| `servings` | int | Yes | Number of servings |
| `prepTimeMinutes` | int | Yes | Preparation time in minutes |
| `cookTimeMinutes` | int | Yes | Cooking time in minutes |
| `difficulty` | String | Yes | Difficulty level: Easy, Medium, Hard |
| `category` | String | Yes | Recipe category (Appetizer, Main Course, etc.) |
| `cuisineType` | String? | No | Cuisine type (Italian, Mexican, etc.) |
| `dietaryTags` | List\<String\> | Yes | Dietary tags (Vegetarian, Vegan, etc.) |
| `tags` | List\<String\> | Yes | Additional searchable tags |
| `privacy` | String | Yes | Privacy: Public, Friends Only, Private, Event Only |
| `likeCount` | int | Yes | Number of likes |
| `commentCount` | int | Yes | Number of comments |
| `ratingCount` | int | Yes | Number of ratings |
| `averageRating` | double | Yes | Average rating (0-5) |
| `forkedFromId` | String? | No | ID of original recipe if this is a fork |
| `forkCount` | int | Yes | Number of times this recipe was forked |
| `madeItCount` | int | Yes | Number of "I Made This" posts |
| `createdAt` | DateTime | Yes | Creation timestamp |
| `updatedAt` | DateTime | Yes | Last update timestamp |

### Sub-Models

#### Ingredient
```dart
class Ingredient {
  final String name;        // e.g., "Flour"
  final String? amount;     // e.g., "2", "1/2", "2 1/4"
  final String? unit;       // e.g., "cup", "tsp", "grams"
  final String? notes;      // e.g., "sifted", "room temperature"
}
```

#### RecipeStep
```dart
class RecipeStep {
  final int stepNumber;     // Sequential step number
  final String instruction; // Step instruction text
  final String? photoUrl;   // Optional photo for this step
  final int? timeMinutes;   // Optional time for this step
}
```

### Relationships
- **Many-to-One**: Recipe → User (via `authorId`)
- **One-to-Many**: Recipe → Comments
- **One-to-Many**: Recipe → Ratings
- **One-to-Many**: Recipe → MadeItPosts
- **Self-referential**: Recipe → Recipe (via `forkedFromId`)

### Privacy Levels
- **Public**: Visible to everyone
- **Friends Only**: Visible only to followers
- **Private**: Visible only to creator
- **Event Only**: Visible only to event attendees

### Example
```dart
RecipeModel(
  id: 'recipe_456',
  title: 'Classic Chocolate Chip Cookies',
  description: 'Soft and chewy chocolate chip cookies',
  authorId: 'user_123',
  authorName: 'Chef Julia',
  photoUrls: ['https://storage.../cookie1.jpg'],
  ingredients: [
    Ingredient(name: 'Flour', amount: '2', unit: 'cup'),
    Ingredient(name: 'Sugar', amount: '1', unit: 'cup'),
    // ...
  ],
  steps: [
    RecipeStep(stepNumber: 1, instruction: 'Preheat oven to 350°F'),
    RecipeStep(stepNumber: 2, instruction: 'Mix dry ingredients'),
    // ...
  ],
  servings: 24,
  prepTimeMinutes: 15,
  cookTimeMinutes: 12,
  difficulty: 'Easy',
  category: 'Dessert',
  cuisineType: 'American',
  dietaryTags: ['Vegetarian'],
  tags: ['cookies', 'baking', 'dessert'],
  privacy: 'Public',
  likeCount: 127,
  commentCount: 23,
  ratingCount: 45,
  averageRating: 4.7,
  forkCount: 12,
  madeItCount: 89,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
)
```

---

## Event Model

**File**: `lib/data/models/event_model.dart`
**Collection**: `events`

### Description
Represents a food-related event (dinner party, potluck, etc.) with guest management.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique event identifier |
| `title` | String | Yes | Event title/name |
| `description` | String | Yes | Event description |
| `creatorId` | String | Yes | User ID of event creator |
| `creatorName` | String | Yes | Display name of creator (denormalized) |
| `photoUrls` | List\<String\> | Yes | Event photos (max 50) |
| `eventType` | String | Yes | Type: Dinner Party, Potluck, BBQ, etc. |
| `dateTime` | DateTime | Yes | Event date and time |
| `location` | String | Yes | Event location/address |
| `maxGuests` | int? | No | Maximum number of guests (null = unlimited) |
| `privacy` | String | Yes | Privacy: Public, Friends Only, Private |
| `recipeIds` | List\<String\> | Yes | List of recipe IDs in event menu |
| `guestList` | List\<EventGuest\> | Yes | List of invited/attending guests |
| `commentCount` | int | Yes | Number of comments |
| `createdAt` | DateTime | Yes | Creation timestamp |
| `updatedAt` | DateTime | Yes | Last update timestamp |

### Sub-Models

#### EventGuest
```dart
class EventGuest {
  final String userId;      // Guest user ID
  final String userName;    // Guest display name
  final String? photoUrl;   // Guest photo URL
  final String status;      // RSVP: Going, Maybe, Declined, Pending
  final DateTime respondedAt; // When they RSVPed
}
```

### Relationships
- **Many-to-One**: Event → User (via `creatorId`)
- **Many-to-Many**: Event ↔ Recipe (via `recipeIds`)
- **Many-to-Many**: Event ↔ User (via `guestList`)
- **One-to-Many**: Event → Comments

### Event Types
- Dinner Party
- Potluck
- BBQ
- Holiday Meal
- Brunch
- Cooking Class
- Food Festival
- Other

### RSVP Statuses
- **Pending**: Invitation sent, no response
- **Going**: Guest confirmed attendance
- **Maybe**: Guest is unsure
- **Declined**: Guest declined invitation

### Example
```dart
EventModel(
  id: 'event_789',
  title: 'Summer BBQ Cookout',
  description: 'Annual backyard BBQ with friends',
  creatorId: 'user_123',
  creatorName: 'Chef Julia',
  photoUrls: ['https://storage.../bbq1.jpg'],
  eventType: 'BBQ',
  dateTime: DateTime(2025, 7, 4, 17, 0),
  location: '123 Main St, Anytown, USA',
  maxGuests: 50,
  privacy: 'Public',
  recipeIds: ['recipe_456', 'recipe_789'],
  guestList: [
    EventGuest(
      userId: 'user_456',
      userName: 'John Doe',
      status: 'Going',
      respondedAt: DateTime.now(),
    ),
    // ...
  ],
  commentCount: 12,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
)
```

---

## Comment Model

**File**: `lib/data/models/comment_model.dart`
**Collection**: `comments`

### Description
Represents a comment on a recipe or event.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique comment identifier |
| `authorId` | String | Yes | User ID of comment author |
| `authorName` | String | Yes | Display name of author (denormalized) |
| `authorPhotoUrl` | String? | No | Author's photo URL (denormalized) |
| `targetType` | String | Yes | Type: 'recipe' or 'event' |
| `targetId` | String | Yes | ID of recipe or event |
| `content` | String | Yes | Comment text content |
| `likeCount` | int | Yes | Number of likes on this comment |
| `createdAt` | DateTime | Yes | Creation timestamp |
| `updatedAt` | DateTime | Yes | Last update timestamp |

### Relationships
- **Many-to-One**: Comment → User (via `authorId`)
- **Polymorphic**: Comment → Recipe OR Event (via `targetType` + `targetId`)

---

## Rating Model

**File**: `lib/data/models/rating_model.dart`
**Collection**: `ratings`

### Description
Represents a user's rating of a recipe (1-5 stars).

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique rating identifier |
| `userId` | String | Yes | User ID of rater |
| `userName` | String | Yes | Display name of rater (denormalized) |
| `recipeId` | String | Yes | ID of rated recipe |
| `rating` | int | Yes | Rating value (1-5) |
| `review` | String? | No | Optional text review |
| `createdAt` | DateTime | Yes | Creation timestamp |
| `updatedAt` | DateTime | Yes | Last update timestamp |

### Constraints
- Rating value must be between 1 and 5 (inclusive)
- One rating per user per recipe (composite key: `userId`_`recipeId`)

---

## Made It Model

**File**: `lib/data/models/made_it_model.dart`
**Collection**: `madeIt`

### Description
Represents an "I Made This" post where a user shares their experience making a recipe.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique post identifier |
| `userId` | String | Yes | User ID of post creator |
| `userName` | String | Yes | Display name of creator (denormalized) |
| `userPhotoUrl` | String? | No | Creator's photo URL (denormalized) |
| `recipeId` | String | Yes | ID of recipe that was made |
| `recipeTitle` | String | Yes | Recipe title (denormalized) |
| `photoUrls` | List\<String\> | Yes | Photos of user's creation (max 10) |
| `notes` | String? | No | User's notes/modifications |
| `likeCount` | int | Yes | Number of likes |
| `commentCount` | int | Yes | Number of comments |
| `createdAt` | DateTime | Yes | Creation timestamp |

### Relationships
- **Many-to-One**: MadeIt → User (via `userId`)
- **Many-to-One**: MadeIt → Recipe (via `recipeId`)

---

## Shopping List Model

**File**: `lib/data/models/shopping_list_model.dart`
**Collection**: `shoppingLists`

### Description
Represents a shopping list generated from one or more recipes.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique list identifier |
| `userId` | String | Yes | User ID of list owner |
| `title` | String | Yes | List title/name |
| `recipeIds` | List\<String\> | Yes | Source recipe IDs |
| `items` | List\<ShoppingItem\> | Yes | Shopping list items |
| `createdAt` | DateTime | Yes | Creation timestamp |
| `updatedAt` | DateTime | Yes | Last update timestamp |

### Sub-Models

#### ShoppingItem
```dart
class ShoppingItem {
  final String id;          // Unique item ID
  final String name;        // Ingredient name
  final String? amount;     // Consolidated amount
  final String? unit;       // Unit of measurement
  final bool isChecked;     // Whether item is checked off
  final List<String> recipeIds; // Which recipes need this item
}
```

### Features
- Automatically consolidates duplicate ingredients from multiple recipes
- Supports manual item additions
- Checkbox tracking for shopping

---

## Notification Model

**File**: `lib/data/models/notification_model.dart`
**Collection**: `notifications`

### Description
Represents an in-app notification for user activities.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique notification identifier |
| `userId` | String | Yes | Recipient user ID |
| `type` | String | Yes | Notification type |
| `title` | String | Yes | Notification title |
| `message` | String | Yes | Notification message |
| `actorId` | String? | No | User who triggered notification |
| `actorName` | String? | No | Actor's display name |
| `actorPhotoUrl` | String? | No | Actor's photo URL |
| `targetType` | String? | No | Type: 'recipe', 'event', 'user', etc. |
| `targetId` | String? | No | ID of related entity |
| `isRead` | bool | Yes | Whether notification was read |
| `createdAt` | DateTime | Yes | Creation timestamp |

### Notification Types
- `follow` - Someone followed you
- `like` - Someone liked your recipe/post
- `comment` - Someone commented on your recipe/event
- `rating` - Someone rated your recipe
- `made_it` - Someone made your recipe
- `fork` - Someone forked your recipe
- `event_invite` - You were invited to an event
- `event_update` - An event you're attending was updated

---

## Activity Model

**File**: `lib/data/models/activity_model.dart`
**Collection**: `activities`

### Description
Represents an activity feed item showing actions by followed users.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique activity identifier |
| `actorId` | String | Yes | User who performed the action |
| `actorName` | String | Yes | Actor's display name |
| `actorPhotoUrl` | String? | No | Actor's photo URL |
| `type` | String | Yes | Activity type |
| `targetType` | String | Yes | Type of target entity |
| `targetId` | String | Yes | ID of target entity |
| `targetTitle` | String? | No | Title of target (denormalized) |
| `targetPhotoUrl` | String? | No | Photo of target (denormalized) |
| `createdAt` | DateTime | Yes | Activity timestamp |

### Activity Types
- `created_recipe` - User created a new recipe
- `forked_recipe` - User forked a recipe
- `made_recipe` - User posted "I Made This"
- `rated_recipe` - User rated a recipe
- `created_event` - User created an event
- `joined_event` - User joined an event

---

## Recipe Collection Model

**File**: `lib/data/models/recipe_collection_model.dart`
**Collection**: `recipeCollections`

### Description
Represents a user's custom collection/folder of saved recipes.

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique collection identifier |
| `userId` | String | Yes | Collection owner ID |
| `title` | String | Yes | Collection title/name |
| `description` | String? | No | Collection description |
| `recipeIds` | List\<String\> | Yes | List of recipe IDs in collection |
| `isPrivate` | bool | Yes | Whether collection is private |
| `createdAt` | DateTime | Yes | Creation timestamp |
| `updatedAt` | DateTime | Yes | Last update timestamp |

---

## Firestore Collection Structure

### Top-Level Collections

```
firestore/
├── users/                      # User profiles
│   └── {userId}/              # Document per user
│
├── recipes/                    # Recipe documents
│   └── {recipeId}/            # Document per recipe
│
├── events/                     # Event documents
│   └── {eventId}/             # Document per event
│
├── comments/                   # Comment documents
│   └── {commentId}/           # Document per comment
│
├── ratings/                    # Rating documents
│   └── {ratingId}/            # Document per rating
│
├── madeIt/                     # "I Made This" posts
│   └── {postId}/              # Document per post
│
├── shoppingLists/              # Shopping list documents
│   └── {listId}/              # Document per list
│
├── notifications/              # Notification documents
│   └── {notificationId}/      # Document per notification
│
├── activities/                 # Activity feed documents
│   └── {activityId}/          # Document per activity
│
├── recipeCollections/          # Recipe collections
│   └── {collectionId}/        # Document per collection
│
└── following/                  # Follow relationships
    └── {relationshipId}/      # Document per relationship
```

### Indexes Required

For optimal query performance, create these composite indexes:

```javascript
// Recipes by author, sorted by date
recipes: {
  fields: [
    { authorId: 'ASC' },
    { createdAt: 'DESC' }
  ]
}

// Public recipes by category
recipes: {
  fields: [
    { privacy: 'ASC' },
    { category: 'ASC' },
    { createdAt: 'DESC' }
  ]
}

// Comments for a target
comments: {
  fields: [
    { targetType: 'ASC' },
    { targetId: 'ASC' },
    { createdAt: 'DESC' }
  ]
}

// User's notifications
notifications: {
  fields: [
    { userId: 'ASC' },
    { isRead: 'ASC' },
    { createdAt: 'DESC' }
  ]
}

// Activity feed (for followed users)
activities: {
  fields: [
    { actorId: 'IN' },  // Array of followed user IDs
    { createdAt: 'DESC' }
  ]
}
```

---

## Data Validation Rules

See `firestore.rules` for complete security rules. Key validations:

1. **Authentication**: All write operations require authentication
2. **Ownership**: Users can only modify their own data
3. **Privacy**: Access control based on privacy settings
4. **Size Limits**: Enforced via constants in `app_constants.dart`
5. **Required Fields**: All required fields must be present

---

## Best Practices

1. **Denormalization**: Store frequently accessed data (author name, photo URL) directly in documents
2. **Counters**: Maintain aggregate counts (likeCount, commentCount) for performance
3. **Timestamps**: Always use server timestamps for consistency
4. **Batch Writes**: Use batch operations for related updates
5. **Pagination**: Implement pagination for large collections
6. **Caching**: Leverage Firestore offline persistence

---

**Last Updated**: 2025-11-22
**Schema Version**: 1.0
**Total Models**: 10
