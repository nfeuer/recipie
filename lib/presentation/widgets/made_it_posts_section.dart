import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/made_it_model.dart';
import 'package:recipe_app/presentation/providers/made_it_providers.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/screens/profile/user_profile_screen.dart';

class MadeItPostsSection extends ConsumerWidget {
  final String recipeId;

  const MadeItPostsSection({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(recipePostsStreamProvider(recipeId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Text(
            'People Who Made This',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),

        postsAsync.when(
          data: (posts) {
            if (posts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppTheme.paddingLarge),
                child: Center(
                  child: Text(
                    'No one has made this yet. Be the first!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _MadeItPostCard(post: posts[index]);
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
              child: Text('Error loading posts: $error'),
            ),
          ),
        ),
      ],
    );
  }
}

class _MadeItPostCard extends ConsumerWidget {
  final MadeItModel post;

  const _MadeItPostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isLiked = currentUser != null && post.likes.contains(currentUser.uid);
    final isOwner = currentUser?.uid == post.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info header
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(userId: post.userId),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                backgroundImage: post.userPhotoUrl != null
                    ? CachedNetworkImageProvider(post.userPhotoUrl!)
                    : null,
                child: post.userPhotoUrl == null
                    ? Text(
                        post.userName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(userId: post.userId),
                  ),
                );
              },
              child: Text(
                post.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              DateFormat('MMM d, y').format(post.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: isOwner
                ? PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
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
                          final madeItRepository = ref.read(madeItRepositoryProvider);
                          await madeItRepository.deletePost(post.postId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Post deleted')),
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
                  )
                : null,
          ),

          // Photos
          if (post.photoUrls.isNotEmpty)
            SizedBox(
              height: 300,
              child: post.photoUrls.length == 1
                  ? CachedNetworkImage(
                      imageUrl: post.photoUrls.first,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : PageView.builder(
                      itemCount: post.photoUrls.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: post.photoUrls[index],
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating
                if (post.rating != null)
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < post.rating! ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${post.rating}/5',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                // Caption
                if (post.caption != null && post.caption!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(post.caption!, style: const TextStyle(fontSize: 14)),
                ],

                // Modifications
                if (post.modifications != null && post.modifications!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit_note, size: 16, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              'Modifications',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.modifications!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Like button
                Row(
                  children: [
                    InkWell(
                      onTap: currentUser != null
                          ? () async {
                              try {
                                final madeItRepository = ref.read(madeItRepositoryProvider);
                                await madeItRepository.toggleLike(
                                  post.postId,
                                  currentUser.uid,
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
                            size: 20,
                            color: isLiked ? Colors.red : Colors.grey[600],
                          ),
                          if (post.likes.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${post.likes.length} ${post.likes.length == 1 ? 'like' : 'likes'}',
                              style: TextStyle(
                                fontSize: 14,
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
}
