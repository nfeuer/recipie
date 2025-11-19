import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/presentation/providers/recipe_providers.dart';

class EditRecipeScreen extends ConsumerStatefulWidget {
  final RecipeModel recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  ConsumerState<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends ConsumerState<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _servingsController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;

  String? _selectedDifficulty;
  List<Ingredient> _ingredients = [];
  List<RecipeStep> _steps = [];
  List<String> _selectedDietaryTags = [];
  List<String> _selectedTags = [];
  late RecipePrivacy _privacy;
  bool _isLoading = false;

  final _ingredientNameController = TextEditingController();
  final _ingredientAmountController = TextEditingController();
  final _ingredientUnitController = TextEditingController();
  final _stepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController = TextEditingController(text: widget.recipe.description ?? '');
    _servingsController = TextEditingController(text: widget.recipe.servings.toString());
    _prepTimeController = TextEditingController(
      text: widget.recipe.prepTimeMinutes?.toString() ?? '',
    );
    _cookTimeController = TextEditingController(
      text: widget.recipe.cookTimeMinutes?.toString() ?? '',
    );
    _selectedDifficulty = widget.recipe.difficulty;
    _ingredients = List.from(widget.recipe.ingredients);
    _steps = List.from(widget.recipe.steps);
    _selectedDietaryTags = List.from(widget.recipe.dietaryTags);
    _selectedTags = List.from(widget.recipe.tags);
    _privacy = widget.recipe.privacy;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _ingredientNameController.dispose();
    _ingredientAmountController.dispose();
    _ingredientUnitController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingredientNameController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(Ingredient(
          name: _ingredientNameController.text,
          amount: _ingredientAmountController.text.isNotEmpty
              ? _ingredientAmountController.text
              : null,
          unit: _ingredientUnitController.text.isNotEmpty
              ? _ingredientUnitController.text
              : null,
        ));
        _ingredientNameController.clear();
        _ingredientAmountController.clear();
        _ingredientUnitController.clear();
      });
    }
  }

  void _addStep() {
    if (_stepController.text.isNotEmpty) {
      setState(() {
        _steps.add(RecipeStep(
          order: _steps.length,
          instruction: _stepController.text,
        ));
        _stepController.clear();
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one instruction step')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedRecipe = widget.recipe.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        ingredients: _ingredients,
        steps: _steps,
        prepTimeMinutes: _prepTimeController.text.isNotEmpty
            ? int.tryParse(_prepTimeController.text)
            : null,
        cookTimeMinutes: _cookTimeController.text.isNotEmpty
            ? int.tryParse(_cookTimeController.text)
            : null,
        servings: int.parse(_servingsController.text),
        difficulty: _selectedDifficulty,
        tags: _selectedTags,
        dietaryTags: _selectedDietaryTags,
        privacy: _privacy,
        updatedAt: DateTime.now(),
      );

      final recipeRepository = ref.read(recipeRepositoryProvider);
      await recipeRepository.updateRecipe(updatedRecipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating recipe: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
        actions: [
          if (_isLoading)
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
              onPressed: _saveChanges,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          children: [
            // Basic Info
            Text('Basic Information', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title *',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Recipe Details
            Text('Recipe Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: const InputDecoration(labelText: 'Servings *'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    decoration: const InputDecoration(labelText: 'Prep (min)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cookTimeController,
                    decoration: const InputDecoration(labelText: 'Cook (min)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    items: AppConstants.difficulties.map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedDifficulty = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dietary Tags
            _buildDietaryTagsSection(),
            const SizedBox(height: 24),

            // Ingredients
            _buildIngredientsSection(),
            const SizedBox(height: 24),

            // Steps
            _buildStepsSection(),
            const SizedBox(height: 24),

            // Privacy
            _buildPrivacySection(),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dietary Tags', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.dietaryTags.map((tag) {
            final isSelected = _selectedDietaryTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDietaryTags.add(tag);
                  } else {
                    _selectedDietaryTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients *', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _ingredientNameController,
                decoration: const InputDecoration(labelText: 'Ingredient'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ingredientAmountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ingredientUnitController,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addIngredient,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_ingredients.isNotEmpty) ...[
          ...List.generate(_ingredients.length, (index) {
            final ingredient = _ingredients[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(
                  '${ingredient.amount ?? ''} ${ingredient.unit ?? ''} ${ingredient.name}'.trim(),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _ingredients.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instructions *', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _stepController,
                decoration: const InputDecoration(labelText: 'Step instruction'),
                maxLines: 2,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addStep,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_steps.isNotEmpty) ...[
          ...List.generate(_steps.length, (index) {
            final step = _steps[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text('${index + 1}'),
                ),
                title: Text(step.instruction),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _steps.removeAt(index);
                      for (int i = 0; i < _steps.length; i++) {
                        _steps[i] = RecipeStep(
                          order: i,
                          instruction: _steps[i].instruction,
                        );
                      }
                    });
                  },
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Privacy', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        DropdownButtonFormField<RecipePrivacy>(
          value: _privacy,
          decoration: const InputDecoration(labelText: 'Who can see this recipe?'),
          items: RecipePrivacy.values.map((privacy) {
            return DropdownMenuItem(
              value: privacy,
              child: Text(_getPrivacyLabel(privacy)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _privacy = value);
            }
          },
        ),
      ],
    );
  }

  String _getPrivacyLabel(RecipePrivacy privacy) {
    switch (privacy) {
      case RecipePrivacy.public:
        return 'Public - Everyone can see';
      case RecipePrivacy.friends:
      case RecipePrivacy.friendsOnly:
        return 'Friends - Only followers';
      case RecipePrivacy.private:
        return 'Private - Only me';
      case RecipePrivacy.eventOnly:
        return 'Event Only - Only event guests';
    }
  }
}
