import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_backend_service.dart';
import 'recipe_detail_modal.dart';

class NutritionRecipesView extends StatefulWidget {
  final String selectedDateRange;
  final List<Animation<double>> fadeAnimations;
  final List<Animation<Offset>> slideAnimations;

  const NutritionRecipesView({
    super.key,
    required this.selectedDateRange,
    required this.fadeAnimations,
    required this.slideAnimations,
  });

  @override
  State<NutritionRecipesView> createState() => _NutritionRecipesViewState();
}

class _NutritionRecipesViewState extends State<NutritionRecipesView> {
  final RecipeBackendService _recipeService = RecipeBackendService();
  final TextEditingController _searchController = TextEditingController();

  int _selectedCatIndex = 0;
  String _selectedDiet = 'All';
  String _searchQuery = '';
  String _selectedSource = 'db'; // 'db', 'all', 'indian', 'usda', 'mealdb'
  Timer? _debounceTimer;

  // Progressive Lazy Loading (6 by 6 items)
  int _displayLimit = 6;
  bool _isLoadingMore = false;

  final List<String> _recipeCategories = [
    'All Recipes',
    'High Protein',
    'Breakfast',
    'Main Course',
    'Curries & Dals',
    'Rice & Biryani',
    'Healthy Snacks',
  ];

  final List<String> _dietaryFilters = [
    'All',
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Eggitarian',
  ];

  final List<String> _quickSuggestions = [
    'Paneer Tikka',
    'Butter Chicken',
    'Chicken Biryani',
    'Grilled Salmon',
    'Chicken & Sweet Potato',
    'Turkey Chili',
    'Greek Power Bowl',
    'Palak Paneer',
    'Dal Makhani',
    'Protein Oats',
    'Tofu Stir-Fry',
    'Top Sirloin Steak',
    'Avocado Egg Toast',
    'Fish Tikka',
    'Idli Sambar',
    'Masala Oats',
  ];

  @override
  void initState() {
    super.initState();
    _recipeService.fetchRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _triggerLiveRecipeSearch(String query, {String? source}) {
    final effectiveSource = source ?? (_selectedSource == 'db' ? 'all' : _selectedSource);
    final cleanQuery = query.trim();
    _searchController.text = cleanQuery;

    setState(() {
      _selectedSource = effectiveSource;
      _searchQuery = cleanQuery;
      _displayLimit = 6;
    });

    _recipeService.searchLiveRecipes(cleanQuery, source: effectiveSource);
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _searchQuery = query;
        _displayLimit = 6;
      });

