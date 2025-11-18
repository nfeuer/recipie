import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/made_it_model.dart';
import 'package:recipe_app/data/models/activity_model.dart';
import 'package:recipe_app/data/services/storage_service.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/user_providers.dart';
import 'package:recipe_app/presentation/providers/made_it_providers.dart';
import 'package:recipe_app/presentation/providers/activity_providers.dart';

class CreateMadeItPostScreen extends ConsumerStatefulWidget {
  final String recipeId;
  final String recipeName;
  final String? recipePhotoUrl;

  const CreateMadeItPostScreen({
    super.key,
    required this.recipeId,
    required this.recipeName,
    this.recipePhotoUrl,
  });

  @override
  ConsumerState<CreateMadeItPostScreen> createState() => _CreateMadeItPostScreenState();
}

class _CreateMadeItPostScreenState extends ConsumerState<CreateMadeItPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _modificationsController = TextEditingController();

  List<XFile> _selectedImages = [];
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _captionController.dispose();
    _modificationsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  Future<void> _submitPost() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) throw Exception('User not signed in');

      // Get user profile
      final userProfile = await ref.read(userProfileProvider(currentUser.uid).future);
      if (userProfile == null) throw Exception('User profile not found');

      // Upload images to Storage
      final storageService = StorageService();
      final postId = const Uuid().v4();
      final photoUrls = <String>[];

      for (int i = 0; i < _selectedImages.length; i++) {
        final url = await storageService.uploadMadeItPhoto(
          File(_selectedImages[i].path),
          postId,
          i,
        );
        photoUrls.add(url);
      }

      // Create post
      final post = MadeItModel(
        postId: postId,
        recipeId: widget.recipeId,
        recipeName: widget.recipeName,
        userId: currentUser.uid,
        userName: userProfile.displayName,
        userPhotoUrl: userProfile.photoUrl,
        photoUrls: photoUrls,
        caption: _captionController.text.trim().isNotEmpty
            ? _captionController.text.trim()
            : null,
        modifications: _modificationsController.text.trim().isNotEmpty
            ? _modificationsController.text.trim()
            : null,
        rating: _rating > 0 ? _rating.toInt() : null,
        createdAt: DateTime.now(),
      );

      final madeItRepository = ref.read(madeItRepositoryProvider);
      await madeItRepository.createPost(post);

      // Create activity
      final activity = ActivityModel(
        activityId: const Uuid().v4(),
        userId: currentUser.uid,
        userName: userProfile.displayName,
        userPhotoUrl: userProfile.photoUrl,
        type: ActivityType.recipeMade,
        timestamp: DateTime.now(),
        recipeId: widget.recipeId,
        recipeName: widget.recipeName,
        recipePhotoUrl: widget.recipePhotoUrl,
        postId: postId,
        photoUrls: photoUrls,
      );

      final activityRepository = ref.read(activityRepositoryProvider);
      await activityRepository.createActivity(activity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
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
        title: const Text('I Made This!'),
        actions: [
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
              onPressed: _submitPost,
              child: const Text('Post'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          children: [
            // Recipe info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.recipeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Photos Section
            Text(
              'Photos *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_selectedImages.isEmpty)
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add photos',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImages[index].path),
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add More Photos'),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Caption
            Text(
              'Caption',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Share your experience with this recipe...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Modifications
            Text(
              'Modifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Did you make any changes to the original recipe?',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modificationsController,
              decoration: const InputDecoration(
                hintText: 'e.g., I used honey instead of sugar...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Rating
            Text(
              'Rating (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),

            // Post Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
