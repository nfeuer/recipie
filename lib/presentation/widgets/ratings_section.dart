import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/rating_model.dart';
import 'package:recipe_app/data/models/activity_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/rating_providers.dart';
import 'package:recipe_app/presentation/providers/user_providers.dart';
import 'package:recipe_app/presentation/providers/activity_providers.dart';
import 'package:recipe_app/presentation/screens/profile/user_profile_screen.dart';

class RatingsSection extends ConsumerStatefulWidget {
  final String recipeId;
  final String recipeName;
  final String? recipePhotoUrl;

  const RatingsSection({
    super.key,
    required this.recipeId,
    required this.recipeName,
    this.recipePhotoUrl,
  });

  @override
  ConsumerState<RatingsSection> createState() => _RatingsSectionState();
}

class _RatingsSectionState extends ConsumerState<RatingsSection> {
  @override
  Widget build(BuildContext context) {
    final ratingsAsync = ref.watch(recipeRatingsStreamProvider(widget.recipeId));
    final statsAsync = ref.watch(recipeRatingStatsProvider(widget.recipeId));
    final currentUserRatingAsync = ref.watch(currentUserRatingProvider(widget.recipeId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ratings & Reviews',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (currentUser != null)
                TextButton.icon(
                  onPressed: () {
                    _showAddRatingDialog(context);
                  },
                  icon: const Icon(Icons.star_border),
                  label: currentUserRatingAsync.when(
                    data: (userRating) => Text(userRating != null ? 'Edit Rating' : 'Rate'),
                    loading: () => const Text('Rate'),
                    error: (_, __) => const Text('Rate'),
                  ),
                ),
            ],
          ),
        ),

        // Rating Stats Summary
        statsAsync.when(
          data: (stats) {
            if (stats['count'] == 0) {
              return Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.star_outline, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      const Text(
                        'No ratings yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Be the first to rate this recipe!',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Row(
                    children: [
                      // Average rating
                      Column(
                        children: [
                          Text(
                            stats['average'].toStringAsFixed(1),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          RatingBarIndicator(
                            rating: stats['average'],
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stats['count']} ratings',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),

                      // Rating distribution
                      Expanded(
                        child: Column(
                          children: List.generate(5, (index) {
                            final star = 5 - index;
                            final count = stats['distribution'][star] ?? 0;
                            final percentage = stats['count'] > 0 ? count / stats['count'] : 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '$star',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      count.toString(),
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppTheme.paddingLarge),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Center(
              child: Text('Error loading ratings: $error'),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Ratings list
        ratingsAsync.when(
          data: (ratings) {
            if (ratings.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                return _RatingItem(
                  rating: ratings[index],
                  currentUserId: currentUser?.uid,
                );
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _showAddRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddRatingDialog(
        recipeId: widget.recipeId,
        recipeName: widget.recipeName,
        recipePhotoUrl: widget.recipePhotoUrl,
      ),
    );
  }
}

class _RatingItem extends ConsumerWidget {
  final RatingModel rating;
  final String? currentUserId;

  const _RatingItem({
    required this.rating,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = currentUserId == rating.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User avatar
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(userId: rating.userId),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    backgroundImage: rating.userPhotoUrl != null
                        ? CachedNetworkImageProvider(rating.userPhotoUrl!)
                        : null,
                    child: rating.userPhotoUrl == null
                        ? Text(
                            rating.userName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // User info and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UserProfileScreen(userId: rating.userId),
                            ),
                          );
                        },
                        child: Text(
                          rating.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: rating.rating.toDouble(),
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 16.0,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM d, y').format(rating.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (isOwner)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        try {
                          final ratingRepository = ref.read(ratingRepositoryProvider);
                          await ratingRepository.deleteRating(rating.ratingId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Rating deleted')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
              ],
            ),

            // Review text
            if (rating.review != null && rating.review!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                rating.review!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddRatingDialog extends ConsumerStatefulWidget {
  final String recipeId;
  final String recipeName;
  final String? recipePhotoUrl;

  const _AddRatingDialog({
    required this.recipeId,
    required this.recipeName,
    this.recipePhotoUrl,
  });

  @override
  ConsumerState<_AddRatingDialog> createState() => _AddRatingDialogState();
}

class _AddRatingDialogState extends ConsumerState<_AddRatingDialog> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Get current user profile
      final userProfile = await ref.read(userProfileProvider(currentUser.uid).future);
      if (userProfile == null) throw Exception('User profile not found');

      // Check if user already rated
      final existingRating = await ref.read(currentUserRatingProvider(widget.recipeId).future);

      final ratingId = existingRating?.ratingId ?? const Uuid().v4();
      final now = DateTime.now();

      final rating = RatingModel(
        ratingId: ratingId,
        recipeId: widget.recipeId,
        userId: currentUser.uid,
        userName: userProfile.displayName,
        userPhotoUrl: userProfile.photoUrl,
        rating: _rating.toInt(),
        review: _reviewController.text.trim().isNotEmpty ? _reviewController.text.trim() : null,
        createdAt: existingRating?.createdAt ?? now,
        updatedAt: now,
      );

      final ratingRepository = ref.read(ratingRepositoryProvider);
      await ratingRepository.setRating(rating);

      // Create activity only if it's a new rating
      if (existingRating == null) {
        final activity = ActivityModel(
          activityId: const Uuid().v4(),
          userId: currentUser.uid,
          userName: userProfile.displayName,
          userPhotoUrl: userProfile.photoUrl,
          type: ActivityType.recipeRated,
          timestamp: now,
          recipeId: widget.recipeId,
          recipeName: widget.recipeName,
          recipePhotoUrl: widget.recipePhotoUrl,
          rating: _rating.toInt(),
        );

        final activityRepository = ref.read(activityRepositoryProvider);
        await activityRepository.createActivity(activity);
      }

      // Invalidate providers
      ref.invalidate(currentUserRatingProvider(widget.recipeId));
      ref.invalidate(recipeRatingStatsProvider(widget.recipeId));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingRatingAsync = ref.watch(currentUserRatingProvider(widget.recipeId));

    return existingRatingAsync.when(
      data: (existingRating) {
        if (_rating == 0 && existingRating != null) {
          _rating = existingRating.rating.toDouble();
          _reviewController.text = existingRating.review ?? '';
        }

        return AlertDialog(
          title: Text(existingRating != null ? 'Edit Rating' : 'Rate this Recipe'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How would you rate this recipe?'),
                const SizedBox(height: 16),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    labelText: 'Write a review (optional)',
                    hintText: 'Share your thoughts about this recipe...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRating,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        );
      },
      loading: () => const AlertDialog(
        content: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to load rating: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
