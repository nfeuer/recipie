import 'package:flutter/material.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/core/utils/ingredient_scaling.dart';
import 'package:recipe_app/data/models/recipe_model.dart';

/// Widget for scaling recipe servings
class IngredientScalingWidget extends StatefulWidget {
  final RecipeModel recipe;
  final Function(RecipeModel) onScaled;

  const IngredientScalingWidget({
    super.key,
    required this.recipe,
    required this.onScaled,
  });

  @override
  State<IngredientScalingWidget> createState() => _IngredientScalingWidgetState();
}

class _IngredientScalingWidgetState extends State<IngredientScalingWidget> {
  late int _currentServings;

  @override
  void initState() {
    super.initState();
    _currentServings = widget.recipe.servings;
  }

  void _scaleRecipe(int newServings) {
    if (newServings == _currentServings) return;

    final scaledRecipe = IngredientScaling.scaleRecipe(widget.recipe, newServings);
    setState(() {
      _currentServings = newServings;
    });
    widget.onScaled(scaledRecipe);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = IngredientScaling.getScalingSuggestions(widget.recipe.servings);

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Servings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _currentServings > 1
                        ? () => _scaleRecipe(_currentServings - 1)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentServings.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _scaleRecipe(_currentServings + 1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((servings) {
              final isSelected = servings == _currentServings;
              final isOriginal = servings == widget.recipe.servings;

              return FilterChip(
                label: Text(
                  servings.toString() + (isOriginal ? ' (original)' : ''),
                ),
                selected: isSelected,
                onSelected: (_) => _scaleRecipe(servings),
                selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                backgroundColor: isOriginal
                    ? Colors.blue[50]
                    : null,
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          if (_currentServings != widget.recipe.servings) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ingredients have been scaled from ${widget.recipe.servings} to $_currentServings servings',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact inline serving scaler
class CompactServingScaler extends StatelessWidget {
  final int currentServings;
  final ValueChanged<int> onChanged;

  const CompactServingScaler({
    super.key,
    required this.currentServings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Servings:',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: currentServings > 1
              ? () => onChanged(currentServings - 1)
              : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        Text(
          currentServings.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: () => onChanged(currentServings + 1),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
