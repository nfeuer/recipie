import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String recipeId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;
  final List<String> likes; // List of user IDs who liked the comment

  CommentModel({
    required this.commentId,
    required this.recipeId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
    this.likes = const [],
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'commentId': commentId,
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }

  // Create from Firestore document
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      commentId: doc.id,
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  // Copy with method
  CommentModel copyWith({
    String? userName,
    String? userPhotoUrl,
    String? text,
    List<String>? likes,
  }) {
    return CommentModel(
      commentId: commentId,
      recipeId: recipeId,
      userId: userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      text: text ?? this.text,
      createdAt: createdAt,
      likes: likes ?? this.likes,
    );
  }
}
