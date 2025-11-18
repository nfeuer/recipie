import 'package:cloud_firestore/cloud_firestore.dart';

class MadeItModel {
  final String postId;
  final String recipeId;
  final String recipeName;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final List<String> photoUrls;
  final String? caption;
  final String? modifications; // Any changes made to the original recipe
  final int? rating; // Optional rating
  final DateTime createdAt;
  final List<String> likes; // List of user IDs who liked the post

  MadeItModel({
    required this.postId,
    required this.recipeId,
    required this.recipeName,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.photoUrls,
    this.caption,
    this.modifications,
    this.rating,
    required this.createdAt,
    this.likes = const [],
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'photoUrls': photoUrls,
      'caption': caption,
      'modifications': modifications,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }

  // Create from Firestore document
  factory MadeItModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MadeItModel(
      postId: doc.id,
      recipeId: data['recipeId'] ?? '',
      recipeName: data['recipeName'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      caption: data['caption'],
      modifications: data['modifications'],
      rating: data['rating'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  // Copy with method
  MadeItModel copyWith({
    String? userName,
    String? userPhotoUrl,
    List<String>? photoUrls,
    String? caption,
    String? modifications,
    int? rating,
    List<String>? likes,
  }) {
    return MadeItModel(
      postId: postId,
      recipeId: recipeId,
      recipeName: recipeName,
      userId: userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      caption: caption ?? this.caption,
      modifications: modifications ?? this.modifications,
      rating: rating ?? this.rating,
      createdAt: createdAt,
      likes: likes ?? this.likes,
    );
  }
}
