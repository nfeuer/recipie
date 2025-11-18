import 'package:cloud_firestore/cloud_firestore.dart';

enum RecipePrivacy {
  public,
  friends,
  private,
  eventOnly,
}

class Ingredient {
  final String name;
  final String? amount;
  final String? unit;
  final bool? isModified;
  final String? modificationNote;

  Ingredient({
    required this.name,
    this.amount,
    this.unit,
    this.isModified,
    this.modificationNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'isModified': isModified,
      'modificationNote': modificationNote,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] ?? '',
      amount: map['amount'],
      unit: map['unit'],
      isModified: map['isModified'],
      modificationNote: map['modificationNote'],
    );
  }
}

class RecipeStep {
  final int order;
  final String instruction;
  final String? imageUrl;
  final bool? isModified;
  final String? modificationNote;

  RecipeStep({
    required this.order,
    required this.instruction,
    this.imageUrl,
    this.isModified,
    this.modificationNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'instruction': instruction,
      'imageUrl': imageUrl,
      'isModified': isModified,
      'modificationNote': modificationNote,
    };
  }

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      order: map['order'] ?? 0,
      instruction: map['instruction'] ?? '',
      imageUrl: map['imageUrl'],
      isModified: map['isModified'],
      modificationNote: map['modificationNote'],
    );
  }
}

class ModificationDetail {
  final String type;
  final String description;
  final dynamic before;
  final dynamic after;

  ModificationDetail({
    required this.type,
    required this.description,
    this.before,
    this.after,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'before': before,
      'after': after,
    };
  }

  factory ModificationDetail.fromMap(Map<String, dynamic> map) {
    return ModificationDetail(
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      before: map['before'],
      after: map['after'],
    );
  }
}

class RecipeModifications {
  final String parentRecipeId;
  final String modificationReason;
  final List<ModificationDetail> changes;
  final DateTime modifiedAt;

  RecipeModifications({
    required this.parentRecipeId,
    required this.modificationReason,
    required this.changes,
    required this.modifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'parentRecipeId': parentRecipeId,
      'modificationReason': modificationReason,
      'changes': changes.map((c) => c.toMap()).toList(),
      'modifiedAt': Timestamp.fromDate(modifiedAt),
    };
  }

  factory RecipeModifications.fromMap(Map<String, dynamic> map) {
    return RecipeModifications(
      parentRecipeId: map['parentRecipeId'] ?? '',
      modificationReason: map['modificationReason'] ?? '',
      changes: (map['changes'] as List<dynamic>?)
              ?.map((c) => ModificationDetail.fromMap(c))
              .toList() ??
          [],
      modifiedAt: (map['modifiedAt'] as Timestamp).toDate(),
    );
  }
}

class RecipeModel {
  final String recipeId;
  final String authorId;
  final String title;
  final String? description;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final List<String> photoUrls;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int servings;
  final String? difficulty;
  final List<String> tags;
  final List<String> dietaryTags;
  final String? originalSource;
  final String? parentRecipeId;
  final List<String> attributionChain;
  final RecipeModifications? modifications;
  final int forkCount;
  final int madeItCount;
  final double? averageRating;
  final RecipePrivacy privacy;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecipeModel({
    required this.recipeId,
    required this.authorId,
    required this.title,
    this.description,
    this.ingredients = const [],
    this.steps = const [],
    this.photoUrls = const [],
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    required this.servings,
    this.difficulty,
    this.tags = const [],
    this.dietaryTags = const [],
    this.originalSource,
    this.parentRecipeId,
    this.attributionChain = const [],
    this.modifications,
    this.forkCount = 0,
    this.madeItCount = 0,
    this.averageRating,
    this.privacy = RecipePrivacy.public,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'recipeId': recipeId,
      'authorId': authorId,
      'title': title,
      'description': description,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'steps': steps.map((s) => s.toMap()).toList(),
      'photoUrls': photoUrls,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'tags': tags,
      'dietaryTags': dietaryTags,
      'originalSource': originalSource,
      'parentRecipeId': parentRecipeId,
      'attributionChain': attributionChain,
      'modifications': modifications?.toMap(),
      'forkCount': forkCount,
      'madeItCount': madeItCount,
      'averageRating': averageRating,
      'privacy': privacy.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecipeModel(
      recipeId: doc.id,
      authorId: data['authorId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      ingredients: (data['ingredients'] as List<dynamic>?)
              ?.map((i) => Ingredient.fromMap(i))
              .toList() ??
          [],
      steps: (data['steps'] as List<dynamic>?)
              ?.map((s) => RecipeStep.fromMap(s))
              .toList() ??
          [],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      prepTimeMinutes: data['prepTimeMinutes'],
      cookTimeMinutes: data['cookTimeMinutes'],
      servings: data['servings'] ?? 1,
      difficulty: data['difficulty'],
      tags: List<String>.from(data['tags'] ?? []),
      dietaryTags: List<String>.from(data['dietaryTags'] ?? []),
      originalSource: data['originalSource'],
      parentRecipeId: data['parentRecipeId'],
      attributionChain: List<String>.from(data['attributionChain'] ?? []),
      modifications: data['modifications'] != null
          ? RecipeModifications.fromMap(data['modifications'])
          : null,
      forkCount: data['forkCount'] ?? 0,
      madeItCount: data['madeItCount'] ?? 0,
      averageRating: data['averageRating']?.toDouble(),
      privacy: RecipePrivacy.values.firstWhere(
        (e) => e.name == data['privacy'],
        orElse: () => RecipePrivacy.public,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  RecipeModel copyWith({
    String? title,
    String? description,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    List<String>? photoUrls,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? difficulty,
    List<String>? tags,
    List<String>? dietaryTags,
    String? originalSource,
    String? parentRecipeId,
    List<String>? attributionChain,
    RecipeModifications? modifications,
    int? forkCount,
    int? madeItCount,
    double? averageRating,
    RecipePrivacy? privacy,
    DateTime? updatedAt,
  }) {
    return RecipeModel(
      recipeId: recipeId,
      authorId: authorId,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      photoUrls: photoUrls ?? this.photoUrls,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      originalSource: originalSource ?? this.originalSource,
      parentRecipeId: parentRecipeId ?? this.parentRecipeId,
      attributionChain: attributionChain ?? this.attributionChain,
      modifications: modifications ?? this.modifications,
      forkCount: forkCount ?? this.forkCount,
      madeItCount: madeItCount ?? this.madeItCount,
      averageRating: averageRating ?? this.averageRating,
      privacy: privacy ?? this.privacy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
