import 'package:cloud_firestore/cloud_firestore.dart';

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
    required this.createdAt,
    required this.updatedAt,
  });

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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
