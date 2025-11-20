# Firebase Setup Guide - Recipe & Event Platform

This guide will walk you through connecting your app to Firebase for production use.

## Prerequisites

- Firebase account (https://firebase.google.com/)
- Flutter SDK installed
- Firebase CLI installed: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `recipe-event-platform` (or your preferred name)
4. Enable Google Analytics (recommended) or skip
5. Click **"Create project"**

---

## Step 2: Register Your Apps

### For Web:

1. In Firebase Console, click the **Web icon** (</>) to add a web app
2. Enter app nickname: `Recipe App Web`
3. **Check** "Also set up Firebase Hosting"
4. Click **"Register app"**
5. Copy the Firebase config - you'll need this later
6. Click **"Continue to console"**

### For Android:

1. Click **Android icon** to add Android app
2. Enter package name: `com.example.recipe_app` (or your package name from `android/app/build.gradle`)
3. Enter app nickname: `Recipe App Android`
4. Download `google-services.json`
5. Click **"Next"** → **"Continue to console"**

### For iOS:

1. Click **iOS icon** to add iOS app
2. Enter bundle ID: `com.example.recipeApp` (or your bundle ID from `ios/Runner.xcodeproj`)
3. Enter app nickname: `Recipe App iOS`
4. Download `GoogleService-Info.plist`
5. Click **"Next"** → **"Continue to console"**

---

## Step 3: Configure FlutterFire

### Option A: Automatic Configuration (Recommended)

Run this command in your project root:

```bash
flutterfire configure
```

This will:
- Prompt you to select your Firebase project
- Generate `lib/firebase_options.dart`
- Configure all platforms automatically

### Option B: Manual Configuration

If automatic configuration fails, follow manual steps:

#### Web Manual Setup:

1. Open or create `web/index.html`
2. Add Firebase SDK before `</body>`:

```html
<!-- Firebase SDK -->
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-storage-compat.js"></script>

<script>
  // Your web app's Firebase configuration
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
  };

  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
</script>
```

#### Android Manual Setup:

1. Place `google-services.json` in `android/app/`
2. Open `android/build.gradle`, add to dependencies:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

3. Open `android/app/build.gradle`, add at bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

#### iOS Manual Setup:

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Drag `GoogleService-Info.plist` into `Runner/Runner` folder
3. Ensure "Copy items if needed" is checked
4. Close Xcode

---

## Step 4: Enable Firebase Services

### 4.1 Authentication

1. In Firebase Console, go to **Build → Authentication**
2. Click **"Get started"**
3. Enable sign-in methods:
   - **Email/Password**: Click → Enable → Save
   - **Google**: Click → Enable → Add support email → Save

### 4.2 Cloud Firestore

1. Go to **Build → Firestore Database**
2. Click **"Create database"**
3. Select **"Start in test mode"** (we'll add security rules later)
4. Choose your region (closest to your users)
5. Click **"Enable"**

### 4.3 Storage

1. Go to **Build → Storage**
2. Click **"Get started"**
3. Select **"Start in test mode"**
4. Use same region as Firestore
5. Click **"Done"**

### 4.4 Firebase Analytics (Optional)

1. Go to **Build → Analytics**
2. Click **"Get started"**
3. Follow the setup wizard

---

## Step 5: Set Up Security Rules

### Firestore Rules

1. Go to **Firestore Database → Rules** tab
2. Replace with production-ready rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(userId);
      allow update, delete: if isOwner(userId);
    }

    // Recipes collection
    match /recipes/{recipeId} {
      allow read: if isSignedIn() &&
        (resource.data.privacy == 'public' ||
         resource.data.authorId == request.auth.uid);
      allow create: if isSignedIn() &&
        request.resource.data.authorId == request.auth.uid;
      allow update, delete: if isSignedIn() &&
        resource.data.authorId == request.auth.uid;
    }

    // Events collection
    match /events/{eventId} {
      allow read: if isSignedIn() &&
        (resource.data.privacy == 'public' ||
         resource.data.hostId == request.auth.uid ||
         request.auth.uid in resource.data.attendees);
      allow create: if isSignedIn() &&
        request.resource.data.hostId == request.auth.uid;
      allow update, delete: if isSignedIn() &&
        resource.data.hostId == request.auth.uid;
    }

    // Made It posts
    match /made_it_posts/{postId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() &&
        request.resource.data.userId == request.auth.uid;
      allow update, delete: if isSignedIn() &&
        resource.data.userId == request.auth.uid;
    }

    // Activities feed
    match /activities/{activityId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() &&
        resource.data.userId == request.auth.uid;
    }
  }
}
```

3. Click **"Publish"**

### Storage Rules

1. Go to **Storage → Rules** tab
2. Replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    function isSignedIn() {
      return request.auth != null;
    }

    function isImageFile() {
      return request.resource.contentType.matches('image/.*');
    }

    function isUnder5MB() {
      return request.resource.size < 5 * 1024 * 1024;
    }

    // Recipe images
    match /recipes/{userId}/{recipeId}/{imageId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() &&
        request.auth.uid == userId &&
        isImageFile() &&
        isUnder5MB();
    }

    // Event images
    match /events/{userId}/{eventId}/{imageId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() &&
        request.auth.uid == userId &&
        isImageFile() &&
        isUnder5MB();
    }

    // Made It images
    match /made_it/{userId}/{postId}/{imageId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() &&
        request.auth.uid == userId &&
        isImageFile() &&
        isUnder5MB();
    }

    // Profile pictures
    match /profile_pictures/{userId}/{imageId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() &&
        request.auth.uid == userId &&
        isImageFile() &&
        isUnder5MB();
    }
  }
}
```

