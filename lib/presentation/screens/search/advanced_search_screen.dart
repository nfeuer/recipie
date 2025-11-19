import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/presentation/providers/recipe_providers.dart';
import 'package:recipe_app/presentation/screens/recipes/recipe_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  // Filter states
  String _searchQuery = '';
  List<String> _selectedTags = [];
  List<String> _selectedCategories = [];
  List<String> _selectedDifficulties = [];
  List<String> _requiredIngredients = [];
  int? _maxPrepTime;
  int? _maxCookTime;

  // Available filter options
  final List<String> _availableTags = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Low-Carb',
    'Keto',
    'Paleo',
    'Healthy',
    'Quick & Easy',
    'Comfort Food',
  ];

  final List<String> _availableCategories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Appetizer',
    'Snack',
    'Beverage',
    'Salad',
    'Soup',
    'Main Course',
  ];

  final List<String> _availableDifficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final ingredient = _ingredientsController.text.trim();
    if (ingredient.isNotEmpty && !_requiredIngredients.contains(ingredient)) {
      setState(() {
        _requiredIngredients.add(ingredient);
        _ingredientsController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _requiredIngredients.remove(ingredient);
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedTags.clear();
      _selectedCategories.clear();
      _selectedDifficulties.clear();
      _requiredIngredients.clear();
      _ingredientsController.clear();
      _maxPrepTime = null;
      _maxCookTime = null;
    });
  }

  List<RecipeModel> _applyFilters(List<RecipeModel> recipes) {
    return recipes.where((recipe) {
      // Text search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = recipe.title.toLowerCase().contains(query);
        final matchesDescription = recipe.description?.toLowerCase().contains(query) ?? false;
        if (!matchesTitle && !matchesDescription) return false;
      }

      // Tags filter
      if (_selectedTags.isNotEmpty) {
        final hasMatchingTag = _selectedTags.any((tag) => recipe.tags.contains(tag));
        if (!hasMatchingTag) return false;
      }

      // Category filter
      if (_selectedCategories.isNotEmpty) {
        if (!_selectedCategories.contains(recipe.category)) return false;
      }

      // Difficulty filter
      if (_selectedDifficulties.isNotEmpty) {
        if (!_selectedDifficulties.contains(recipe.difficulty)) return false;
      }

      // Required ingredients filter
      if (_requiredIngredients.isNotEmpty) {
        final recipeIngredientNames = recipe.ingredients
            .map((i) => i.item.toLowerCase())
            .toList();
        final hasAllIngredients = _requiredIngredients.every(
          (req) => recipeIngredientNames.any(
            (recipeName) => recipeName.contains(req.toLowerCase()),
          ),
        );
        if (!hasAllIngredients) return false;
      }

      // Prep time filter
      if (_maxPrepTime != null && recipe.prepTime > _maxPrepTime!) {
        return false;
      }

      // Cook time filter
      if (_maxCookTime != null && recipe.cookTime > _maxCookTime!) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(allRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        actions: [
          if (_hasActiveFilters())
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all, color: Colors.white),
              label: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            color: Colors.grey[100],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filters section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              children: [
                // Tags filter
                _buildFilterSection(
                  title: 'Tags',
                  icon: Icons.label,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Category filter
                _buildFilterSection(
                  title: 'Category',
                  icon: Icons.category,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableCategories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Difficulty filter
                _buildFilterSection(
                  title: 'Difficulty',
                  icon: Icons.trending_up,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableDifficulties.map((difficulty) {
                      final isSelected = _selectedDifficulties.contains(difficulty);
                      return FilterChip(
                        label: Text(difficulty),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDifficulties.add(difficulty);
                            } else {
                              _selectedDifficulties.remove(difficulty);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Required ingredients
                _buildFilterSection(
                  title: 'Must Include Ingredients',
                  icon: Icons.shopping_basket,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ingredientsController,
                              decoration: InputDecoration(
                                hintText: 'e.g., tomato',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onSubmitted: (_) => _addIngredient(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addIngredient,
                            icon: const Icon(Icons.add_circle),
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                      if (_requiredIngredients.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _requiredIngredients.map((ingredient) {
                            return Chip(
                              label: Text(ingredient),
                              onDeleted: () => _removeIngredient(ingredient),
                              deleteIcon: const Icon(Icons.close, size: 18),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Time filters
                _buildFilterSection(
                  title: 'Maximum Time',
                  icon: Icons.access_time,
                  child: Column(
                    children: [
                      _buildTimeSlider(
                        label: 'Prep Time',
                        value: _maxPrepTime,
                        onChanged: (value) {
                          setState(() {
                            _maxPrepTime = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildTimeSlider(
                        label: 'Cook Time',
                        value: _maxCookTime,
                        onChanged: (value) {
                          setState(() {
                            _maxCookTime = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Results section
                recipesAsync.when(
                  data: (recipes) {
                    final filteredRecipes = _applyFilters(recipes);
                    return _buildResultsSection(filteredRecipes);
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Error loading recipes: $error'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTimeSlider({
    required String label,
    required int? value,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value == null ? 'Any' : '$value min',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: (value ?? 0).toDouble(),
                min: 0,
                max: 180,
                divisions: 18,
                label: value == null ? 'Any' : '$value min',
                onChanged: (newValue) {
                  onChanged(newValue == 0 ? null : newValue.round());
                },
              ),
            ),
            if (value != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => onChanged(null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsSection(List<RecipeModel> filteredRecipes) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                '${filteredRecipes.length} recipes found',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (filteredRecipes.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...filteredRecipes.map((recipe) => _buildRecipeCard(recipe)),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipeId: recipe.recipeId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Recipe image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: recipe.photoUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: recipe.photoUrls.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        child: const Icon(Icons.restaurant, size: 32),
                      ),
              ),
              const SizedBox(width: 12),

              // Recipe info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.category ?? 'Uncategorized',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.prepTime + recipe.cookTime} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.trending_up, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty ?? 'Medium',
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
            ],
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _selectedTags.isNotEmpty ||
        _selectedCategories.isNotEmpty ||
        _selectedDifficulties.isNotEmpty ||
        _requiredIngredients.isNotEmpty ||
        _maxPrepTime != null ||
        _maxCookTime != null;
  }
}
