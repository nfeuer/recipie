import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/activity_model.dart';
import 'package:recipe_app/presentation/screens/recipes/recipe_detail_screen.dart';
import 'package:recipe_app/presentation/screens/events/event_detail_screen.dart';
import 'package:recipe_app/presentation/screens/profile/user_profile_screen.dart';

class ActivityItem extends StatelessWidget {
  final ActivityModel activity;

  const ActivityItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: 8,
      ),
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(userId: activity.userId),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                      backgroundImage: activity.userPhotoUrl != null
                          ? CachedNetworkImageProvider(activity.userPhotoUrl!)
                          : null,
                      child: activity.userPhotoUrl == null
                          ? Text(
                              activity.userName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: activity.userName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(text: activity.getDescription()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(activity.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildActivityIcon(),
                ],
              ),

              // Activity content
              if (_hasContentToShow()) ...[
                const SizedBox(height: 12),
                _buildActivityContent(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityIcon() {
    IconData icon;
    Color color;

    switch (activity.type) {
      case ActivityType.recipeCreated:
        icon = Icons.restaurant_menu;
        color = Colors.green;
        break;
      case ActivityType.recipeMade:
        icon = Icons.check_circle;
        color = Colors.blue;
        break;
      case ActivityType.eventCreated:
        icon = Icons.event;
        color = Colors.orange;
        break;
      case ActivityType.userFollowed:
        icon = Icons.person_add;
        color = AppTheme.primaryColor;
        break;
      case ActivityType.recipeCommented:
        icon = Icons.comment;
        color = Colors.purple;
        break;
      case ActivityType.recipeRated:
        icon = Icons.star;
        color = Colors.amber;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }

  bool _hasContentToShow() {
    return activity.recipePhotoUrl != null ||
        activity.photoUrls != null && activity.photoUrls!.isNotEmpty ||
        activity.comment != null;
  }

  Widget _buildActivityContent(BuildContext context) {
    // Show recipe photo for recipe-related activities
    if (activity.recipePhotoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: activity.recipePhotoUrl!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        ),
      );
    }

    // Show "I Made This" photos
    if (activity.photoUrls != null && activity.photoUrls!.isNotEmpty) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: activity.photoUrls!.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: activity.photoUrls![index],
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    }

    // Show comment
    if (activity.comment != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          activity.comment!,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _handleTap(BuildContext context) {
    // Navigate to related content
    if (activity.recipeId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipeId: activity.recipeId!),
        ),
      );
    } else if (activity.eventId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(eventId: activity.eventId!),
        ),
      );
    } else if (activity.targetUserId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(userId: activity.targetUserId!),
        ),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
