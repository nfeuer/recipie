import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/event_model.dart';
import 'package:recipe_app/data/models/recipe_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/event_providers.dart';
import 'package:recipe_app/presentation/providers/recipe_providers.dart';

class EditEventScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EditEventScreen({super.key, required this.event});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _maxGuestsController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedEventType;
  late EventPrivacy _privacy;
  late bool _allowPlusOnes;
  late bool _allowRecipeRequests;

  late List<EventGuest> _guests;
  late List<EventRecipe> _selectedRecipes;

  bool _isLoading = false;

  final _guestNameController = TextEditingController();
  final _guestEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing event data
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description ?? '');
    _locationController = TextEditingController(text: widget.event.location ?? '');
    _maxGuestsController = TextEditingController(
      text: widget.event.maxGuests?.toString() ?? '',
    );

    // Initialize date/time from existing event
    _selectedDate = widget.event.eventDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.eventDate);

    // Initialize other fields
    _selectedEventType = widget.event.eventType;
    _privacy = widget.event.privacy;
    _allowPlusOnes = widget.event.allowPlusOnes;
    _allowRecipeRequests = widget.event.allowRecipeRequests;

    // Copy guest and recipe lists
    _guests = List.from(widget.event.guests);
    _selectedRecipes = List.from(widget.event.recipes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxGuestsController.dispose();
    _guestNameController.dispose();
    _guestEmailController.dispose();
    super.dispose();
  }

  void _addGuest() {
    if (_guestNameController.text.isNotEmpty &&
        _guestEmailController.text.isNotEmpty) {
      setState(() {
        _guests.add(EventGuest(
          email: _guestEmailController.text.trim(),
          name: _guestNameController.text.trim(),
          status: GuestStatus.invited,
        ));
        _guestNameController.clear();
        _guestEmailController.clear();
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectRecipes() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final userRecipes = await ref.read(userRecipesProvider(currentUser.uid).future);

    if (!mounted) return;

    final List<RecipeModel>? selectedRecipes = await showDialog<List<RecipeModel>>(
      context: context,
      builder: (context) => _RecipeSelectionDialog(recipes: userRecipes),
    );

    if (selectedRecipes != null && selectedRecipes.isNotEmpty) {
      setState(() {
        for (final recipe in selectedRecipes) {
          if (!_selectedRecipes.any((r) => r.recipeId == recipe.recipeId)) {
            _selectedRecipes.add(EventRecipe(
              recipeId: recipe.recipeId,
              dishName: recipe.title,
              servingsPlanned: recipe.servings,
            ));
          }
        }
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final updatedEvent = widget.event.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        eventDate: eventDateTime,
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        eventType: _selectedEventType,
        guests: _guests,
        maxGuests: _maxGuestsController.text.isNotEmpty
            ? int.tryParse(_maxGuestsController.text)
            : null,
        allowPlusOnes: _allowPlusOnes,
        recipes: _selectedRecipes,
        privacy: _privacy,
        allowRecipeRequests: _allowRecipeRequests,
        updatedAt: DateTime.now(),
      );

      final eventRepository = ref.read(eventRepositoryProvider);
      await eventRepository.updateEvent(updatedEvent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating event: $e')),
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
        title: const Text('Edit Event'),
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
              onPressed: _updateEvent,
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
            Text('Event Information', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title *',
                hintText: 'e.g., Summer BBQ Party',
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
                hintText: 'Tell guests about your event...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedEventType,
              decoration: const InputDecoration(labelText: 'Event Type *'),
              items: AppConstants.eventTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedEventType = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Date & Time
            Text('Date & Time', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Location
            Text('Location', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Event Location',
                hintText: 'e.g., 123 Main St, New York',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),

            // Guest Settings
            Text('Guest Settings', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            TextFormField(
              controller: _maxGuestsController,
              decoration: const InputDecoration(
                labelText: 'Maximum Guests (optional)',
                hintText: 'Leave empty for unlimited',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Allow Plus Ones'),
              subtitle: const Text('Guests can bring additional people'),
              value: _allowPlusOnes,
              onChanged: (value) {
                setState(() => _allowPlusOnes = value);
              },
            ),

            SwitchListTile(
              title: const Text('Allow Recipe Requests'),
              subtitle: const Text('Guests can request recipes after the event'),
              value: _allowRecipeRequests,
              onChanged: (value) {
                setState(() => _allowRecipeRequests = value);
              },
            ),
            const SizedBox(height: 24),

            // Guest List
            _buildGuestListSection(),
            const SizedBox(height: 24),

            // Menu/Recipes
            _buildMenuSection(),
            const SizedBox(height: 24),

            // Privacy
            Text('Privacy', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            DropdownButtonFormField<EventPrivacy>(
              value: _privacy,
              decoration: const InputDecoration(labelText: 'Who can see this event?'),
              items: EventPrivacy.values.map((privacy) {
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
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _updateEvent,
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

  Widget _buildGuestListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Guest List', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),

        // Add guest form
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _guestNameController,
                decoration: const InputDecoration(
                  labelText: 'Guest Name',
                  hintText: 'John Doe',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _guestEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'john@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _addGuest,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Guest list
        if (_guests.isNotEmpty) ...[
          ...List.generate(_guests.length, (index) {
            final guest = _guests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(guest.name.substring(0, 1).toUpperCase()),
                ),
                title: Text(guest.name),
                subtitle: Text(guest.email ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _guests.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }),
        ] else
          const Text('No guests added yet', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Menu', style: Theme.of(context).textTheme.headlineSmall),
            TextButton.icon(
              onPressed: _selectRecipes,
              icon: const Icon(Icons.add),
              label: const Text('Add Recipes'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_selectedRecipes.isNotEmpty) ...[
          ...List.generate(_selectedRecipes.length, (index) {
            final eventRecipe = _selectedRecipes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.restaurant, color: AppTheme.primaryColor),
                title: Text(eventRecipe.dishName),
                subtitle: Text('${eventRecipe.servingsPlanned} servings'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedRecipes.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }),
        ] else
          const Text('No recipes added yet', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  String _getPrivacyLabel(EventPrivacy privacy) {
    switch (privacy) {
      case EventPrivacy.public:
        return 'Public - Everyone can see';
      case EventPrivacy.friendsOnly:
        return 'Friends Only - Only followers';
      case EventPrivacy.private:
        return 'Private - Invite only';
    }
  }
}

// Recipe Selection Dialog
class _RecipeSelectionDialog extends StatefulWidget {
  final List<RecipeModel> recipes;

  const _RecipeSelectionDialog({required this.recipes});

  @override
  State<_RecipeSelectionDialog> createState() => _RecipeSelectionDialogState();
}

class _RecipeSelectionDialogState extends State<_RecipeSelectionDialog> {
  final Set<RecipeModel> _selectedRecipes = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Recipes'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.recipes.isEmpty
            ? const Center(child: Text('No recipes available'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.recipes.length,
                itemBuilder: (context, index) {
                  final recipe = widget.recipes[index];
                  final isSelected = _selectedRecipes.contains(recipe);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRecipes.add(recipe);
                        } else {
                          _selectedRecipes.remove(recipe);
                        }
                      });
                    },
                    title: Text(recipe.title),
                    subtitle: Text('${recipe.servings} servings'),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedRecipes.toList()),
          child: const Text('Add Selected'),
        ),
      ],
    );
  }
}
