import 'r2_media_library_picker_modal.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/exercises_backend_service.dart' hide ExerciseCategoryModel;
import '../services/exercise_category_backend_service.dart';
import '../services/category_backend_service.dart';
import 'exercise_media_widget.dart';
import 'exercise_detail_modal.dart';

class FitnessExercisesView extends StatefulWidget {
  final String selectedDateRange;
  final List<Animation<double>> fadeAnimations;
  final List<Animation<Offset>> slideAnimations;

  const FitnessExercisesView({
    super.key,
    required this.selectedDateRange,
    required this.fadeAnimations,
    required this.slideAnimations,
  });

  @override
  State<FitnessExercisesView> createState() => _FitnessExercisesViewState();
}

class _FitnessExercisesViewState extends State<FitnessExercisesView> {
  final ExercisesBackendService _backendService = ExercisesBackendService();
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  int _displayLimit = 5;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _backendService.addListener(_onExServiceUpdate);
    ExerciseCategoryBackendService().addListener(_onExServiceUpdate);
    _backendService.fetchExercisesFromFirestore();
    ExerciseCategoryBackendService().fetchCategories();
  }

  @override
  void dispose() {
    _backendService.removeListener(_onExServiceUpdate);
    ExerciseCategoryBackendService().removeListener(_onExServiceUpdate);
    super.dispose();
  }

  void _onExServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _loadMoreExercises(int totalLength) {
    if (_isLoadingMore || _displayLimit >= totalLength) return;
    setState(() => _isLoadingMore = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _displayLimit = (_displayLimit + 5).clamp(0, totalLength);
          _isLoadingMore = false;
        });
      }
    });
  }

  void _openAddCategorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddExerciseCategorySheet(
        onAdded: () => setState(() {}),
      ),
    );
  }

  void _openEditCategorySheet(ExerciseCategoryModel category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditExerciseCategorySheet(
        category: category,
        onUpdated: () => setState(() {}),
      ),
    );
  }

  void _openAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddExerciseBottomSheet(
        onAdded: () => setState(() {}),
      ),
    );
  }

  void _openExerciseSlider(ExerciseModel exercise) {
    ExerciseDetailModal.show(
      context,
      exercise,
      () => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fadeAnim = widget.fadeAnimations.isNotEmpty
        ? widget.fadeAnimations[0]
        : const AlwaysStoppedAnimation(1.0);
    final slideAnim = widget.slideAnimations.isNotEmpty
        ? widget.slideAnimations[0]
        : const AlwaysStoppedAnimation(Offset.zero);

    final dbCategories = ExerciseCategoryBackendService().categories;
    final List<ExerciseCategoryModel> categoriesList = [];
    final Set<String> seenCatIds = {};

    for (var c in dbCategories) {
      if (!seenCatIds.contains(c.categoryId)) {
        seenCatIds.add(c.categoryId);
        categoriesList.add(c);
      }
    }
    for (var c in _backendService.categories) {
      if (!seenCatIds.contains(c.categoryId)) {
        seenCatIds.add(c.categoryId);
        categoriesList.add(ExerciseCategoryModel(
          id: c.categoryId,
          categoryId: c.categoryId,
          name: c.name,
          imageUrl: c.imageUrl,
        ));
      }
    }

    final exercises = _backendService.exercises.where((e) {
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.name.toLowerCase().contains(q) ||
          e.muscleGroup.toLowerCase().contains(q) ||
          e.target.toLowerCase().contains(q) ||
          e.equipment.toLowerCase().contains(q) ||
          e.categoryName.toLowerCase().contains(q);
      final matchesCategory = _selectedCategoryFilter == 'All' ||
          e.categoryId == _selectedCategoryFilter ||
          e.categoryName.toLowerCase() == _selectedCategoryFilter.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    final visibleExercises = exercises.take(_displayLimit).toList();

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoadingMore &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 400 &&
            _displayLimit < exercises.length) {
          _loadMoreExercises(exercises.length);
        }
        return false;
      },
      child: FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(
          position: slideAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Bar
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exercises Directory',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Categories, GIF animations & MP4 videos',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          foregroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _openAddCategorySheet,
                        icon: const Icon(Icons.add_photo_alternate_rounded, size: 15),
                        label: const Text('+ Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: _openAddExerciseSheet,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Exercise', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 1. CATEGORIES CARDS CAROUSEL (ABOVE EXERCISES)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Muscle Group Categories', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  Text('Tap card to filter • Edit icon to manage', style: TextStyle(fontSize: 10, color: const Color(0xFF64748B).withValues(alpha: 0.8))),
                ],
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 'All Exercises' Card
                    _buildAllCategoriesCard(),
                    ...categoriesList.map((c) => _buildCategoryCard(c)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Search Bar
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (v) {
                    setState(() {
                      _searchQuery = v;
                      _displayLimit = 5;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search movements, muscles (e.g. Incline Bench, Deadlift)...',
                    hintStyle: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Exercises Grid Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategoryFilter == 'All'
                        ? 'All Exercises (${visibleExercises.length} of ${exercises.length})'
                        : '${categoriesList.firstWhere((c) => c.categoryId == _selectedCategoryFilter, orElse: () => categoriesList.isNotEmpty ? categoriesList.first : ExerciseCategoryModel(categoryId: '', name: 'Selected')).name} (${visibleExercises.length} of ${exercises.length})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  if (_selectedCategoryFilter != 'All')
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategoryFilter = 'All';
                        _displayLimit = 5;
                      }),
                      child: const Text('Clear Filter', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6366F1))),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // 2. EXERCISES GRID
              if (exercises.isEmpty)
                _buildEmptyState()
              else ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.76,
                  ),
                  itemCount: visibleExercises.length,
                  itemBuilder: (context, index) {
                    final ex = visibleExercises[index];
                    return RepaintBoundary(
                      key: ValueKey(ex.exerciseId.isNotEmpty ? ex.exerciseId : ex.id),
                      child: _buildExerciseCard(ex),
                    );
                  },
                ),

                // Progressive Lazy Loading Indicator & Load More
                if (_displayLimit < exercises.length) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: _isLoadingMore
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Color(0xFF6366F1), strokeWidth: 2.5),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Loading next 5 movements...',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                              ),
                            ],
                          )
                        : OutlinedButton.icon(
                            onPressed: () => _loadMoreExercises(exercises.length),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF6366F1)),
                              foregroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.expand_more_rounded, size: 18),
                            label: Text(
                              'Load Next 5 GIFs (Showing $_displayLimit of ${exercises.length})',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllCategoriesCard() {
    final isSelected = _selectedCategoryFilter == 'All';

    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryFilter = 'All'),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: isSelected ? const Color(0xFF6366F1).withOpacity(0.3) : Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 16),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('All Exercises', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w900)),
                  Text('${_backendService.exercises.length} Movements', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ExerciseCategoryModel cat) {
    final isSelected = _selectedCategoryFilter == cat.categoryId || _selectedCategoryFilter.toLowerCase() == cat.name.toLowerCase();

    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryFilter = cat.name),
      child: Container(
        width: 125,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0xFF6366F1).withOpacity(0.2) : Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image/Video
            Positioned.fill(
              child: ExerciseMediaWidget(
                mediaUrl: cat.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(5)),
                        child: Text('${cat.exerciseCount > 0 ? cat.exerciseCount : 'Active'} Moves', style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800)),
                      ),
                      // Edit Icon Trigger
                      GestureDetector(
                        onTap: () => _openEditCategorySheet(cat),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), shape: BoxShape.circle),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 11),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    cat.name,
                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: const [
          Icon(Icons.fitness_center_rounded, size: 36, color: Color(0xFF6366F1)),
          SizedBox(height: 8),
          Text('No Exercises Found', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          SizedBox(height: 4),
          Text('Tap "+ Add Exercise" to upload GIF, MP4 video, or image movement demos.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseModel ex) {
    Color badgeColor = const Color(0xFF6366F1);
    if (ex.mediaType == 'video') badgeColor = const Color(0xFFEF4444);
    if (ex.mediaType == 'gif') badgeColor = const Color(0xFF10B981);

    return GestureDetector(
      onTap: () => _openExerciseSlider(ex),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
                      color: Color(0xFF0F172A),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ExerciseMediaWidget(
                      mediaUrl: ex.displayMediaUrl,
                      fallbackUrl: ex.displayThumbnailUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        ex.mediaType.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        ex.difficulty,
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.categoryName.toUpperCase(),
                    style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF6366F1), letterSpacing: 0.4),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ex.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ex.target.isNotEmpty ? ex.target : ex.muscleGroup,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          ex.equipment,
                          style: const TextStyle(fontSize: 8.5, color: Color(0xFF475569), fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 3. EDIT / DELETE CATEGORY SHEET
// =========================================================================
class _EditExerciseCategorySheet extends StatefulWidget {
  final ExerciseCategoryModel category;
  final VoidCallback onUpdated;

  const _EditExerciseCategorySheet({required this.category, required this.onUpdated});

  @override
  State<_EditExerciseCategorySheet> createState() => _EditExerciseCategorySheetState();
}

class _EditExerciseCategorySheetState extends State<_EditExerciseCategorySheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  String? _selectedR2Url;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category.name);
    _descCtrl = TextEditingController(text: widget.category.description);
    _selectedR2Url = widget.category.imageUrl;
  }

  void _openR2MediaPicker() {
    R2MediaLibraryPickerModal.show(
      context,
      onImageSelected: (url) {
        setState(() {
          _selectedR2Url = url;
        });
      },
    );
  }

  void _handleSave() async {
    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isSaving = true);
    Navigator.pop(context);

    final imageUrl = _selectedR2Url ?? widget.category.imageUrl;
    final isVideo = imageUrl.toLowerCase().endsWith('.mp4') || imageUrl.toLowerCase().endsWith('.mov') || imageUrl.toLowerCase().endsWith('.webm');
    final isGif = imageUrl.toLowerCase().endsWith('.gif');
    final mediaType = isVideo ? 'video' : (isGif ? 'gif' : 'image');

    final catModel = ExerciseCategoryModel(
      id: widget.category.id,
      categoryId: widget.category.categoryId,
      name: newName,
      description: _descCtrl.text.trim(),
      imageUrl: imageUrl,
      mediaType: mediaType,
      sortOrder: widget.category.sortOrder,
    );

    await ExerciseCategoryBackendService().updateCategory(catModel);
    await ExercisesBackendService().updateCategory(
      categoryId: widget.category.categoryId,
      newName: newName,
      newImageUrl: imageUrl,
    );

    widget.onUpdated();
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Category?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Text('Are you sure you want to delete "${widget.category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              await ExerciseCategoryBackendService().deleteCategory(widget.category.id.isNotEmpty ? widget.category.id : widget.category.categoryId);
              await ExercisesBackendService().deleteCategory(widget.category.categoryId);
              widget.onUpdated();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _selectedR2Url ?? widget.category.imageUrl;
    final isVideo = imageUrl.toLowerCase().endsWith('.mp4') || imageUrl.toLowerCase().endsWith('.mov') || imageUrl.toLowerCase().endsWith('.webm');

    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 28),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 44, height: 4.5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          const Text('Edit Exercise Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('ID: ${widget.category.categoryId} • Category Details', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 16),

          // Media Preview & R2 Switch
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (isVideo
                      ? Container(
                          width: 80,
                          height: 65,
                          color: const Color(0xFF0F172A),
                          child: const Center(
                            child: Icon(Icons.play_arrow_rounded, color: Color(0xFF38BDF8), size: 28),
                          ),
                        )
                      : Image.network(
                          CategoryBackendService.getDisplayableImageUrl(imageUrl),
                          width: 80,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 65,
                            color: const Color(0xFF0F172A),
                            child: const Icon(Icons.broken_image, color: Colors.white),
                          ),
                        )),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        imageUrl.split('/').last,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: _openR2MediaPicker,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0284C7)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        icon: const Icon(Icons.cloud_done_rounded, size: 15, color: Color(0xFF0284C7)),
                        label: const Text('Change Media (R2)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Category Title')),
          const SizedBox(height: 10),
          TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Category Description')),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF4444)), foregroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _handleDelete,
                  child: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _isSaving ? null : _handleSave,
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 4. ADD EXERCISE CATEGORY SHEET
// =========================================================================
class _AddExerciseCategorySheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddExerciseCategorySheet({required this.onAdded});

  @override
  State<_AddExerciseCategorySheet> createState() => _AddExerciseCategorySheetState();
}

