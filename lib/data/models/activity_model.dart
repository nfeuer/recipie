import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType {
  recipeCreated,
  recipeMade,
  eventCreated,
  userFollowed,
  recipeCommented,
  recipeRated,
}

class ActivityModel {
  final String activityId;
  final String userId; // The user who performed the activity
  final String userName;
  final String? userPhotoUrl;
  final ActivityType type;
  final DateTime timestamp;

  // Related content IDs
  final String? recipeId;
  final String? recipeName;
  final String? recipePhotoUrl;
  final String? eventId;
  final String? eventName;
  final String? postId;
  final String? targetUserId; // For follow activities
  final String? targetUserName;

  // Activity-specific data
  final String? comment; // For comments
  final int? rating; // For ratings
  final List<String>? photoUrls; // For "I Made This" posts

  ActivityModel({
    required this.activityId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.type,
    required this.timestamp,
    this.recipeId,
    this.recipeName,
    this.recipePhotoUrl,
    this.eventId,
    this.eventName,
    this.postId,
    this.targetUserId,
    this.targetUserName,
    this.comment,
    this.rating,
    this.photoUrls,
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'activityId': activityId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'recipeId': recipeId,
      'recipeName': recipeName,
      'recipePhotoUrl': recipePhotoUrl,
      'eventId': eventId,
      'eventName': eventName,
      'postId': postId,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'comment': comment,
      'rating': rating,
      'photoUrls': photoUrls,
    };
  }

  // Create from Firestore document
  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      activityId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => ActivityType.recipeCreated,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      recipeId: data['recipeId'],
      recipeName: data['recipeName'],
      recipePhotoUrl: data['recipePhotoUrl'],
      eventId: data['eventId'],
      eventName: data['eventName'],
      postId: data['postId'],
      targetUserId: data['targetUserId'],
      targetUserName: data['targetUserName'],
      comment: data['comment'],
      rating: data['rating'],
      photoUrls: data['photoUrls'] != null
          ? List<String>.from(data['photoUrls'])
          : null,
    );
  }

  // Helper method to get activity description
  String getDescription() {
    switch (type) {
      case ActivityType.recipeCreated:
        return 'created a new recipe: $recipeName';
      case ActivityType.recipeMade:
        return 'made $recipeName';
      case ActivityType.eventCreated:
        return 'created a new event: $eventName';
      case ActivityType.userFollowed:
        return 'started following $targetUserName';
      case ActivityType.recipeCommented:
        return 'commented on $recipeName';
      case ActivityType.recipeRated:
        return 'rated $recipeName $rating stars';
    }
  }

  // Copy with method
  ActivityModel copyWith({
    String? userName,
    String? userPhotoUrl,
    String? recipeName,
    String? recipePhotoUrl,
    String? eventName,
    String? targetUserName,
    String? comment,
    int? rating,
    List<String>? photoUrls,
  }) {
    return ActivityModel(
      activityId: activityId,
      userId: userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      type: type,
      timestamp: timestamp,
      recipeId: recipeId,
      recipeName: recipeName ?? this.recipeName,
      recipePhotoUrl: recipePhotoUrl ?? this.recipePhotoUrl,
      eventId: eventId,
      eventName: eventName ?? this.eventName,
      postId: postId,
      targetUserId: targetUserId,
      targetUserName: targetUserName ?? this.targetUserName,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}
