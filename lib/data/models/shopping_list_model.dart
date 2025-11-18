import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListItem {
  final String ingredientName;
  final String amount;
  final String? unit;
  final bool isChecked;
  final String? category;
  final String? sourceRecipeId;

  ShoppingListItem({
    required this.ingredientName,
    required this.amount,
    this.unit,
    this.isChecked = false,
    this.category,
    this.sourceRecipeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'ingredientName': ingredientName,
      'amount': amount,
      'unit': unit,
      'isChecked': isChecked,
      'category': category,
      'sourceRecipeId': sourceRecipeId,
    };
  }

  factory ShoppingListItem.fromMap(Map<String, dynamic> map) {
    return ShoppingListItem(
      ingredientName: map['ingredientName'] ?? '',
      amount: map['amount'] ?? '',
      unit: map['unit'],
      isChecked: map['isChecked'] ?? false,
      category: map['category'],
      sourceRecipeId: map['sourceRecipeId'],
    );
  }

  ShoppingListItem copyWith({
    String? ingredientName,
    String? amount,
    String? unit,
    bool? isChecked,
    String? category,
    String? sourceRecipeId,
  }) {
    return ShoppingListItem(
      ingredientName: ingredientName ?? this.ingredientName,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      category: category ?? this.category,
      sourceRecipeId: sourceRecipeId ?? this.sourceRecipeId,
    );
  }
}

class ShoppingListModel {
  final String listId;
  final String userId;
  final String? eventId;
  final String name;
  final List<ShoppingListItem> items;
  final bool isGenerated;
  final List<String> sourceRecipeIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingListModel({
    required this.listId,
    required this.userId,
    this.eventId,
    required this.name,
    this.items = const [],
    this.isGenerated = false,
    this.sourceRecipeIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'listId': listId,
      'userId': userId,
      'eventId': eventId,
      'name': name,
      'items': items.map((i) => i.toMap()).toList(),
      'isGenerated': isGenerated,
      'sourceRecipeIds': sourceRecipeIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ShoppingListModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingListModel(
      listId: doc.id,
      userId: data['userId'] ?? '',
      eventId: data['eventId'],
      name: data['name'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((i) => ShoppingListItem.fromMap(i))
              .toList() ??
          [],
      isGenerated: data['isGenerated'] ?? false,
      sourceRecipeIds: List<String>.from(data['sourceRecipeIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  ShoppingListModel copyWith({
    String? name,
    List<ShoppingListItem>? items,
    DateTime? updatedAt,
  }) {
    return ShoppingListModel(
      listId: listId,
      userId: userId,
      eventId: eventId,
      name: name ?? this.name,
      items: items ?? this.items,
      isGenerated: isGenerated,
      sourceRecipeIds: sourceRecipeIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
