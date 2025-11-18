import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/recipe_providers.dart';
import 'package:recipe_app/presentation/providers/shopping_list_providers.dart';
import 'package:recipe_app/presentation/screens/shopping_list/shopping_list_detail_screen.dart';

class CreateShoppingListScreen extends ConsumerStatefulWidget {
  const CreateShoppingListScreen({super.key});

  @override
  ConsumerState<CreateShoppingListScreen> createState() => _CreateShoppingListScreenState();
}

class _CreateShoppingListScreenState extends ConsumerState<CreateShoppingListScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Shopping List',
  );
  final Set<String> _selectedRecipeIds = {};
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generateList() async {
    if (_selectedRecipeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one recipe')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() => _isGenerating = true);

    try {
      // Get all selected recipes
      final futures = _selectedRecipeIds.map(
        (id) => ref.read(recipeProvider(id).future),
      );

      final recipes = (await Future.wait(futures))
          .where((recipe) => recipe != null)
          .cast<RecipeModel>()
          .toList();

      if (recipes.isEmpty) {
        throw Exception('No recipes found');
      }

      // Generate shopping list
      final repository = ref.read(shoppingListRepositoryProvider);
      final generatedList = await repository.generateFromRecipes(
        currentUser.uid,
        recipes,
        _nameController.text.trim(),
      );

      // Create with proper ID
      final listWithId = generatedList.copyWith(
        name: generatedList.name,
      );

      final finalList = ShoppingListModel(
        listId: const Uuid().v4(),
        userId: listWithId.userId,
        name: listWithId.name,
        items: listWithId.items,
        isGenerated: listWithId.isGenerated,
        sourceRecipeIds: listWithId.sourceRecipeIds,
        createdAt: listWithId.createdAt,
        updatedAt: listWithId.updatedAt,
      );

      await repository.createShoppingList(finalList);

      if (mounted) {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ShoppingListDetailScreen(listId: finalList.listId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating list: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final recipesAsync = currentUser != null
        ? ref.watch(userRecipesProvider(currentUser.uid))
        : const AsyncValue.data(<RecipeModel>[]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Shopping List'),
        actions: [
          if (_isGenerating)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _generateList,
              child: const Text('Generate'),
            ),
        ],
      ),
      body: Column(
        children: [
          // List name input
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                hintText: 'e.g., Weekly Groceries',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Select recipes to combine their ingredients',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recipe selection
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No recipes found',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create some recipes first',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    final isSelected = _selectedRecipeIds.contains(recipe.recipeId);

                    return Card(
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedRecipeIds.add(recipe.recipeId);
                            } else {
                              _selectedRecipeIds.remove(recipe.recipeId);
                            }
                          });
                        },
                        title: Text(recipe.title),
                        subtitle: Text(
                          '${recipe.ingredients.length} ingredients • ${recipe.servings} servings',
                          style: const TextStyle(fontSize: 12),
                        ),
                        secondary: recipe.photoUrls.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  recipe.photoUrls.first,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.restaurant_menu),
                              ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading recipes: $error'),
              ),
            ),
          ),

          // Selected count
          if (_selectedRecipeIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedRecipeIds.length} recipe${_selectedRecipeIds.length == 1 ? '' : 's'} selected',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
