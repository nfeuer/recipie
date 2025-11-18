import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/event_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/event_providers.dart';
import 'package:recipe_app/presentation/screens/events/edit_event_screen.dart';
import 'package:recipe_app/presentation/screens/recipes/recipe_detail_screen.dart';
import 'package:share_plus/share_plus.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final currentUser = ref.watch(currentUserProvider);

    return eventAsync.when(
      data: (event) {
        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Event Not Found')),
            body: const Center(child: Text('Event not found')),
          );
        }

        final isHost = currentUser.value?.uid == event.hostId;
        final isPast = event.eventDate.isBefore(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: Text(event.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Share.share('Join my event: ${event.title}\n${event.shareCode ?? ''}');
                },
              ),
              if (isHost)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (!isPast)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'qr',
                      child: Row(
                        children: [
                          Icon(Icons.qr_code),
                          SizedBox(width: 8),
                          Text('Show QR Code'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditEventScreen(event: event),
                        ),
                      );
                    } else if (value == 'qr') {
                      _showQRCode(context, event);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, ref, event);
                    }
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Header
                _buildEventHeader(context, event),

                Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (event.description != null) ...[
                        Text(
                          event.description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Event Details
                      _buildEventDetails(context, event),
                      const SizedBox(height: 24),

                      // Guest List
                      _buildGuestListSection(context, event, isHost),
                      const SizedBox(height: 24),

                      // Menu/Recipes
                      if (event.recipes.isNotEmpty) ...[
                        _buildMenuSection(context, event),
                        const SizedBox(height: 24),
                      ],

                      // Event Photos
                      if (event.eventPhotoUrls.isNotEmpty) ...[
                        _buildPhotosSection(context, event),
                        const SizedBox(height: 24),
                      ],

                      // Recap
                      if (isPast && event.recap != null) ...[
                        _buildRecapSection(context, event),
                        const SizedBox(height: 24),
                      ],

                      // Actions
                      if (!isHost && !isPast)
                        _buildGuestActions(context, ref, event),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading event: $error')),
      ),
    );
  }

  Widget _buildEventHeader(BuildContext context, EventModel event) {
    final isPast = event.eventDate.isBefore(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isPast ? Colors.grey : AppTheme.primaryColor,
            isPast ? Colors.grey[600]! : AppTheme.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d, y').format(event.eventDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('h:mm a').format(event.eventDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isPast)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PAST EVENT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(BuildContext context, EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              children: [
                _buildDetailRow(Icons.category, 'Type', event.eventType),
                if (event.location != null) ...[
                  const Divider(),
                  _buildDetailRow(Icons.location_on, 'Location', event.location!),
                ],
                const Divider(),
                _buildDetailRow(
                  Icons.people,
                  'Guests',
                  '${event.guests.length}${event.maxGuests != null ? ' / ${event.maxGuests}' : ''}',
                ),
                if (event.allowPlusOnes) ...[
                  const Divider(),
                  _buildDetailRow(Icons.person_add, 'Plus Ones', 'Allowed'),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestListSection(BuildContext context, EventModel event, bool isHost) {
    final confirmedGuests = event.guests
        .where((g) => g.status == GuestStatus.confirmed || g.status == GuestStatus.attended)
        .toList();
    final pendingGuests = event.guests.where((g) => g.status == GuestStatus.invited).toList();
    final declinedGuests = event.guests.where((g) => g.status == GuestStatus.declined).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Guest List',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${confirmedGuests.length} confirmed',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Confirmed Guests
        if (confirmedGuests.isNotEmpty) ...[
          _buildGuestCategory('Confirmed', confirmedGuests, Colors.green),
          const SizedBox(height: 12),
        ],

        // Pending Guests
        if (pendingGuests.isNotEmpty && isHost) ...[
          _buildGuestCategory('Pending', pendingGuests, Colors.orange),
          const SizedBox(height: 12),
        ],

        // Declined Guests
        if (declinedGuests.isNotEmpty && isHost) ...[
          _buildGuestCategory('Declined', declinedGuests, Colors.red),
        ],
      ],
    );
  }

  Widget _buildGuestCategory(String title, List<EventGuest> guests, Color color) {
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.people, color: color),
        title: Text('$title (${guests.length})'),
        children: guests.map((guest) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                guest.name.substring(0, 1).toUpperCase(),
                style: TextStyle(color: color),
              ),
            ),
            title: Text(guest.name),
            subtitle: guest.email != null ? Text(guest.email!) : null,
            trailing: guest.plusOnes > 0
                ? Text('+${guest.plusOnes}', style: TextStyle(color: Colors.grey[600]))
                : null,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        ...event.recipes.map((eventRecipe) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.restaurant, color: AppTheme.primaryColor),
              title: Text(eventRecipe.dishName),
              subtitle: Text('${eventRecipe.servingsPlanned} servings'),
              trailing: eventRecipe.requestCount > 0
                  ? Chip(
                      label: Text('${eventRecipe.requestCount} requests'),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    )
                  : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(recipeId: eventRecipe.recipeId),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPhotosSection(BuildContext context, EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Photos',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: event.eventPhotoUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    event.eventPhotoUrls[index],
                    width: 160,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecapSection(BuildContext context, EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Recap',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(event.recap!),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestActions(BuildContext context, WidgetRef ref, EventModel event) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement RSVP
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('RSVP feature coming soon')),
            );
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('RSVP to Event'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Add to calendar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add to calendar feature coming soon')),
            );
          },
          icon: const Icon(Icons.calendar_today),
          label: const Text('Add to Calendar'),
        ),
      ],
    );
  }

  void _showQRCode(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event QR Code'),
        content: SizedBox(
          width: 280,
          height: 280,
          child: QrImageView(
            data: event.shareCode ?? event.eventId,
            version: QrVersions.auto,
            size: 280,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final eventRepo = ref.read(eventRepositoryProvider);
                await eventRepo.deleteEvent(event.eventId);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting event: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