      if (_selectedSource != 'db') {
        _recipeService.searchLiveRecipes(query.trim(), source: _selectedSource);
      }
    });
  }




  void _loadMoreItems(int totalAvailable) {
    if (_isLoadingMore || _displayLimit >= totalAvailable) return;
    setState(() => _isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _displayLimit = (_displayLimit + 6).clamp(0, totalAvailable);
          _isLoadingMore = false;
        });
      }
    });
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    final int safeIndex = index < widget.fadeAnimations.length ? index : widget.fadeAnimations.length - 1;
    return FadeTransition(
      opacity: widget.fadeAnimations[safeIndex],
      child: SlideTransition(
        position: widget.slideAnimations[safeIndex],
        child: child,
      ),
    );
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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

  void _showAddRecipeDialog() {
    final titleController = TextEditingController();
    final kcalController = TextEditingController(text: '380');
    final pController = TextEditingController(text: '28');
    final cController = TextEditingController(text: '35');
    final fController = TextEditingController(text: '12');
    final prepController = TextEditingController(text: '15');
    final cookController = TextEditingController(text: '20');
    final imgController = TextEditingController();
    final tipsController = TextEditingController();
    final ingredientsController = TextEditingController(text: '200g Primary Ingredient, 1 tbsp Olive Oil, Indian Spices');
    final stepsController = TextEditingController(text: '1. Prepare and marinate ingredients.\n2. Cook on medium heat for 15 minutes.');

    String selectedCat = 'High Protein';
    String selectedCuisine = 'North Indian';
    String selectedDiet = 'Vegetarian';

    final categories = ['Breakfast', 'Main Course', 'High Protein', 'Curries & Dals', 'Rice & Biryani', 'Healthy Snacks'];
    final cuisines = ['North Indian', 'South Indian', 'Punjabi', 'Mughlai', 'Indian Fitness', 'Maharashtrian', 'Bengali', 'Gujarati'];
    final diets = ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggitarian'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.soup_kitchen_rounded, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 8),
              Text('Create New Indian Recipe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recipe Title', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'e.g. Tandoori Chicken Tikka, Paneer Bhurji',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
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
                                  value: selectedCuisine,
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
                                  value: selectedDiet,
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
                                  value: selectedCat,
                                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11.5)))).toList(),
                                  onChanged: (val) => setDlgState(() => selectedCat = val!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMiniInput('Calories (kcal)', kcalController)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Macro Breakdown (Per Serving)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildMiniInput('Protein (g)', pController)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMiniInput('Carbs (g)', cController)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMiniInput('Fat (g)', fController)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildMiniInput('Prep Time (mins)', prepController)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMiniInput('Cook Time (mins)', cookController)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Ingredients (Comma separated)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  TextField(
                    controller: ingredientsController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 11.5),
                    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(10)),
                  ),
                  const SizedBox(height: 10),
                  const Text('Preparation Steps', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  TextField(
                    controller: stepsController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 11.5),
                    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(10)),
                  ),
                  const SizedBox(height: 10),
                  _buildMiniInput('Food Image URL', imgController),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  final ings = ingredientsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  final stps = stepsController.text
                      .split('\n')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  final newRec = RecipeModel(
                    id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    name: title,
                    cuisine: selectedCuisine,
                    dietaryType: selectedDiet,
                    category: selectedCat,
                    prepTimeMinutes: int.tryParse(prepController.text) ?? 15,
                    cookTimeMinutes: int.tryParse(cookController.text) ?? 20,
                    totalTime: '${(int.tryParse(prepController.text) ?? 15) + (int.tryParse(cookController.text) ?? 20)} mins',
                    calories: double.tryParse(kcalController.text) ?? 350,
                    protein: double.tryParse(pController.text) ?? 25,
                    carbs: double.tryParse(cController.text) ?? 30,
                    fat: double.tryParse(fController.text) ?? 10,
                    imageUrl: imgController.text.trim(),
                    ingredientList: ings,
                    steps: stps,
                    chefTips: tipsController.text.trim(),
                    source: 'NeuroFitAdmin',
                  );

                  await _recipeService.createRecipe(newRec);
                  if (mounted) {
                    Navigator.pop(ctx);
                    _showSnackbar('Recipe "$title" added to MongoDB Atlas!', const Color(0xFF10B981));
                  }
                }
              },
              child: const Text('Publish Recipe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _recipeService,
      builder: (context, _) {
        final List<RecipeModel> sourceList = _selectedSource != 'db'
            ? _recipeService.liveSearchResults
            : _recipeService.recipes;

        final filtered = sourceList.where((r) {
          if (_selectedCatIndex > 0) {
            final cat = _recipeCategories[_selectedCatIndex];
            if (r.category.toLowerCase() != cat.toLowerCase()) return false;
          }

          if (_selectedDiet != 'All') {
            if (r.dietaryType.toLowerCase() != _selectedDiet.toLowerCase()) return false;
          }

          if (_selectedSource != 'db') return true;

          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return r.title.toLowerCase().contains(q) ||
              r.cuisine.toLowerCase().contains(q) ||
              r.category.toLowerCase().contains(q) ||
              r.ingredientList.any((i) => i.toLowerCase().contains(q));
        }).toList();

        final visibleCount = _displayLimit.clamp(0, filtered.length);
        final visibleRecipes = filtered.take(visibleCount).toList();

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 350) {
              _loadMoreItems(filtered.length);
            }
            return false;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedSection(0, _buildKpiCarousel()),
              const SizedBox(height: 16),
              _buildAnimatedSection(1, _buildSearchAndActionBar()),
              const SizedBox(height: 12),
              _buildAnimatedSection(2, _buildDietAndCategoryFilters()),
              const SizedBox(height: 16),
              _buildAnimatedSection(3, _buildRecipesGrid(visibleRecipes, filtered.length)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCarousel() {
    final totalRec = _recipeService.totalCount > 0 ? _recipeService.totalCount : _recipeService.recipes.length;
    final highProtein = _recipeService.recipes.where((r) => r.protein >= 25).length;
    final pureVeg = _recipeService.recipes.where((r) => r.isVegetarian).length;

    final kpis = [
      {'title': 'Recipes Database', 'val': '$totalRec Recipes', 'growth': 'Atlas + USDA + Indian', 'icon': Icons.soup_kitchen_rounded, 'color': const Color(0xFF10B981), 'bg': const Color(0xFFECFDF5)},
      {'title': 'High-Protein', 'val': '$highProtein Recipes', 'growth': '>= 25g Clean Protein', 'icon': Icons.fitness_center_rounded, 'color': const Color(0xFF3B82F6), 'bg': const Color(0xFFEFF6FF)},
      {'title': 'Pure Vegetarian', 'val': '$pureVeg Recipes', 'growth': 'Plant & Dairy Flavors', 'icon': Icons.eco_rounded, 'color': const Color(0xFF059669), 'bg': const Color(0xFFECFDF5)},
      {'title': 'Avg Cook Time', 'val': '22 mins', 'growth': 'Step-by-step guides', 'icon': Icons.timer_outlined, 'color': const Color(0xFFF59E0B), 'bg': const Color(0xFFFFFBEB)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: kpis.map((k) {
          final Color color = k['color'] as Color;
          return Container(
            width: 145,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: color.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: k['bg'] as Color, borderRadius: BorderRadius.circular(8)), child: Icon(k['icon'] as IconData, color: color, size: 14)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(k['title'] as String, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(k['val'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(k['growth'] as String, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchAndActionBar() {
    final isLive = _selectedSource != 'db';

    String hintText = 'Search Atlas recipes (e.g. Paneer Tikka, Salmon)...';
    if (_selectedSource == 'indian') {
      hintText = 'Search Indian recipes (e.g. Paneer Tikka, Biryani, Dal)...';
    } else if (_selectedSource == 'usda') {
      hintText = 'Search USDA & Healthy meals (e.g. Salmon, Chicken, Oats)...';
    } else if (_selectedSource == 'mealdb') {
      hintText = 'Search Global TheMealDB (e.g. Pasta, Steak, Salad)...';
    } else if (_selectedSource == 'all') {
      hintText = 'Search ALL live APIs (Indian + USDA + Global Meals)...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isLive ? const Color(0xFF3B82F6) : Colors.grey.shade300,
                    width: isLive ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onSubmitted: (val) => _triggerLiveRecipeSearch(val),
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: hintText,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ),
                    if (_recipeService.isLoading || _recipeService.isSearchingLive) ...[
                      const SizedBox(width: 6),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Dedicated SEARCH LIVE BUTTON
            GestureDetector(
              onTap: () {
                final q = _searchController.text.trim();
                _triggerLiveRecipeSearch(q.isNotEmpty ? q : 'Chicken');
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.travel_explore_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 5),
                    Text('Search Live', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // ADD RECIPE BUTTON
            GestureDetector(
              onTap: _showAddRecipeDialog,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Add Recipe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Multi-Source Database Selector Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildSourceChip('db', '🍃 Atlas Database (${_recipeService.recipes.length})', const Color(0xFF10B981)),
              const SizedBox(width: 6),
              _buildSourceChip('all', '⚡ All Free APIs', const Color(0xFF3B82F6)),
              const SizedBox(width: 6),
              _buildSourceChip('indian', '🇮🇳 Indian Recipes', const Color(0xFFEA580C)),
              const SizedBox(width: 6),
              _buildSourceChip('usda', '🇺🇸 USDA Healthy Meals', const Color(0xFF2563EB)),
              const SizedBox(width: 6),
              _buildSourceChip('mealdb', '🌐 Global TheMealDB', const Color(0xFF059669)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Quick Search Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const Text('✨ Popular: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
              ..._quickSuggestions.map((item) {
                final isCurrent = _searchQuery.toLowerCase() == item.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => _triggerLiveRecipeSearch(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF3B82F6) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isCurrent ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: isCurrent ? Colors.white : const Color(0xFF334155)),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceChip(String sourceKey, String label, Color activeColor) {
    final isSelected = _selectedSource == sourceKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSource = sourceKey;
          _displayLimit = 6;
        });
        if (sourceKey == 'db') {
          _recipeService.fetchRecipes();
        } else {
          _triggerLiveRecipeSearch(_searchQuery.isNotEmpty ? _searchQuery : '', source: sourceKey);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: isSelected ? activeColor : Colors.grey.shade300, width: isSelected ? 1.5 : 1.0),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 9.5, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: isSelected ? activeColor : const Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _buildDietAndCategoryFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dietary Type Filter (Veg/Non-Veg)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _dietaryFilters.map((d) {
              final isSel = _selectedDiet == d;
              final color = d == 'All' ? const Color(0xFF10B981) : _getDietColor(d);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedDiet = d;
                    _displayLimit = 6;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: isSel ? color : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSel ? color : Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        if (d != 'All') ...[
                          Icon(Icons.circle, color: isSel ? Colors.white : color, size: 8),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          d == 'All' ? 'All Diets' : d,
                          style: TextStyle(fontSize: 9.5, fontWeight: isSel ? FontWeight.w900 : FontWeight.w700, color: isSel ? Colors.white : const Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Category Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_recipeCategories.length, (i) {
              final isSelected = _selectedCatIndex == i;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedCatIndex = i;
                    _displayLimit = 6;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF10B981) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200),
                    ),
                    child: Text(
                      _recipeCategories[i],
                      style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipesGrid(List<RecipeModel> visibleRecipes, int totalCount) {
    final isBusy = _recipeService.isLoading || _recipeService.isSearchingLive;
    if (isBusy && visibleRecipes.isEmpty) {
      String loadingText = 'Searching live recipe databases...';
      if (_selectedSource == 'indian') {
        loadingText = 'Querying Indian recipes database...';
      } else if (_selectedSource == 'usda') {
        loadingText = 'Querying USDA & Healthy Meals...';
      } else if (_selectedSource == 'mealdb') {
        loadingText = 'Querying Global TheMealDB...';
      } else if (_selectedSource == 'all') {
        loadingText = 'Aggregating Indian, USDA & Global recipes...';
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(height: 14),
            Text(
              loadingText,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    if (visibleRecipes.isEmpty) {
      String emptyMsg = 'No recipes match your filter';
      if (_selectedSource == 'indian') {
        emptyMsg = 'No Indian recipes found. Try "Paneer", "Chicken", "Biryani", "Dal".';
      } else if (_selectedSource == 'usda') {
        emptyMsg = 'No USDA meals found. Try "Salmon", "Turkey", "Oats", "Steak".';
      } else if (_selectedSource != 'db') {
        emptyMsg = 'Type a recipe name above and tap "Search Live" to query free databases.';
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.soup_kitchen_rounded, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            Text(
              emptyMsg,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${visibleRecipes.length} of $totalCount recipes',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
            ),
            if (visibleRecipes.length < totalCount)
              const Text(
                'Scroll down to lazy load more ⚡',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemCount: visibleRecipes.length,
          itemBuilder: (ctx, i) {
            final r = visibleRecipes[i];
            return RepaintBoundary(
              child: GestureDetector(
                onTap: () => RecipeDetailModal.show(context, r, onUpdated: () => setState(() {})),
                child: _buildRecipeCard(r),
              ),
            );
          },
        ),
        if (_isLoadingMore) ...[
          const SizedBox(height: 16),
          const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF10B981)))),
        ],
        if (visibleRecipes.length < totalCount && !_isLoadingMore) ...[
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF10B981)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _loadMoreItems(totalCount),
              icon: const Icon(Icons.expand_more_rounded, size: 16, color: Color(0xFF10B981)),
              label: Text(
                'Load Next 6 Recipes (${totalCount - visibleRecipes.length} remaining)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecipeCard(RecipeModel r) {
    final dietColor = _getDietColor(r.dietaryType);

    // Determine source badge styling
    String sourceBadge = '🍃 Atlas';
    Color sourceColor = const Color(0xFF475569);
    if (r.source.contains('Indian') || r.id.startsWith('live_ind_')) {
      sourceBadge = '🇮🇳 Indian';
      sourceColor = const Color(0xFFEA580C);
    } else if (r.source.contains('USDA') || r.id.startsWith('live_usda_') || r.id.startsWith('rec_usda_')) {
      sourceBadge = '🇺🇸 USDA';
      sourceColor = const Color(0xFF2563EB);
    } else if (r.source.contains('MealDB') || r.id.startsWith('mealdb_')) {
      sourceBadge = '🌐 TheMealDB';
      sourceColor = const Color(0xFF059669);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: r.displayImageUrl.isNotEmpty
                    ? Image.network(
                        r.displayImageUrl,
                        height: 96,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 96,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.soup_kitchen, color: Color(0xFF94A3B8), size: 32),
                        ),
                      )
                    : Container(
                        height: 96,
                        color: const Color(0xFFECFDF5),
                        child: const Center(child: Icon(Icons.soup_kitchen, color: Color(0xFF10B981), size: 32)),
                      ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black87.withOpacity(0.8), borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        r.category,
                        style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: sourceColor, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        sourceBadge,
                        style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: dietColor, size: 8),
                      const SizedBox(width: 3),
                      Text(
                        r.cuisine,
                        style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '⏱️ ${r.totalTime} • ${r.difficulty}',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        '${r.calories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                      ),
                    ),
                    Text('P: ${r.protein.toStringAsFixed(0)}g', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                    Text('C: ${r.carbs.toStringAsFixed(0)}g', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6))),
                    Text('F: ${r.fat.toStringAsFixed(0)}g', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
