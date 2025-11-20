import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum SubscriptionTier {
  free,
  premium,
  superAdmin,
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final List<String> dietaryPreferences;
  final Map<String, bool> privacySettings;
  final List<String> following;
  final List<String> followers;
  final SubscriptionTier subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.dietaryPreferences = const [],
    this.privacySettings = const {
      'defaultRecipePrivacy': true,
      'profileVisibility': true,
    },
    this.following = const [],
    this.followers = const [],
    this.subscriptionTier = SubscriptionTier.free,
    this.subscriptionExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  bool get isSuperAdmin => subscriptionTier == SubscriptionTier.superAdmin;

  bool get isPremium {
    if (subscriptionTier == SubscriptionTier.superAdmin) return true;
    if (subscriptionTier == SubscriptionTier.premium) {
      if (subscriptionExpiresAt == null) return true; // Lifetime premium
      return subscriptionExpiresAt!.isAfter(DateTime.now());
    }
    return false;
  }

  bool get hasPremiumAccess => isPremium || isSuperAdmin;

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'dietaryPreferences': dietaryPreferences,
      'privacySettings': privacySettings,
      'following': following,
      'followers': followers,
      'subscriptionTier': subscriptionTier.name,
      'subscriptionExpiresAt': subscriptionExpiresAt != null
          ? Timestamp.fromDate(subscriptionExpiresAt!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse subscription tier
    SubscriptionTier tier = SubscriptionTier.free;
    if (data['subscriptionTier'] != null) {
      try {
        tier = SubscriptionTier.values.firstWhere(
          (e) => e.name == data['subscriptionTier'],
          orElse: () => SubscriptionTier.free,
        );
      } catch (_) {
        tier = SubscriptionTier.free;
      }
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      dietaryPreferences: List<String>.from(data['dietaryPreferences'] ?? []),
      privacySettings: Map<String, bool>.from(data['privacySettings'] ?? {}),
      following: List<String>.from(data['following'] ?? []),
      followers: List<String>.from(data['followers'] ?? []),
      subscriptionTier: tier,
      subscriptionExpiresAt: data['subscriptionExpiresAt'] != null
          ? (data['subscriptionExpiresAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    List<String>? dietaryPreferences,
    Map<String, bool>? privacySettings,
    List<String>? following,
    List<String>? followers,
    SubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      privacySettings: privacySettings ?? this.privacySettings,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Debug mode test user (only available in debug builds)
  static UserModel get debugTestUser {
    if (!kDebugMode) {
      throw Exception('Debug test user is only available in debug mode');
    }

    return UserModel(
      uid: 'debug-test-user-123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: null,
      bio: 'This is a test user for development',
      dietaryPreferences: ['vegetarian', 'gluten-free'],
      privacySettings: const {
        'defaultRecipePrivacy': true,
        'profileVisibility': true,
      },
      following: [],
      followers: [],
      subscriptionTier: SubscriptionTier.premium,
      subscriptionExpiresAt: null, // Lifetime premium for testing
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
