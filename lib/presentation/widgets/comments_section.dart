import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/comment_model.dart';
import 'package:recipe_app/data/models/activity_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/comment_providers.dart';
import 'package:recipe_app/presentation/providers/user_providers.dart';
import 'package:recipe_app/presentation/providers/activity_providers.dart';
import 'package:recipe_app/presentation/screens/profile/user_profile_screen.dart';

class CommentsSection extends ConsumerStatefulWidget {
  final String recipeId;
  final String recipeName;
  final String? recipePhotoUrl;

  const CommentsSection({
    super.key,
    required this.recipeId,
    required this.recipeName,
    this.recipePhotoUrl,
  });

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Get current user profile for name and photo
      final userProfile = await ref.read(userProfileProvider(currentUser.uid).future);
      if (userProfile == null) throw Exception('User profile not found');

      final comment = CommentModel(
        commentId: const Uuid().v4(),
        recipeId: widget.recipeId,
        userId: currentUser.uid,
        userName: userProfile.displayName,
        userPhotoUrl: userProfile.photoUrl,
        text: text,
        createdAt: DateTime.now(),
      );

      final commentRepository = ref.read(commentRepositoryProvider);
      await commentRepository.createComment(comment);

      // Create activity
      final activity = ActivityModel(
        activityId: const Uuid().v4(),
        userId: currentUser.uid,
        userName: userProfile.displayName,
        userPhotoUrl: userProfile.photoUrl,
        type: ActivityType.recipeCommented,
        timestamp: DateTime.now(),
        recipeId: widget.recipeId,
        recipeName: widget.recipeName,
        recipePhotoUrl: widget.recipePhotoUrl,
        comment: text,
      );

      final activityRepository = ref.read(activityRepositoryProvider);
      await activityRepository.createActivity(activity);

      _commentController.clear();

      if (mounted) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding comment: $e')),
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
    final commentsAsync = ref.watch(recipeCommentsStreamProvider(widget.recipeId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Text(
            'Comments',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),

        // Comments list
        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.comment_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      const Text(
                        'No comments yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Be the first to comment!',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return _CommentItem(
                  comment: comments[index],
                  currentUserId: currentUser?.uid,
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppTheme.paddingLarge),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Center(
              child: Text('Error loading comments: $error'),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Comment input
        if (currentUser != null)
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: const Center(
              child: Text(
                'Sign in to comment',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}

class _CommentItem extends ConsumerWidget {
  final CommentModel comment;
  final String? currentUserId;

  const _CommentItem({
    required this.comment,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = currentUserId != null && comment.likes.contains(currentUserId);
    final isOwner = currentUserId == comment.userId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(userId: comment.userId),
                ),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              backgroundImage: comment.userPhotoUrl != null
                  ? CachedNetworkImageProvider(comment.userPhotoUrl!)
                  : null,
              child: comment.userPhotoUrl == null
                  ? Text(
                      comment.userName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name and timestamp
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UserProfileScreen(userId: comment.userId),
                            ),
                          );
                        },
                        child: Text(
                          comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _formatTimestamp(comment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (isOwner)
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert, size: 16, color: Colors.grey[600]),
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
                              final commentRepository = ref.read(commentRepositoryProvider);
                              await commentRepository.deleteComment(comment.commentId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Comment deleted')),
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
                const SizedBox(height: 4),

                // Comment text
                Text(
                  comment.text,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Like button
                Row(
                  children: [
                    InkWell(
                      onTap: currentUserId != null
                          ? () async {
                              try {
                                final commentRepository = ref.read(commentRepositoryProvider);
                                await commentRepository.toggleLike(
                                  comment.commentId,
                                  currentUserId!,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          : null,
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isLiked ? Colors.red : Colors.grey[600],
                          ),
                          if (comment.likes.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              comment.likes.length.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
