import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_backend_service.dart';

class RecipeDetailModal extends StatefulWidget {
  final RecipeModel initialRecipe;
  final VoidCallback? onUpdated;

  const RecipeDetailModal({
    super.key,
    required this.initialRecipe,
    this.onUpdated,
  });

  static void show(BuildContext context, RecipeModel recipe, {VoidCallback? onUpdated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) => RecipeDetailModal(
        initialRecipe: recipe,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<RecipeDetailModal> createState() => _RecipeDetailModalState();
}

class _RecipeDetailModalState extends State<RecipeDetailModal> {
  late RecipeModel _recipe;
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _recipe = widget.initialRecipe;
  }

  Color _getDietColor(String diet) {
    switch (diet.toLowerCase()) {
      case 'vegetarian':
        return const Color(0xFF10B981);
      case 'vegan':
        return const Color(0xFF059669);
      case 'eggitarian':
        return const Color(0xFFF59E0B);
      case 'non-vegetarian':
      default:
        return const Color(0xFFEF4444);
    }
  }

  void _showEditRecipeDialog() {
    final titleCtrl = TextEditingController(text: _recipe.title);
    final kcalCtrl = TextEditingController(text: _recipe.calories.toStringAsFixed(0));
    final pCtrl = TextEditingController(text: _recipe.protein.toStringAsFixed(1));
    final cCtrl = TextEditingController(text: _recipe.carbs.toStringAsFixed(1));
    final fCtrl = TextEditingController(text: _recipe.fat.toStringAsFixed(1));
    final prepCtrl = TextEditingController(text: _recipe.prepTimeMinutes.toString());
    final cookCtrl = TextEditingController(text: _recipe.cookTimeMinutes.toString());
    final imgCtrl = TextEditingController(text: _recipe.imageUrl);
    final tipsCtrl = TextEditingController(text: _recipe.chefTips);
    String selectedCat = _recipe.category;
    String selectedCuisine = _recipe.cuisine;
    String selectedDiet = _recipe.dietaryType;

    final categories = ['Breakfast', 'Main Course', 'High Protein', 'Curries & Dals', 'Rice & Biryani', 'Healthy Snacks', 'General'];
    final cuisines = ['North Indian', 'South Indian', 'Punjabi', 'Mughlai', 'Indian Fitness', 'Maharashtrian', 'Bengali', 'Gujarati'];
    final diets = ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggitarian'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.edit_note_rounded, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 8),
              Text('Edit Indian Recipe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditField('Recipe Title', titleCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cuisine', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: cuisines.contains(selectedCuisine) ? selectedCuisine : 'North Indian',
                                  items: cuisines.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11.5)))).toList(),
                                  onChanged: (val) => setDlgState(() => selectedCuisine = val!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dietary Type', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: diets.contains(selectedDiet) ? selectedDiet : 'Vegetarian',
                                  items: diets.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 11.5)))).toList(),
                                  onChanged: (val) => setDlgState(() => selectedDiet = val!),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Category', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: categories.contains(selectedCat) ? selectedCat : 'High Protein',
                                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11.5)))).toList(),
                                  onChanged: (val) => setDlgState(() => selectedCat = val!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildEditField('Calories (kcal)', kcalCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildEditField('Protein (g)', pCtrl, isNumber: true)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildEditField('Carbs (g)', cCtrl, isNumber: true)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildEditField('Fat (g)', fCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildEditField('Prep (mins)', prepCtrl, isNumber: true)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildEditField('Cook (mins)', cookCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildEditField('Image URL', imgCtrl),
                  const SizedBox(height: 10),
                  _buildEditField('Chef Tips & Secrets', tipsCtrl),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final updated = RecipeModel(
                  id: _recipe.id,
                  title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : _recipe.title,
                  name: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : _recipe.name,
                  cuisine: selectedCuisine,
                  dietaryType: selectedDiet,
                  category: selectedCat,
                  prepTimeMinutes: int.tryParse(prepCtrl.text) ?? _recipe.prepTimeMinutes,
                  cookTimeMinutes: int.tryParse(cookCtrl.text) ?? _recipe.cookTimeMinutes,
                  totalTime: '${(int.tryParse(prepCtrl.text) ?? _recipe.prepTimeMinutes) + (int.tryParse(cookCtrl.text) ?? _recipe.cookTimeMinutes)} mins',
                  servings: _recipe.servings,
                  difficulty: _recipe.difficulty,
                  rating: _recipe.rating,
                  calories: double.tryParse(kcalCtrl.text) ?? _recipe.calories,
                  protein: double.tryParse(pCtrl.text) ?? _recipe.protein,
                  carbs: double.tryParse(cCtrl.text) ?? _recipe.carbs,
                  fat: double.tryParse(fCtrl.text) ?? _recipe.fat,
                  fiber: _recipe.fiber,
                  imageUrl: imgCtrl.text.trim(),
                  thumbnailUrl: imgCtrl.text.trim(),
                  youtubeUrl: _recipe.youtubeUrl,
                  ingredients: _recipe.ingredients,
                  ingredientList: _recipe.ingredientList,
                  steps: _recipe.steps,
                  instructions: _recipe.instructions,
                  chefTips: tipsCtrl.text.trim(),
                  tags: _recipe.tags,
                  source: _recipe.source,
                );

                await RecipeBackendService().updateRecipe(updated);
                setState(() => _recipe = updated);
                Navigator.pop(ctx);
                widget.onUpdated?.call();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Updated "${updated.title}" successfully!'), backgroundColor: const Color(0xFF10B981)),
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
    final dietColor = _getDietColor(_recipe.dietaryType);
    final pPct = _recipe.proteinPercentage;
    final cPct = _recipe.carbsPercentage;
    final fPct = _recipe.fatPercentage;

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
          Container(width: 44, height: 5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 8),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _recipe.displayImageUrl.isNotEmpty
                      ? Image.network(
                          _recipe.displayImageUrl,
                          width: 68,
                          height: 68,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 68,
                            height: 68,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.soup_kitchen_rounded, color: Color(0xFF94A3B8), size: 32),
                          ),
                        )
                      : Container(
                          width: 68,
                          height: 68,
                          color: const Color(0xFFECFDF5),
                          child: const Icon(Icons.soup_kitchen_rounded, color: Color(0xFF10B981), size: 32),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Veg / Non-Veg icon dot
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(color: dietColor, width: 1.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(Icons.circle, color: dietColor, size: 8),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: dietColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                            child: Text(_recipe.dietaryType.toUpperCase(), style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: dietColor)),
                          ),
                          const SizedBox(width: 6),
                          _buildHeaderSourceBadge(),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                            child: Text(_recipe.cuisine.toUpperCase(), style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF3B82F6))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _recipe.title,
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '⏱️ ${_recipe.totalTime} • ${_recipe.difficulty} • ★ ${_recipe.rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Divider(height: 20, thickness: 0.8, color: Color(0xFFF1F5F9)),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Source Origin Banner
                _buildSourceOriginBanner(),
                const SizedBox(height: 14),

                // 1. Macro Profile Cards
                _buildMacroProfileSection(pPct, cPct, fPct),
                const SizedBox(height: 18),

                // 2. Ingredients Checklist
                _buildIngredientsSection(),
                const SizedBox(height: 18),

                // 3. Step-by-Step Cooking Method
                _buildCookingStepsSection(),
                const SizedBox(height: 18),

                // 4. Chef Tips & Secrets
                if (_recipe.chefTips.isNotEmpty) ...[
                  _buildChefTipsSection(),
                  const SizedBox(height: 18),
                ],

                // 5. Tags
                if (_recipe.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _recipe.tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                      child: Text('#$t', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                if (_isLiveRecipe) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        final String importSource = _recipe.source.isNotEmpty
                            ? '${_recipe.source}_Imported'
                            : 'Live_Imported';

                        final toSave = RecipeModel(
                          id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
                          title: _recipe.title,
                          name: _recipe.name,
                          cuisine: _recipe.cuisine,
                          dietaryType: _recipe.dietaryType,
                          category: _recipe.category,
                          prepTimeMinutes: _recipe.prepTimeMinutes,
                          cookTimeMinutes: _recipe.cookTimeMinutes,
                          totalTime: _recipe.totalTime,
                          servings: _recipe.servings,
                          difficulty: _recipe.difficulty,
                          rating: _recipe.rating,
                          calories: _recipe.calories,
                          protein: _recipe.protein,
                          carbs: _recipe.carbs,
                          fat: _recipe.fat,
                          fiber: _recipe.fiber,
                          imageUrl: _recipe.imageUrl,
                          thumbnailUrl: _recipe.thumbnailUrl,
                          youtubeUrl: _recipe.youtubeUrl,
                          ingredients: _recipe.ingredients,
                          ingredientList: _recipe.ingredientList,
                          steps: _recipe.steps,
                          instructions: _recipe.instructions,
                          chefTips: _recipe.chefTips,
                          tags: _recipe.tags,
                          source: importSource,
                        );

                        await RecipeBackendService().createRecipe(toSave);
                        if (mounted) {
                          Navigator.pop(context);
                          widget.onUpdated?.call();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Imported "${toSave.title}" to MongoDB Atlas!'), backgroundColor: const Color(0xFF10B981)),
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
                    ),
                    onPressed: _showEditRecipeDialog,
                    icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                    label: const Text('Edit Recipe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        title: const Text('Delete Recipe?'),
                        content: Text('Are you sure you want to delete "${_recipe.title}"?'),
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
                      await RecipeBackendService().deleteRecipe(_recipe.id);
                      if (mounted) {
                        Navigator.pop(context);
                        widget.onUpdated?.call();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Recipe "${_recipe.title}" removed.'), backgroundColor: const Color(0xFFDC2626)),
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

  bool get _isLiveRecipe {
    final id = _recipe.id;
    return id.startsWith('live_') || id.startsWith('mealdb_') || _recipe.source.contains('Live') || _recipe.source.contains('USDA');
  }

  Widget _buildHeaderSourceBadge() {
    String label = 'ATLAS';
    Color col = const Color(0xFF10B981);
    if (_recipe.source.contains('Indian') || _recipe.id.startsWith('live_ind_')) {
      label = '🇮🇳 INDIAN';
      col = const Color(0xFFEA580C);
    } else if (_recipe.source.contains('USDA') || _recipe.id.startsWith('live_usda_') || _recipe.id.startsWith('rec_usda_')) {
      label = '🇺🇸 USDA';
      col = const Color(0xFF2563EB);
    } else if (_recipe.source.contains('MealDB') || _recipe.id.startsWith('mealdb_')) {
      label = '🌐 MEALDB';
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
    String title = 'Verified NeuroFit Atlas Recipe';
    String sub = 'Locally stored & structured in MongoDB Atlas database.';
    IconData icon = Icons.storage_rounded;
    Color col = const Color(0xFF10B981);
    Color bg = const Color(0xFFECFDF5);

    if (_recipe.source.contains('Indian') || _recipe.id.startsWith('live_ind_')) {
      title = 'Authentic Indian Traditional & Fitness Recipes';
      sub = 'Standardized regional and high-protein Indian fitness recipe engine.';
      icon = Icons.soup_kitchen_rounded;
      col = const Color(0xFFEA580C);
      bg = const Color(0xFFFFF7ED);
    } else if (_recipe.source.contains('USDA') || _recipe.id.startsWith('live_usda_') || _recipe.id.startsWith('rec_usda_')) {
      title = 'USDA Healthy Meal Guidelines & Macros';
      sub = 'Official high-protein fitness meal profiles with exact USDA macro breakdowns.';
      icon = Icons.account_balance_rounded;
      col = const Color(0xFF2563EB);
      bg = const Color(0xFFEFF6FF);
    } else if (_recipe.source.contains('MealDB') || _recipe.id.startsWith('mealdb_')) {
      title = 'TheMealDB Global Open Culinary Database';
      sub = 'International open-source recipe catalog with authentic global cuisines.';
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

  // 1. Macro Profile Section
  Widget _buildMacroProfileSection(double pPct, double cPct, double fPct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Nutrition Profile & Macros', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
              child: Text('🔥 ${_recipe.calories.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFB45309))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tri-color ratio bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (pPct > 0) Expanded(flex: (pPct * 10).round().clamp(1, 1000), child: Container(color: const Color(0xFF10B981))),
                if (cPct > 0) Expanded(flex: (cPct * 10).round().clamp(1, 1000), child: Container(color: const Color(0xFF3B82F6))),
                if (fPct > 0) Expanded(flex: (fPct * 10).round().clamp(1, 1000), child: Container(color: const Color(0xFFF59E0B))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(child: _buildMacroCard('Protein', '${_recipe.protein.toStringAsFixed(1)}g', '${pPct.toStringAsFixed(0)}% cal', const Color(0xFF10B981), const Color(0xFFECFDF5))),
            const SizedBox(width: 8),
            Expanded(child: _buildMacroCard('Carbs', '${_recipe.carbs.toStringAsFixed(1)}g', '${cPct.toStringAsFixed(0)}% cal', const Color(0xFF3B82F6), const Color(0xFFEFF6FF))),
            const SizedBox(width: 8),
            Expanded(child: _buildMacroCard('Fats', '${_recipe.fat.toStringAsFixed(1)}g', '${fPct.toStringAsFixed(0)}% cal', const Color(0xFFF59E0B), const Color(0xFFFFFBEB))),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(String name, String grams, String pct, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
              Text(pct, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(grams, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  // 2. Ingredients Section
  Widget _buildIngredientsSection() {
    final list = _recipe.ingredientList.isNotEmpty ? _recipe.ingredientList : _recipe.ingredients.map((i) => i.displayText).toList();

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
              Icon(Icons.checklist_rounded, color: Color(0xFF10B981), size: 18),
              SizedBox(width: 6),
              Text('Ingredients Checklist', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(list.length, (i) {
            final isChecked = _checkedIngredients.contains(i);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isChecked) {
                    _checkedIngredients.remove(i);
                  } else {
                    _checkedIngredients.add(i);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: isChecked ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        list[i],
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isChecked ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                          decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 3. Step-by-Step Cooking Steps
  Widget _buildCookingStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.menu_book_rounded, color: Color(0xFF3B82F6), size: 18),
            SizedBox(width: 6),
            Text('Step-by-Step Preparation Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(_recipe.steps.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                  child: Text('Step ${i + 1}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF3B82F6))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _recipe.steps[i],
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.4, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 4. Chef Tips
  Widget _buildChefTipsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chef\'s Secret & Cooking Tip', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                const SizedBox(height: 3),
                Text(_recipe.chefTips, style: const TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
