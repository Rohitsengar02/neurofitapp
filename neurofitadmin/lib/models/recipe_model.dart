class RecipeIngredientModel {
  final String name;
  final String quantity;
  final String unit;

  const RecipeIngredientModel({
    required this.name,
    this.quantity = '',
    this.unit = '',
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      name: (json['name'] ?? json['ingredient'] ?? '').toString(),
      quantity: (json['quantity'] ?? json['amount'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  String get displayText {
    final qty = quantity.trim();
    final u = unit.trim();
    if (qty.isNotEmpty && u.isNotEmpty) return '$qty $u $name';
    if (qty.isNotEmpty) return '$qty $name';
    return name;
  }
}

class RecipeModel {
  final String id;
  final String title;
  final String name;
  final String cuisine;
  final String dietaryType; // 'Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggitarian'
  final String category; // 'Breakfast', 'Main Course', 'High Protein', 'Curries & Dals', 'Rice & Biryani', etc.
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String totalTime;
  final int servings;
  final String difficulty; // 'Easy', 'Intermediate', 'Advanced'
  final double rating;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String imageUrl;
  final String thumbnailUrl;
  final String videoUrl;
  final String youtubeUrl;
  final List<RecipeIngredientModel> ingredients;
  final List<String> ingredientList;
  final List<String> steps;
  final String instructions;
  final String chefTips;
  final List<String> tags;
  final String source;
  final bool isVerified;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RecipeModel({
    required this.id,
    required this.title,
    String? name,
    this.cuisine = 'North Indian',
    this.dietaryType = 'Vegetarian',
    this.category = 'High Protein',
    this.prepTimeMinutes = 15,
    this.cookTimeMinutes = 20,
    this.totalTime = '35 mins',
    this.servings = 2,
    this.difficulty = 'Easy',
    this.rating = 4.8,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 5.0,
    this.imageUrl = '',
    this.thumbnailUrl = '',
    this.videoUrl = '',
    this.youtubeUrl = '',
    this.ingredients = const [],
    this.ingredientList = const [],
    this.steps = const [],
    this.instructions = '',
    this.chefTips = '',
    this.tags = const [],
    this.source = 'IndianCurated',
    this.isVerified = true,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  }) : name = name ?? title;

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    int parseI(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? fallback;
    }

    List<String> parseStrList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String && val.trim().isNotEmpty) return [val];
      return [];
    }

    List<RecipeIngredientModel> parseIngredients(dynamic val) {
      if (val is List) {
        return val.map((e) {
          if (e is Map<String, dynamic>) return RecipeIngredientModel.fromJson(e);
          if (e is Map) return RecipeIngredientModel.fromJson(Map<String, dynamic>.from(e));
          return RecipeIngredientModel(name: e.toString());
        }).toList();
      }
      return [];
    }

    final idVal = (json['id'] ?? json['_id'] ?? '').toString();
    final titleVal = (json['title'] ?? json['name'] ?? 'Indian Recipe').toString();
    final img = (json['imageUrl'] ?? json['image'] ?? json['strMealThumb'] ?? '').toString();

    final ings = parseIngredients(json['ingredients']);
    List<String> ingList = parseStrList(json['ingredientList']);
    if (ingList.isEmpty && ings.isNotEmpty) {
      ingList = ings.map((i) => i.displayText).toList();
    }

    List<String> stepList = parseStrList(json['steps']);
    if (stepList.isEmpty && json['instructions'] != null) {
      final raw = json['instructions'].toString();
      stepList = raw.split(RegExp(r'\r?\n')).where((s) => s.trim().length > 5).toList();
    }

    return RecipeModel(
      id: idVal.isNotEmpty ? idVal : 'rec_${DateTime.now().millisecondsSinceEpoch}',
      title: titleVal,
      name: (json['name'] ?? titleVal).toString(),
      cuisine: (json['cuisine'] ?? 'North Indian').toString(),
      dietaryType: (json['dietaryType'] ?? 'Vegetarian').toString(),
      category: (json['category'] ?? 'High Protein').toString(),
      prepTimeMinutes: parseI(json['prepTimeMinutes'], 15),
      cookTimeMinutes: parseI(json['cookTimeMinutes'], 20),
      totalTime: (json['totalTime'] ?? '${parseI(json['prepTimeMinutes'], 15) + parseI(json['cookTimeMinutes'], 20)} mins').toString(),
      servings: parseI(json['servings'], 2),
      difficulty: (json['difficulty'] ?? 'Easy').toString(),
      rating: parseD(json['rating'] ?? 4.8),
      calories: parseD(json['calories'] ?? 350),
      protein: parseD(json['protein'] ?? 25),
      carbs: parseD(json['carbs'] ?? 30),
      fat: parseD(json['fat'] ?? 10),
      fiber: parseD(json['fiber'] ?? 5),
      imageUrl: img,
      thumbnailUrl: (json['thumbnailUrl'] ?? img).toString(),
      videoUrl: (json['videoUrl'] ?? '').toString(),
      youtubeUrl: (json['youtubeUrl'] ?? json['strYoutube'] ?? '').toString(),
      ingredients: ings,
      ingredientList: ingList,
      steps: stepList,
      instructions: (json['instructions'] ?? '').toString(),
      chefTips: (json['chefTips'] ?? '').toString(),
      tags: parseStrList(json['tags']),
      source: (json['source'] ?? 'IndianCurated').toString(),
      isVerified: json['isVerified'] ?? true,
      isActive: json['isActive'] ?? true,
      sortOrder: parseI(json['sortOrder'], 0),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'cuisine': cuisine,
      'dietaryType': dietaryType,
      'category': category,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'totalTime': totalTime,
      'servings': servings,
      'difficulty': difficulty,
      'rating': rating,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'youtubeUrl': youtubeUrl,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'ingredientList': ingredientList,
      'steps': steps,
      'instructions': instructions,
      'chefTips': chefTips,
      'tags': tags,
      'source': source,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  // Macro Calorie Percentages
  double get proteinCalories => protein * 4;
  double get carbsCalories => carbs * 4;
  double get fatCalories => fat * 9;

  double get calculatedTotalCalories {
    final sum = proteinCalories + carbsCalories + fatCalories;
    return sum > 0 ? sum : calories;
  }

  double get proteinPercentage {
    final tot = calculatedTotalCalories;
    return tot > 0 ? (proteinCalories / tot * 100) : 0.0;
  }

  double get carbsPercentage {
    final tot = calculatedTotalCalories;
    return tot > 0 ? (carbsCalories / tot * 100) : 0.0;
  }

  double get fatPercentage {
    final tot = calculatedTotalCalories;
    return tot > 0 ? (fatCalories / tot * 100) : 0.0;
  }

  bool get isVegetarian => dietaryType.toLowerCase() == 'vegetarian' || dietaryType.toLowerCase() == 'vegan';

  String get displayImageUrl {
    if (imageUrl.isNotEmpty) return imageUrl;
    if (thumbnailUrl.isNotEmpty) return thumbnailUrl;
    return '';
  }
}
