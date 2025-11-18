import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/recipe_providers.dart';
import 'package:recipe_app/presentation/providers/dynamic_link_providers.dart';
import 'package:recipe_app/presentation/screens/recipes/edit_recipe_screen.dart';
import 'package:recipe_app/presentation/screens/recipes/fork_recipe_screen.dart';
import 'package:recipe_app/presentation/screens/made_it/create_made_it_post_screen.dart';
import 'package:recipe_app/presentation/widgets/comments_section.dart';
import 'package:recipe_app/presentation/widgets/ratings_section.dart';
import 'package:recipe_app/presentation/widgets/made_it_posts_section.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeProvider(recipeId));
    final currentUser = ref.watch(currentUserProvider);

    return recipeAsync.when(
      data: (recipe) {
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe Not Found')),
            body: const Center(child: Text('Recipe not found')),
          );
        }

        final isOwner = currentUser.value?.uid == recipe.authorId;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3.0,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  background: recipe.photoUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: recipe.photoUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 64),
                          ),
                        )
                      : Container(
                          color: AppTheme.primaryColor,
                          child: const Icon(
                            Icons.restaurant,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () async {
                      final dynamicLinkService = ref.read(dynamicLinkServiceProvider);
                      await dynamicLinkService.shareRecipe(
                        recipeId: recipe.recipeId,
                        recipeTitle: recipe.title,
                        imageUrl: recipe.photoUrls.isNotEmpty ? recipe.photoUrls.first : null,
                      );
                    },
                  ),
                  if (isOwner)
                    PopupMenuButton(
                      itemBuilder: (context) => [
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
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditRecipeScreen(recipe: recipe),
                            ),
                          );
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, ref, recipe);
                        }
                      },
                    ),
                ],
              ),

              // Recipe Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (recipe.description != null) ...[
                        Text(
                          recipe.description!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Metadata Cards
                      _buildMetadataRow(context, recipe),
                      const SizedBox(height: 24),

                      // Dietary Tags
                      if (recipe.dietaryTags.isNotEmpty) ...[
                        _buildSectionTitle(context, 'Dietary Information'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recipe.dietaryTags.map((tag) {
                            return Chip(label: Text(tag));
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Tags
                      if (recipe.tags.isNotEmpty) ...[
                        _buildSectionTitle(context, 'Tags'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recipe.tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Ingredients
                      _buildSectionTitle(context, 'Ingredients'),
                      const SizedBox(height: 12),
                      _buildIngredientsList(recipe),
                      const SizedBox(height: 24),

                      // Steps
                      _buildSectionTitle(context, 'Instructions'),
                      const SizedBox(height: 12),
                      _buildStepsList(recipe),
                      const SizedBox(height: 24),

                      // Attribution
                      if (recipe.parentRecipeId != null || recipe.originalSource != null) ...[
                        _buildAttribution(context, recipe),
                        const SizedBox(height: 24),
                      ],

                      // Actions
                      _buildActionButtons(context, ref, recipe, isOwner),
                      const SizedBox(height: 32),

                      // Ratings Section
                      const Divider(),
                      RatingsSection(
                        recipeId: recipe.recipeId,
                        recipeName: recipe.title,
                        recipePhotoUrl: recipe.photoUrls.isNotEmpty ? recipe.photoUrls.first : null,
                      ),
                      const SizedBox(height: 24),

                      // Comments Section
                      const Divider(),
                      CommentsSection(
                        recipeId: recipe.recipeId,
                        recipeName: recipe.title,
                        recipePhotoUrl: recipe.photoUrls.isNotEmpty ? recipe.photoUrls.first : null,
                      ),
                      const SizedBox(height: 24),

                      // Made It Posts Section
                      const Divider(),
                      MadeItPostsSection(recipeId: recipe.recipeId),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading recipe: $error')),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, RecipeModel recipe) {
    return Row(
      children: [
        if (recipe.prepTimeMinutes != null)
          Expanded(
            child: _buildMetadataCard(
              context,
              icon: Icons.schedule,
              title: 'Prep',
              value: '${recipe.prepTimeMinutes} min',
            ),
          ),
        if (recipe.cookTimeMinutes != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetadataCard(
              context,
              icon: Icons.whatshot,
              title: 'Cook',
              value: '${recipe.cookTimeMinutes} min',
            ),
          ),
        ],
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetadataCard(
            context,
            icon: Icons.people,
            title: 'Servings',
            value: '${recipe.servings}',
          ),
        ),
        if (recipe.difficulty != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetadataCard(
              context,
              icon: Icons.bar_chart,
              title: 'Level',
              value: recipe.difficulty!,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildIngredientsList(RecipeModel recipe) {
    return Column(
      children: recipe.ingredients.asMap().entries.map((entry) {
        final ingredient = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${ingredient.amount ?? ''} ${ingredient.unit ?? ''} ${ingredient.name}'.trim(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepsList(RecipeModel recipe) {
    return Column(
      children: recipe.steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.instruction,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (step.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: step.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttribution(BuildContext context, RecipeModel recipe) {
    return Card(
      color: AppTheme.secondaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (recipe.originalSource != null)
              Text('Original source: ${recipe.originalSource}'),
            if (recipe.parentRecipeId != null)
              const Text('This is a modified version of another recipe'),
            if (recipe.attributionChain.isNotEmpty)
              Text('Attribution chain: ${recipe.attributionChain.join(' → ')}'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    RecipeModel recipe,
    bool isOwner,
  ) {
    return Row(
      children: [
        if (!isOwner) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ForkRecipeScreen(originalRecipe: recipe),
                  ),
                );
              },
              icon: const Icon(Icons.call_split),
              label: const Text('Fork Recipe'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateMadeItPostScreen(
                    recipeId: recipe.recipeId,
                    recipeName: recipe.title,
                    recipePhotoUrl: recipe.photoUrls.isNotEmpty ? recipe.photoUrls.first : null,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('I Made This'),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, RecipeModel recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final recipeRepo = ref.read(recipeRepositoryProvider);
                await recipeRepo.deleteRecipe(recipe.recipeId);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recipe deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting recipe: $e')),
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
