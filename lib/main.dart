/// Recipe & Event Platform - Main Application Entry Point
///
/// This is the entry point for the Recipe & Event Platform Flutter application.
/// The app is a full-featured social platform for sharing recipes, hosting events,
/// and connecting with other home cooks.
///
/// Key Features:
/// - Recipe creation and sharing with photos, ingredients, and steps
/// - Event planning and guest management with RSVP
/// - Social features (follow, like, comment, "I Made This" posts)
/// - Shopping list generation from recipes
/// - Advanced search and filtering
/// - Recipe forking and modification tracking
/// - Real-time notifications and activity feed
/// - Firebase backend integration (Auth, Firestore, Storage, FCM, Dynamic Links, Analytics)
///
/// Architecture:
/// - Clean Architecture with presentation, data, and core layers
/// - Riverpod 3.0 for state management
/// - Go Router for navigation
/// - Material 3 design system
///
/// For detailed documentation, see:
/// - Architecture: docs/ARCHITECTURE.md
/// - Data Models: docs/DATA_MODELS.md
/// - API Reference: docs/API.md
/// - Quick Start: docs/QUICKSTART.md
///
/// Main responsibilities of this file:
/// 1. Initialize Flutter framework
/// 2. Initialize Firebase services
/// 3. Configure debug mode (optional test user)
/// 4. Set up Riverpod provider scope
/// 5. Launch the app with theme configuration
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/config/firebase_config.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/theme_provider.dart';
import 'package:recipe_app/presentation/screens/splash_screen.dart';

/// Application entry point.
///
/// This function is called when the app starts. It performs the following steps:
/// 1. Ensures Flutter framework is initialized
/// 2. Initializes Firebase (unless in debug mode with test user)
/// 3. Wraps the app in a ProviderScope for Riverpod state management
/// 4. Launches the RecipeApp widget
///
/// The app supports a debug mode that skips Firebase initialization,
/// allowing development without Firebase credentials. Set kUseDebugUser = true
/// in auth_providers.dart to enable this mode.
void main() async {
  // Ensures that Flutter framework is fully initialized before proceeding.
  // This is required when using async operations in main().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase services (Auth, Firestore, Storage, FCM, etc.)
  // Skipped in debug mode if using the test user feature for development
  // without Firebase credentials.
  if (!kDebugMode || !kUseDebugUser) {
    try {
      await FirebaseConfig.initialize();
    } catch (e) {
      // Non-fatal: log error but continue app startup
      // The app will show appropriate error messages for Firebase operations
      debugPrint('Firebase initialization error: $e');
    }
  } else {
    debugPrint('🔧 DEBUG MODE: Using test user, Firebase initialization skipped');
  }

  // Launch the app wrapped in ProviderScope for Riverpod state management.
  // ProviderScope creates the container that holds all providers and their state.
  runApp(
    const ProviderScope(
      child: RecipeApp(),
    ),
  );
}

/// Root application widget.
///
/// This widget sets up the MaterialApp with:
/// - Light and dark theme support (Material 3)
/// - Theme mode controlled by Riverpod provider
/// - App title and branding
/// - Initial route to splash screen
///
/// The widget is a ConsumerWidget to access Riverpod providers for theme state.
class RecipeApp extends ConsumerWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme mode provider to rebuild when user changes theme preference
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      // App title displayed in task switcher and browser title bar
      title: 'Recipe & Event Platform',

      // Hide debug banner in top-right corner
      debugShowCheckedModeBanner: false,

      // Light theme configuration (Material 3)
      theme: AppTheme.lightTheme,

      // Dark theme configuration (Material 3)
      darkTheme: AppTheme.darkTheme,

      // Theme mode (light, dark, or system) - controlled by user preference
      themeMode: themeMode,

      // Initial screen - shows while checking authentication state
      home: const SplashScreen(),
    );
  }
}
