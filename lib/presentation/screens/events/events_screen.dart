import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/event_providers.dart';
import 'package:recipe_app/presentation/screens/events/create_event_screen.dart';
import 'package:recipe_app/presentation/screens/events/event_detail_screen.dart';
import 'package:recipe_app/presentation/widgets/event_card.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: Implement QR code scanner
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Scanner coming soon')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Events'),
            Tab(text: 'Attending'),
            Tab(text: 'Upcoming'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Events Tab
          currentUser.when(
            data: (user) {
              if (user == null) {
                return const Center(
                  child: Text('Please sign in to view your events'),
                );
              }
              return _buildMyEventsTab(user.uid);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error loading user')),
          ),
          // Attending Tab
          currentUser.when(
            data: (user) {
              if (user == null) {
                return const Center(
                  child: Text('Please sign in to view events'),
                );
              }
              return _buildAttendingEventsTab(user.uid);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error loading user')),
          ),
          // Upcoming Tab
          _buildUpcomingEventsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateEventScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }

  Widget _buildMyEventsTab(String userId) {
    final eventsAsync = ref.watch(userHostedEventsProvider(userId));

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No events yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Create your first event to get started'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateEventScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Event'),
                ),
              ],
            ),
          );
        }

        // Separate upcoming and past events
        final now = DateTime.now();
        final upcomingEvents = events.where((e) => e.eventDate.isAfter(now)).toList();
        final pastEvents = events.where((e) => e.eventDate.isBefore(now)).toList();

        // Sort: upcoming first (ascending), then past (descending)
        upcomingEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        pastEvents.sort((a, b) => b.eventDate.compareTo(a.eventDate));

        final sortedEvents = [...upcomingEvents, ...pastEvents];

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userHostedEventsProvider(userId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: sortedEvents.length,
            itemBuilder: (context, index) {
              final event = sortedEvents[index];
              return EventCard(
                event: event,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(eventId: event.eventId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading events: $error'),
      ),
    );
  }

  Widget _buildAttendingEventsTab(String userId) {
    final eventsAsync = ref.watch(userAttendedEventsProvider(userId));

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No events to attend'),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final upcomingEvents = events.where((e) => e.eventDate.isAfter(now)).toList();
        final pastEvents = events.where((e) => e.eventDate.isBefore(now)).toList();

        upcomingEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        pastEvents.sort((a, b) => b.eventDate.compareTo(a.eventDate));

        final sortedEvents = [...upcomingEvents, ...pastEvents];

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userAttendedEventsProvider(userId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: sortedEvents.length,
            itemBuilder: (context, index) {
              final event = sortedEvents[index];
              return EventCard(
                event: event,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(eventId: event.eventId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading events: $error'),
      ),
    );
  }

  Widget _buildUpcomingEventsTab() {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No upcoming public events'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(upcomingEventsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(eventId: event.eventId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading events: $error'),
      ),
    );
  }
}
