import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/recipe_providers.dart';
import 'package:uuid/uuid.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController(text: '4');
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();

  String? _selectedDifficulty;
  final List<Ingredient> _ingredients = [];
  final List<RecipeStep> _steps = [];
  final List<String> _selectedDietaryTags = [];
  final List<String> _selectedTags = [];
  final List<XFile> _imageFiles = [];
  RecipePrivacy _privacy = RecipePrivacy.public;
  bool _isLoading = false;

  final _ingredientNameController = TextEditingController();
  final _ingredientAmountController = TextEditingController();
  final _ingredientUnitController = TextEditingController();
  final _stepController = TextEditingController();

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

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(images);
      });
    }
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

  Future<void> _saveRecipe() async {
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
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Upload images first
      List<String> photoUrls = [];
      if (_imageFiles.isNotEmpty) {
        final storageService = ref.read(storageServiceProvider);
        final recipeId = const Uuid().v4(); // Generate temp ID for storage path

        photoUrls = await storageService.uploadMultipleRecipePhotos(
          recipeId: recipeId,
          files: _imageFiles,
        );
      }

      // Create recipe
      final recipe = RecipeModel(
        recipeId: '', // Will be set by repository
        authorId: currentUser.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        ingredients: _ingredients,
        steps: _steps,
        photoUrls: photoUrls,
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final recipeRepository = ref.read(recipeRepositoryProvider);
      await recipeRepository.createRecipe(recipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating recipe: $e')),
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
        title: const Text('Create Recipe'),
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
              onPressed: _saveRecipe,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          children: [
            // Photos Section
            _buildPhotosSection(),
            const SizedBox(height: 24),

            // Basic Info
            Text('Basic Information', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title *',
                hintText: 'e.g., Grandma\'s Chocolate Cake',
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
                hintText: 'Tell us about this recipe...',
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
                    decoration: const InputDecoration(
                      labelText: 'Prep Time (min)',
                    ),
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
                    decoration: const InputDecoration(
                      labelText: 'Cook Time (min)',
                    ),
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
              onPressed: _isLoading ? null : _saveRecipe,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Recipe'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Photos', style: Theme.of(context).textTheme.headlineSmall),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_imageFiles.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageFiles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                _imageFiles[index].path,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_imageFiles[index].path),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            padding: const EdgeInsets.all(4),
                          ),
                          onPressed: () {
                            setState(() {
                              _imageFiles.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No photos added',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
      ],
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

        // Add ingredient form
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _ingredientNameController,
                decoration: const InputDecoration(
                  labelText: 'Ingredient',
                  hintText: 'e.g., flour',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ingredientAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '2',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ingredientUnitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'cups',
                ),
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

        // Ingredients list
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
        ] else
          const Text('No ingredients added yet', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instructions *', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),

        // Add step form
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _stepController,
                decoration: const InputDecoration(
                  labelText: 'Step instruction',
                  hintText: 'Describe this step...',
                ),
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

        // Steps list
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
                      // Reorder remaining steps
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
        ] else
          const Text('No steps added yet', style: TextStyle(color: Colors.grey)),
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
