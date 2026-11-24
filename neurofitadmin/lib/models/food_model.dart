class FoodItemModel {

  final String id;
  final String barcode;
  final String name;
  final String brand;
  final String category;
  final String servingSize;
  final String servingUnit;
  final double servingWeightGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium; // mg
  final double potassium; // mg
  final double cholesterol; // mg
  final double saturatedFat; // g
  final String nutriscore; // 'A', 'B', 'C', 'D', 'E', 'Unknown'
  final int? novaGroup; // 1, 2, 3, 4
  final String imageUrl;
  final String thumbnailUrl;
  final List<String> ingredients;
  final String ingredientText;
  final List<String> allergens;
  final String vitamins;
  final bool isVerified;
  final String source;
  final bool isActive;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoodItemModel({
    required this.id,
    this.barcode = '',
    required this.name,
    this.brand = '',
    this.category = 'General',
    this.servingSize = '100g',
    this.servingUnit = 'g',
    this.servingWeightGrams = 100.0,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.potassium = 0.0,
    this.cholesterol = 0.0,
    this.saturatedFat = 0.0,
    this.nutriscore = 'A',
    this.novaGroup,
    this.imageUrl = '',
    this.thumbnailUrl = '',
    this.ingredients = const [],
    this.ingredientText = '',
    this.allergens = const [],
    this.vitamins = '',
    this.isVerified = true,
    this.source = 'OpenFoodFacts',
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String && val.trim().isNotEmpty) return [val];
      return [];
    }

    final idVal = (json['id'] ?? json['_id'] ?? '').toString();
    final nameVal = (json['name'] ?? json['product_name'] ?? 'Unnamed Food').toString();
    final img = (json['imageUrl'] ?? json['image_url'] ?? json['image'] ?? '').toString();
    final thumb = (json['thumbnailUrl'] ?? json['image_small_url'] ?? img).toString();

    int? nova;
    if (json['novaGroup'] != null || json['nova_group'] != null) {
      final nv = json['novaGroup'] ?? json['nova_group'];
      nova = nv is int ? nv : int.tryParse(nv.toString());
    }

    return FoodItemModel(
      id: idVal.isNotEmpty ? idVal : 'food_${DateTime.now().millisecondsSinceEpoch}',
      barcode: (json['barcode'] ?? json['code'] ?? '').toString(),
      name: nameVal,
      brand: (json['brand'] ?? json['brands'] ?? '').toString(),
      category: (json['category'] ?? 'General').toString(),
      servingSize: (json['servingSize'] ?? json['serving_size'] ?? '100g').toString(),
      servingUnit: (json['servingUnit'] ?? 'g').toString(),
      servingWeightGrams: parseD(json['servingWeightGrams'] ?? json['serving_quantity'] ?? 100),
      calories: parseD(json['calories'] ?? json['energy_kcal'] ?? json['energy-kcal']),
      protein: parseD(json['protein'] ?? json['proteins']),
      carbs: parseD(json['carbs'] ?? json['carbohydrates']),
      fat: parseD(json['fat'] ?? json['fats']),
      fiber: parseD(json['fiber']),
      sugar: parseD(json['sugar'] ?? json['sugars']),
      sodium: parseD(json['sodium']),
      potassium: parseD(json['potassium']),
      cholesterol: parseD(json['cholesterol']),
      saturatedFat: parseD(json['saturatedFat'] ?? json['saturated_fat'] ?? json['saturated-fat']),
      nutriscore: (json['nutriscore'] ?? json['nutriscore_grade'] ?? 'A').toString().toUpperCase(),
      novaGroup: nova,
      imageUrl: img,
      thumbnailUrl: thumb,
      ingredients: parseList(json['ingredients']),
      ingredientText: (json['ingredientText'] ?? json['ingredients_text'] ?? '').toString(),
      allergens: parseList(json['allergens'] ?? json['allergens_tags']),
      vitamins: (json['vitamins'] ?? '').toString(),
      isVerified: json['isVerified'] ?? true,
      source: (json['source'] ?? 'OpenFoodFacts').toString(),
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] is int ? json['sortOrder'] : int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'category': category,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'servingWeightGrams': servingWeightGrams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'potassium': potassium,
      'cholesterol': cholesterol,
      'saturatedFat': saturatedFat,
      'nutriscore': nutriscore,
      'novaGroup': novaGroup,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'ingredients': ingredients,
      'ingredientText': ingredientText,
      'allergens': allergens,
      'vitamins': vitamins,
      'isVerified': isVerified,
      'source': source,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  // Calculated Macro Calories & Percentages
  double get totalMacroGrams => protein + carbs + fat;

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

  /// Scale all nutritional values based on dynamic grams input
  FoodItemModel scaledFor(double targetGrams) {
    if (servingWeightGrams <= 0 || targetGrams <= 0) return this;
    final ratio = targetGrams / servingWeightGrams;

    return FoodItemModel(
      id: id,
      barcode: barcode,
      name: name,
      brand: brand,
      category: category,
      servingSize: '${targetGrams.toStringAsFixed(targetGrams % 1 == 0 ? 0 : 1)}$servingUnit',
      servingUnit: servingUnit,
      servingWeightGrams: targetGrams,
      calories: (calories * ratio),
      protein: (protein * ratio),
      carbs: (carbs * ratio),
      fat: (fat * ratio),
      fiber: (fiber * ratio),
      sugar: (sugar * ratio),
      sodium: (sodium * ratio),
      potassium: (potassium * ratio),
      cholesterol: (cholesterol * ratio),
      saturatedFat: (saturatedFat * ratio),
      nutriscore: nutriscore,
      novaGroup: novaGroup,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      ingredients: ingredients,
      ingredientText: ingredientText,
      allergens: allergens,
      vitamins: vitamins,
      isVerified: isVerified,
      source: source,
      isActive: isActive,
      sortOrder: sortOrder,
    );
  }

  String get displayImageUrl {
    if (imageUrl.isNotEmpty) return imageUrl;
    if (thumbnailUrl.isNotEmpty) return thumbnailUrl;
    return '';
  }
}
