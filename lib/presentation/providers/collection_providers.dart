import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/recipe_collection_model.dart';
import 'package:recipe_app/data/repositories/recipe_collection_repository.dart';

// Repository Provider
final collectionRepositoryProvider = Provider<RecipeCollectionRepository>((ref) {
  return RecipeCollectionRepository();
});

// Get single collection
final collectionProvider = FutureProvider.family<RecipeCollectionModel?, String>(
  (ref, collectionId) async {
    final repository = ref.watch(collectionRepositoryProvider);
    return repository.getCollection(collectionId);
  },
);

// Stream single collection
final collectionStreamProvider = StreamProvider.family<RecipeCollectionModel?, String>(
  (ref, collectionId) {
    final repository = ref.watch(collectionRepositoryProvider);
    return repository.streamCollection(collectionId);
  },
);

// Get user's collections
final userCollectionsProvider = FutureProvider.family<List<RecipeCollectionModel>, String>(
  (ref, userId) async {
    final repository = ref.watch(collectionRepositoryProvider);
    return repository.getUserCollections(userId);
  },
);

// Stream user's collections
final userCollectionsStreamProvider = StreamProvider.family<List<RecipeCollectionModel>, String>(
  (ref, userId) {
    final repository = ref.watch(collectionRepositoryProvider);
    return repository.streamUserCollections(userId);
  },
);

// Get public collections
final publicCollectionsProvider = FutureProvider<List<RecipeCollectionModel>>((ref) async {
  final repository = ref.watch(collectionRepositoryProvider);
  return repository.getPublicCollections(limit: 20);
});

// Stream public collections
final publicCollectionsStreamProvider = StreamProvider<List<RecipeCollectionModel>>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return repository.streamPublicCollections(limit: 20);
});
