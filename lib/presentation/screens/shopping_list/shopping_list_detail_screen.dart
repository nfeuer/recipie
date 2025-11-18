import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/core/constants/app_theme.dart';
import 'package:recipe_app/data/models/shopping_list_model.dart';
import 'package:recipe_app/presentation/providers/shopping_list_providers.dart';

class ShoppingListDetailScreen extends ConsumerStatefulWidget {
  final String listId;

  const ShoppingListDetailScreen({super.key, required this.listId});

  @override
  ConsumerState<ShoppingListDetailScreen> createState() => _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends ConsumerState<ShoppingListDetailScreen> {
  final TextEditingController _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _toggleItem(ShoppingListModel list, int index) async {
    try {
      final repository = ref.read(shoppingListRepositoryProvider);
      await repository.toggleItemChecked(widget.listId, index);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _addItem(ShoppingListModel list) async {
    final text = _itemController.text.trim();
    if (text.isEmpty) return;

    try {
      final newItem = ShoppingListItem(
        ingredientName: text,
        amount: '1',
      );

      final updatedList = list.copyWith(
        items: [...list.items, newItem],
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(shoppingListRepositoryProvider);
      await repository.updateShoppingList(updatedList);

      _itemController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    }
  }

  Future<void> _removeItem(ShoppingListModel list, int index) async {
    try {
      final items = List<ShoppingListItem>.from(list.items);
      items.removeAt(index);

      final updatedList = list.copyWith(
        items: items,
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(shoppingListRepositoryProvider);
      await repository.updateShoppingList(updatedList);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing item: $e')),
        );
      }
    }
  }

  Future<void> _deleteList() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shopping List'),
        content: const Text('Are you sure you want to delete this shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(shoppingListRepositoryProvider);
        await repository.deleteShoppingList(widget.listId);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shopping list deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting list: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(shoppingListStreamProvider(widget.listId));

    return listAsync.when(
      data: (list) {
        if (list == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shopping List Not Found')),
            body: const Center(child: Text('Shopping list not found')),
          );
        }

        final completedCount = list.items.where((item) => item.isChecked).length;
        final totalCount = list.items.length;

        return Scaffold(
          appBar: AppBar(
            title: Text(list.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteList,
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress header
              if (totalCount > 0)
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$completedCount of $totalCount items',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(completedCount / totalCount * 100).toStringAsFixed(0)}% complete',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: completedCount / totalCount,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),

              // Items list
              Expanded(
                child: list.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_basket, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text(
                              'No items yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add items below',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        itemCount: list.items.length,
                        itemBuilder: (context, index) {
                          final item = list.items[index];
                          return Dismissible(
                            key: Key('${list.listId}_$index'),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _removeItem(list, index),
                            child: Card(
                              child: CheckboxListTile(
                                value: item.isChecked,
                                onChanged: (_) => _toggleItem(list, index),
                                title: Text(
                                  item.ingredientName,
                                  style: TextStyle(
                                    decoration: item.isChecked
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: item.unit != null
                                    ? Text('${item.amount} ${item.unit}')
                                    : null,
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Add item input
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _itemController,
                          decoration: InputDecoration(
                            hintText: 'Add item...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _addItem(list),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _addItem(list),
                        icon: const Icon(Icons.add_circle),
                        color: AppTheme.primaryColor,
                        iconSize: 32,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading shopping list: $error')),
      ),
    );
  }
}
