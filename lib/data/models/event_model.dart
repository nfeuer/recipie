import 'package:cloud_firestore/cloud_firestore.dart';

enum GuestStatus {
  invited,
  confirmed,
  declined,
  attended,
}

enum EventPrivacy {
  public,
  friendsOnly,
  private,
}

class EventGuest {
  final String? userId;
  final String? email;
  final String name;
  final GuestStatus status;
  final List<String> dietaryRestrictions;
  final int plusOnes;
  final DateTime? respondedAt;
  final DateTime? checkedInAt;

  EventGuest({
    this.userId,
    this.email,
    required this.name,
    required this.status,
    this.dietaryRestrictions = const [],
    this.plusOnes = 0,
    this.respondedAt,
    this.checkedInAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'status': status.name,
      'dietaryRestrictions': dietaryRestrictions,
      'plusOnes': plusOnes,
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'checkedInAt':
          checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
    };
  }

  factory EventGuest.fromMap(Map<String, dynamic> map) {
    return EventGuest(
      userId: map['userId'],
      email: map['email'],
      name: map['name'] ?? '',
      status: GuestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GuestStatus.invited,
      ),
      dietaryRestrictions:
          List<String>.from(map['dietaryRestrictions'] ?? []),
      plusOnes: map['plusOnes'] ?? 0,
      respondedAt: map['respondedAt'] != null
          ? (map['respondedAt'] as Timestamp).toDate()
          : null,
      checkedInAt: map['checkedInAt'] != null
          ? (map['checkedInAt'] as Timestamp).toDate()
          : null,
    );
  }
}

class EventRecipe {
  final String recipeId;
  final String dishName;
  final String? assignedTo;
  final int servingsPlanned;
  final List<String> dishPhotos;
  final bool wasHighlight;
  final int requestCount;

  EventRecipe({
    required this.recipeId,
    required this.dishName,
    this.assignedTo,
    required this.servingsPlanned,
    this.dishPhotos = const [],
    this.wasHighlight = false,
    this.requestCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'dishName': dishName,
      'assignedTo': assignedTo,
      'servingsPlanned': servingsPlanned,
      'dishPhotos': dishPhotos,
      'wasHighlight': wasHighlight,
      'requestCount': requestCount,
    };
  }

  factory EventRecipe.fromMap(Map<String, dynamic> map) {
    return EventRecipe(
      recipeId: map['recipeId'] ?? '',
      dishName: map['dishName'] ?? '',
      assignedTo: map['assignedTo'],
      servingsPlanned: map['servingsPlanned'] ?? 1,
      dishPhotos: List<String>.from(map['dishPhotos'] ?? []),
      wasHighlight: map['wasHighlight'] ?? false,
      requestCount: map['requestCount'] ?? 0,
    );
  }
}

class EventModel {
  final String eventId;
  final String hostId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final String eventType;
  final List<EventGuest> guests;
  final int? maxGuests;
  final bool allowPlusOnes;
  final List<EventRecipe> recipes;
  final List<String> eventPhotoUrls;
  final String? recap;
  final Map<String, List<String>> dishFeedback;
  final EventPrivacy privacy;
  final String? shareCode;
  final bool allowRecipeRequests;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.eventId,
    required this.hostId,
    required this.title,
    this.description,
    required this.eventDate,
    this.location,
    required this.eventType,
    this.guests = const [],
    this.maxGuests,
    this.allowPlusOnes = false,
    this.recipes = const [],
    this.eventPhotoUrls = const [],
    this.recap,
    this.dishFeedback = const {},
    this.privacy = EventPrivacy.private,
    this.shareCode,
    this.allowRecipeRequests = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'hostId': hostId,
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'location': location,
      'eventType': eventType,
      'guests': guests.map((g) => g.toMap()).toList(),
      'maxGuests': maxGuests,
      'allowPlusOnes': allowPlusOnes,
      'recipes': recipes.map((r) => r.toMap()).toList(),
      'eventPhotoUrls': eventPhotoUrls,
      'recap': recap,
      'dishFeedback': dishFeedback,
      'privacy': privacy.name,
      'shareCode': shareCode,
      'allowRecipeRequests': allowRecipeRequests,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      eventId: doc.id,
      hostId: data['hostId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      location: data['location'],
      eventType: data['eventType'] ?? '',
      guests: (data['guests'] as List<dynamic>?)
              ?.map((g) => EventGuest.fromMap(g))
              .toList() ??
          [],
      maxGuests: data['maxGuests'],
      allowPlusOnes: data['allowPlusOnes'] ?? false,
      recipes: (data['recipes'] as List<dynamic>?)
              ?.map((r) => EventRecipe.fromMap(r))
              .toList() ??
          [],
      eventPhotoUrls: List<String>.from(data['eventPhotoUrls'] ?? []),
      recap: data['recap'],
      dishFeedback: Map<String, List<String>>.from(
        (data['dishFeedback'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      privacy: EventPrivacy.values.firstWhere(
        (e) => e.name == data['privacy'],
        orElse: () => EventPrivacy.private,
      ),
      shareCode: data['shareCode'],
      allowRecipeRequests: data['allowRecipeRequests'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  EventModel copyWith({
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? eventType,
    List<EventGuest>? guests,
    int? maxGuests,
    bool? allowPlusOnes,
    List<EventRecipe>? recipes,
    List<String>? eventPhotoUrls,
    String? recap,
    Map<String, List<String>>? dishFeedback,
    EventPrivacy? privacy,
    String? shareCode,
    bool? allowRecipeRequests,
    DateTime? updatedAt,
  }) {
    return EventModel(
      eventId: eventId,
      hostId: hostId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
      guests: guests ?? this.guests,
      maxGuests: maxGuests ?? this.maxGuests,
      allowPlusOnes: allowPlusOnes ?? this.allowPlusOnes,
      recipes: recipes ?? this.recipes,
      eventPhotoUrls: eventPhotoUrls ?? this.eventPhotoUrls,
      recap: recap ?? this.recap,
      dishFeedback: dishFeedback ?? this.dishFeedback,
      privacy: privacy ?? this.privacy,
      shareCode: shareCode ?? this.shareCode,
      allowRecipeRequests: allowRecipeRequests ?? this.allowRecipeRequests,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
