# Recipe & Event Social Platform

A social platform that connects recipe management with event hosting, allowing home cooks to share their adapted recipes in the context of real gatherings.

## Overview

This is the **MVP (Minimum Viable Product)** foundation for the Recipe & Event Social Platform. The project implements:

- ✅ Complete project structure following clean architecture
- ✅ Comprehensive data models (User, Recipe, Event, ShoppingList, Notification)
- ✅ Firebase integration setup (Firestore, Auth, Storage)
- ✅ Authentication service (Email/Password, Google Sign-In)
- ✅ Data repositories for all core entities
- ✅ Firebase security rules (Firestore & Storage)
- ✅ Basic UI screens (Splash, Login, Signup, Home)
- ✅ Theme and constants configuration

## Project Structure

```
lib/
├── core/
│   ├── config/          # Firebase configuration
│   ├── constants/       # App constants, theme, strings
│   ├── errors/          # Error handling (TODO)
│   └── utils/           # Helper functions (TODO)
├── data/
│   ├── models/          # Data models
│   │   ├── user_model.dart
│   │   ├── recipe_model.dart
│   │   ├── event_model.dart
│   │   ├── shopping_list_model.dart
│   │   └── notification_model.dart
│   ├── repositories/    # Data access layer
│   │   ├── user_repository.dart
│   │   ├── recipe_repository.dart
│   │   └── event_repository.dart
│   └── services/        # External services
│       ├── auth_service.dart
│       └── storage_service.dart
├── domain/              # Business entities and use cases (TODO)
├── presentation/        # UI layer
│   ├── screens/
│   │   ├── auth/       # Login, Signup
│   │   ├── home/       # Home screen
│   │   ├── recipes/    # Recipe screens (TODO)
│   │   ├── events/     # Event screens (TODO)
│   │   └── profile/    # Profile screens (TODO)
│   ├── widgets/        # Reusable components (TODO)
│   └── providers/      # State management (TODO)
└── main.dart
```

## Features Implemented

### ✅ Authentication
- Email/Password authentication
- Google Sign-In
- User session management
- Password reset functionality
- Email verification support

### ✅ Data Models
- **User**: Complete user profile with preferences and privacy settings
- **Recipe**: Full recipe model with ingredients, steps, photos, and modification tracking
- **Event**: Event management with guest lists, RSVPs, and menu planning
- **Shopping List**: Auto-generated from recipes with categorization
- **Notification**: Push notification support for various event types

### ✅ Repositories
- **UserRepository**: User CRUD, following/followers system, search
- **RecipeRepository**: Recipe CRUD, forking, ratings, trending recipes
- **EventRepository**: Event CRUD, RSVP management, recipe requests

### ✅ Storage Service
- Profile photo upload
- Recipe photo upload (single and multiple)
- Event photo upload
- File deletion and cleanup

### ✅ Firebase Security Rules
- Firestore rules for users, recipes, events, and social features
- Storage rules with file size limits and type validation
- Privacy-aware access control

## Setup Instructions

### 1. Prerequisites

- Flutter SDK 3.10 or higher
- Dart SDK 3.10 or higher
- Firebase account
- (Optional) Google Cloud account for additional services

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable the following services:
   - Authentication (Email/Password, Google)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Messaging (for notifications)
   - Firebase Dynamic Links (for recipe sharing)

#### Configure Firebase for Flutter

**Option 1: Using FlutterFire CLI (Recommended)**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure
```

**Option 2: Manual Configuration**

1. For Android:
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/`

2. For iOS:
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/`

3. For Web:
   - Copy Firebase config object
   - Update `lib/core/config/firebase_config.dart` with your credentials

#### Update Firebase Configuration

Edit `lib/core/config/firebase_config.dart` and replace the placeholder values:

```dart
apiKey: 'YOUR_API_KEY',
appId: 'YOUR_APP_ID',
messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
projectId: 'YOUR_PROJECT_ID',
storageBucket: 'YOUR_STORAGE_BUCKET',
```

### 4. Deploy Firebase Security Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage
```

### 5. Enable Google Sign-In

1. In Firebase Console, go to Authentication > Sign-in method
2. Enable Google provider
3. For Android:
   - Add SHA-1 and SHA-256 fingerprints to Firebase project settings
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

4. For iOS:
   - Download updated `GoogleService-Info.plist`
   - Add URL schemes to `ios/Runner/Info.plist`

### 6. Run the App

```bash
# Run on connected device or emulator
flutter run

# For web
flutter run -d chrome

# For specific platform
flutter run -d android
flutter run -d ios
```

## Environment Setup

Create a `.env` file in the root directory (optional, for additional configuration):

```env
FIREBASE_PROJECT_ID=your-project-id
API_BASE_URL=your-api-url
```

