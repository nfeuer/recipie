import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/recipe_providers.dart';
import 'package:recipe_app/presentation/screens/recipes/recipe_detail_screen.dart';
import 'package:recipe_app/presentation/screens/recipes/create_recipe_screen.dart';
import 'package:recipe_app/presentation/screens/search/advanced_search_screen.dart';
import 'package:recipe_app/presentation/widgets/recipe_card.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdvancedSearchScreen(),
                ),
              );
            },
            tooltip: 'Advanced Search',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RecipeSearchDelegate(ref),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Recipes'),
            Tab(text: 'Public'),
            Tab(text: 'Trending'),
            Tab(text: 'Top Rated'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Recipes Tab
          currentUser.when(
            data: (user) {
              if (user == null) {
                return const Center(child: Text('Please sign in to view your recipes'));
              }
              return _buildMyRecipesTab(user.uid);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error loading user')),
          ),
          // Public Recipes Tab
          _buildPublicRecipesTab(),
          // Trending Recipes Tab
          _buildTrendingRecipesTab(),
          // Top Rated Recipes Tab
          _buildTopRatedRecipesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateRecipeScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Recipe'),
      ),
    );
  }

  Widget _buildMyRecipesTab(String userId) {
    final recipesAsync = ref.watch(userRecipesProvider(userId));

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No recipes yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Create your first recipe to get started'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateRecipeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Recipe'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userRecipesProvider(userId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipeId: recipe.recipeId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading recipes: $error'),
      ),
    );
  }

  Widget _buildPublicRecipesTab() {
    final recipesAsync = ref.watch(publicRecipesProvider);

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(child: Text('No public recipes available'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(publicRecipesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipeId: recipe.recipeId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading recipes: $error'),
      ),
    );
  }

  Widget _buildTrendingRecipesTab() {
    final recipesAsync = ref.watch(trendingRecipesProvider);

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(child: Text('No trending recipes'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trendingRecipesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipeId: recipe.recipeId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading recipes: $error'),
      ),
    );
  }

  Widget _buildTopRatedRecipesTab() {
    final recipesAsync = ref.watch(topRatedRecipesProvider);

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(child: Text('No top rated recipes'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(topRatedRecipesProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipeId: recipe.recipeId),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading recipes: $error'),
      ),
    );
  }
}

// Recipe Search Delegate
class RecipeSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  RecipeSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    final searchResults = ref.watch(recipeSearchProvider(query));

    return searchResults.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(child: Text('No recipes found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return RecipeCard(
              recipe: recipe,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(recipeId: recipe.recipeId),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search for recipes by name, ingredients, or tags'),
    );
  }
}
