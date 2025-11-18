import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/user_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/user_providers.dart';
import 'package:recipe_app/presentation/providers/recipe_providers.dart';
import 'package:recipe_app/presentation/screens/profile/edit_profile_screen.dart';
import 'package:recipe_app/presentation/screens/profile/followers_screen.dart';
import 'package:recipe_app/presentation/widgets/recipe_card.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileStreamProvider(userId));
    final currentUser = ref.watch(currentUserProvider).value;
    final isOwnProfile = currentUser?.uid == userId;

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('User Not Found')),
            body: const Center(child: Text('User not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(user.displayName),
            actions: [
              if (isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // TODO: Navigate to settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon')),
                    );
                  },
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userProfileStreamProvider(userId));
              ref.invalidate(userRecipesProvider(userId));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileHeader(context, ref, user, isOwnProfile),
                      const SizedBox(height: 16),
                      _buildStats(context, ref, user),
                      const SizedBox(height: 16),
                      if (!isOwnProfile) _buildFollowButton(context, ref, user),
                      const Divider(),
                    ],
                  ),
                ),
                _buildRecipesGrid(context, ref, user),
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
        body: Center(child: Text('Error loading profile: $error')),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    bool isOwnProfile,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            backgroundImage: user.photoUrl != null
                ? CachedNetworkImageProvider(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? Text(
                    user.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Display Name
          Text(
            user.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),

          // Bio
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],

          // Dietary Preferences
          if (user.dietaryPreferences.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: user.dietaryPreferences.map((pref) {
                return Chip(
                  label: Text(pref),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Edit Profile Button
          if (isOwnProfile)
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(user: user),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, WidgetRef ref, UserModel user) {
    final recipesAsync = ref.watch(userRecipesProvider(userId));
    final followersAsync = ref.watch(followersProvider(userId));
    final followingAsync = ref.watch(followingProvider(userId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            'Recipes',
            recipesAsync.when(
              data: (recipes) => recipes.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            onTap: null,
          ),
          _buildStatItem(
            context,
            'Followers',
            followersAsync.when(
              data: (followers) => followers.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FollowersScreen(
                    userId: userId,
                    initialTab: 0,
                  ),
                ),
              );
            },
          ),
          _buildStatItem(
            context,
            'Following',
            followingAsync.when(
              data: (following) => following.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FollowersScreen(
                    userId: userId,
                    initialTab: 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, WidgetRef ref, UserModel user) {
    final isFollowingAsync = ref.watch(isFollowingProvider(userId));

    return isFollowingAsync.when(
      data: (isFollowing) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final currentUser = ref.read(currentUserProvider).value;
                if (currentUser == null) return;

                try {
                  final userRepository = ref.read(userRepositoryProvider);
                  if (isFollowing) {
                    await userRepository.unfollowUser(currentUser.uid, userId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unfollowed ${user.displayName}')),
                      );
                    }
                  } else {
                    await userRepository.followUser(currentUser.uid, userId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Now following ${user.displayName}')),
                      );
                    }
                  }
                  // Refresh following status
                  ref.invalidate(isFollowingProvider(userId));
                  ref.invalidate(followersProvider(userId));
                  ref.invalidate(followingProvider(currentUser.uid));
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              icon: Icon(isFollowing ? Icons.person_remove : Icons.person_add),
              label: Text(isFollowing ? 'Unfollow' : 'Follow'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey : AppTheme.primaryColor,
              ),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecipesGrid(BuildContext context, WidgetRef ref, UserModel user) {
    final recipesAsync = ref.watch(userRecipesProvider(userId));

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No recipes yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return RecipeCard(recipe: recipes[index]);
              },
              childCount: recipes.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SliverFillRemaining(
        child: Center(child: Text('Error loading recipes: $error')),
      ),
    );
  }
}
