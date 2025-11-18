import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/core/constants/app_constants.dart';
import 'package:recipe_app/data/models/shopping_list_model.dart';
import 'package:recipe_app/data/models/recipe_model.dart';

class ShoppingListRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create shopping list
  Future<void> createShoppingList(ShoppingListModel list) async {
    try {
      await _firestore
          .collection(FirebaseCollections.shoppingLists)
          .doc(list.listId)
          .set(list.toFirestore());
    } catch (e) {
      throw Exception('Failed to create shopping list: $e');
    }
  }

  // Get user's shopping lists (stream)
  Stream<List<ShoppingListModel>> getUserListsStream(String userId) {
    return _firestore
        .collection(FirebaseCollections.shoppingLists)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShoppingListModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get single shopping list
  Future<ShoppingListModel?> getShoppingList(String listId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseCollections.shoppingLists)
          .doc(listId)
          .get();

      if (!doc.exists) return null;
      return ShoppingListModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get shopping list: $e');
    }
  }

  // Get shopping list stream
  Stream<ShoppingListModel?> getShoppingListStream(String listId) {
    return _firestore
        .collection(FirebaseCollections.shoppingLists)
        .doc(listId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return ShoppingListModel.fromFirestore(doc);
    });
  }

  // Update shopping list
  Future<void> updateShoppingList(ShoppingListModel list) async {
    try {
      await _firestore
          .collection(FirebaseCollections.shoppingLists)
          .doc(list.listId)
          .update(list.toFirestore());
    } catch (e) {
      throw Exception('Failed to update shopping list: $e');
    }
  }

  // Delete shopping list
  Future<void> deleteShoppingList(String listId) async {
    try {
      await _firestore
          .collection(FirebaseCollections.shoppingLists)
          .doc(listId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete shopping list: $e');
    }
  }

  // Toggle item checked status
  Future<void> toggleItemChecked(String listId, int itemIndex) async {
    try {
      final list = await getShoppingList(listId);
      if (list == null) throw Exception('Shopping list not found');

      final updatedItems = List<ShoppingListItem>.from(list.items);
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
        isChecked: !updatedItems[itemIndex].isChecked,
      );

      final updatedList = list.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await updateShoppingList(updatedList);
    } catch (e) {
      throw Exception('Failed to toggle item: $e');
    }
  }

  // Generate shopping list from recipes
  Future<ShoppingListModel> generateFromRecipes(
    String userId,
    List<RecipeModel> recipes,
    String listName,
  ) async {
    try {
      final items = <ShoppingListItem>[];
      final sourceRecipeIds = <String>[];

      // Combine all ingredients from all recipes
      for (final recipe in recipes) {
        sourceRecipeIds.add(recipe.recipeId);

        for (final ingredient in recipe.ingredients) {
          // Check if we already have this ingredient
          final existingIndex = items.indexWhere(
            (item) =>
                item.ingredientName.toLowerCase() == ingredient.item.toLowerCase() &&
                item.unit?.toLowerCase() == ingredient.unit.toLowerCase(),
          );

          if (existingIndex != -1) {
            // Combine amounts if same ingredient and unit
            final existing = items[existingIndex];
            final currentAmount = double.tryParse(existing.amount) ?? 0;
            final newAmount = currentAmount + ingredient.amount;

            items[existingIndex] = existing.copyWith(
              amount: newAmount.toString(),
            );
          } else {
            // Add new ingredient
            items.add(ShoppingListItem(
              ingredientName: ingredient.item,
              amount: ingredient.amount.toString(),
              unit: ingredient.unit,
              sourceRecipeId: recipe.recipeId,
            ));
          }
        }
      }

      // Sort items alphabetically
      items.sort((a, b) => a.ingredientName.compareTo(b.ingredientName));

      return ShoppingListModel(
        listId: '', // Will be set when creating
        userId: userId,
        name: listName,
        items: items,
        isGenerated: true,
        sourceRecipeIds: sourceRecipeIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to generate shopping list: $e');
    }
  }

  // Generate shopping list from event
  Future<ShoppingListModel> generateFromEvent(
    String userId,
    String eventId,
    List<RecipeModel> eventRecipes,
    String listName,
  ) async {
    try {
      final generatedList = await generateFromRecipes(
        userId,
        eventRecipes,
        listName,
      );

      return generatedList.copyWith(
        name: listName,
      );
    } catch (e) {
      throw Exception('Failed to generate shopping list from event: $e');
    }
  }
}
