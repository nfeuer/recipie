import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/event_model.dart';
import 'package:recipe_app/data/repositories/event_repository.dart';

// Event Repository Provider
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

// User Hosted Events Provider
final userHostedEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, userId) async {
  final eventRepository = ref.watch(eventRepositoryProvider);
  return eventRepository.getUserHostedEvents(userId);
});

// User Attended Events Provider
final userAttendedEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, userId) async {
  final eventRepository = ref.watch(eventRepositoryProvider);
  return eventRepository.getUserAttendedEvents(userId);
});

// Upcoming Events Provider
final upcomingEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final eventRepository = ref.watch(eventRepositoryProvider);
  return eventRepository.getUpcomingEvents(limit: 20);
});

// Single Event Provider
final eventProvider = StreamProvider.family<EventModel?, String>((ref, eventId) {
  final eventRepository = ref.watch(eventRepositoryProvider);
  return eventRepository.getEventStream(eventId);
});

// Event by Share Code Provider
final eventByShareCodeProvider = FutureProvider.family<EventModel?, String>((ref, shareCode) async {
  final eventRepository = ref.watch(eventRepositoryProvider);
  return eventRepository.getEventByShareCode(shareCode);
});
