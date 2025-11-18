import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/data/models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create event
  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseCollections.events)
          .add(event.toFirestore());

      // Update the event with its ID
      await docRef.update({'eventId': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  // Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.events)
          .doc(eventId)
          .get();

      if (!doc.exists) return null;
      return EventModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  // Get event stream
  Stream<EventModel?> getEventStream(String eventId) {
    return _firestore
        .collection(FirebaseCollections.events)
        .doc(eventId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return EventModel.fromFirestore(doc);
    });
  }

  // Update event
  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection(FirebaseCollections.events)
          .doc(event.eventId)
          .update(event.toFirestore());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.events)
          .doc(eventId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Get user hosted events
  Future<List<EventModel>> getUserHostedEvents(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.events)
          .where('hostId', isEqualTo: userId)
          .orderBy('eventDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get user hosted events: $e');
    }
  }

  // Get user attended events
  Future<List<EventModel>> getUserAttendedEvents(String userId) async {
    try {
      // Note: This requires a more complex query
      // In production, you might want to maintain a separate collection
      // or use Cloud Functions to keep a list of attended events
      final snapshot = await _firestore
          .collection(FirebaseCollections.events)
          .orderBy('eventDate', descending: true)
          .get();

      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((event) => event.guests.any((guest) =>
              guest.userId == userId &&
              guest.status == GuestStatus.attended))
          .toList();

      return events;
    } catch (e) {
      throw Exception('Failed to get user attended events: $e');
    }
  }

  // Get upcoming events
  Future<List<EventModel>> getUpcomingEvents({int limit = 20}) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(FirebaseCollections.events)
          .where('privacy', isEqualTo: 'public')
          .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('eventDate')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get upcoming events: $e');
    }
  }

  // Update guest RSVP
  Future<void> updateGuestRSVP({
    required String eventId,
    required String guestEmail,
    required GuestStatus status,
  }) async {
    try {
      final event = await getEventById(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }

      final updatedGuests = event.guests.map((guest) {
        if (guest.email == guestEmail) {
          return EventGuest(
            userId: guest.userId,
            email: guest.email,
            name: guest.name,
            status: status,
            dietaryRestrictions: guest.dietaryRestrictions,
            plusOnes: guest.plusOnes,
            respondedAt: DateTime.now(),
            checkedInAt: guest.checkedInAt,
          );
        }
        return guest;
      }).toList();

      await _firestore
          .collection(FirebaseCollections.events)
          .doc(eventId)
          .update({
        'guests': updatedGuests.map((g) => g.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update guest RSVP: $e');
    }
  }

  // Check in guest
  Future<void> checkInGuest({
    required String eventId,
    required String guestEmail,
  }) async {
    try {
      final event = await getEventById(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }

      final updatedGuests = event.guests.map((guest) {
        if (guest.email == guestEmail) {
          return EventGuest(
            userId: guest.userId,
            email: guest.email,
            name: guest.name,
            status: GuestStatus.attended,
            dietaryRestrictions: guest.dietaryRestrictions,
            plusOnes: guest.plusOnes,
            respondedAt: guest.respondedAt,
            checkedInAt: DateTime.now(),
          );
        }
        return guest;
      }).toList();

      await _firestore
          .collection(FirebaseCollections.events)
          .doc(eventId)
          .update({
        'guests': updatedGuests.map((g) => g.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to check in guest: $e');
    }
  }

  // Increment recipe request count
  Future<void> incrementRecipeRequestCount({
    required String eventId,
    required String recipeId,
  }) async {
    try {
      final event = await getEventById(eventId);
      if (event == null) {
        throw Exception('Event not found');
      }

      final updatedRecipes = event.recipes.map((recipe) {
        if (recipe.recipeId == recipeId) {
          return EventRecipe(
            recipeId: recipe.recipeId,
            dishName: recipe.dishName,
            assignedTo: recipe.assignedTo,
            servingsPlanned: recipe.servingsPlanned,
            dishPhotos: recipe.dishPhotos,
            wasHighlight: recipe.wasHighlight,
            requestCount: recipe.requestCount + 1,
          );
        }
        return recipe;
      }).toList();

      await _firestore
          .collection(FirebaseCollections.events)
          .doc(eventId)
          .update({
        'recipes': updatedRecipes.map((r) => r.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to increment recipe request count: $e');
    }
  }

  // Add dish feedback
  Future<void> addDishFeedback({
    required String eventId,
    required String recipeId,
    required String feedback,
  }) async {
    try {
      await _firestore
          .collection(FirebaseCollections.events)
          .doc(eventId)
          .update({
        'dishFeedback.$recipeId': FieldValue.arrayUnion([feedback]),
      });
    } catch (e) {
      throw Exception('Failed to add dish feedback: $e');
    }
  }

  // Get events by share code
  Future<EventModel?> getEventByShareCode(String shareCode) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.events)
          .where('shareCode', isEqualTo: shareCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return EventModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Failed to get event by share code: $e');
    }
  }
}
