import 'package:flutter/material.dart';
import '../services/workout_layout_backend_service.dart';
import '../services/category_backend_service.dart';
import '../services/workout_category_backend_service.dart';
import '../services/banners_backend_service.dart';
import '../services/fitness_cms_backend_service.dart';
import '../services/workout_banners_backend_service.dart';
import 'r2_media_library_picker_modal.dart';

class FitnessWorkoutLayoutView extends StatefulWidget {
  final String selectedDateRange;
  final List<Animation<double>> fadeAnimations;
  final List<Animation<Offset>> slideAnimations;

  const FitnessWorkoutLayoutView({
    super.key,
    required this.selectedDateRange,
    required this.fadeAnimations,
    required this.slideAnimations,
  });

  @override
  State<FitnessWorkoutLayoutView> createState() => _FitnessWorkoutLayoutViewState();
}

class _FitnessWorkoutLayoutViewState extends State<FitnessWorkoutLayoutView> {
  final WorkoutLayoutBackendService _layoutService = WorkoutLayoutBackendService();
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _layoutService.addListener(_onUpdate);
    _layoutService.fetchLayoutSections();
  }

  @override
  void dispose() {
    _layoutService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _openAddOrEditSectionModal({WorkoutLayoutSectionModel? sectionToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddOrEditWorkoutSectionModal(
        sectionToEdit: sectionToEdit,
        onSaved: () => setState(() {}),
      ),
    );
  }

  void _openPhonePreview() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => _WorkoutPhoneMockupPreviewDialog(
        sections: _layoutService.activeSections,
      ),
    );
  }

  void _deleteSection(WorkoutLayoutSectionModel s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Section?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to remove "${s.title}" from the workout layout?'),
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
              _layoutService.deleteSection(s.id);
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

    final allSections = _layoutService.sections;
    final totalActive = _layoutService.activeSections.length;

    final filteredSections = allSections.where((s) {
      if (_filterType == 'all') return true;
      if (_filterType == 'banners') return s.type == 'hero_banners' || s.type == 'custom_banner';
      if (_filterType == 'categories') return s.type == 'categories';
      if (_filterType == 'programs') return s.type == 'popular_programs';
      if (_filterType == 'spotlight') return s.type == 'bento_spotlight';
      return s.type == _filterType;
    }).toList();

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER BANNER (Exact UI from screenshot)
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
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.dashboard_customize_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Workout Tab Layout CMS',
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
                                    '$totalActive of ${allSections.length} Sections Live in App',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Live Phone Preview Button
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                              backgroundColor: Colors.white.withValues(alpha: 0.05),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _openPhonePreview,
                            icon: const Icon(Icons.phone_iphone_rounded, size: 16, color: Color(0xFF38BDF8)),
                            label: const Text('Live Phone Preview', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 8),
                          // Add Section Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                            onPressed: () => _openAddOrEditSectionModal(),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add Section', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterBadge('All (${allSections.length})', 'all', Icons.grid_view_rounded, const Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        _buildFilterBadge('Banners (${allSections.where((s) => s.type == 'hero_banners' || s.type == 'custom_banner').length})', 'banners', Icons.view_carousel_rounded, const Color(0xFFEC4899)),
                        const SizedBox(width: 8),
                        _buildFilterBadge('Categories (${allSections.where((s) => s.type == 'categories').length})', 'categories', Icons.category_rounded, const Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        _buildFilterBadge('Programs (${allSections.where((s) => s.type == 'popular_programs').length})', 'programs', Icons.calendar_today_rounded, const Color(0xFF3B82F6)),
                        const SizedBox(width: 8),
                        _buildFilterBadge('Spotlight (${allSections.where((s) => s.type == 'bento_spotlight').length})', 'spotlight', Icons.dashboard_rounded, const Color(0xFF10B981)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. REORDER INFO STRIP (Exact UI from screenshot)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.swap_vert_rounded, color: Color(0xFF3B82F6), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Use Up/Down arrows to reorder sections. Updates sync to MongoDB Atlas in real-time.',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. SECTIONS LIST
            _layoutService.isLoading && allSections.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Color(0xFF10B981)),
                    ),
                  )
                : filteredSections.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredSections.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildExactSectionCard(
                          filteredSections[index],
                          index,
                          filteredSections.length,
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
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.dashboard_customize_outlined, size: 44, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 14),
          const Text('No Sections Found', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          const Text('Tap "+ Add Section" to build your custom dynamic workout layout.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  // =========================================================================
  // EXACT SECTION CARD (Matching User Screenshot 100%)
  // =========================================================================
  Widget _buildExactSectionCard(WorkoutLayoutSectionModel s, int index, int totalCount) {
    Color typeColor = const Color(0xFFEC4899);
    IconData typeIcon = Icons.view_carousel_rounded;
    String typeLabel = 'BANNERS';

    if (s.type == 'categories') {
      typeColor = const Color(0xFFF59E0B);
      typeIcon = Icons.category_rounded;
      typeLabel = 'CATEGORIES';
    } else if (s.type == 'popular_programs') {
      typeColor = const Color(0xFF3B82F6);
      typeIcon = Icons.calendar_today_rounded;
      typeLabel = 'PROGRAMS';
    } else if (s.type == 'bento_spotlight') {
      typeColor = const Color(0xFF8B5CF6);
      typeIcon = Icons.dashboard_rounded;
      typeLabel = 'SPOTLIGHT';
    } else if (s.type == 'muscle_groups') {
      typeColor = const Color(0xFF10B981);
      typeIcon = Icons.accessibility_new_rounded;
      typeLabel = 'MUSCLE GROUPS';
    } else if (s.type == 'celebrity_coaches') {
      typeColor = const Color(0xFFEA580C);
      typeIcon = Icons.sports_rounded;
      typeLabel = 'COACHES';
    } else if (s.type == 'equipment_training') {
      typeColor = const Color(0xFF0284C7);
      typeIcon = Icons.sports_gymnastics_rounded;
      typeLabel = 'EQUIPMENT';
    } else if (s.type == 'trending_challenges') {
      typeColor = const Color(0xFFEF4444);
      typeIcon = Icons.emoji_events_rounded;
      typeLabel = 'CHALLENGES';
    } else if (s.type == 'audio_beats') {
      typeColor = const Color(0xFF14B8A6);
      typeIcon = Icons.graphic_eq_rounded;
      typeLabel = 'MUSIC BEATS';
    }

    final isCarousel = s.layoutMode == 'carousel' || s.layoutMode == 'hero_carousel';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: s.isActive ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          width: s.isActive ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: s.isActive ? 0.03 : 0.01),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Order Index & Up/Down Reorder Arrows
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index > 0)
                      GestureDetector(
                        onTap: () => _layoutService.reorderSectionsByIndex(index, index - 1),
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
                          colors: s.isActive
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
                        onTap: () => _layoutService.reorderSectionsByIndex(index, index + 2),
                        child: const Icon(Icons.arrow_drop_down_rounded, size: 22, color: Color(0xFF64748B)),
                      )
                    else
                      const SizedBox(height: 18),
                  ],
                ),
                const SizedBox(width: 10),

                // Component Type Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 22),
                ),
                const SizedBox(width: 12),

                // Section Details
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isCarousel ? Icons.swipe_rounded : Icons.grid_view_rounded, size: 9, color: const Color(0xFF0F172A)),
                                const SizedBox(width: 3),
                                Text(
                                  s.layoutMode.toUpperCase(),
                                  style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                          ),
                          if (!s.showTitle)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF64748B).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('HEADING HIDDEN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.title.isNotEmpty ? s.title : 'Untitled Section',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          color: s.isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (s.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          s.subtitle,
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
                          value: s.isActive,
                          activeColor: const Color(0xFF10B981),
                          onChanged: (v) {
                            _layoutService.toggleSectionStatus(s.id, s.isActive);
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
                          _openAddOrEditSectionModal(sectionToEdit: s);
                        } else if (action == 'preview') {
                          _openPhonePreview();
                        } else if (action == 'up' && index > 0) {
                          _layoutService.reorderSectionsByIndex(index, index - 1);
                        } else if (action == 'down' && index < totalCount - 1) {
                          _layoutService.reorderSectionsByIndex(index, index + 2);
                        } else if (action == 'toggle') {
                          _layoutService.toggleSectionStatus(s.id, s.isActive);
                        } else if (action == 'delete') {
                          _deleteSection(s);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.tune_rounded, size: 18, color: Color(0xFF6366F1)),
                              SizedBox(width: 10),
                              Text('Edit Section', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'preview',
                          child: Row(
                            children: [
                              Icon(Icons.phone_iphone_rounded, size: 18, color: Color(0xFF0284C7)),
                              SizedBox(width: 10),
                              Text('Live App Preview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
                              Text('Delete Section', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFEF4444))),
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

          // Mini Visual Content Preview Strip (Scrollable to prevent any overflow)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(19)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Live Preview:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  const SizedBox(width: 8),
                  _buildSectionMiniThumbnails(s),
                  const SizedBox(width: 10),
                  Text(
                    _buildConfigSummary(s),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionMiniThumbnails(WorkoutLayoutSectionModel s) {
    if (s.type == 'hero_banners' || s.type == 'custom_banner') {
      final banners = [
        CategoryBackendService.getDisplayableImageUrl('workout_banner_1.png'),
        CategoryBackendService.getDisplayableImageUrl('workout_banner_2.png'),
        CategoryBackendService.getDisplayableImageUrl('workout_banner_3.png'),
        CategoryBackendService.getDisplayableImageUrl('workout_banner_4.png'),
      ];
      return SizedBox(
        height: 32,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: banners.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            return Container(
              width: 58,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                image: DecorationImage(
                  image: _resolveMedia(banners[i]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    } else if (s.type == 'categories') {
      final cats = [
        CategoryBackendService.getDisplayableImageUrl('workout_category_1.png'),
        CategoryBackendService.getDisplayableImageUrl('workout_category_2.jpg'),
        CategoryBackendService.getDisplayableImageUrl('workout_category_3.png'),
        CategoryBackendService.getDisplayableImageUrl('workout_category_4.png'),
        CategoryBackendService.getDisplayableImageUrl('workout_category_5.png'),
      ];
      return SizedBox(
        height: 32,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (ctx, i) {
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                image: DecorationImage(
                  image: _resolveMedia(cats[i]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    } else if (s.type == 'bento_spotlight') {
      final spots = [
        CategoryBackendService.getDisplayableImageUrl('spotlight_1.png'),
        CategoryBackendService.getDisplayableImageUrl('spotlight_2.png'),
        CategoryBackendService.getDisplayableImageUrl('spotlight_3.png'),
      ];
      return SizedBox(
        height: 32,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: spots.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (ctx, i) {
            return Container(
              width: 45,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                image: DecorationImage(
                  image: _resolveMedia(spots[i]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    } else {
      final sample = [
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=200&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=200&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=200&auto=format&fit=crop',
      ];
      return SizedBox(
        height: 32,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: sample.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (ctx, i) {
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  image: NetworkImage(sample[i]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  String _buildConfigSummary(WorkoutLayoutSectionModel s) {
    if (s.type == 'hero_banners') return '4 Banners';
    if (s.type == 'categories') return '5 Disciplines';
    if (s.type == 'bento_spotlight') return '3 Spotlight Splits';
    if (s.type == 'popular_programs') return '4 Featured Programs';
    if (s.type == 'muscle_groups') return '4 Muscle Targets';
    if (s.type == 'celebrity_coaches') return '3 Elite Coaches';
    if (s.type == 'equipment_training') return '4 Gear Sets';
    if (s.type == 'trending_challenges') return '2 Active Challenges';
    if (s.type == 'audio_beats') return '3 BPM Audio Tracks';
    return '${s.type} items';
  }

  ImageProvider _resolveMedia(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    return AssetImage('assets/images/$path');
  }
}

// ----------------------------------------------------------------------
// ADD OR EDIT WORKOUT SECTION MODAL WITH R2 MEDIA PICKER INTEGRATION
// ----------------------------------------------------------------------
class _AddOrEditWorkoutSectionModal extends StatefulWidget {
  final WorkoutLayoutSectionModel? sectionToEdit;
  final VoidCallback onSaved;

  const _AddOrEditWorkoutSectionModal({
    this.sectionToEdit,
    required this.onSaved,
  });

  @override
  State<_AddOrEditWorkoutSectionModal> createState() => _AddOrEditWorkoutSectionModalState();
}

class _AddOrEditWorkoutSectionModalState extends State<_AddOrEditWorkoutSectionModal> {
  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late TextEditingController _badgeCtrl;
  late TextEditingController _buttonTextCtrl;
  String _selectedType = 'popular_programs';
  String _selectedLayoutMode = 'carousel';
  String _customMediaUrl = '';
  List<String> _selectedCategoryIds = [];
  bool _showTitle = true;
  bool _isActive = true;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _sectionTypes = [
    {'type': 'hero_banners', 'label': 'Featured Hero Banners', 'icon': Icons.view_carousel_rounded},
    {'type': 'categories', 'label': 'Workout Categories', 'icon': Icons.grid_view_rounded},
    {'type': 'popular_programs', 'label': 'Popular Programs Carousel', 'icon': Icons.calendar_today_rounded},
    {'type': 'bento_spotlight', 'label': 'Workout Spotlight (Bento)', 'icon': Icons.dashboard_rounded},
    {'type': 'muscle_groups', 'label': 'Target Muscle Groups', 'icon': Icons.accessibility_new_rounded},
    {'type': 'celebrity_coaches', 'label': 'Elite Coaches', 'icon': Icons.sports_rounded},
    {'type': 'equipment_training', 'label': 'Workout by Equipment', 'icon': Icons.sports_gymnastics_rounded},
    {'type': 'trending_challenges', 'label': 'Trending Challenges', 'icon': Icons.emoji_events_rounded},
    {'type': 'audio_beats', 'label': 'Music-Synced Workouts', 'icon': Icons.graphic_eq_rounded},
    {'type': 'custom_banner', 'label': 'Custom Promo Banner Strip', 'icon': Icons.ad_units_rounded},
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.sectionToEdit;
    _titleCtrl = TextEditingController(text: s?.title ?? 'New Workout Section');
    _subtitleCtrl = TextEditingController(text: s?.subtitle ?? '');
    _badgeCtrl = TextEditingController(text: s?.customBannerBadge ?? '');
    _buttonTextCtrl = TextEditingController(text: s?.customBannerButtonText ?? 'Start Workout');
    _selectedType = s?.type ?? 'popular_programs';
    _selectedLayoutMode = s?.layoutMode ?? 'carousel';
    _customMediaUrl = s?.customBannerImageUrl ?? '';
    _selectedCategoryIds = List<String>.from(s?.selectedItemIds ?? []);
    _showTitle = s?.showTitle ?? true;
    _isActive = s?.isActive ?? true;

    WorkoutCategoryBackendService().fetchCategories();
    BannersBackendService().fetchBannersFromFirestore();
    FitnessCmsBackendService().fetchCmsItemsFromFirestore();
    WorkoutBannersBackendService().fetchWorkoutBanners();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _badgeCtrl.dispose();
    _buttonTextCtrl.dispose();
    super.dispose();
  }

  void _openR2MediaPicker() {
    R2MediaLibraryPickerModal.show(
      context,
      onImageSelected: (url) {
        setState(() => _customMediaUrl = url);
      },
    );
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    final service = WorkoutLayoutBackendService();
    bool success = false;

    final isMultiSelectable = _selectedType == 'categories' || _selectedType == 'hero_banners' || _selectedType == 'custom_banner';

    if (widget.sectionToEdit != null) {
      final updated = widget.sectionToEdit!;
      updated.title = _titleCtrl.text.trim();
      updated.subtitle = _subtitleCtrl.text.trim();
      updated.type = _selectedType;
      updated.layoutMode = _selectedLayoutMode;
      updated.selectedItemIds = isMultiSelectable ? _selectedCategoryIds : updated.selectedItemIds;
      updated.customBannerImageUrl = _customMediaUrl;
      updated.customBannerBadge = _badgeCtrl.text.trim();
      updated.customBannerButtonText = _buttonTextCtrl.text.trim();
      updated.showTitle = _showTitle;
      updated.isActive = _isActive;
      success = await service.updateSection(updated);
    } else {
      final newSec = WorkoutLayoutSectionModel(
        id: 'sec_workout_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim(),
        type: _selectedType,
        layoutMode: _selectedLayoutMode,
        selectedItemIds: isMultiSelectable ? _selectedCategoryIds : [],
        customBannerImageUrl: _customMediaUrl,
        customBannerBadge: _badgeCtrl.text.trim(),
        customBannerButtonText: _buttonTextCtrl.text.trim(),
        showTitle: _showTitle,
        isActive: _isActive,
      );
      success = await service.createSection(newSec);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        widget.onSaved();
        Navigator.pop(context);
      }
    }
  }

  Widget _buildCategoriesSelectionForm() {
    final catService = WorkoutCategoryBackendService();
    final categories = catService.categories;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.checklist_rounded, size: 18, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(
                    'Select Categories (${_selectedCategoryIds.length}/${categories.length})',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryIds = categories.map((c) => c.id).toList();
                      });
                    },
                    child: const Text('Select All', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoryIds.clear();
                      });
                    },
                    child: const Text('Clear', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFEF4444))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _selectedCategoryIds.isEmpty
                ? '💡 No categories selected yet. Tap to select which categories will appear in the Workout tab on user phones.'
                : '✅ ${_selectedCategoryIds.length} categories selected to appear in mobile app.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('No categories available. Please add categories in Categories sub-tab first.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategoryIds.contains(cat.id);
                final displayUrl = CategoryBackendService.getDisplayableImageUrl(cat.mediaUrl);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategoryIds.remove(cat.id);
                      } else {
                        _selectedCategoryIds.add(cat.id);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          activeColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedCategoryIds.add(cat.id);
                              } else {
                                _selectedCategoryIds.remove(cat.id);
                              }
                            });
                          },
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: displayUrl.isNotEmpty
                              ? Image.network(
                                  displayUrl,
                                  width: 38,
                                  height: 38,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 38,
                                    height: 38,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.category_rounded, size: 18, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  width: 38,
                                  height: 38,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.category_rounded, size: 18, color: Colors.grey),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cat.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      cat.mediaType.toUpperCase(),
                                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                              if (cat.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  cat.description,
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${cat.sortOrder}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBannersSelectionForm() {
    final List<BannerModel> allBanners = [
      ...WorkoutBannersBackendService().banners.map((wb) => BannerModel(
            bannerId: wb.bannerId,
            id: wb.id,
            title: wb.title,
            subtitle: wb.subtitle,
            imageUrl: wb.imageUrl,
            mediaType: wb.mediaType,
            showTitle: wb.showTitle,
            sortOrder: wb.sortOrder,
            isActive: wb.isActive,
          )),
      ...FitnessCmsBackendService().banners.map((cms) => BannerModel(
            bannerId: cms.itemId,
            id: cms.id,
            title: cms.title,
            subtitle: cms.subtitle,
            imageUrl: cms.imageUrl,
            mediaType: cms.imageUrl.toLowerCase().endsWith('.mp4') || cms.imageUrl.toLowerCase().endsWith('.mov') || cms.imageUrl.toLowerCase().endsWith('.webm')
                ? 'video'
                : (cms.imageUrl.toLowerCase().endsWith('.gif') ? 'gif' : 'image'),
            showTitle: true,
            sortOrder: cms.sortOrder,
            isActive: cms.isActive,
          )),
    ];
    final banners = allBanners.where((b) => b.isActive).toList();
    final isAllSelected = banners.isNotEmpty && banners.every((b) => _selectedCategoryIds.contains(b.bannerId) || _selectedCategoryIds.contains(b.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.view_carousel_rounded, size: 18, color: Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  Text(
                    'Select Hero Banners (${_selectedCategoryIds.length}/${banners.length} Selected)',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (isAllSelected) {
                          _selectedCategoryIds.clear();
                        } else {
                          _selectedCategoryIds = banners.map((b) => b.bannerId.isNotEmpty ? b.bannerId : b.id).toList();
                        }
                      });
                    },
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                    child: Text(
                      isAllSelected ? 'Clear All' : 'Select All',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Check the banners you want to feature in this layout section. Supports Video, GIF & Image formats.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          if (banners.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text('No Banners found. Add banners in Fitness -> CMS & Banners tab.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: banners.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ban = banners[index];
                final bId = ban.bannerId.isNotEmpty ? ban.bannerId : ban.id;
                final isSelected = _selectedCategoryIds.contains(bId);
                final displayUrl = CategoryBackendService.getDisplayableImageUrl(ban.imageUrl);
                final isVideo = ban.mediaType == 'video' || ban.imageUrl.toLowerCase().endsWith('.mp4') || ban.imageUrl.toLowerCase().endsWith('.mov');

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategoryIds.remove(bId);
                      } else {
                        _selectedCategoryIds.add(bId);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isSelected,
                          activeColor: const Color(0xFF0284C7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedCategoryIds.add(bId);
                              } else {
                                _selectedCategoryIds.remove(bId);
                              }
                            });
                          },
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isVideo
                              ? Container(
                                  width: 44,
                                  height: 38,
                                  color: const Color(0xFF0F172A),
                                  child: const Center(
                                    child: Icon(Icons.play_arrow_rounded, color: Color(0xFF38BDF8), size: 20),
                                  ),
                                )
                              : (displayUrl.isNotEmpty
                                  ? Image.network(
                                      displayUrl,
                                      width: 44,
                                      height: 38,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, _) => Container(
                                        width: 44,
                                        height: 38,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image, size: 18, color: Colors.grey),
                                      ),
                                    )
                                  : Container(
                                      width: 44,
                                      height: 38,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.view_carousel_rounded, size: 18, color: Colors.grey),
                                    )),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ban.title.isNotEmpty ? ban.title : 'Banner Item',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: isVideo
                                          ? const Color(0xFF0284C7)
                                          : (ban.mediaType == 'gif' ? const Color(0xFFEC4899) : const Color(0xFF10B981)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      ban.mediaType.toUpperCase(),
                                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              if (ban.subtitle.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  ban.subtitle,
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${ban.sortOrder}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.sectionToEdit != null;

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
                isEdit ? 'Edit Workout Section' : 'Add Workout Section',
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
                const Text('Section Type', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _sectionTypes.map((t) {
                    return DropdownMenuItem<String>(
                      value: t['type'] as String,
                      child: Row(
                        children: [
                          Icon(t['icon'] as IconData, size: 18, color: const Color(0xFF10B981)),
                          const SizedBox(width: 10),
                          Text(t['label'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 16),

                const Text('Section Title', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Workout Categories or Training Disciplines',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Section Subtitle', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                TextField(
                  controller: _subtitleCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Browse by training discipline',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                if (_selectedType == 'categories') ...[
                  _buildCategoriesSelectionForm(),
                  const SizedBox(height: 16),
                ] else if (_selectedType == 'hero_banners' || _selectedType == 'custom_banner') ...[
                  _buildBannersSelectionForm(),
                  const SizedBox(height: 16),
                ] else ...[
                  const Text('Media Attachment (R2 Image, GIF, Video)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_customMediaUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            CategoryBackendService.getDisplayableImageUrl(_customMediaUrl),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 20),
                            ),
                          ),
                        ),
                      if (_customMediaUrl.isNotEmpty) const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openR2MediaPicker,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF10B981)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF10B981)),
                          label: Text(
                            _customMediaUrl.isEmpty ? 'Select Media from R2 Library' : 'Change R2 Media',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show Heading on Screen', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  value: _showTitle,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (val) => setState(() => _showTitle = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active (Visible in App)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
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
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(isEdit ? 'Save Changes' : 'Create Section', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}
}

// ----------------------------------------------------------------------
// LIVE PHONE MOCKUP PREVIEW DIALOG FOR WORKOUT TAB
// ----------------------------------------------------------------------
class _WorkoutPhoneMockupPreviewDialog extends StatelessWidget {
  final List<WorkoutLayoutSectionModel> sections;

  const _WorkoutPhoneMockupPreviewDialog({required this.sections});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Center(
        child: Container(
          width: 380,
          height: 720,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: const Color(0xFF0F172A), width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                height: 36,
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Workout Tab', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final s = sections[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.title,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s.type,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 65,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Center(
                              child: Text(
                                '${s.layoutMode} • Live Shimmer Preview',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