## Cloud Functions (Optional)

The `functions/` directory is prepared for Python Cloud Functions:

```bash
cd functions
pip install -r requirements.txt
firebase deploy --only functions
```

### Functions to Implement:
- Recipe URL parser (using recipe-scrapers)
- Shopping list generator
- QR code generator for events
- Notification triggers

## Next Steps - Features to Implement

### Phase 1: Core Recipe Management
- [ ] Recipe creation and editing UI
- [ ] Recipe detail view with photos
- [ ] Recipe list and search
- [ ] Photo upload and management
- [ ] Recipe categories and tags

### Phase 2: Event Management
- [ ] Event creation wizard
- [ ] Guest management and RSVP system
- [ ] Event calendar view
- [ ] QR code generation for events
- [ ] Post-event recap

### Phase 3: Social Features
- [ ] User profiles with recipe collections
- [ ] Following/followers system
- [ ] Recipe comments and ratings
- [ ] "I Made This" posts
- [ ] Activity feed

### Phase 4: Advanced Features
- [ ] Recipe forking with modification tracking
- [ ] Side-by-side recipe comparison
- [ ] Shopping list generation
- [ ] Recipe import from URLs
- [ ] Push notifications
- [ ] Firebase Dynamic Links for sharing
- [ ] Search and discovery
- [ ] Recipe collections/cookbooks

### Phase 5: Polish & Optimization
- [ ] Offline support
- [ ] Image optimization
- [ ] Performance improvements
- [ ] Analytics integration
- [ ] Testing (unit, widget, integration)
- [ ] CI/CD pipeline

## Tech Stack

- **Frontend**: Flutter 3.x (iOS, Android, Web)
- **State Management**: Riverpod
- **Backend**: Firebase
  - Firestore (Database)
  - Firebase Auth (Authentication)
  - Cloud Storage (File storage)
  - Cloud Functions (Python 3.11)
  - Cloud Messaging (Notifications)
  - Dynamic Links (Sharing)
- **Navigation**: go_router (to be implemented)
- **UI Components**: Material Design 3

## Key Dependencies

```yaml
# Firebase
firebase_core: ^3.15.2
firebase_auth: ^5.7.0
cloud_firestore: ^5.6.12
firebase_storage: ^12.4.10
firebase_messaging: ^15.2.10

# State Management
flutter_riverpod: ^3.0.3

# Navigation
go_router: ^17.0.0

# UI Components
cached_network_image: ^3.3.0
image_picker: ^1.0.5
flutter_rating_bar: ^4.0.1

# Utilities
uuid: ^4.2.0
share_plus: ^12.0.1
qr_flutter: ^4.1.0
mobile_scanner: ^7.1.3
```

## Architecture

This project follows **Clean Architecture** principles:

- **Presentation Layer**: UI screens and widgets
- **Domain Layer**: Business logic and use cases (to be implemented)
- **Data Layer**: Repositories and data sources

### Design Patterns Used:
- Repository Pattern (data access)
- Provider Pattern (state management)
- Factory Pattern (model creation)
- Singleton Pattern (services)

## Firebase Cost Estimation

### Free Tier Limits:
- Firestore: 50K reads, 20K writes, 20K deletes per day
- Storage: 5GB stored, 1GB downloaded per day
- Functions: 2M invocations per month
- Hosting: 10GB storage, 360MB/day transfer

### Estimated Monthly Cost (1,000 active users):
- **$20-35/month** on Firebase free tier
- Scale to $150-255/month for 10,000 users

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## Contributing

This is a foundation project. To continue development:

1. Create feature branches for new features
2. Follow the existing architecture and naming conventions
3. Add tests for new features
4. Update documentation

## Documentation

- [Technical Specification](docs/TECHNICAL_SPEC.md) - Full technical specification
- [API Documentation](docs/API.md) - API endpoints and usage
- [Data Models](docs/DATA_MODELS.md) - Detailed data model documentation

## Troubleshooting

### Firebase Initialization Error
- Verify Firebase configuration in `lib/core/config/firebase_config.dart`
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) are in place

### Google Sign-In Not Working
- Add SHA-1 fingerprint to Firebase project
- Enable Google provider in Firebase Authentication
- Check iOS URL schemes are configured

### Build Errors
- Run `flutter clean && flutter pub get`
- Update Flutter: `flutter upgrade`
- Check minimum SDK versions in `pubspec.yaml`

## License

Copyright © 2024 Recipe & Event Social Platform

## Contact

For questions or support, please open an issue in the repository.

---

**Status**: MVP Foundation Complete ✅
**Next**: Continue implementing Phase 1 features

Built with ❤️ using Flutter and Firebase
