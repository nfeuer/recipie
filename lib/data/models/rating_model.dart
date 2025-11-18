import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String ratingId;
  final String recipeId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int rating; // 1-5 stars
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;

  RatingModel({
    required this.ratingId,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'ratingId': ratingId,
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore document
  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      ratingId: doc.id,
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      rating: data['rating'] ?? 0,
      review: data['review'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Copy with method
  RatingModel copyWith({
    String? userName,
    String? userPhotoUrl,
    int? rating,
    String? review,
    DateTime? updatedAt,
  }) {
    return RatingModel(
      ratingId: ratingId,
      recipeId: recipeId,
      userId: userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
