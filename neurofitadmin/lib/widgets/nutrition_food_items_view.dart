import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/nutrition_backend_service.dart';
import 'food_detail_modal.dart';

class NutritionFoodItemsView extends StatefulWidget {
  final String selectedDateRange;
  final List<Animation<double>> fadeAnimations;
  final List<Animation<Offset>> slideAnimations;

  const NutritionFoodItemsView({
    super.key,
    required this.selectedDateRange,
    required this.fadeAnimations,
    required this.slideAnimations,
  });

  @override
  State<NutritionFoodItemsView> createState() => _NutritionFoodItemsViewState();
}

class _NutritionFoodItemsViewState extends State<NutritionFoodItemsView> {
  final NutritionBackendService _nutritionService = NutritionBackendService();
  final TextEditingController _searchController = TextEditingController();

  int _selectedCatIndex = 0;
  String _searchQuery = '';
  String _selectedSource = 'db'; // 'db', 'all', 'ifct', 'usda', 'off'
  Timer? _debounceTimer;

  final List<String> _quickSuggestions = [
    'Roti / Chapati',
    'Fresh Paneer',
    'Makhana (Foxnuts)',
    'Chana Sattu',
    'Moong Dal',
    'Desi Ghee',
    'Jaggery (Gur)',
    'Ragi Millet',
    'Poha',
    'Besan Chilla',
    'Curd / Dahi',
    'Sprouted Moong',
    'Whey Protein',
    'Chicken Breast',
    'Greek Yogurt',
    'Almond Milk',
  ];

  // Progressive Lazy Loading (6 by 6 items)
  int _displayLimit = 6;
  bool _isLoadingMore = false;

  final List<String> _foodCategories = [
    'All Foods',
    'Fruits',
    'Poultry & Meat',
    'Grains & Oats',
    'Dairy & Eggs',
    'Nuts & Seeds',
    'Seafood',
    'Vegetables & Greens',
    'Supplements & Shakes',
    'Healthy Snacks',
  ];

  @override
  void initState() {
    super.initState();
    _nutritionService.fetchFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _triggerLiveNutritionSearch(String query, {String? source}) {
    final effectiveSource = source ?? (_selectedSource == 'db' ? 'all' : _selectedSource);
    final cleanQuery = query.trim();
    _searchController.text = cleanQuery;

    setState(() {
      _selectedSource = effectiveSource;
      _searchQuery = cleanQuery;
      _displayLimit = 6;
    });

    _nutritionService.searchLiveNutrition(cleanQuery, source: effectiveSource);
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _searchQuery = query;
        _displayLimit = 6;
      });

