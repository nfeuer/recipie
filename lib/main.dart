import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/config/firebase_config.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/theme_provider.dart';
import 'package:recipe_app/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (skip if using debug user)
  if (!kDebugMode || !kUseDebugUser) {
    try {
      await FirebaseConfig.initialize();
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
  } else {
    debugPrint('🔧 DEBUG MODE: Using test user, Firebase initialization skipped');
  }

  runApp(
    const ProviderScope(
      child: RecipeApp(),
    ),
  );
}

class RecipeApp extends ConsumerWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Recipe & Event Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
