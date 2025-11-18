import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/recipe_model.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            if (recipe.photoUrls.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: recipe.photoUrls.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
              ),

            // Recipe Details
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (recipe.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      recipe.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Metadata Row
                  Row(
                    children: [
                      // Time
                      if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null)
                        _buildMetadataChip(
                          icon: Icons.access_time,
                          label: _getTotalTime(),
                        ),

                      const SizedBox(width: 8),

                      // Servings
                      _buildMetadataChip(
                        icon: Icons.people,
                        label: '${recipe.servings} servings',
                      ),

                      const SizedBox(width: 8),

                      // Difficulty
                      if (recipe.difficulty != null)
                        _buildMetadataChip(
                          icon: Icons.bar_chart,
                          label: recipe.difficulty!,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Rating and Stats
                  Row(
                    children: [
                      if (recipe.averageRating != null) ...[
                        RatingBarIndicator(
                          rating: recipe.averageRating!,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 16.0,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          recipe.averageRating!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                      ],

                      if (recipe.forkCount > 0) ...[
                        Icon(Icons.call_split, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.forkCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                      ],

                      if (recipe.madeItCount > 0) ...[
                        Icon(Icons.check_circle, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.madeItCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),

                  // Tags
                  if (recipe.dietaryTags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recipe.dietaryTags.take(3).map((tag) {
                        return Chip(
                          label: Text(tag),
                          labelStyle: const TextStyle(fontSize: 12),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getTotalTime() {
    final prep = recipe.prepTimeMinutes ?? 0;
    final cook = recipe.cookTimeMinutes ?? 0;
    final total = prep + cook;

    if (total < 60) {
      return '${total}min';
    } else {
      final hours = total ~/ 60;
      final minutes = total % 60;
      if (minutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${minutes}min';
    }
  }
}