      if (_selectedSource != 'db') {
        _nutritionService.searchLiveNutrition(query.trim(), source: _selectedSource);
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

  void _showAddFoodItemDialog() {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final servingController = TextEditingController(text: '100g');
    final kcalController = TextEditingController(text: '120');
    final pController = TextEditingController(text: '5.0');
    final cController = TextEditingController(text: '20.0');
    final fController = TextEditingController(text: '2.0');
    final fiberController = TextEditingController(text: '3.0');
    final sugarController = TextEditingController(text: '2.0');
    final sodiumController = TextEditingController(text: '10');
    final imgController = TextEditingController();
    String selectedCat = 'Fruits';
    String nutriscore = 'A';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.restaurant_menu_rounded, color: Color(0xFF3B82F6), size: 22),
              SizedBox(width: 8),
              Text('Add Food & Nutrition Facts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Food Item Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'e.g. Organic Honeycrisp Apple, Whey Protein',
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
                            const Text('Category', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedCat,
                                  items: _foodCategories.skip(1).map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11)))).toList(),
                                  onChanged: (val) => setDlgState(() => selectedCat = val!),
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
                            const Text('Brand / Maker', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            TextField(
                              controller: brandController,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'e.g. Nature Choice',
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                            const Text('Serving Size', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            TextField(
                              controller: servingController,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nutri-Score Grade', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: nutriscore,
                                  items: ['A', 'B', 'C', 'D', 'E'].map((s) => DropdownMenuItem(value: s, child: Text('Grade $s', style: const TextStyle(fontSize: 11)))).toList(),
                                  onChanged: (val) => setDlgState(() => nutriscore = val!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Nutrition Facts (Per Serving)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildMiniInput('Calories (kcal)', kcalController)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMiniInput('Protein (g)', pController)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMiniInput('Carbs (g)', cController)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildMiniInput('Fat (g)', fController)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMiniInput('Fiber (g)', fiberController)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMiniInput('Sugar (g)', sugarController)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Food Image URL', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  TextField(
                    controller: imgController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'https://images.unsplash.com/... or leave empty',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final newFood = FoodItemModel(
                    id: 'food_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    brand: brandController.text.trim(),
                    category: selectedCat,
                    servingSize: servingController.text.trim(),
                    calories: double.tryParse(kcalController.text) ?? 100,
                    protein: double.tryParse(pController.text) ?? 0,
                    carbs: double.tryParse(cController.text) ?? 0,
                    fat: double.tryParse(fController.text) ?? 0,
                    fiber: double.tryParse(fiberController.text) ?? 0,
                    sugar: double.tryParse(sugarController.text) ?? 0,
                    sodium: double.tryParse(sodiumController.text) ?? 0,
                    nutriscore: nutriscore,
                    imageUrl: imgController.text.trim(),
                    vitamins: 'Custom Verified Item',
                    isVerified: true,
                    source: 'NeuroFitAdmin',
                  );

                  await _nutritionService.createFood(newFood);
                  if (mounted) {
                    Navigator.pop(ctx);
                    _showSnackbar('Food item "$name" added with verified nutrition facts!', const Color(0xFF3B82F6));
                  }
                }
              },
              child: const Text('Save Food Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _nutritionService,
      builder: (context, _) {
        final List<FoodItemModel> sourceList = _selectedSource != 'db'
            ? _nutritionService.liveNutritionResults
            : _nutritionService.foods;

        final filtered = sourceList.where((f) {
          if (_selectedCatIndex > 0) {
            final cat = _foodCategories[_selectedCatIndex];
            if (f.category.toLowerCase() != cat.toLowerCase()) return false;
          }
          if (_selectedSource != 'db') return true;
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return f.name.toLowerCase().contains(q) ||
              f.brand.toLowerCase().contains(q) ||
              f.category.toLowerCase().contains(q) ||
              f.barcode.toLowerCase().contains(q);
        }).toList();

        final visibleCount = _displayLimit.clamp(0, filtered.length);
        final visibleFoods = filtered.take(visibleCount).toList();

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
              _buildAnimatedSection(2, _buildCategoryChips()),
              const SizedBox(height: 16),
              _buildAnimatedSection(3, _buildFoodItemsGrid(visibleFoods, filtered.length)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCarousel() {
    final totalFoods = _nutritionService.totalCount > 0 ? _nutritionService.totalCount : _nutritionService.foods.length;
    final verifiedA = _nutritionService.foods.where((f) => f.nutriscore == 'A').length;
    final highProtein = _nutritionService.foods.where((f) => f.protein >= 15).length;

    final kpis = [
      {'title': 'Food Items', 'val': '$totalFoods Foods', 'growth': 'Atlas + IFCT + USDA', 'icon': Icons.kitchen_rounded, 'color': const Color(0xFF3B82F6), 'bg': const Color(0xFFEFF6FF)},
      {'title': 'Indian Nutrition', 'val': '50+ IFCT', 'growth': 'ICMR-NIN Standardized', 'icon': Icons.spa_rounded, 'color': const Color(0xFF10B981), 'bg': const Color(0xFFECFDF5)},
      {'title': 'Nutri-Score A', 'val': '$verifiedA Items', 'growth': 'Grade A Whole Foods', 'icon': Icons.verified_rounded, 'color': const Color(0xFF059669), 'bg': const Color(0xFFECFDF5)},
      {'title': 'High Protein', 'val': '$highProtein Items', 'growth': '>= 15g Protein / serving', 'icon': Icons.fitness_center_rounded, 'color': const Color(0xFF8B5CF6), 'bg': const Color(0xFFF5F3FF)},
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

    String hintText = 'Search Atlas database foods...';
    if (_selectedSource == 'ifct') {
      hintText = 'Search Indian ICMR-NIN facts (e.g. Roti, Sattu, Paneer, Ghee)...';
    } else if (_selectedSource == 'usda') {
      hintText = 'Search USDA FoodData Central (e.g. Chicken, Salmon, Oats)...';
    } else if (_selectedSource == 'off') {
      hintText = 'Search Open Food Facts (e.g. Nutella, Whey, Yogurt)...';
    } else if (_selectedSource == 'all') {
      hintText = 'Search ALL live APIs (Indian IFCT + USDA + Open Food Facts)...';
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
                    color: isLive ? const Color(0xFF10B981) : Colors.grey.shade300,
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
                        onSubmitted: (val) => _triggerLiveNutritionSearch(val.trim()),
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
                    if (_nutritionService.isLoading || _nutritionService.isSearchingLive || _nutritionService.isSearchingOff) ...[
                      const SizedBox(width: 6),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
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
                _triggerLiveNutritionSearch(q.isNotEmpty ? q : 'Makhana');
              },
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
                    Icon(Icons.travel_explore_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 5),
                    Text('Search Live', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showAddFoodItemDialog,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Add Food', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
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
              _buildSourceChip('db', '🍃 Atlas Database (${_nutritionService.foods.length})', const Color(0xFF3B82F6)),
              const SizedBox(width: 6),
              _buildSourceChip('all', '⚡ All Free APIs', const Color(0xFF10B981)),
              const SizedBox(width: 6),
              _buildSourceChip('ifct', '🇮🇳 Indian IFCT (ICMR-NIN)', const Color(0xFFEA580C)),
              const SizedBox(width: 6),
              _buildSourceChip('usda', '🇺🇸 USDA FoodData Central', const Color(0xFF2563EB)),
              const SizedBox(width: 6),
              _buildSourceChip('off', '🌐 Open Food Facts', const Color(0xFF059669)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Quick Indian & Fitness Search Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const Text('🇮🇳 Popular: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
              ..._quickSuggestions.map((item) {
                final isCurrent = _searchQuery.toLowerCase() == item.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => _triggerLiveNutritionSearch(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isCurrent ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
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
          _nutritionService.fetchFoods();
        } else {
          _triggerLiveNutritionSearch(_searchQuery.isNotEmpty ? _searchQuery : 'Roti', source: sourceKey);
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


  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_foodCategories.length, (i) {
          final isSelected = _selectedCatIndex == i;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedCatIndex = i;
                _displayLimit = 6;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200),
                ),
                child: Text(
                  _foodCategories[i],
                  style: TextStyle(fontSize: 10.5, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFoodItemsGrid(List<FoodItemModel> visibleFoods, int totalCount) {
    final bool isBusy = _nutritionService.isLoading || _nutritionService.isSearchingLive || _nutritionService.isSearchingOff;
    if (isBusy && visibleFoods.isEmpty) {
      String loadingText = 'Searching live nutrition databases...';
      if (_selectedSource == 'ifct') {
        loadingText = 'Querying ICMR-NIN Indian Food Composition...';
      } else if (_selectedSource == 'usda') {
        loadingText = 'Querying USDA FoodData Central...';
      } else if (_selectedSource == 'off') {
        loadingText = 'Querying Open Food Facts database...';
      } else if (_selectedSource == 'all') {
        loadingText = 'Aggregating Indian IFCT, USDA & Open Food Facts...';
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF10B981)),
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

    if (visibleFoods.isEmpty) {
      String emptyMsg = 'No food items match your filter';
      if (_selectedSource == 'ifct') {
        emptyMsg = 'No Indian IFCT staple foods found. Try "Roti", "Paneer", "Sattu", "Makhana".';
      } else if (_selectedSource == 'usda') {
        emptyMsg = 'No USDA items found. Try searching "Chicken", "Salmon", "Oats", "Whey".';
      } else if (_selectedSource != 'db') {
        emptyMsg = 'Type a food name above and tap "Search Live" to query free databases.';
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.no_meals_rounded, size: 48, color: Color(0xFFCBD5E1)),
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
              'Showing ${visibleFoods.length} of $totalCount foods',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
            ),
            if (visibleFoods.length < totalCount)
              const Text(
                'Scroll down to lazy load more ⚡',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6)),
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
          itemCount: visibleFoods.length,
          itemBuilder: (ctx, i) {
            final f = visibleFoods[i];
            return RepaintBoundary(
              child: GestureDetector(
                onTap: () => FoodDetailModal.show(context, f, onUpdated: () => setState(() {})),
                child: _buildFoodCard(f),
              ),
            );
          },
        ),
        if (_isLoadingMore) ...[
          const SizedBox(height: 16),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF3B82F6)),
            ),
          ),
        ],
        if (visibleFoods.length < totalCount && !_isLoadingMore) ...[
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _loadMoreItems(totalCount),
              icon: const Icon(Icons.expand_more_rounded, size: 16, color: Color(0xFF3B82F6)),
              label: Text(
                'Load Next 6 Foods (${totalCount - visibleFoods.length} remaining)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFoodCard(FoodItemModel f) {
    // Determine source badge styling
    String sourceBadge = '🍃 Atlas';
    Color sourceColor = const Color(0xFF475569);
    if (f.source.contains('ICMR') || f.source.contains('IFCT') || f.id.startsWith('ifct_')) {
      sourceBadge = '🇮🇳 IFCT';
      sourceColor = const Color(0xFFEA580C);
    } else if (f.source.contains('USDA') || f.id.startsWith('usda_')) {
      sourceBadge = '🇺🇸 USDA';
      sourceColor = const Color(0xFF2563EB);
    } else if (f.source.contains('OpenFoodFacts') || f.id.startsWith('off_')) {
      sourceBadge = '🌐 OFF';
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
                child: f.displayImageUrl.isNotEmpty
                    ? Image.network(
                        f.displayImageUrl,
                        height: 96,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 96,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.restaurant, color: Color(0xFF94A3B8), size: 32),
                        ),
                      )
                    : Container(
                        height: 96,
                        color: const Color(0xFFEFF6FF),
                        child: const Center(child: Icon(Icons.restaurant, color: Color(0xFF3B82F6), size: 32)),
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
                        f.category,
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
              if (f.nutriscore != 'UNKNOWN')
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getNutriscoreColor(f.nutriscore),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                    ),
                    child: Text(
                      'Score ${f.nutriscore}',
                      style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: Colors.white),
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
                  f.name,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${f.servingSize} • ${f.brand.isNotEmpty ? f.brand : "Whole Food"}',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        '${f.calories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                      ),
                    ),
                    Text('P: ${f.protein.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                    Text('C: ${f.carbs.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6))),
                    Text('F: ${f.fat.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B))),
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
