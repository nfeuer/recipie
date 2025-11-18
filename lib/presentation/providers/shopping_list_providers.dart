import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/models/shopping_list_model.dart';
import 'package:recipe_app/data/repositories/shopping_list_repository.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';

// Shopping List Repository Provider
final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepository();
});

// User Shopping Lists Stream Provider
final userShoppingListsStreamProvider = StreamProvider<List<ShoppingListModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(shoppingListRepositoryProvider);
  return repository.getUserListsStream(currentUser.uid);
});

// Single Shopping List Stream Provider
final shoppingListStreamProvider = StreamProvider.family<ShoppingListModel?, String>((ref, listId) {
  final repository = ref.watch(shoppingListRepositoryProvider);
  return repository.getShoppingListStream(listId);
});

// Single Shopping List Future Provider
final shoppingListProvider = FutureProvider.family<ShoppingListModel?, String>((ref, listId) async {
  final repository = ref.watch(shoppingListRepositoryProvider);
  return repository.getShoppingList(listId);
});
