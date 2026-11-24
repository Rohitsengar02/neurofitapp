import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/nutrition_backend_service.dart';

class FoodDetailModal extends StatefulWidget {
  final FoodItemModel initialFood;
  final VoidCallback? onUpdated;

  const FoodDetailModal({
    super.key,
    required this.initialFood,
    this.onUpdated,
  });

  static void show(BuildContext context, FoodItemModel food, {VoidCallback? onUpdated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) => FoodDetailModal(
        initialFood: food,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<FoodDetailModal> createState() => _FoodDetailModalState();
}

class _FoodDetailModalState extends State<FoodDetailModal> {
  late FoodItemModel _currentFood;
  late double _customGrams;
  late TextEditingController _gramsController;

  final List<double> _presetGrams = [50, 100, 150, 200, 250];

  @override
  void initState() {
    super.initState();
    _currentFood = widget.initialFood;
    _customGrams = _currentFood.servingWeightGrams > 0 ? _currentFood.servingWeightGrams : 100.0;
    _gramsController = TextEditingController(text: _customGrams.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _updateGrams(double grams) {
    if (grams < 1) grams = 1;
    if (grams > 1000) grams = 1000;
    setState(() {
      _customGrams = grams;
      _gramsController.text = grams.toStringAsFixed(grams % 1 == 0 ? 0 : 1);
    });
  }

  Color _getNutriscoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A':
        return const Color(0xFF038141);
      case 'B':
        return const Color(0xFF85BB2F);
      case 'C':
        return const Color(0xFFFECB02);
      case 'D':
        return const Color(0xFFEE8100);
      case 'E':
        return const Color(0xFFE63E11);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color _getNovaColor(int? nova) {
    switch (nova) {
      case 1:
        return const Color(0xFF10B981);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFFF97316);
      case 4:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getNovaDescription(int? nova) {
    switch (nova) {
      case 1:
        return 'Unprocessed or minimally processed';
      case 2:
        return 'Processed culinary ingredients';
      case 3:
        return 'Processed foods';
      case 4:
        return 'Ultra-processed food and drink';
      default:
        return 'Standard whole food';
    }
  }

  void _showEditFoodDialog() {
    final nameCtrl = TextEditingController(text: _currentFood.name);
    final brandCtrl = TextEditingController(text: _currentFood.brand);
    final servingCtrl = TextEditingController(text: _currentFood.servingSize);
    final kcalCtrl = TextEditingController(text: _currentFood.calories.toStringAsFixed(0));
    final pCtrl = TextEditingController(text: _currentFood.protein.toStringAsFixed(1));
    final cCtrl = TextEditingController(text: _currentFood.carbs.toStringAsFixed(1));
    final fCtrl = TextEditingController(text: _currentFood.fat.toStringAsFixed(1));
    final fiberCtrl = TextEditingController(text: _currentFood.fiber.toStringAsFixed(1));
    final sugarCtrl = TextEditingController(text: _currentFood.sugar.toStringAsFixed(1));
    final sodiumCtrl = TextEditingController(text: _currentFood.sodium.toStringAsFixed(0));
    final imgCtrl = TextEditingController(text: _currentFood.imageUrl);
    String selectedCat = _currentFood.category;

    final categories = [
      'Fruits',
      'Poultry & Meat',
      'Grains & Oats',
      'Dairy & Eggs',
      'Nuts & Seeds',
      'Seafood',
      'Vegetables & Greens',
      'Supplements & Shakes',
      'Healthy Snacks',
      'General',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.edit_note_rounded, color: Color(0xFF3B82F6), size: 24),
              SizedBox(width: 8),
              Text('Edit Nutrition Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditField('Food Name', nameCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildEditField('Brand', brandCtrl)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Category', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: categories.contains(selectedCat) ? selectedCat : 'General',
                                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11.5)))).toList(),
                                  onChanged: (val) => setDlgState(() => selectedCat = val!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildEditField('Serving Size (e.g. 100g)', servingCtrl)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildEditField('Calories (kcal)', kcalCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Macro Breakdown (grams per serving)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildEditField('Protein (g)', pCtrl, isNumber: true)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildEditField('Carbs (g)', cCtrl, isNumber: true)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildEditField('Fat (g)', fCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildEditField('Fiber (g)', fiberCtrl, isNumber: true)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildEditField('Sugar (g)', sugarCtrl, isNumber: true)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildEditField('Sodium (mg)', sodiumCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildEditField('Image URL', imgCtrl),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final updated = FoodItemModel(
                  id: _currentFood.id,
                  barcode: _currentFood.barcode,
                  name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : _currentFood.name,
                  brand: brandCtrl.text.trim(),
                  category: selectedCat,
                  servingSize: servingCtrl.text.trim(),
                  servingUnit: _currentFood.servingUnit,
                  servingWeightGrams: _currentFood.servingWeightGrams,
                  calories: double.tryParse(kcalCtrl.text) ?? _currentFood.calories,
                  protein: double.tryParse(pCtrl.text) ?? _currentFood.protein,
                  carbs: double.tryParse(cCtrl.text) ?? _currentFood.carbs,
                  fat: double.tryParse(fCtrl.text) ?? _currentFood.fat,
                  fiber: double.tryParse(fiberCtrl.text) ?? _currentFood.fiber,
                  sugar: double.tryParse(sugarCtrl.text) ?? _currentFood.sugar,
                  sodium: double.tryParse(sodiumCtrl.text) ?? _currentFood.sodium,
                  potassium: _currentFood.potassium,
                  cholesterol: _currentFood.cholesterol,
                  saturatedFat: _currentFood.saturatedFat,
                  nutriscore: _currentFood.nutriscore,
                  novaGroup: _currentFood.novaGroup,
                  imageUrl: imgCtrl.text.trim(),
                  thumbnailUrl: imgCtrl.text.trim(),
                  ingredients: _currentFood.ingredients,
                  ingredientText: _currentFood.ingredientText,
                  allergens: _currentFood.allergens,
                  vitamins: _currentFood.vitamins,
                  isVerified: true,
                  source: _currentFood.source,
                );

                await NutritionBackendService().updateFood(updated);
                setState(() => _currentFood = updated);
                Navigator.pop(ctx);
                widget.onUpdated?.call();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated "${updated.name}" successfully!'),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              },
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 3),
        TextField(
          controller: ctrl,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaled = _currentFood.scaledFor(_customGrams);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 8),

          // Modal Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Hero(
                  tag: 'food_img_${_currentFood.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _currentFood.displayImageUrl.isNotEmpty
                        ? Image.network(
                            _currentFood.displayImageUrl,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 68,
                              height: 68,
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.restaurant_rounded, color: Color(0xFF94A3B8), size: 30),
                            ),
                          )
                        : Container(
                            width: 68,
                            height: 68,
                            color: const Color(0xFFEFF6FF),
                            child: const Icon(Icons.restaurant_rounded, color: Color(0xFF3B82F6), size: 30),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _currentFood.category.toUpperCase(),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF3B82F6)),
                            ),
                          ),
                          const SizedBox(width: 5),
                          _buildHeaderSourceBadge(),
                          if (_currentFood.nutriscore != 'UNKNOWN') ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getNutriscoreColor(_currentFood.nutriscore),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'SCORE ${_currentFood.nutriscore}',
                                style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                            ),
                          ],
                          if (_currentFood.isVerified) ...[
                            const SizedBox(width: 5),
                            const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentFood.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_currentFood.brand.isNotEmpty)
                        Text(
                          _currentFood.brand,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Divider(height: 20, thickness: 0.8, color: Color(0xFFF1F5F9)),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Source Origin Banner
                _buildSourceOriginBanner(),
                const SizedBox(height: 12),

                // 1. Interactive Dynamic Serving Scaler
                _buildServingScalerCard(scaled),
                const SizedBox(height: 16),

                // 2. Macro Ratio Visual Cards
                _buildMacroBreakdownCards(scaled),
                const SizedBox(height: 16),

                // 3. Micronutrient Highlights (Calcium, Iron, Potassium, Fiber, Sugar)
                _buildMicronutrientHighlights(scaled),
                const SizedBox(height: 16),

                // 4. Official FDA Nutrition Facts Label
                _buildFdaNutritionFactsLabel(scaled),
                const SizedBox(height: 16),

                // 5. NOVA & Quality Badges
                if (_currentFood.novaGroup != null) ...[
                  _buildNovaCard(),
                  const SizedBox(height: 16),
                ],

                // 6. Ingredients & Allergens
                _buildIngredientsAndAllergensCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                if (_isLiveItem) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final String importSource = _currentFood.source.isNotEmpty
                            ? '${_currentFood.source}_Imported'
                            : 'Live_Imported';

                        final toSave = FoodItemModel(
                          id: 'food_${DateTime.now().millisecondsSinceEpoch}',
                          barcode: _currentFood.barcode,
                          name: _currentFood.name,
                          brand: _currentFood.brand,
                          category: _currentFood.category,
                          servingSize: _currentFood.servingSize,
                          servingUnit: _currentFood.servingUnit,
                          servingWeightGrams: _currentFood.servingWeightGrams,
                          calories: _currentFood.calories,
                          protein: _currentFood.protein,
                          carbs: _currentFood.carbs,
                          fat: _currentFood.fat,
                          fiber: _currentFood.fiber,
                          sugar: _currentFood.sugar,
                          sodium: _currentFood.sodium,
                          potassium: _currentFood.potassium,
                          cholesterol: _currentFood.cholesterol,
                          saturatedFat: _currentFood.saturatedFat,
                          nutriscore: _currentFood.nutriscore,
                          novaGroup: _currentFood.novaGroup,
                          imageUrl: _currentFood.imageUrl,
                          thumbnailUrl: _currentFood.thumbnailUrl,
                          ingredients: _currentFood.ingredients,
                          ingredientText: _currentFood.ingredientText,
                          allergens: _currentFood.allergens,
                          vitamins: _currentFood.vitamins,
                          isVerified: true,
                          source: importSource,
                        );

                        await NutritionBackendService().createFood(toSave);
                        if (mounted) {
                          Navigator.pop(context);
                          widget.onUpdated?.call();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Imported "${toSave.name}" to MongoDB Atlas!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.download_done_rounded, size: 16, color: Colors.white),
                      label: const Text('Import to Database', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _showEditFoodDialog,
                    icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                    label: const Text('Edit Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        title: const Text('Delete Food Item?'),
                        content: Text('Are you sure you want to delete "${_currentFood.name}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await NutritionBackendService().deleteFood(_currentFood.id);
                      if (mounted) {
                        Navigator.pop(context);
                        widget.onUpdated?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Food "${_currentFood.name}" removed.'),
                            backgroundColor: const Color(0xFFDC2626),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

  bool get _isLiveItem {
    final id = _currentFood.id;
    return id.startsWith('off_') || id.startsWith('usda_') || id.startsWith('ifct_');
  }

  Widget _buildHeaderSourceBadge() {
    String label = 'ATLAS';
    Color col = const Color(0xFF64748B);
    if (_currentFood.source.contains('ICMR') || _currentFood.source.contains('IFCT') || _currentFood.id.startsWith('ifct_')) {
      label = '🇮🇳 IFCT';
      col = const Color(0xFFEA580C);
    } else if (_currentFood.source.contains('USDA') || _currentFood.id.startsWith('usda_')) {
      label = '🇺🇸 USDA';
      col = const Color(0xFF2563EB);
    } else if (_currentFood.source.contains('OpenFoodFacts') || _currentFood.id.startsWith('off_')) {
      label = '🌐 OFF';
      col = const Color(0xFF059669);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: col.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: col.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: col),
      ),
    );
  }

  Widget _buildSourceOriginBanner() {
    String title = 'Verified NeuroFit Atlas Database';
    String sub = 'Locally stored & verified nutrition facts in MongoDB Atlas.';
    IconData icon = Icons.cloud_done_rounded;
    Color col = const Color(0xFF3B82F6);
    Color bg = const Color(0xFFEFF6FF);

    if (_currentFood.source.contains('ICMR') || _currentFood.source.contains('IFCT') || _currentFood.id.startsWith('ifct_')) {
      title = 'ICMR-NIN Indian Food Composition Tables (IFCT)';
      sub = 'Standardized raw & cooked nutritional facts from the National Institute of Nutrition, India.';
      icon = Icons.spa_rounded;
      col = const Color(0xFFEA580C);
      bg = const Color(0xFFFFF7ED);
    } else if (_currentFood.source.contains('USDA') || _currentFood.id.startsWith('usda_')) {
      title = 'USDA FoodData Central Official Database';
      sub = 'Official nutritional dataset published by the U.S. Department of Agriculture (ARS).';
      icon = Icons.account_balance_rounded;
      col = const Color(0xFF2563EB);
      bg = const Color(0xFFEFF6FF);
    } else if (_currentFood.source.contains('OpenFoodFacts') || _currentFood.id.startsWith('off_')) {
      title = 'Open Food Facts Global Open Database';
      sub = 'Crowdsourced barcode and food composition database verified by open contributors.';
      icon = Icons.public_rounded;
      col = const Color(0xFF059669);
      bg = const Color(0xFFECFDF5);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: col.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: col, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: col)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicronutrientHighlights(FoodItemModel scaled) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.biotech_rounded, color: Color(0xFF8B5CF6), size: 18),
              SizedBox(width: 6),
              Text('Key Micronutrients & Electrolytes', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMicroBadge('Dietary Fiber', '${scaled.fiber.toStringAsFixed(1)}g', const Color(0xFF059669)),
              _buildMicroBadge('Total Sugars', '${scaled.sugar.toStringAsFixed(1)}g', const Color(0xFFD97706)),
              _buildMicroBadge('Sodium', '${scaled.sodium.toStringAsFixed(0)}mg', const Color(0xFF4F46E5)),
              if (scaled.potassium > 0)
                _buildMicroBadge('Potassium', '${scaled.potassium.toStringAsFixed(0)}mg', const Color(0xFF0284C7)),
              if (scaled.cholesterol > 0)
                _buildMicroBadge('Cholesterol', '${scaled.cholesterol.toStringAsFixed(0)}mg', const Color(0xFFDC2626)),
              if (scaled.saturatedFat > 0)
                _buildMicroBadge('Sat. Fat', '${scaled.saturatedFat.toStringAsFixed(1)}g', const Color(0xFFEA580C)),
            ],
          ),
          if (scaled.vitamins.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      scaled.vitamins,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMicroBadge(String label, String val, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: col.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: col)),
        ],
      ),
    );
  }

  // 1. Serving Scaler Widget
  Widget _buildServingScalerCard(FoodItemModel scaled) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.scale_rounded, color: Color(0xFF3B82F6), size: 18),
                  SizedBox(width: 6),
                  Text('Dynamic Serving Scaler', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                ],
              ),
              Container(
                width: 90,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _gramsController,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                        onSubmitted: (val) {
                          final g = double.tryParse(val) ?? 100.0;
                          _updateGrams(g);
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text('g', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: const Color(0xFF3B82F6),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF3B82F6),
              overlayColor: const Color(0xFF3B82F6).withOpacity(0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              value: _customGrams.clamp(10, 500),
              min: 10,
              max: 500,
              divisions: 98,
              onChanged: (val) => _updateGrams(val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _presetGrams.map((g) {
              final isSelected = (_customGrams - g).abs() < 0.5;
              return GestureDetector(
                onTap: () => _updateGrams(g),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    '${g.toInt()}g',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: isSelected ? Colors.white : const Color(0xFF475569)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 2. Macro Breakdown Cards Widget
  Widget _buildMacroBreakdownCards(FoodItemModel scaled) {
    final pPct = scaled.proteinPercentage;
    final cPct = scaled.carbsPercentage;
    final fPct = scaled.fatPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Macro Profile & Caloric Ratio', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '🔥 ${scaled.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Multi-segment ratio bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (pPct > 0)
                  Expanded(
                    flex: (pPct * 10).round().clamp(1, 1000),
                    child: Container(color: const Color(0xFF10B981)), // Protein: Green
                  ),
                if (cPct > 0)
                  Expanded(
                    flex: (cPct * 10).round().clamp(1, 1000),
                    child: Container(color: const Color(0xFF3B82F6)), // Carbs: Blue
                  ),
                if (fPct > 0)
                  Expanded(
                    flex: (fPct * 10).round().clamp(1, 1000),
                    child: Container(color: const Color(0xFFF59E0B)), // Fat: Amber
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 3 Cards: Protein, Carbs, Fats
        Row(
          children: [
            Expanded(
              child: _buildMacroCard(
                'Protein',
                '${scaled.protein.toStringAsFixed(1)}g',
                '${pPct.toStringAsFixed(0)}% cal',
                '${scaled.proteinCalories.toStringAsFixed(0)} kcal',
                const Color(0xFF10B981),
                const Color(0xFFECFDF5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                'Carbs',
                '${scaled.carbs.toStringAsFixed(1)}g',
                '${cPct.toStringAsFixed(0)}% cal',
                '${scaled.carbsCalories.toStringAsFixed(0)} kcal',
                const Color(0xFF3B82F6),
                const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMacroCard(
                'Fats',
                '${scaled.fat.toStringAsFixed(1)}g',
                '${fPct.toStringAsFixed(0)}% cal',
                '${scaled.fatCalories.toStringAsFixed(0)} kcal',
                const Color(0xFFF59E0B),
                const Color(0xFFFFFBEB),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String name, String grams, String pct, String kcal, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
              Text(pct, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(grams, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          Text(kcal, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // 3. Official FDA Nutrition Facts Label Box
  Widget _buildFdaNutritionFactsLabel(FoodItemModel scaled) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Facts',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.8),
          ),
          Text(
            'Serving Size: ${scaled.servingSize} (${scaled.servingWeightGrams.toStringAsFixed(0)}g)',
            style: const TextStyle(fontSize: 10.5, color: Colors.black, fontWeight: FontWeight.w700),
          ),
          const Divider(thickness: 6, color: Colors.black, height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Amount Per Serving', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.black)),
                  Text('Calories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                ],
              ),
              Text(
                scaled.calories.toStringAsFixed(0),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ],
          ),
          const Divider(thickness: 3, color: Colors.black, height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('% Daily Value*', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black)),
          ),
          _buildFdaFactRow('Total Fat', '${scaled.fat.toStringAsFixed(1)}g', '${((scaled.fat / 78) * 100).toStringAsFixed(0)}%', isBold: true),
          _buildFdaFactRow('   Saturated Fat', '${scaled.saturatedFat.toStringAsFixed(1)}g', '${((scaled.saturatedFat / 20) * 100).toStringAsFixed(0)}%'),
          _buildFdaFactRow('Cholesterol', '${scaled.cholesterol.toStringAsFixed(0)}mg', '${((scaled.cholesterol / 300) * 100).toStringAsFixed(0)}%', isBold: true),
          _buildFdaFactRow('Sodium', '${scaled.sodium.toStringAsFixed(0)}mg', '${((scaled.sodium / 2300) * 100).toStringAsFixed(0)}%', isBold: true),
          _buildFdaFactRow('Total Carbohydrate', '${scaled.carbs.toStringAsFixed(1)}g', '${((scaled.carbs / 275) * 100).toStringAsFixed(0)}%', isBold: true),
          _buildFdaFactRow('   Dietary Fiber', '${scaled.fiber.toStringAsFixed(1)}g', '${((scaled.fiber / 28) * 100).toStringAsFixed(0)}%'),
          _buildFdaFactRow('   Total Sugars', '${scaled.sugar.toStringAsFixed(1)}g', ''),
          _buildFdaFactRow('Protein', '${scaled.protein.toStringAsFixed(1)}g', '${((scaled.protein / 50) * 100).toStringAsFixed(0)}%', isBold: true),
          const Divider(thickness: 4, color: Colors.black, height: 10),
          if (scaled.potassium > 0)
            _buildFdaFactRow('Potassium', '${scaled.potassium.toStringAsFixed(0)}mg', '${((scaled.potassium / 4700) * 100).toStringAsFixed(0)}%'),
          if (scaled.vitamins.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Vitamins & Bioactives: ${scaled.vitamins}', style: const TextStyle(fontSize: 9.5, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  Widget _buildFdaFactRow(String name, String value, String dv, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(name, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.w900 : FontWeight.w500, color: Colors.black)),
              const SizedBox(width: 4),
              Text(value, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, color: Colors.black)),
            ],
          ),
          if (dv.isNotEmpty)
            Text(dv, style: TextStyle(fontSize: 10.5, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: Colors.black)),
        ],
      ),
    );
  }

  // 4. NOVA Group Card
  Widget _buildNovaCard() {
    final nova = _currentFood.novaGroup;
    final color = _getNovaColor(nova);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Text('NOVA $nova', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Food Processing Classification', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                Text(_getNovaDescription(nova), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Ingredients & Allergens Card
  Widget _buildIngredientsAndAllergensCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.format_list_bulleted_rounded, color: Color(0xFF3B82F6), size: 18),
              SizedBox(width: 6),
              Text('Ingredients & Allergens', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 10),
          if (_currentFood.ingredientText.isNotEmpty || _currentFood.ingredients.isNotEmpty) ...[
            const Text('Ingredients List:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
            const SizedBox(height: 4),
            Text(
              _currentFood.ingredientText.isNotEmpty ? _currentFood.ingredientText : _currentFood.ingredients.join(', '),
              style: const TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.4),
            ),
            const SizedBox(height: 12),
          ],
          if (_currentFood.allergens.isNotEmpty) ...[
            const Text('Allergen Warnings:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _currentFood.allergens.map((a) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFDC2626)),
                      const SizedBox(width: 4),
                      Text(a.toUpperCase(), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Row(
              children: const [
                Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 14),
                SizedBox(width: 4),
                Text('No common allergen declarations reported.', style: TextStyle(fontSize: 10.5, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
