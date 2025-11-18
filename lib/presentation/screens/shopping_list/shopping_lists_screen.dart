import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/shopping_list_model.dart';
import 'package:recipe_app/presentation/providers/auth_providers.dart';
import 'package:recipe_app/presentation/providers/shopping_list_providers.dart';
import 'package:recipe_app/presentation/screens/shopping_list/shopping_list_detail_screen.dart';
import 'package:recipe_app/presentation/screens/shopping_list/create_shopping_list_screen.dart';

class ShoppingListsScreen extends ConsumerWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(userShoppingListsStreamProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Lists'),
      ),
      body: listsAsync.when(
        data: (lists) {
          if (currentUser == null) {
            return const Center(
              child: Text('Please sign in to view shopping lists'),
            );
          }

          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No shopping lists yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a list or generate one from recipes',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showCreateListDialog(context, ref, currentUser.uid);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Shopping List'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userShoppingListsStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                return _ShoppingListCard(list: lists[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Error loading shopping lists: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userShoppingListsStreamProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (currentUser != null) {
            _showCreateListDialog(context, ref, currentUser.uid);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New List'),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, WidgetRef ref, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Shopping List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.create, color: AppTheme.primaryColor),
              title: const Text('Create Empty List'),
              subtitle: const Text('Start from scratch'),
              onTap: () {
                Navigator.pop(context);
                _createEmptyList(context, ref, userId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: AppTheme.primaryColor),
              title: const Text('Generate from Recipes'),
              subtitle: const Text('Select recipes to combine ingredients'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateShoppingListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createEmptyList(BuildContext context, WidgetRef ref, String userId) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('List Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Weekly Groceries',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      try {
        final list = ShoppingListModel(
          listId: const Uuid().v4(),
          userId: userId,
          name: name,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final repository = ref.read(shoppingListRepositoryProvider);
        await repository.createShoppingList(list);

        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ShoppingListDetailScreen(listId: list.listId),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating list: $e')),
          );
        }
      }
    }
  }
}

class _ShoppingListCard extends ConsumerWidget {
  final ShoppingListModel list;

  const _ShoppingListCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount = list.items.where((item) => item.isChecked).length;
    final totalCount = list.items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ShoppingListDetailScreen(listId: list.listId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, y').format(list.updatedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (list.isGenerated)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Generated',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              if (totalCount > 0) ...[
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$completedCount / $totalCount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ] else
                Text(
                  'Empty list',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