3. Click **"Publish"**

---

## Step 6: Update App Configuration

### Disable Debug Mode

Open `lib/presentation/providers/auth_providers.dart`:

```dart
// Debug mode flag - set to false for production
const bool kUseDebugUser = false;  // Change from true to false
```

### Verify Firebase Config File

Check that `lib/core/config/firebase_config.dart` exists and contains:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
```

---

## Step 7: Test the Connection

### Run the App

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Run on Web
flutter run -d chrome

# Run on Android
flutter run -d <device-id>

# Run on iOS
flutter run -d <device-id>
```

### Test Features

1. **Sign Up**: Create a new account with email/password
2. **Sign In with Google**: Test Google authentication
3. **Create Recipe**: Add a new recipe with images
4. **Create Event**: Create an event and add recipes
5. **View Data**: Check Firebase Console to see data being created

---

## Step 8: Google Sign-In Setup (Additional Configuration)

### Web:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services → Credentials**
4. Find **Web client (auto created by Google Service)**
5. Add authorized JavaScript origins:
   - `http://localhost`
   - `http://localhost:5000`
   - Your production domain (e.g., `https://yourdomain.com`)
6. Add authorized redirect URIs:
   - `http://localhost`
   - Your production domain

### Android:

1. In Firebase Console: **Project Settings → Your Android app**
2. Add SHA-1 and SHA-256 fingerprints:

```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore (when ready for production)
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

3. Copy SHA-1 and SHA-256 to Firebase Console
4. Download new `google-services.json`
5. Replace in `android/app/google-services.json`

### iOS:

1. Open `ios/Runner/Info.plist`
2. Add your reversed client ID from `GoogleService-Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR-REVERSED-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

---

## Step 9: Deploy to Production

### Web Deployment (Firebase Hosting)

```bash
# Build web app
flutter build web --release

# Login to Firebase
firebase login

# Initialize hosting
firebase init hosting

# Select:
# - Use existing project
# - Public directory: build/web
# - Configure as single-page app: Yes
# - Set up automatic builds: No

# Deploy
firebase deploy --only hosting
```

Your app will be live at: `https://your-project-id.web.app`

---

## Troubleshooting

### Common Issues

**1. "Firebase not initialized" error**
- Ensure `FirebaseConfig.initialize()` is called before `runApp()`
- Check `firebase_options.dart` exists

**2. Google Sign-In fails on Android**
- Verify SHA-1/SHA-256 fingerprints are added
- Download new `google-services.json` after adding fingerprints
- Rebuild app completely

**3. Web image upload fails**
- Check CORS settings in Firebase Storage
- Add your domain to allowed origins

**4. Permission denied errors**
- Review Firestore/Storage security rules
- Ensure user is authenticated
- Check data structure matches rules

**5. Network images not loading**
- Ensure Storage rules allow read access
- Check image URLs are valid
- Verify internet permission (Android)

---

## Security Checklist

Before going live:

- [ ] Change Firestore rules from "test mode" to production rules
- [ ] Change Storage rules from "test mode" to production rules
- [ ] Set `kUseDebugUser = false`
- [ ] Remove any test accounts from Firebase Auth
- [ ] Set up Firebase App Check (optional but recommended)
- [ ] Enable rate limiting in Firebase
- [ ] Set up monitoring and alerts
- [ ] Review API key restrictions in Google Cloud Console

---

## Monitoring & Analytics

### Set Up Crashlytics (Optional)

1. In Firebase Console: **Build → Crashlytics**
2. Follow setup wizard
3. Add to `pubspec.yaml`:
```yaml
firebase_crashlytics: ^4.3.10
```

4. Update `main.dart`:
```dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

### View Analytics

- Go to **Analytics → Dashboard** to see user activity
- Set up custom events for key actions (recipe created, event attended, etc.)

---

## Cost Management

Firebase Free Tier includes:
- **Firestore**: 50K reads, 20K writes, 20K deletes per day
- **Storage**: 5GB storage, 1GB downloads per day
- **Authentication**: Unlimited
- **Hosting**: 10GB storage, 360MB/day transfer

Monitor usage at: **Firebase Console → Usage and billing**

---

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Support](https://firebase.google.com/support)

---

## Next Steps

After successful Firebase connection:

1. Test all features thoroughly
2. Set up CI/CD pipeline (optional)
3. Configure custom domain for web
4. Submit to app stores (iOS/Android)
5. Set up analytics goals and funnels
6. Plan for scaling (Blaze plan when needed)

**Good luck with your Recipe & Event Platform! 🚀**
