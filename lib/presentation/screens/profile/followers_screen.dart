import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/user_model.dart';
import 'package:recipe_app/presentation/providers/user_providers.dart';
import 'package:recipe_app/presentation/screens/profile/user_profile_screen.dart';

class FollowersScreen extends ConsumerStatefulWidget {
  final String userId;
  final int initialTab;

  const FollowersScreen({
    super.key,
    required this.userId,
    this.initialTab = 0,
  });

  @override
  ConsumerState<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends ConsumerState<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowersList(),
          _buildFollowingList(),
        ],
      ),
    );
  }

  Widget _buildFollowersList() {
    final followersAsync = ref.watch(followersProvider(widget.userId));

    return followersAsync.when(
      data: (followers) {
        if (followers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No followers yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(followersProvider(widget.userId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: followers.length,
            itemBuilder: (context, index) {
              return _buildUserListTile(followers[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading followers: $error'),
      ),
    );
  }

  Widget _buildFollowingList() {
    final followingAsync = ref.watch(followingProvider(widget.userId));

    return followingAsync.when(
      data: (following) {
        if (following.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Not following anyone yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(followingProvider(widget.userId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: following.length,
            itemBuilder: (context, index) {
              return _buildUserListTile(following[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading following: $error'),
      ),
    );
  }

  Widget _buildUserListTile(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
          backgroundImage: user.photoUrl != null
              ? CachedNetworkImageProvider(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Text(
                  user.displayName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(user.displayName),
        subtitle: user.bio != null && user.bio!.isNotEmpty
            ? Text(
                user.bio!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(userId: user.uid),
            ),
          );
        },
      ),
    );
  }
}
