import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/data/services/storage_service.dart';
import 'package:recipe_app/data/models/activity_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/recipe_providers.dart';
import 'package:recipe_app/presentation/providers/user_providers.dart';
import 'package:recipe_app/presentation/providers/activity_providers.dart';

class ForkRecipeScreen extends ConsumerStatefulWidget {
  final RecipeModel originalRecipe;

  const ForkRecipeScreen({super.key, required this.originalRecipe});

  @override
  ConsumerState<ForkRecipeScreen> createState() => _ForkRecipeScreenState();
}

class _ForkRecipeScreenState extends ConsumerState<ForkRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _servingsController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _modificationsController;

  late List<Ingredient> _ingredients;
  late List<RecipeStep> _steps;
  late List<String> _selectedTags;
  late String _difficulty;
  late RecipePrivacy _privacy;

  List<XFile> _selectedImages = [];
  List<String> _existingPhotoUrls = [];
  bool _isSubmitting = false;
  bool _showComparison = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with original recipe data
    _titleController = TextEditingController(text: '${widget.originalRecipe.title} (My Version)');
    _descriptionController = TextEditingController(text: widget.originalRecipe.description);
    _servingsController = TextEditingController(text: widget.originalRecipe.servings.toString());
    _prepTimeController = TextEditingController(
      text: widget.originalRecipe.prepTimeMinutes?.toString() ?? '',
    );
    _cookTimeController = TextEditingController(
      text: widget.originalRecipe.cookTimeMinutes?.toString() ?? '',
    );
    _modificationsController = TextEditingController();

    // Copy lists from original recipe
    _ingredients = widget.originalRecipe.ingredients.map((i) => i.copyWith()).toList();
    _steps = widget.originalRecipe.steps.map((s) => s.copyWith()).toList();
    _selectedTags = List.from(widget.originalRecipe.tags);
    _difficulty = widget.originalRecipe.difficulty ?? 'Medium';
    _privacy = RecipePrivacy.public;
    _existingPhotoUrls = List.from(widget.originalRecipe.photoUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _modificationsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(Ingredient(
        item: '',
        amount: 0,
        unit: '',
      ));
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    setState(() {
      _steps.add(RecipeStep(
        stepNumber: _steps.length + 1,
        instruction: '',
      ));
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Renumber steps
      for (int i = 0; i < _steps.length; i++) {
        _steps[i] = _steps[i].copyWith(stepNumber: i + 1);
      }
    });
  }

  Future<void> _forkRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one step')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) throw Exception('User not signed in');

      // Get user profile
      final userProfile = await ref.read(userProfileProvider(currentUser.uid).future);
      if (userProfile == null) throw Exception('User profile not found');

      final recipeId = const Uuid().v4();
      List<String> photoUrls = List.from(_existingPhotoUrls);

      // Upload new images if any
      if (_selectedImages.isNotEmpty) {
        final storageService = StorageService();
        final newPhotoUrls = await storageService.uploadMultipleRecipePhotos(
          recipeId: recipeId,
          files: _selectedImages.map((xfile) => File(xfile.path)).toList(),
        );
        photoUrls.addAll(newPhotoUrls);
      }

      // Create forked recipe
      final forkedRecipe = RecipeModel(
        recipeId: recipeId,
        authorId: currentUser.uid,
        authorName: userProfile.displayName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: _ingredients,
        steps: _steps,
        servings: int.parse(_servingsController.text),
        prepTimeMinutes: _prepTimeController.text.isNotEmpty
            ? int.tryParse(_prepTimeController.text)
            : null,
        cookTimeMinutes: _cookTimeController.text.isNotEmpty
            ? int.tryParse(_cookTimeController.text)
            : null,
        difficulty: _difficulty,
        tags: _selectedTags,
        photoUrls: photoUrls,
        privacy: _privacy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        parentRecipeId: widget.originalRecipe.recipeId,
        modifications: RecipeModifications(
          summary: _modificationsController.text.trim().isNotEmpty
              ? _modificationsController.text.trim()
              : 'Forked from ${widget.originalRecipe.title}',
          changeLog: [],
        ),
      );

      final recipeRepository = ref.read(recipeRepositoryProvider);
      await recipeRepository.createRecipe(forkedRecipe);

      // Create activity
      final activity = ActivityModel(
        activityId: const Uuid().v4(),
        userId: currentUser.uid,
        userName: userProfile.displayName,
        userPhotoUrl: userProfile.photoUrl,
        type: ActivityType.recipeCreated,
        timestamp: DateTime.now(),
        recipeId: recipeId,
        recipeName: forkedRecipe.title,
        recipePhotoUrl: photoUrls.isNotEmpty ? photoUrls.first : null,
      );

      final activityRepository = ref.read(activityRepositoryProvider);
      await activityRepository.createActivity(activity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe forked successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error forking recipe: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fork Recipe'),
        actions: [
          IconButton(
            icon: Icon(_showComparison ? Icons.edit : Icons.compare_arrows),
            onPressed: () {
              setState(() {
                _showComparison = !_showComparison;
              });
            },
            tooltip: _showComparison ? 'Edit Mode' : 'Compare with Original',
          ),
          if (_isSubmitting)
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
              onPressed: _forkRecipe,
              child: const Text('Fork'),
            ),
        ],
      ),
      body: _showComparison
          ? _buildComparisonView()
          : _buildEditForm(),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        children: [
          // Attribution banner
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.call_split, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forking from:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        widget.originalRecipe.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'by ${widget.originalRecipe.authorName}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Recipe Title *',
              hintText: 'Give your version a name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your version of this recipe',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Modifications summary
          TextFormField(
            controller: _modificationsController,
            decoration: const InputDecoration(
              labelText: 'What did you change?',
              hintText: 'Describe your modifications...',
              prefixIcon: Icon(Icons.edit_note),
            ),
            maxLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 24),

          // Basic info row
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
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cookTimeController,
                  decoration: const InputDecoration(labelText: 'Cook (min)'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Difficulty
          DropdownButtonFormField<String>(
            value: _difficulty,
            decoration: const InputDecoration(labelText: 'Difficulty'),
            items: ['Easy', 'Medium', 'Hard'].map((difficulty) {
              return DropdownMenuItem(value: difficulty, child: Text(difficulty));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _difficulty = value);
              }
            },
          ),
          const SizedBox(height: 24),

          // Photos section
          Text('Photos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (_existingPhotoUrls.isNotEmpty || _selectedImages.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Existing photos
                  ..._existingPhotoUrls.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              entry.value,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 12, color: Colors.white),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _existingPhotoUrls.removeAt(entry.key);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // New photos
                  ..._selectedImages.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(entry.value.path),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 12, color: Colors.white),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    _selectedImages.removeAt(entry.key);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Photos'),
          ),
          const SizedBox(height: 24),

          // Ingredients section (truncated for brevity - similar to create_recipe_screen)
          _buildIngredientsSection(),
          const SizedBox(height: 24),

          // Steps section
          _buildStepsSection(),
          const SizedBox(height: 24),

          // Tags
          _buildTagsSection(),
          const SizedBox(height: 24),

          // Privacy
          DropdownButtonFormField<RecipePrivacy>(
            value: _privacy,
            decoration: const InputDecoration(labelText: 'Privacy'),
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
          const SizedBox(height: 32),

          // Fork button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _forkRecipe,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Fork Recipe'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      children: [
        Text(
          'Compare Versions',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Titles comparison
        _buildComparisonRow(
          'Title',
          widget.originalRecipe.title,
          _titleController.text,
        ),

        // Servings comparison
        _buildComparisonRow(
          'Servings',
          widget.originalRecipe.servings.toString(),
          _servingsController.text,
        ),

        // Ingredients count
        _buildComparisonRow(
          'Ingredients',
          '${widget.originalRecipe.ingredients.length} items',
          '${_ingredients.length} items',
        ),

        // Steps count
        _buildComparisonRow(
          'Steps',
          '${widget.originalRecipe.steps.length} steps',
          '${_steps.length} steps',
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Ingredients comparison
        Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Original', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...widget.originalRecipe.ingredients.map((ing) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• ${ing.amount} ${ing.unit} ${ing.item}', style: const TextStyle(fontSize: 12)),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Version', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const SizedBox(height: 8),
                  ..._ingredients.map((ing) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• ${ing.amount} ${ing.unit} ${ing.item}', style: const TextStyle(fontSize: 12)),
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String label, String original, String yours) {
    final isDifferent = original != yours;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(original, style: const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDifferent
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: isDifferent
                    ? Border.all(color: AppTheme.primaryColor)
                    : null,
              ),
              child: Text(
                yours,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isDifferent ? FontWeight.bold : FontWeight.normal,
                  color: isDifferent ? AppTheme.primaryColor : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: ingredient.item,
                    decoration: const InputDecoration(
                      labelText: 'Item',
                      hintText: 'e.g., Flour',
                    ),
                    onChanged: (value) {
                      _ingredients[index] = ingredient.copyWith(item: value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: ingredient.amount.toString(),
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _ingredients[index] = ingredient.copyWith(
                        amount: double.tryParse(value) ?? 0,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: ingredient.unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    onChanged: (value) {
                      _ingredients[index] = ingredient.copyWith(unit: value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeIngredient(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: _addStep,
              icon: const Icon(Icons.add),
              label: const Text('Add Step'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text('${step.stepNumber}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: step.instruction,
                    decoration: InputDecoration(
                      labelText: 'Step ${step.stepNumber}',
                      hintText: 'Describe this step...',
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      _steps[index] = step.copyWith(instruction: value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeStep(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dietary Tags', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.dietaryTags.map((tag) {
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
      ],
    );
  }

  String _getPrivacyLabel(RecipePrivacy privacy) {
    switch (privacy) {
      case RecipePrivacy.public:
        return 'Public';
      case RecipePrivacy.friendsOnly:
        return 'Friends Only';
      case RecipePrivacy.private:
        return 'Private';
      case RecipePrivacy.eventOnly:
        return 'Event Only';
    }
  }
}
