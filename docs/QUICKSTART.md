# Quick Start Guide

## Welcome to Recipe & Event Platform!

This guide will help you get started with the Recipe & Event Platform codebase quickly. Whether you're a new developer joining the project or just exploring the code, this document provides everything you need to get up and running.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [Running the App](#running-the-app)
5. [Project Structure Overview](#project-structure-overview)
6. [Common Development Tasks](#common-development-tasks)
7. [Understanding the Data Flow](#understanding-the-data-flow)
8. [Testing](#testing)
9. [Troubleshooting](#troubleshooting)
10. [Next Steps](#next-steps)

---

## Prerequisites

### Required Software

- **Flutter SDK**: 3.0 or higher
  - Install from: https://flutter.dev/docs/get-started/install
  - Verify with: `flutter --version`

- **Dart SDK**: 3.10 or higher (comes with Flutter)
  - Verify with: `dart --version`

- **IDE** (choose one):
  - VS Code with Flutter/Dart extensions
  - Android Studio with Flutter plugin
  - IntelliJ IDEA with Flutter plugin

- **Git**: For version control
  - Install from: https://git-scm.com/

- **Firebase CLI** (optional but recommended):
  ```bash
  npm install -g firebase-tools
  ```

### Platform-Specific Requirements

#### For Android Development
- Android Studio
- Android SDK (API 21 or higher)
- Android Emulator or physical device

#### For iOS Development (macOS only)
- Xcode 12 or higher
- iOS Simulator or physical device
- CocoaPods: `sudo gem install cocoapods`

#### For Web Development
- Chrome browser

---

## Initial Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd recipie
```

### 2. Install Dependencies

```bash
flutter pub get
```

This command downloads all required packages defined in `pubspec.yaml`.

### 3. Verify Flutter Installation

```bash
flutter doctor
```

Fix any issues reported by `flutter doctor` before proceeding.

---

## Firebase Configuration

The app requires Firebase for authentication, database, storage, and other services.

### Option 1: Use Existing Firebase Project

If a Firebase project is already set up:

1. **Get Firebase configuration files** from the project admin
2. **Place configuration files**:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
   - Web: Update `lib/core/config/firebase_config.dart`

### Option 2: Create New Firebase Project

1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com/
   - Click "Add project"
   - Follow the setup wizard

2. **Enable Required Services**:
   - Authentication (Email/Password, Google Sign-In)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Messaging (FCM)
   - Dynamic Links
   - Analytics
   - Crashlytics

3. **Add Apps to Firebase Project**:

   **For Android**:
   ```bash
   # In Firebase Console, add Android app
   # Package name: com.recipeplatform.recipeApp
   # Download google-services.json
   # Place in: android/app/google-services.json
   ```

   **For iOS**:
   ```bash
   # In Firebase Console, add iOS app
   # Bundle ID: com.recipeplatform.recipeApp
   # Download GoogleService-Info.plist
   # Place in: ios/Runner/GoogleService-Info.plist
   ```

   **For Web**:
   ```bash
   # In Firebase Console, add Web app
   # Copy the config object
   # Update lib/core/config/firebase_config.dart with your values
   ```

4. **Configure Firestore Security Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```
   (Uses `firestore.rules` in project root)

5. **Configure Storage Security Rules**:
   ```bash
   firebase deploy --only storage
   ```
   (Uses `storage.rules` in project root)

### Update Firebase Config

Edit `lib/core/config/firebase_config.dart` and replace placeholders:

```dart
// Replace these with your Firebase project values:
apiKey: 'YOUR_API_KEY',
appId: 'YOUR_APP_ID',
messagingSenderId: 'YOUR_SENDER_ID',
projectId: 'YOUR_PROJECT_ID',
storageBucket: 'YOUR_STORAGE_BUCKET',
// ... etc for each platform
```

---

## Running the App

### Development Mode

#### Run on Android Emulator/Device
```bash
flutter run -d android
```

#### Run on iOS Simulator/Device (macOS only)
```bash
flutter run -d ios
```

#### Run on Web
```bash
flutter run -d chrome
```

#### Run on Windows/macOS/Linux
```bash
flutter run -d windows  # Windows
flutter run -d macos    # macOS
flutter run -d linux    # Linux
```

### Hot Reload

While the app is running:
- **Hot Reload**: Press `r` in the terminal (preserves app state)
- **Hot Restart**: Press `R` in the terminal (resets app state)
- **Quit**: Press `q`

### Build for Production

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS only)
```bash
flutter build ios --release
# Then open in Xcode to archive and distribute
```

#### Web
```bash
flutter build web --release
# Output: build/web/
```

---

## Project Structure Overview

```
lib/
├── main.dart                   # App entry point
├── core/                       # Core utilities
│   ├── config/                 # Firebase & app config
│   ├── constants/              # Constants & theme
│   └── utils/                  # Helper functions
├── data/                       # Data layer
│   ├── models/                 # Data models
│   ├── repositories/           # Data access
│   └── services/               # Business logic
└── presentation/               # UI layer
    ├── providers/              # State management
    ├── screens/                # Full screens
    └── widgets/                # Reusable widgets
```

**For detailed architecture**, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Common Development Tasks

### 1. Creating a New Screen

```dart
// 1. Create screen file
// lib/presentation/screens/my_feature/my_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: const Center(child: Text('Hello!')),
    );
  }
}
```

```dart
// 2. Add route (in router configuration)
GoRoute(
  path: '/my-screen',
  builder: (context, state) => const MyScreen(),
),
```

### 2. Adding a New Provider

```dart
// lib/presentation/providers/my_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple state provider
final counterProvider = StateProvider<int>((ref) => 0);

// Stream provider for real-time data
final myDataProvider = StreamProvider<List<MyModel>>((ref) {
  final repository = ref.read(myRepositoryProvider);
  return repository.getMyDataStream();
});

// Future provider for one-time data fetch
final myAsyncDataProvider = FutureProvider<MyModel>((ref) async {
  final repository = ref.read(myRepositoryProvider);
  return repository.fetchData();
});
```

### 3. Creating a New Model

```dart
// lib/data/models/my_model.dart

class MyModel {
  final String id;
  final String name;
  final DateTime createdAt;

  const MyModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // From Firestore
  factory MyModel.fromMap(Map<String, dynamic> map) {
    return MyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // To Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // CopyWith for immutability
  MyModel copyWith({String? name}) {
    return MyModel(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }
}
```

### 4. Adding a Repository Method

```dart
// In lib/data/repositories/my_repository.dart

Future<void> createItem(MyModel item) async {
  try {
    await _firestore
      .collection('items')
      .doc(item.id)
      .set(item.toMap());
  } on FirebaseException catch (e) {
    print('Error creating item: ${e.code} - ${e.message}');
    rethrow;
  }
}

Stream<List<MyModel>> getItems() {
  return _firestore
    .collection('items')
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => MyModel.fromMap(doc.data()))
      .toList());
}
```

---

## Understanding the Data Flow

### Reading Data (Real-time)

```
1. UI Widget
   ↓
2. ref.watch(myDataProvider) - Watches provider
   ↓
3. Provider calls Repository
   ↓
4. Repository queries Firestore (Stream)
   ↓
5. Firestore emits data changes
   ↓
6. Provider updates
   ↓
7. UI rebuilds automatically
```

### Writing Data

```
1. User Action (button press)
   ↓
2. Call repository method
   ↓
3. Repository writes to Firestore
   ↓
4. Firestore triggers stream update
   ↓
5. Provider receives new data
   ↓
6. UI rebuilds with new data
```

**For detailed data flow**, see [ARCHITECTURE.md](ARCHITECTURE.md#data-flow).

---

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/models/recipe_model_test.dart
```

### Run Widget Tests
```bash
flutter test test/widgets/
```

### Run Integration Tests
```bash
flutter test integration_test/
```

### Code Coverage
```bash
flutter test --coverage
# View coverage report in coverage/lcov.info
```

---

## Troubleshooting

### Common Issues

#### 1. Firebase Initialization Fails

**Error**: "No Firebase App '[DEFAULT]' has been created"

**Solution**:
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) are in correct locations
- Ensure `firebase_config.dart` has correct configuration
- Run `flutter clean && flutter pub get`

#### 2. Dependencies Not Found

**Error**: Package import errors

**Solution**:
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

#### 3. Build Fails on iOS

**Error**: CocoaPods errors

**Solution**:
```bash
cd ios
pod install --repo-update
cd ..
flutter clean
flutter run -d ios
```

#### 4. Hot Reload Not Working

**Solution**:
- Press `R` for hot restart instead of `r`
- If that doesn't work, stop and restart the app

#### 5. Firestore Permission Denied

**Error**: "PERMISSION_DENIED: Missing or insufficient permissions"

**Solution**:
- Check `firestore.rules` are deployed
- Verify user is authenticated
- Check security rules allow the operation

### Debug Mode

Enable debug prints:
```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Debug info: $variable');
}
```

### Firebase Debug Mode

View Firestore operations:
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## Next Steps

### 1. Explore the Documentation

- Read [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Review [DATA_MODELS.md](DATA_MODELS.md) for database schema
- Check [API.md](API.md) for repository/service methods

### 2. Explore the Code

Start with these key files:
- `lib/main.dart` - App entry point
- `lib/presentation/screens/home/home_screen.dart` - Main screen
- `lib/data/models/recipe_model.dart` - Example model
- `lib/data/repositories/recipe_repository.dart` - Example repository

### 3. Try Making Changes

- Add a new field to a model
- Create a new widget
- Modify a screen's UI
- Add a new provider

### 4. Run the App

- Test all features
- Try creating recipes
- Test social features
- Experiment with events

### 5. Join the Community

- Ask questions in team chat
- Review pull requests
- Contribute improvements
- Share your learnings

---

## Useful Commands

```bash
# Format all Dart code
flutter format .

# Analyze code for issues
flutter analyze

# Update dependencies
flutter pub upgrade

# Clean build artifacts
flutter clean

# Check for outdated packages
flutter pub outdated

# Generate code (for build_runner packages)
flutter pub run build_runner build

# Run app in profile mode (performance testing)
flutter run --profile

# Build for all platforms
flutter build apk --release      # Android
flutter build ios --release      # iOS
flutter build web --release      # Web
flutter build windows --release  # Windows
flutter build macos --release    # macOS
flutter build linux --release    # Linux
```

---

## Development Best Practices

1. **Always Format Code**: Run `flutter format .` before committing
2. **Analyze Before Push**: Run `flutter analyze` to catch issues
3. **Write Tests**: Add tests for new features
4. **Follow Conventions**: Match existing code style
5. **Document Changes**: Add comments for complex logic
6. **Use Providers**: Don't call Firebase directly from UI
7. **Handle Errors**: Always wrap Firebase calls in try-catch
8. **Test Offline**: Test app behavior without internet

---

## Resources

### Official Documentation
- **Flutter**: https://flutter.dev/docs
- **Firebase**: https://firebase.google.com/docs
- **Riverpod**: https://riverpod.dev/
- **Go Router**: https://pub.dev/packages/go_router

### Learning Resources
- **Flutter Codelabs**: https://flutter.dev/docs/codelabs
- **Firebase Codelabs**: https://firebase.google.com/codelabs
- **Dart Language Tour**: https://dart.dev/guides/language/language-tour

### Community
- **Flutter Discord**: https://discord.gg/flutter
- **Stack Overflow**: Tag questions with `flutter` and `firebase`

---

## Getting Help

### Internal Resources
1. Check this documentation first
2. Review existing code for examples
3. Ask in team chat
4. Create an issue in the repository

### External Resources
1. Search Flutter documentation
2. Search Firebase documentation
3. Check Stack Overflow
4. Read package documentation on pub.dev

---

**Welcome aboard! Happy coding! 🚀**

---

**Last Updated**: 2025-11-22
**Version**: 1.0
