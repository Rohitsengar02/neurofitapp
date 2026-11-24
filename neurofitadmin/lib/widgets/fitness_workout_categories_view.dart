import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/workout_category_backend_service.dart';
import '../services/category_backend_service.dart';
import 'r2_media_library_picker_modal.dart';

class FitnessWorkoutCategoriesView extends StatefulWidget {
  final String selectedDateRange;
  final List<Animation<double>> fadeAnimations;
  final List<Animation<Offset>> slideAnimations;

  const FitnessWorkoutCategoriesView({
    super.key,
    required this.selectedDateRange,
    required this.fadeAnimations,
    required this.slideAnimations,
  });

  @override
  State<FitnessWorkoutCategoriesView> createState() => _FitnessWorkoutCategoriesViewState();
}

class _FitnessWorkoutCategoriesViewState extends State<FitnessWorkoutCategoriesView> {
  final WorkoutCategoryBackendService _catService = WorkoutCategoryBackendService();
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _catService.addListener(_onUpdate);
    _catService.fetchCategories();
  }

  @override
  void dispose() {
    _catService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _openAddOrEditCategoryModal({WorkoutCategoryModel? categoryToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddOrEditWorkoutCategoryModal(
        categoryToEdit: categoryToEdit,
        onSaved: () => setState(() {}),
      ),
    );
  }

  void _deleteCategory(WorkoutCategoryModel cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Category?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to delete "${cat.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _catService.deleteCategory(cat.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fadeAnim = widget.fadeAnimations.isNotEmpty ? widget.fadeAnimations[0] : const AlwaysStoppedAnimation(1.0);
    final slideAnim = widget.slideAnimations.isNotEmpty ? widget.slideAnimations[0] : const AlwaysStoppedAnimation(Offset.zero);

    final allCategories = _catService.categories;
    final totalActive = _catService.activeCategories.length;

    final filtered = allCategories.where((c) {
      if (_filterType == 'all') return true;
      if (_filterType == 'image') return c.mediaType == 'image';
      if (_filterType == 'gif') return c.mediaType == 'gif';
      if (_filterType == 'video') return c.mediaType == 'video';
      return true;
    }).toList();

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER BANNER (Consistent dark aesthetic)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.category_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Workout Categories Studio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$totalActive of ${allCategories.length} Categories Live in App',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: () => _openAddOrEditCategoryModal(),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Workout Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterBadge('All (${allCategories.length})', 'all', Icons.grid_view_rounded, const Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        _buildFilterBadge('Images (${allCategories.where((c) => c.mediaType == 'image').length})', 'image', Icons.image_rounded, const Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        _buildFilterBadge('GIFs (${allCategories.where((c) => c.mediaType == 'gif').length})', 'gif', Icons.gif_box_rounded, const Color(0xFFEC4899)),
                        const SizedBox(width: 8),
                        _buildFilterBadge('Videos (${allCategories.where((c) => c.mediaType == 'video').length})', 'video', Icons.video_collection_rounded, const Color(0xFF0284C7)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. REORDER INFO STRIP
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.swap_vert_rounded, color: Color(0xFFF59E0B), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Use Up/Down arrows to control exact index order. Supports image, animated GIF & video formats from R2.',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. CATEGORIES LIST
            _catService.isLoading && allCategories.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
                    ),
                  )
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildCategoryCard(
                          filtered[index],
                          index,
                          filtered.length,
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBadge(String label, String typeKey, IconData icon, Color badgeColor) {
    final isSelected = _filterType == typeKey;
    return GestureDetector(
      onTap: () => setState(() => _filterType = typeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? badgeColor : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white70,
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
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.category_outlined, size: 44, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 14),
          const Text('No Workout Categories Found', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Tap "+ Add Workout Category" to create training disciplines with R2 images, GIFs or videos.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(WorkoutCategoryModel cat, int index, int totalCount) {
    Color typeColor = const Color(0xFF10B981);
    IconData typeIcon = Icons.image_rounded;
    String typeLabel = 'IMAGE';

    if (cat.mediaType == 'gif') {
      typeColor = const Color(0xFFEC4899);
      typeIcon = Icons.gif_box_rounded;
      typeLabel = 'GIF';
    } else if (cat.mediaType == 'video') {
      typeColor = const Color(0xFF0284C7);
      typeIcon = Icons.video_collection_rounded;
      typeLabel = 'VIDEO';
    }

    final displayUrl = CategoryBackendService.getDisplayableImageUrl(cat.mediaUrl);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cat.isActive ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          width: cat.isActive ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: cat.isActive ? 0.03 : 0.01),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Up/Down Arrows and Index
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0)
                  GestureDetector(
                    onTap: () => _catService.reorderCategoriesByIndex(index, index - 1),
                    child: const Icon(Icons.arrow_drop_up_rounded, size: 22, color: Color(0xFF64748B)),
                  )
                else
                  const SizedBox(height: 18),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: cat.isActive
                          ? [const Color(0xFF0F172A), const Color(0xFF334155)]
                          : [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}'.padLeft(2, '0'),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
                if (index < totalCount - 1)
                  GestureDetector(
                    onTap: () => _catService.reorderCategoriesByIndex(index, index + 2),
                    child: const Icon(Icons.arrow_drop_down_rounded, size: 22, color: Color(0xFF64748B)),
                  )
                else
                  const SizedBox(height: 18),
              ],
            ),
            const SizedBox(width: 10),

            // Media Preview Avatar (Image / GIF / Video)
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    color: const Color(0xFFF1F5F9),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: displayUrl.isNotEmpty
                      ? Image.network(
                          displayUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(typeIcon, color: typeColor, size: 24),
                          ),
                        )
                      : Center(
                          child: Icon(typeIcon, color: typeColor, size: 24),
                        ),
                ),
                if (cat.mediaType == 'video')
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0284C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Category Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: typeColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SORT ORDER: ${cat.sortOrder}',
                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                      color: cat.isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cat.description.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      cat.description,
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Live Switch & 3-Dots Dropdown Actions Menu
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: 0.82,
                    child: Switch(
                      value: cat.isActive,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (v) {
                        _catService.toggleCategoryStatus(cat.id, cat.isActive);
                      },
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF475569)),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  onSelected: (action) {
                    if (action == 'edit') {
                      _openAddOrEditCategoryModal(categoryToEdit: cat);
                    } else if (action == 'up' && index > 0) {
                      _catService.reorderCategoriesByIndex(index, index - 1);
                    } else if (action == 'down' && index < totalCount - 1) {
                      _catService.reorderCategoriesByIndex(index, index + 2);
                    } else if (action == 'toggle') {
                      _catService.toggleCategoryStatus(cat.id, cat.isActive);
                    } else if (action == 'delete') {
                      _deleteCategory(cat);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 18, color: Color(0xFF6366F1)),
                          SizedBox(width: 10),
                          Text('Edit Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    ),
                    if (index > 0)
                      const PopupMenuItem(
                        value: 'up',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward_rounded, size: 18, color: Color(0xFF475569)),
                            SizedBox(width: 10),
                            Text('Move Up', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ),
                    if (index < totalCount - 1)
                      const PopupMenuItem(
                        value: 'down',
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward_rounded, size: 18, color: Color(0xFF475569)),
                            SizedBox(width: 10),
                            Text('Move Down', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          SizedBox(width: 10),
                          Text('Delete Category', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// ADD OR EDIT WORKOUT CATEGORY MODAL (WITH R2 PICKER FOR IMAGE, GIF, VIDEO)
// ----------------------------------------------------------------------
class _AddOrEditWorkoutCategoryModal extends StatefulWidget {
  final WorkoutCategoryModel? categoryToEdit;
  final VoidCallback onSaved;

  const _AddOrEditWorkoutCategoryModal({
    this.categoryToEdit,
    required this.onSaved,
  });

  @override
  State<_AddOrEditWorkoutCategoryModal> createState() => _AddOrEditWorkoutCategoryModalState();
}

class _AddOrEditWorkoutCategoryModalState extends State<_AddOrEditWorkoutCategoryModal> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _orderCtrl;
  String _selectedMediaType = 'image'; // 'image' | 'gif' | 'video'
  String _mediaUrl = '';
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.categoryToEdit;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _orderCtrl = TextEditingController(text: (c?.sortOrder ?? 1).toString());
    _selectedMediaType = c?.mediaType ?? 'image';
    _mediaUrl = c?.mediaUrl ?? '';
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  void _openR2MediaPicker() {
    R2MediaLibraryPickerModal.show(
      context,
      onImageSelected: (url) {
        setState(() {
          _mediaUrl = url;
          // Auto-detect media type if possible
          final lower = url.toLowerCase();
          if (lower.endsWith('.gif')) {
            _selectedMediaType = 'gif';
          } else if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.webm')) {
            _selectedMediaType = 'video';
          }
        });
      },
    );
  }

  Future<void> _uploadDirectMedia({required bool isVideo}) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? file;
      if (isVideo) {
        try {
          file = await picker.pickVideo(source: ImageSource.gallery);
        } catch (_) {}
        file ??= await picker.pickMedia();
      } else {
        try {
          file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
        } catch (_) {}
        file ??= await picker.pickMedia();
      }

      if (file != null) {
        setState(() => _isSaving = true);
        final bytes = await file.readAsBytes();
        final uploadedUrl = await CategoryBackendService().uploadRawImageToR2(
          fileName: file.name,
          imageBytes: bytes,
        );
        if (uploadedUrl != null && mounted) {
          setState(() {
            _mediaUrl = uploadedUrl;
            final lower = uploadedUrl.toLowerCase();
            if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.webm')) {
              _selectedMediaType = 'video';
            } else if (lower.endsWith('.gif')) {
              _selectedMediaType = 'gif';
            } else {
              _selectedMediaType = 'image';
            }
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: isVideo ? const Color(0xFF0284C7) : const Color(0xFF10B981),
              content: Text(isVideo ? '🎬 Video uploaded to R2 successfully!' : '✅ Image uploaded to R2 successfully!'),
            ),
          );
        } else {
          if (mounted) setState(() => _isSaving = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    final service = WorkoutCategoryBackendService();
    bool success = false;
    final sortVal = int.tryParse(_orderCtrl.text.trim()) ?? 1;

    if (widget.categoryToEdit != null) {
      final updated = widget.categoryToEdit!;
      updated.name = _nameCtrl.text.trim();
      updated.description = _descCtrl.text.trim();
      updated.mediaType = _selectedMediaType;
      updated.mediaUrl = _mediaUrl;
      updated.sortOrder = sortVal;
      updated.isActive = _isActive;
      success = await service.updateCategory(updated);
    } else {
      final newCat = WorkoutCategoryModel(
        id: 'wcat_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        mediaType: _selectedMediaType,
        mediaUrl: _mediaUrl,
        sortOrder: sortVal,
        isActive: _isActive,
      );
      success = await service.createCategory(newCat);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        widget.onSaved();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.categoryToEdit != null;

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Edit Workout Category' : 'Add Workout Category',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              children: [
                const Text('Category Name', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Strength, HIIT, Yoga, Core',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Description (Optional)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                TextField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Hypertrophy, powerlifting & dumbbells',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Media Format', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMediaTypeOption('image', 'Image', Icons.image_rounded, const Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    _buildMediaTypeOption('gif', 'Animated GIF', Icons.gif_box_rounded, const Color(0xFFEC4899)),
                    const SizedBox(width: 10),
                    _buildMediaTypeOption('video', 'Video Loop', Icons.video_collection_rounded, const Color(0xFF0284C7)),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Media File (Cloudflare R2)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (_mediaUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.network(
                                    CategoryBackendService.getDisplayableImageUrl(_mediaUrl),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, _) => Container(
                                      width: 60,
                                      height: 60,
                                      color: const Color(0xFF0F172A),
                                      child: Icon(
                                        _selectedMediaType == 'video' ? Icons.play_arrow_rounded : Icons.broken_image_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  if (_selectedMediaType == 'video')
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0284C7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 10),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _selectedMediaType == 'video'
                                    ? Icons.video_collection_rounded
                                    : (_selectedMediaType == 'gif' ? Icons.gif_box_rounded : Icons.image_rounded),
                                color: Colors.grey.shade500,
                                size: 28,
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _mediaUrl.isEmpty
                                      ? 'No media selected yet'
                                      : _mediaUrl.split('/').last.split('?').first,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _mediaUrl.isEmpty
                                      ? 'Upload a video (.mp4), GIF, or image to Cloudflare R2'
                                      : 'Attached to this workout category',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _openR2MediaPicker,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            icon: const Icon(Icons.cloud_done_rounded, color: Color(0xFFF59E0B), size: 16),
                            label: const Text('Browse R2 Library', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFFF59E0B))),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : () => _uploadDirectMedia(isVideo: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            icon: const Icon(Icons.videocam_rounded, size: 16),
                            label: const Text('Upload Video (MP4/MOV)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isSaving ? null : () => _uploadDirectMedia(isVideo: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            icon: const Icon(Icons.image_rounded, size: 16),
                            label: const Text('Upload Image/GIF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Sort Order / Index', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                TextField(
                  controller: _orderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 1',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active (Visible in Workout Tab)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  value: _isActive,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(isEdit ? 'Save Changes' : 'Create Category', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMediaTypeOption(String typeKey, String label, IconData icon, Color color) {
    final isSelected = _selectedMediaType == typeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMediaType = typeKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? color : const Color(0xFF64748B), size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? color : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
