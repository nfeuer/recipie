import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  recipeRequested,
  recipeForkCreated,
  eventInvite,
  eventReminder,
  newRecipeFromFollowed,
  commentOnRecipe,
  someoneMadeYourRecipe,
}

class NotificationModel {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final Map<String, dynamic> data;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.data,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type.name,
      'data': data,
      'message': message,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      notificationId: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.newRecipeFromFollowed,
      ),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      type: type,
      data: data,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