class _AddExerciseCategorySheetState extends State<_AddExerciseCategorySheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  String? _selectedR2Url;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  XFile? _imageFile;
  bool _isProcessing = false;

  void _openR2MediaPicker() {
    R2MediaLibraryPickerModal.show(
      context,
      onImageSelected: (url) {
        setState(() {
          _selectedR2Url = url;
          _imageBytes = null;
          _imageFile = null;
        });
      },
    );
  }

  void _pickImage() async {
    final f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1000, maxHeight: 1000, imageQuality: 85);
    if (f != null) {
      final b = await f.readAsBytes();
      setState(() {
        _imageFile = f;
        _imageBytes = b;
        _selectedR2Url = null;
      });
    }
  }

  void _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter category title')));
      return;
    }
    if (_imageBytes == null && _selectedR2Url == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select category image or R2 media')));
      return;
    }

    setState(() => _isProcessing = true);
    Navigator.pop(context);

    String finalUrl = _selectedR2Url ?? '';
    if (_selectedR2Url == null && _imageBytes != null) {
      final res = await ExercisesBackendService().createCategory(
        name: name,
        imageFileName: _imageFile?.name ?? 'ex_category.jpg',
        imageBytes: _imageBytes!,
      );
      if (res != null) finalUrl = res.imageUrl;
    }

    final isVideo = finalUrl.toLowerCase().endsWith('.mp4') || finalUrl.toLowerCase().endsWith('.mov') || finalUrl.toLowerCase().endsWith('.webm');
    final isGif = finalUrl.toLowerCase().endsWith('.gif');
    final mediaType = isVideo ? 'video' : (isGif ? 'gif' : 'image');

    await ExerciseCategoryBackendService().createCategory(
      name: name,
      description: _descCtrl.text.trim(),
      imageUrl: finalUrl,
      mediaType: mediaType,
      sortOrder: ExerciseCategoryBackendService().categories.length + 1,
    );

    widget.onAdded();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 28),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 44, height: 4.5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          const Text('Create Exercise Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Organize workout movement directory by muscle groups', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 16),

          // Media Selection Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.35)),
            ),
            child: Row(
              children: [
                if (_selectedR2Url != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      CategoryBackendService.getDisplayableImageUrl(_selectedR2Url!),
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 54, height: 54, color: const Color(0xFF0F172A), child: const Icon(Icons.play_arrow_rounded, color: Colors.white)),
                    ),
                  )
                else if (_imageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(_imageBytes!, width: 54, height: 54, fit: BoxFit.cover),
                  )
                else
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF6366F1)),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedR2Url != null ? _selectedR2Url!.split('/').last : (_imageFile != null ? _imageFile!.name : 'No image attached'),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _openR2MediaPicker,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0284C7)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            icon: const Icon(Icons.cloud_done_rounded, size: 14, color: Color(0xFF0284C7)),
                            label: const Text('R2 Cloud', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF6366F1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            icon: const Icon(Icons.upload_file_rounded, size: 14, color: Color(0xFF6366F1)),
                            label: const Text('Device', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF6366F1))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Category Name (e.g. Chest & Pecs, Glutes, Hamstrings)')),
          const SizedBox(height: 8),
          TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Category Description (Optional)')),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _isProcessing ? null : _submit,
              child: const Text('Save Category & Sync R2', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 5. ADD EXERCISE BOTTOM SHEET
// =========================================================================
class _AddExerciseBottomSheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddExerciseBottomSheet({required this.onAdded});

  @override
  State<_AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<_AddExerciseBottomSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _muscleCtrl = TextEditingController(text: 'Upper Chest & Front Delts');
  final TextEditingController _equipmentCtrl = TextEditingController(text: 'Dumbbells & Incline Bench');
  final List<TextEditingController> _stepCtrls = [
    TextEditingController(text: 'Set bench to 30 degrees incline.'),
    TextEditingController(text: 'Retract scapula and drive feet firmly into floor.'),
    TextEditingController(text: 'Press dumbbells vertically with full chest squeeze at top.'),
  ];
  final ImagePicker _picker = ImagePicker();

  String _selectedMediaType = 'gif'; // 'gif', 'video', 'image'
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String _selectedDifficulty = 'Intermediate';
  String? _selectedR2Url;

  Uint8List? _mediaBytes;
  XFile? _mediaFile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final categories = ExerciseCategoryBackendService().categories;
    if (categories.isNotEmpty) {
      _selectedCategoryId = categories.first.categoryId;
      _selectedCategoryName = categories.first.name;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _muscleCtrl.dispose();
    _equipmentCtrl.dispose();
    for (var c in _stepCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _stepCtrls.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepCtrls.length > 1) {
      setState(() {
        final ctrl = _stepCtrls.removeAt(index);
        ctrl.dispose();
      });
    }
  }

  void _openR2MediaPicker() {
    R2MediaLibraryPickerModal.show(
      context,
      onImageSelected: (url) {
        setState(() {
          _selectedR2Url = url;
          _mediaBytes = null;
          _mediaFile = null;
          final lower = url.toLowerCase();
          if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.webm')) {
            _selectedMediaType = 'video';
          } else if (lower.endsWith('.gif')) {
            _selectedMediaType = 'gif';
          } else {
            _selectedMediaType = 'image';
          }
        });
      },
    );
  }

  void _pickMedia() async {
    if (_selectedMediaType == 'video') {
      final f = await _picker.pickVideo(source: ImageSource.gallery);
      if (f != null) {
        final b = await f.readAsBytes();
        setState(() {
          _mediaFile = f;
          _mediaBytes = b;
          _selectedR2Url = null;
        });
      }
    } else {
      final f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200, imageQuality: 88);
      if (f != null) {
        final b = await f.readAsBytes();
        setState(() {
          _mediaFile = f;
          _mediaBytes = b;
          _selectedR2Url = null;
        });
      }
    }
  }

  void _submitExercise() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter exercise movement title'), backgroundColor: Color(0xFFEF4444)));
      return;
    }
    if (_mediaBytes == null && _selectedR2Url == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select or upload ${_selectedMediaType.toUpperCase()} media'), backgroundColor: const Color(0xFFEF4444)));
      return;
    }

    final categories = ExerciseCategoryBackendService().categories;
    final catId = _selectedCategoryId ?? (categories.isNotEmpty ? categories.first.categoryId : 'excat_chest');
    final catName = _selectedCategoryName ?? (categories.isNotEmpty ? categories.first.name : 'Chest & Pecs');

    setState(() => _isProcessing = true);

    final stepTexts = _stepCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final formattedInstructions = stepTexts.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');

    ExerciseModel? res;
    if (_selectedR2Url != null) {
      res = await ExercisesBackendService().createExerciseWithUrl(
        title: title,
        categoryId: catId,
        categoryName: catName,
        mediaType: _selectedMediaType,
        muscleGroup: _muscleCtrl.text.trim().isNotEmpty ? _muscleCtrl.text.trim() : 'Full Body',
        difficulty: _selectedDifficulty,
        equipment: _equipmentCtrl.text.trim().isNotEmpty ? _equipmentCtrl.text.trim() : 'Bodyweight',
        instructions: formattedInstructions,
        mediaUrl: _selectedR2Url!,
      );
    } else {
      String extension = 'jpg';
      if (_selectedMediaType == 'gif') extension = 'gif';
      if (_selectedMediaType == 'video') extension = 'mp4';

      final rawName = _mediaFile?.name ?? 'exercise';
      final cleanBase = rawName.split('.').first;
      final finalFileName = '${cleanBase}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      res = await ExercisesBackendService().createExercise(
        title: title,
        categoryId: catId,
        categoryName: catName,
        mediaType: _selectedMediaType,
        muscleGroup: _muscleCtrl.text.trim().isNotEmpty ? _muscleCtrl.text.trim() : 'Full Body',
        difficulty: _selectedDifficulty,
        equipment: _equipmentCtrl.text.trim().isNotEmpty ? _equipmentCtrl.text.trim() : 'Bodyweight',
        instructions: formattedInstructions,
        mediaFileName: finalFileName,
        mediaBytes: _mediaBytes!,
      );
    }

    setState(() => _isProcessing = false);

    if (res != null) {
      Navigator.pop(context);
      widget.onAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exercise "$title" saved to database & R2!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save exercise. Please check network connection.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ExercisesBackendService().categories;

    return Container(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 28),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 44, height: 4.5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            const Text('Upload New Exercise Movement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            const Text('Upload GIF animation, MP4 video demo, or image with Cloudflare R2', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            const SizedBox(height: 16),

            // Extension Type
            const Text('Select Media Extension Type', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('GIF (.gif)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                    selected: _selectedMediaType == 'gif',
                    selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                    onSelected: (v) => setState(() {
                      _selectedMediaType = 'gif';
                      _mediaBytes = null;
                    }),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Video (.mp4)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                    selected: _selectedMediaType == 'video',
                    selectedColor: const Color(0xFFEF4444).withOpacity(0.2),
                    onSelected: (v) => setState(() {
                      _selectedMediaType = 'video';
                      _mediaBytes = null;
                    }),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Image (.jpg)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
                    selected: _selectedMediaType == 'image',
                    selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
                    onSelected: (v) => setState(() {
                      _selectedMediaType = 'image';
                      _mediaBytes = null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Media Box with R2 option
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.35))),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_selectedR2Url != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(CategoryBackendService.getDisplayableImageUrl(_selectedR2Url!), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: const Color(0xFF0F172A), child: const Icon(Icons.play_arrow_rounded, color: Colors.white))),
                        )
                      else if (_mediaBytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(_mediaBytes!, width: 60, height: 60, fit: BoxFit.cover),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                          child: Icon(_selectedMediaType == 'video' ? Icons.videocam_rounded : Icons.animation_rounded, color: const Color(0xFF6366F1)),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedR2Url != null ? _selectedR2Url!.split('/').last : (_mediaFile != null ? _mediaFile!.name : 'No ${_selectedMediaType.toUpperCase()} attached'),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _openR2MediaPicker,
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF0284C7)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                                  icon: const Icon(Icons.cloud_done_rounded, size: 14, color: Color(0xFF0284C7)),
                                  label: const Text('R2 Cloud', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton.icon(
                                  onPressed: _pickMedia,
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF6366F1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                                  icon: const Icon(Icons.upload_file_rounded, size: 14, color: Color(0xFF6366F1)),
                                  label: const Text('Device', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF6366F1))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Exercise Movement Title (e.g. Incline DB Press)', filled: true, fillColor: Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))))),
            const SizedBox(height: 12),

            const Text('Exercise Category', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategoryId,
                  items: categories.map((c) => DropdownMenuItem(value: c.categoryId, child: Text(c.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategoryId = val;
                        _selectedCategoryName = categories.firstWhere((c) => c.categoryId == val).name;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: TextField(controller: _muscleCtrl, decoration: const InputDecoration(labelText: 'Target Muscles', filled: true, fillColor: Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _equipmentCtrl, decoration: const InputDecoration(labelText: 'Equipment', filled: true, fillColor: Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))))),
              ],
            ),
            const SizedBox(height: 12),

            const Text('Difficulty Level', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(
              children: ['Beginner', 'Intermediate', 'Advanced'].map((diff) {
                final isSel = _selectedDifficulty == diff;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(diff, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600)),
                    selected: isSel,
                    onSelected: (v) => setState(() => _selectedDifficulty = diff),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Dynamic "How To Do" Steps List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'How To Do (Step-by-Step Instructions)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                TextButton.icon(
                  onPressed: _addStep,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF10B981)),
                  label: const Text('Add Step', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stepCtrls.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                      child: Text('${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _stepCtrls[index],
                        decoration: InputDecoration(
                          hintText: 'Step ${index + 1} instruction cue...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    if (_stepCtrls.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF4444), size: 20),
                        onPressed: () => _removeStep(index),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isProcessing ? null : _submitExercise,
                child: const Text('Save Exercise & Sync Cloudflare R2', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 6. EXERCISE DETAILS SLIDER SHEET
// =========================================================================
class _ExerciseDetailsSliderSheet extends StatefulWidget {
  final ExerciseModel exercise;
  final VoidCallback onUpdated;
  const _ExerciseDetailsSliderSheet({required this.exercise, required this.onUpdated});

  @override
  State<_ExerciseDetailsSliderSheet> createState() => _ExerciseDetailsSliderSheetState();
}

class _ExerciseDetailsSliderSheetState extends State<_ExerciseDetailsSliderSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _muscleCtrl;
  late TextEditingController _equipmentCtrl;
  final List<TextEditingController> _stepCtrls = [];
  late String _status;
  late String _difficulty;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedR2Url;

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    _titleCtrl = TextEditingController(text: ex.title);
    _muscleCtrl = TextEditingController(text: ex.muscleGroup);
    _equipmentCtrl = TextEditingController(text: ex.equipment);
    _status = ex.status;
    _difficulty = ex.difficulty.isNotEmpty ? ex.difficulty : 'Intermediate';
    _selectedCategoryId = ex.categoryId;
    _selectedCategoryName = ex.categoryName;
    _selectedR2Url = ex.mediaUrl;

    // Parse instructions into individual step lines
    final rawLines = ex.instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (rawLines.isEmpty) {
      _stepCtrls.add(TextEditingController(text: ex.instructions));
    } else {
      for (var line in rawLines) {
        _stepCtrls.add(TextEditingController(text: line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')));
      }
    }

    final categories = ExerciseCategoryBackendService().categories;
    if (categories.isNotEmpty) {
      if (_selectedCategoryId == null || !categories.any((c) => c.categoryId == _selectedCategoryId)) {
        _selectedCategoryId = categories.first.categoryId;
        _selectedCategoryName = categories.first.name;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _muscleCtrl.dispose();
    _equipmentCtrl.dispose();
    for (var c in _stepCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _stepCtrls.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepCtrls.length > 1) {
      setState(() {
        final ctrl = _stepCtrls.removeAt(index);
        ctrl.dispose();
      });
    }
  }

  void _openR2MediaPicker() {
    R2MediaLibraryPickerModal.show(
      context,
      onImageSelected: (url) {
        setState(() {
          _selectedR2Url = url;
        });
      },
    );
  }

  void _handleSave() async {
    Navigator.pop(context);

    final title = _titleCtrl.text.trim();
    final muscle = _muscleCtrl.text.trim();
    final equipment = _equipmentCtrl.text.trim();
    final mediaUrl = _selectedR2Url ?? widget.exercise.mediaUrl;

    final stepTexts = _stepCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final formattedInstructions = stepTexts.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');

    final isVideo = mediaUrl.toLowerCase().endsWith('.mp4') || mediaUrl.toLowerCase().endsWith('.mov') || mediaUrl.toLowerCase().endsWith('.webm');
    final isGif = mediaUrl.toLowerCase().endsWith('.gif');
    final mediaType = isVideo ? 'video' : (isGif ? 'gif' : 'image');

    widget.exercise.title = title;
    widget.exercise.muscleGroup = muscle;
    widget.exercise.equipment = equipment;
    widget.exercise.instructions = formattedInstructions;
    widget.exercise.status = _status;
    widget.exercise.difficulty = _difficulty;
    widget.exercise.mediaUrl = mediaUrl;
    widget.exercise.mediaType = mediaType;
    if (_selectedCategoryId != null) {
      widget.exercise.categoryId = _selectedCategoryId!;
      widget.exercise.categoryName = _selectedCategoryName ?? widget.exercise.categoryName;
    }
    widget.exercise.updatedAt = DateTime.now();

    await ExercisesBackendService().updateExercise(widget.exercise);
    widget.onUpdated();
  }

  void _handleDelete() {
    Navigator.pop(context);
    ExercisesBackendService().deleteExercise(widget.exercise.exerciseId);
    widget.onUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ExerciseCategoryBackendService().categories;
    final mediaUrl = _selectedR2Url ?? widget.exercise.mediaUrl;
    final isVideo = mediaUrl.toLowerCase().endsWith('.mp4') || mediaUrl.toLowerCase().endsWith('.mov') || mediaUrl.toLowerCase().endsWith('.webm');

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 44, height: 4.5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit Exercise Movement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text('${widget.exercise.categoryName} • Media: ${widget.exercise.mediaType.toUpperCase()}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media Header Preview & R2 Switch
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (isVideo
                              ? Container(
                                  width: 80,
                                  height: 65,
                                  color: const Color(0xFF0F172A),
                                  child: const Center(
                                    child: Icon(Icons.play_arrow_rounded, color: Color(0xFF38BDF8), size: 28),
                                  ),
                                )
                              : Image.network(
                                  CategoryBackendService.getDisplayableImageUrl(mediaUrl),
                                  width: 80,
                                  height: 65,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 80,
                                    height: 65,
                                    color: const Color(0xFF0F172A),
                                    child: const Icon(Icons.broken_image, color: Colors.white),
                                  ),
                                )),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mediaUrl.split('/').last,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: _openR2MediaPicker,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF0284C7)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                icon: const Icon(Icons.cloud_done_rounded, size: 15, color: Color(0xFF0284C7)),
                                label: const Text('Change Media (R2)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Exercise Movement Title', filled: true, fillColor: Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  ),
                  const SizedBox(height: 12),

                  const Text('Exercise Category', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategoryId,
                        items: categories.map((c) => DropdownMenuItem(value: c.categoryId, child: Text(c.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategoryId = val;
                              _selectedCategoryName = categories.firstWhere((c) => c.categoryId == val).name;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: TextField(controller: _muscleCtrl, decoration: const InputDecoration(labelText: 'Target Muscles', filled: true, fillColor: Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _equipmentCtrl, decoration: const InputDecoration(labelText: 'Equipment', filled: true, fillColor: Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))))),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Text('Difficulty Level', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: ['Beginner', 'Intermediate', 'Advanced'].map((diff) {
                      final isSel = _difficulty == diff;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(diff, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600)),
                          selected: isSel,
                          onSelected: (v) => setState(() => _difficulty = diff),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic "How To Do" Steps List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'How To Do (Step-by-Step Instructions)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      TextButton.icon(
                        onPressed: _addStep,
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF10B981)),
                        label: const Text('Add Step', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _stepCtrls.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                            child: Text('${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _stepCtrls[index],
                              decoration: InputDecoration(
                                hintText: 'Step ${index + 1} instruction cue...',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          if (_stepCtrls.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF4444), size: 20),
                              onPressed: () => _removeStep(index),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_status == 'Active' ? 'Status: Active (Visible to Athletes)' : 'Status: Deactivated', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    value: _status == 'Active',
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _status = v ? 'Active' : 'Deactivated'),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF4444)), foregroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: _handleDelete,
                          child: const Text('Delete Exercise', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: _handleSave,
                          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
