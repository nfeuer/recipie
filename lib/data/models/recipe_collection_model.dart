import 'package:cloud_firestore/cloud_firestore.dart';

enum CollectionPrivacy {
  public,
  private,
  friends,
}

class RecipeCollectionModel {
  final String collectionId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final List<String> recipeIds;
  final CollectionPrivacy privacy;
  final List<String> tags;
  final List<String> collaborators; // User IDs who can edit
  final int viewCount;
  final int saveCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeCollectionModel({
    required this.collectionId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.name,
    this.description,
    this.coverImageUrl,
    this.recipeIds = const [],
    this.privacy = CollectionPrivacy.public,
    this.tags = const [],
    this.collaborators = const [],
    this.viewCount = 0,
    this.saveCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'collectionId': collectionId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'recipeIds': recipeIds,
      'privacy': privacy.name,
      'tags': tags,
      'collaborators': collaborators,
      'viewCount': viewCount,
      'saveCount': saveCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory RecipeCollectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse privacy
    CollectionPrivacy privacy = CollectionPrivacy.public;
    if (data['privacy'] != null) {
      try {
        privacy = CollectionPrivacy.values.firstWhere(
          (e) => e.name == data['privacy'],
          orElse: () => CollectionPrivacy.public,
        );
      } catch (_) {
        privacy = CollectionPrivacy.public;
      }
    }

    return RecipeCollectionModel(
      collectionId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      name: data['name'] ?? '',
      description: data['description'],
      coverImageUrl: data['coverImageUrl'],
      recipeIds: List<String>.from(data['recipeIds'] ?? []),
      privacy: privacy,
      tags: List<String>.from(data['tags'] ?? []),
      collaborators: List<String>.from(data['collaborators'] ?? []),
      viewCount: data['viewCount'] ?? 0,
      saveCount: data['saveCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method
  RecipeCollectionModel copyWith({
    String? name,
    String? description,
    String? coverImageUrl,
    List<String>? recipeIds,
    CollectionPrivacy? privacy,
    List<String>? tags,
    List<String>? collaborators,
    int? viewCount,
    int? saveCount,
    DateTime? updatedAt,
  }) {
    return RecipeCollectionModel(
      collectionId: collectionId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      recipeIds: recipeIds ?? this.recipeIds,
      privacy: privacy ?? this.privacy,
      tags: tags ?? this.tags,
      collaborators: collaborators ?? this.collaborators,
      viewCount: viewCount ?? this.viewCount,
      saveCount: saveCount ?? this.saveCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
