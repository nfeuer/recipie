import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/data/models/recipe_collection_model.dart';

class RecipeCollectionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new collection
  Future<void> createCollection(RecipeCollectionModel collection) async {
    await _firestore
        .collection('recipe_collections')
        .doc(collection.collectionId)
        .set(collection.toFirestore());
  }

  // Update an existing collection
  Future<void> updateCollection(RecipeCollectionModel collection) async {
    await _firestore
        .collection('recipe_collections')
        .doc(collection.collectionId)
        .update(collection.toFirestore());
  }

  // Delete a collection
  Future<void> deleteCollection(String collectionId) async {
    await _firestore
        .collection('recipe_collections')
        .doc(collectionId)
        .delete();
  }

  // Get a single collection
  Future<RecipeCollectionModel?> getCollection(String collectionId) async {
    final doc = await _firestore
        .collection('recipe_collections')
        .doc(collectionId)
        .get();

    if (!doc.exists) return null;
    return RecipeCollectionModel.fromFirestore(doc);
  }

  // Stream a single collection
  Stream<RecipeCollectionModel?> streamCollection(String collectionId) {
    return _firestore
        .collection('recipe_collections')
        .doc(collectionId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return RecipeCollectionModel.fromFirestore(doc);
    });
  }

  // Get user's collections
  Future<List<RecipeCollectionModel>> getUserCollections(String userId) async {
    final snapshot = await _firestore
        .collection('recipe_collections')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RecipeCollectionModel.fromFirestore(doc))
        .toList();
  }

  // Stream user's collections
  Stream<List<RecipeCollectionModel>> streamUserCollections(String userId) {
    return _firestore
        .collection('recipe_collections')
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecipeCollectionModel.fromFirestore(doc))
            .toList());
  }

  // Get public collections
  Future<List<RecipeCollectionModel>> getPublicCollections({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('recipe_collections')
        .where('privacy', isEqualTo: CollectionPrivacy.public.name)
        .orderBy('saveCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => RecipeCollectionModel.fromFirestore(doc))
        .toList();
  }

  // Stream public collections
  Stream<List<RecipeCollectionModel>> streamPublicCollections({int limit = 20}) {
    return _firestore
        .collection('recipe_collections')
        .where('privacy', isEqualTo: CollectionPrivacy.public.name)
        .orderBy('saveCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecipeCollectionModel.fromFirestore(doc))
            .toList());
  }

  // Add recipe to collection
  Future<void> addRecipeToCollection(String collectionId, String recipeId) async {
    final collection = await getCollection(collectionId);
    if (collection == null) throw Exception('Collection not found');

    final updatedRecipeIds = List<String>.from(collection.recipeIds);
    if (!updatedRecipeIds.contains(recipeId)) {
      updatedRecipeIds.add(recipeId);
      await updateCollection(collection.copyWith(
        recipeIds: updatedRecipeIds,
        updatedAt: DateTime.now(),
      ));
    }
  }

  // Remove recipe from collection
  Future<void> removeRecipeFromCollection(String collectionId, String recipeId) async {
    final collection = await getCollection(collectionId);
    if (collection == null) throw Exception('Collection not found');

    final updatedRecipeIds = List<String>.from(collection.recipeIds);
    updatedRecipeIds.remove(recipeId);

    await updateCollection(collection.copyWith(
      recipeIds: updatedRecipeIds,
      updatedAt: DateTime.now(),
    ));
  }

  // Increment view count
  Future<void> incrementViewCount(String collectionId) async {
    await _firestore
        .collection('recipe_collections')
        .doc(collectionId)
        .update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // Increment save count
  Future<void> incrementSaveCount(String collectionId) async {
    await _firestore
        .collection('recipe_collections')
        .doc(collectionId)
        .update({
      'saveCount': FieldValue.increment(1),
    });
  }

  // Decrement save count
  Future<void> decrementSaveCount(String collectionId) async {
    await _firestore
        .collection('recipe_collections')
        .doc(collectionId)
        .update({
      'saveCount': FieldValue.increment(-1),
    });
  }

  // Add collaborator
  Future<void> addCollaborator(String collectionId, String userId) async {
    final collection = await getCollection(collectionId);
    if (collection == null) throw Exception('Collection not found');

    final updatedCollaborators = List<String>.from(collection.collaborators);
    if (!updatedCollaborators.contains(userId)) {
      updatedCollaborators.add(userId);
      await updateCollection(collection.copyWith(
        collaborators: updatedCollaborators,
        updatedAt: DateTime.now(),
      ));
    }
  }

  // Remove collaborator
  Future<void> removeCollaborator(String collectionId, String userId) async {
    final collection = await getCollection(collectionId);
    if (collection == null) throw Exception('Collection not found');

    final updatedCollaborators = List<String>.from(collection.collaborators);
    updatedCollaborators.remove(userId);

    await updateCollection(collection.copyWith(
      collaborators: updatedCollaborators,
      updatedAt: DateTime.now(),
    ));
  }

  // Search collections
  Future<List<RecipeCollectionModel>> searchCollections(String query) async {
    // Note: This is a simple implementation. For production, use Algolia or similar
    final snapshot = await _firestore
        .collection('recipe_collections')
        .where('privacy', isEqualTo: CollectionPrivacy.public.name)
        .get();

    final allCollections = snapshot.docs
        .map((doc) => RecipeCollectionModel.fromFirestore(doc))
        .toList();

    // Filter by name or description containing query
    final queryLower = query.toLowerCase();
    return allCollections.where((collection) {
      return collection.name.toLowerCase().contains(queryLower) ||
          (collection.description?.toLowerCase().contains(queryLower) ?? false) ||
          collection.tags.any((tag) => tag.toLowerCase().contains(queryLower));
    }).toList();
  }
}
