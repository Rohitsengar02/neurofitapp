import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/workouts_backend_service.dart';
import '../services/workout_category_backend_service.dart';
import '../services/exercise_category_backend_service.dart';
import '../services/exercises_backend_service.dart' hide ExerciseCategoryModel;
import '../services/category_backend_service.dart';
import 'r2_media_library_picker_modal.dart';
import 'skeleton_loader.dart';
import 'exercise_media_widget.dart';

class FitnessWorkoutsView extends StatefulWidget {
  final String selectedDateRange;
  final List<Animation<double>> fadeAnimations;
  final List<Animation<Offset>> slideAnimations;

  const FitnessWorkoutsView({
    super.key,
    required this.selectedDateRange,
    required this.fadeAnimations,
    required this.slideAnimations,
  });

  @override
  State<FitnessWorkoutsView> createState() => _FitnessWorkoutsViewState();
}

class _FitnessWorkoutsViewState extends State<FitnessWorkoutsView> {
  final WorkoutsBackendService _workoutsService = WorkoutsBackendService();
  final WorkoutCategoryBackendService _workoutCategoryService = WorkoutCategoryBackendService();
  final ExerciseCategoryBackendService _exerciseCategoryService = ExerciseCategoryBackendService();
  final ExercisesBackendService _exercisesService = ExercisesBackendService();

  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _workoutsService.addListener(_onServiceUpdate);
    _workoutCategoryService.addListener(_onServiceUpdate);
    _exerciseCategoryService.addListener(_onServiceUpdate);
    _exercisesService.addListener(_onServiceUpdate);

    if (_workoutsService.workouts.isEmpty) {
      _workoutsService.fetchWorkouts();
    }
    if (_workoutCategoryService.categories.isEmpty) {
      _workoutCategoryService.fetchCategories();
    }
    if (_exerciseCategoryService.categories.isEmpty) {
      _exerciseCategoryService.fetchCategories();
    }
    if (_exercisesService.exercises.isEmpty) {
      _exercisesService.fetchExercises();
    }
  }

  @override
  void dispose() {
    _workoutsService.removeListener(_onServiceUpdate);
    _workoutCategoryService.removeListener(_onServiceUpdate);
    _exerciseCategoryService.removeListener(_onServiceUpdate);
    _exercisesService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _openAddWorkoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddOrEditWorkoutSheet(
        onSaved: () => setState(() {}),
      ),
    );
  }

  void _openEditWorkoutSheet(WorkoutModel workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddOrEditWorkoutSheet(
        workout: workout,
        onSaved: () => setState(() {}),
      ),
    );
  }

  void _openManageDaysSheet(WorkoutModel workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManageWorkoutDaysSheet(workout: workout),
    );
  }

  void _confirmDeleteWorkout(WorkoutModel workout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workout Plan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Text('Are you sure you want to delete "${workout.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _workoutsService.deleteWorkout(workout.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Workout "${workout.title}" deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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

    final categories = _workoutCategoryService.categories;
    final workouts = _workoutsService.workouts.where((w) {
      final matchesCat = _selectedCategoryFilter == 'All' ||
          w.category == _selectedCategoryFilter ||
          w.workoutCategoryId == _selectedCategoryFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          w.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.coach.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Search & Create Button
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: 'Search workouts, coaches, muscle targets...',
                        hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _openAddWorkoutSheet,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Workout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Workout Categories Filter Bar (Workout Category, NOT Exercise Category)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        'All Plans (${_workoutsService.workouts.length})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _selectedCategoryFilter == 'All' ? FontWeight.w800 : FontWeight.w600,
                          color: _selectedCategoryFilter == 'All' ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                      selected: _selectedCategoryFilter == 'All',
                      selectedColor: const Color(0xFF10B981),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: _selectedCategoryFilter == 'All' ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategoryFilter = 'All');
                      },
                    ),
                  ),
                  ...categories.map((cat) {
                    final isSelected = _selectedCategoryFilter == cat.name || _selectedCategoryFilter == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF10B981),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategoryFilter = cat.name);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Workouts Grid View
            if (_workoutsService.isLoading && _workoutsService.workouts.isEmpty)
              const SkeletonCardGrid(count: 4, childAspectRatio: 0.72)
            else if (workouts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.fitness_center_rounded, color: Color(0xFF94A3B8), size: 40),
                    const SizedBox(height: 12),
                    const Text('No Workouts Found', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    const Text('Click "+ Add Workout" above to create your first workout plan.', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final w = workouts[index];
                  final isVideo = w.mediaType == 'video' || w.imageUrl.toLowerCase().endsWith('.mp4') || w.imageUrl.toLowerCase().endsWith('.mov');

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover Media Stack
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: const Color(0xFF0F172A),
                                child: isVideo
                                    ? const Center(
                                        child: Icon(Icons.play_arrow_rounded, color: Color(0xFF38BDF8), size: 36),
                                      )
                                    : Image.network(
                                        CategoryBackendService.getDisplayableImageUrl(w.imageUrl),
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Center(
                                          child: Icon(Icons.fitness_center_rounded, color: Colors.white70, size: 32),
                                        ),
                                      ),
                              ),
                              // Status pill
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: w.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    w.isActive ? 'ACTIVE' : 'DEACTIVE',
                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                              // Manage Days, Edit & Delete Action Buttons
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _openManageDaysSheet(w),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6366F1),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 10),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${w.days.length} Days',
                                              style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _openEditWorkoutSheet(w),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), shape: BoxShape.circle),
                                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _confirmDeleteWorkout(w),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.8), shape: BoxShape.circle),
                                        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Duration pill
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(5)),
                                  child: Text('⏱️ ${w.durationMinutes} Mins', style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Card Text Info
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w.category.toUpperCase(),
                                style: const TextStyle(color: Color(0xFF6366F1), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                w.title,
                                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12.5, fontWeight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('🔥 ${w.caloriesBurn} kcal', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 10.5, fontWeight: FontWeight.w800)),
                                  Text('${w.exercises.isNotEmpty ? w.exercises.length : w.exercisesCount} Moves', style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 📝 CREATE & EDIT WORKOUT SLIDER SHEET
// =========================================================================
class _AddOrEditWorkoutSheet extends StatefulWidget {
  final WorkoutModel? workout;
  final VoidCallback onSaved;

  const _AddOrEditWorkoutSheet({this.workout, required this.onSaved});

  @override
  State<_AddOrEditWorkoutSheet> createState() => _AddOrEditWorkoutSheetState();
}

class _AddOrEditWorkoutSheetState extends State<_AddOrEditWorkoutSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _caloriesCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _coachCtrl;
  late TextEditingController _tagInputCtrl;

  String _selectedWorkoutCategoryId = '';
  String _selectedWorkoutCategoryName = 'General';
  String _level = 'Intermediate';
  bool _isActive = true;
  bool _isFeatured = true;

  String? _selectedR2Url;
  Uint8List? _localImageBytes;
  XFile? _localImageFile;

  List<String> _tags = [];
  List<WorkoutExerciseModel> _selectedExercises = [];
  final Set<String> _selectedExerciseIds = {};
  final Map<String, WorkoutExerciseModel> _selectedExerciseMap = {};

  // Exercise Filter State
  String _selectedExerciseCategoryFilter = 'All';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final w = widget.workout;
    _titleCtrl = TextEditingController(text: w?.title ?? '');
    _subtitleCtrl = TextEditingController(text: w?.subtitle ?? '');
    _descCtrl = TextEditingController(text: w?.description ?? '');
    _caloriesCtrl = TextEditingController(text: (w?.caloriesBurn ?? 350).toString());
    _durationCtrl = TextEditingController(text: (w?.durationMinutes ?? 45).toString());
    _coachCtrl = TextEditingController(text: w?.coach ?? 'Coach Vikram');
    _tagInputCtrl = TextEditingController();

    _selectedWorkoutCategoryId = w?.workoutCategoryId ?? '';
    _selectedWorkoutCategoryName = w?.category ?? 'General';
    _level = w?.level ?? 'Intermediate';
    _isActive = w?.isActive ?? true;
    _isFeatured = w?.isFeatured ?? true;
    _selectedR2Url = w?.imageUrl;

    _tags = List.from(w?.tags ?? ['Fat Loss', 'Muscle Mass']);
    _selectedExercises = List.from(w?.exercises ?? []);

    for (var ex in _selectedExercises) {
      _selectedExerciseIds.add(ex.exerciseId);
      _selectedExerciseMap[ex.exerciseId] = ex;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _descCtrl.dispose();
    _caloriesCtrl.dispose();
    _durationCtrl.dispose();
    _coachCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  void _openR2Picker() {
    R2MediaLibraryPickerModal.show(
      context,
      onImageSelected: (url) {
        setState(() {
          _selectedR2Url = url;
          _localImageBytes = null;
          _localImageFile = null;
        });
      },
    );
  }

  void _pickLocalImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _localImageFile = file;
        _localImageBytes = bytes;
        _selectedR2Url = null;
      });
    }
  }

  void _addTag() {
    final text = _tagInputCtrl.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagInputCtrl.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  void _toggleExercise(ExerciseModel ex) {
    setState(() {
      final targetId = ex.exerciseId.isNotEmpty ? ex.exerciseId : ex.id;
      final isSel = _selectedExerciseIds.contains(targetId) ||
          _selectedExerciseIds.contains(ex.id) ||
          _selectedExerciseIds.contains(ex.exerciseId);

      if (isSel) {
        _selectedExerciseIds.remove(targetId);
        _selectedExerciseIds.remove(ex.id);
        _selectedExerciseIds.remove(ex.exerciseId);
        _selectedExerciseMap.remove(targetId);
        _selectedExerciseMap.remove(ex.id);
        _selectedExerciseMap.remove(ex.exerciseId);
        _selectedExercises.removeWhere((e) => e.exerciseId == targetId || e.exerciseId == ex.id || e.exerciseId == ex.exerciseId);
      } else {
        final newModel = WorkoutExerciseModel(
          exerciseId: targetId,
          title: ex.title,
          categoryId: ex.categoryId,
          muscleGroup: ex.muscleGroup.isNotEmpty ? ex.muscleGroup : ex.bodyPart,
          mediaUrl: ex.displayMediaUrl,
          mediaType: ex.mediaType,
          sets: 3,
          reps: 12,
          durationSeconds: 0,
          restSeconds: 45,
          instructions: ex.instructionText.isNotEmpty ? ex.instructionText : ex.instructions,
        );
        _selectedExercises.add(newModel);
        _selectedExerciseIds.add(targetId);
        _selectedExerciseMap[targetId] = newModel;
      }
    });
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    String imageUrl = _selectedR2Url ?? (widget.workout?.imageUrl ?? '');

    if (_localImageBytes != null && _localImageFile != null) {
      final uploaded = await CategoryBackendService().uploadRawImageToR2(
        imageBytes: _localImageBytes!,
        fileName: _localImageFile!.name,
      );
      if (uploaded != null) imageUrl = uploaded;
    }

    final isVid = imageUrl.toLowerCase().endsWith('.mp4') || imageUrl.toLowerCase().endsWith('.mov') || imageUrl.toLowerCase().endsWith('.webm');
    final isGif = imageUrl.toLowerCase().endsWith('.gif');
    final mType = isVid ? 'video' : (isGif ? 'gif' : 'image');

    final wId = widget.workout?.id ?? 'workout_${DateTime.now().millisecondsSinceEpoch}';

    final updatedWorkout = WorkoutModel(
      id: wId,
      title: _titleCtrl.text.trim(),
      subtitle: _subtitleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _selectedWorkoutCategoryName,
      workoutCategoryId: _selectedWorkoutCategoryId,
      caloriesBurn: int.tryParse(_caloriesCtrl.text.trim()) ?? 350,
      durationMinutes: int.tryParse(_durationCtrl.text.trim()) ?? 45,
      level: _level,
      coach: _coachCtrl.text.trim(),
      imageUrl: imageUrl,
      mediaType: mType,
      exercisesCount: _selectedExercises.length,
      completionRate: widget.workout?.completionRate ?? 92.0,
      rating: widget.workout?.rating ?? 4.9,
      tags: _tags,
      exercises: _selectedExercises,
      isFeatured: _isFeatured,
      isActive: _isActive,
    );

    if (widget.workout == null) {
      await WorkoutsBackendService().createWorkout(updatedWorkout);
    } else {
      await WorkoutsBackendService().updateWorkout(updatedWorkout.id, updatedWorkout);
    }

    widget.onSaved();
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workout "${updatedWorkout.title}" saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutCategories = WorkoutCategoryBackendService().categories;
    final dbExerciseCategories = ExerciseCategoryBackendService().categories;
    final exercises = ExercisesBackendService().exercises;

    final filteredExercises = exercises.where((ex) {
      if (_selectedExerciseCategoryFilter == 'All') return true;
      return ex.categoryId == _selectedExerciseCategoryFilter;
    }).toList();

    final isEdit = widget.workout != null;
    final currentCoverUrl = _selectedR2Url ?? widget.workout?.imageUrl ?? '';
    final isCoverVideo = currentCoverUrl.toLowerCase().endsWith('.mp4') || currentCoverUrl.toLowerCase().endsWith('.mov');

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.90,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(child: Container(width: 44, height: 4.5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 14),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Workout Plan' : 'Create New Workout',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEdit ? 'ID: ${widget.workout!.id}' : 'Configure workout plan & linked movements',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),

            // Form Body with Virtualized Lazy Scrolling
            Expanded(
              child: Form(
                key: _formKey,
                child: CustomScrollView(
                  cacheExtent: 300,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Cover Media Picker
                            const Text('Workout Cover Media', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A))),
                            const SizedBox(height: 8),
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (_localImageBytes != null)
                                    Image.memory(_localImageBytes!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                                  else if (currentCoverUrl.isNotEmpty)
                                    isCoverVideo
                                        ? const Center(child: Icon(Icons.play_arrow_rounded, color: Color(0xFF38BDF8), size: 48))
                                        : Image.network(
                                            CategoryBackendService.getDisplayableImageUrl(currentCoverUrl),
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                                          )
                                  else
                                    const Center(child: Icon(Icons.fitness_center_rounded, color: Colors.white54, size: 40)),
                                  // Pick Overlay
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _openR2Picker,
                                          icon: const Icon(Icons.cloud_done_rounded, size: 14),
                                          label: const Text('Pick from R2 Media', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0284C7),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                          onPressed: _pickLocalImage,
                                          icon: const Icon(Icons.upload_file_rounded, size: 14),
                                          label: const Text('Upload File', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            side: const BorderSide(color: Colors.white),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2. Workout Title & Subtitle
                            TextFormField(
                              controller: _titleCtrl,
                              decoration: InputDecoration(
                                labelText: 'Workout Title',
                                hintText: 'e.g. 21-Day Shred & Tone Challenge',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _subtitleCtrl,
                              decoration: InputDecoration(
                                labelText: 'Subtitle (Optional)',
                                hintText: 'e.g. Burn 450+ Calories in 30 Mins',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 3. Description
                            TextFormField(
                              controller: _descCtrl,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Detailed Description',
                                hintText: 'Describe targeted muscle groups, intensity, and equipment needed...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 4. WORKOUT CATEGORY
                            DropdownButtonFormField<String>(
                              initialValue: workoutCategories.any((c) => c.name == _selectedWorkoutCategoryName || c.id == _selectedWorkoutCategoryId)
                                  ? (workoutCategories.firstWhere((c) => c.name == _selectedWorkoutCategoryName || c.id == _selectedWorkoutCategoryId).id)
                                  : (workoutCategories.isNotEmpty ? workoutCategories.first.id : null),
                              decoration: InputDecoration(
                                labelText: 'Workout Category (Workout Session Type)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              items: workoutCategories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat.id,
                                  child: Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final selectedCat = workoutCategories.firstWhere((c) => c.id == val);
                                  setState(() {
                                    _selectedWorkoutCategoryId = selectedCat.id;
                                    _selectedWorkoutCategoryName = selectedCat.name;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 14),

                            // 5. Calories Burn, Duration, Coach, Level
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _caloriesCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Calories Burn (kcal)',
                                      prefixIcon: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFEF4444), size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _durationCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Duration (Mins)',
                                      prefixIcon: const Icon(Icons.timer_rounded, color: Color(0xFF0284C7), size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _level,
                                    decoration: InputDecoration(
                                      labelText: 'Difficulty Level',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                                      DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                                      DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                                      DropdownMenuItem(value: 'All Levels', child: Text('All Levels')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _level = val);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _coachCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'Coach / Instructor',
                                      prefixIcon: const Icon(Icons.person_rounded, size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 6. Active Switch
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Workout Status (Active / Live)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                  Switch(
                                    value: _isActive,
                                    activeThumbColor: const Color(0xFF10B981),
                                    onChanged: (val) => setState(() => _isActive = val),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 7. Tags Manager
                            const Text('Workout Tags', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagInputCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'Add tag e.g. Fat Loss, HIIT, Core',
                                      hintStyle: const TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    onSubmitted: (_) => _addTag(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _addTag,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Add Tag'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _tags.map((tag) {
                                return Chip(
                                  label: Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                                  backgroundColor: const Color(0xFF475569),
                                  deleteIcon: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                  onDeleted: () => _removeTag(tag),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),

                            // 8. MULTI-EXERCISE SELECTION BY EXERCISE CATEGORY
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select Exercises (${_selectedExercises.length} Selected)',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  'Select exercises by category below',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Exercise Category Filter Selector
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: const Text('All Exercises', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                                      selected: _selectedExerciseCategoryFilter == 'All',
                                      selectedColor: const Color(0xFF0284C7),
                                      labelStyle: TextStyle(color: _selectedExerciseCategoryFilter == 'All' ? Colors.white : Colors.black87),
                                      onSelected: (val) {
                                        if (val) setState(() => _selectedExerciseCategoryFilter = 'All');
                                      },
                                    ),
                                  ),
                                  ...dbExerciseCategories.map((eCat) {
                                    final isSel = _selectedExerciseCategoryFilter == eCat.categoryId;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        label: Text(eCat.name, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                                        selected: isSel,
                                        selectedColor: const Color(0xFF0284C7),
                                        labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87),
                                        onSelected: (val) {
                                          if (val) setState(() => _selectedExerciseCategoryFilter = eCat.categoryId);
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // Virtualized List of Filtered Exercises
                    if (filteredExercises.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('No exercises found in this category.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList.separated(
                          itemCount: filteredExercises.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final ex = filteredExercises[idx];
                            final targetId = ex.exerciseId.isNotEmpty ? ex.exerciseId : ex.id;
                            final isSelected = _selectedExerciseIds.contains(targetId) ||
                                _selectedExerciseIds.contains(ex.id) ||
                                _selectedExerciseIds.contains(ex.exerciseId);
                            final exModel = isSelected
                                ? (_selectedExerciseMap[targetId] ?? _selectedExerciseMap[ex.id] ?? _selectedExerciseMap[ex.exerciseId])
                                : null;

                            return RepaintBoundary(
                              key: ValueKey(targetId),
                              child: Material(
                                color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.8 : 1.0,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => _toggleExercise(ex),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: isSelected,
                                              activeColor: const Color(0xFF0284C7),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                              onChanged: (_) => _toggleExercise(ex),
                                            ),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: SizedBox(
                                                width: 46,
                                                height: 46,
                                                child: ExerciseMediaWidget(
                                                  mediaUrl: ex.displayMediaUrl,
                                                  fallbackUrl: ex.displayThumbnailUrl,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(ex.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                                                  const SizedBox(height: 2),
                                                  Text('${ex.muscleGroup.isNotEmpty ? ex.muscleGroup : ex.bodyPart} • ${ex.difficulty}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Additional Config Fields for Selected Exercises (Sets, Reps, Rest)
                                        if (isSelected && exModel != null) ...[
                                          const Divider(height: 14),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: exModel.sets.toString(),
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Sets',
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  onChanged: (v) => exModel.sets = int.tryParse(v) ?? 3,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: exModel.reps.toString(),
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Reps',
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  onChanged: (v) => exModel.reps = int.tryParse(v) ?? 12,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: exModel.restSeconds.toString(),
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Rest (Sec)',
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  onChanged: (v) => exModel.restSeconds = int.tryParse(v) ?? 45,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Bottom Save Button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                            child: _isSaving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text(
                                    isEdit ? 'Save Workout Changes' : 'Create Workout Plan',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// MANAGE WORKOUT DAYS SHEET
// -------------------------------------------------------------
class _ManageWorkoutDaysSheet extends StatefulWidget {
  final WorkoutModel workout;

  const _ManageWorkoutDaysSheet({required this.workout});

  @override
  State<_ManageWorkoutDaysSheet> createState() => _ManageWorkoutDaysSheetState();
}

class _ManageWorkoutDaysSheetState extends State<_ManageWorkoutDaysSheet> {
  late List<WorkoutDayModel> _days;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _days = List.from(widget.workout.days);
  }

  void _addDay() {
    setState(() {
      final newNum = _days.length + 1;
      _days.add(
        WorkoutDayModel(
          dayNumber: newNum,
          weekNumber: ((newNum - 1) ~/ 7) + 1,
          title: 'Day $newNum Routine',
          focus: 'Full Body Focus',
          durationMinutes: 45,
          caloriesBurn: 400,
          isRestDay: false,
          exercises: [],
        ),
      );
    });
  }

  void _editDay(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      useSafeArea: true,
      enableDrag: true,
      builder: (context) => _EditWorkoutDaySheet(
        day: _days[index],
        onSave: (updatedDay) {
          setState(() {
            _days[index] = updatedDay;
          });
        },
      ),
    );
  }

  void _deleteDay(int index) {
    setState(() {
      _days.removeAt(index);
      for (int i = 0; i < _days.length; i++) {
        _days[i].dayNumber = i + 1;
        _days[i].weekNumber = (i ~/ 7) + 1;
      }
    });
  }

  Future<void> _handleSaveDays() async {
    setState(() => _isSaving = true);
    widget.workout.days = _days;
    final success = await WorkoutsBackendService().updateWorkout(widget.workout.id, widget.workout);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout Days Routine Saved Successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manage Routine Days',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        widget.workout.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _addDay,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add Day', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _days.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 40, color: Color(0xFF94A3B8)),
                          SizedBox(height: 12),
                          Text('No Days Added Yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Click "+ Add Day" above to configure your routine schedule.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _days.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final day = _days[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${day.dayNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6366F1), fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      day.title.isNotEmpty ? day.title : 'Day ${day.dayNumber}',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${day.focus} • ${day.exercises.length} Exercises',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, color: Color(0xFF6366F1), size: 18),
                                onPressed: () => _editDay(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                                onPressed: () => _deleteDay(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSaveDays,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Save Routine Schedule', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// EDIT WORKOUT DAY SLIDER SHEET (WITH CATEGORIES & EXERCISES)
// -------------------------------------------------------------
class _EditWorkoutDaySheet extends StatefulWidget {
  final WorkoutDayModel day;
  final Function(WorkoutDayModel) onSave;

  const _EditWorkoutDaySheet({required this.day, required this.onSave});

  @override
  State<_EditWorkoutDaySheet> createState() => _EditWorkoutDaySheetState();
}

class _EditWorkoutDaySheetState extends State<_EditWorkoutDaySheet> {
  late TextEditingController _titleController;
  late TextEditingController _focusController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late bool _isRestDay;

  String _selectedCategoryFilter = 'All';
  String _exerciseSearchQuery = '';
  late List<WorkoutExerciseModel> _selectedExercises;
  final Set<String> _selectedExerciseIds = {};
  final Map<String, WorkoutExerciseModel> _selectedExerciseMap = {};

  final ExerciseCategoryBackendService _exerciseCatService = ExerciseCategoryBackendService();
  final ExercisesBackendService _exercisesService = ExercisesBackendService();

  List<ExerciseModel> _cachedFilteredExercises = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.day.title);
    _focusController = TextEditingController(text: widget.day.focus);
    _durationController = TextEditingController(text: widget.day.durationMinutes.toString());
    _caloriesController = TextEditingController(text: widget.day.caloriesBurn.toString());
    _isRestDay = widget.day.isRestDay;
    _selectedExercises = widget.day.exercises.map((e) => WorkoutExerciseModel.fromJson(e.toJson())).toList();

    for (var e in _selectedExercises) {
      _selectedExerciseIds.add(e.exerciseId);
      _selectedExerciseMap[e.exerciseId] = e;
    }

    _exerciseCatService.addListener(_onServiceDataUpdated);
    _exercisesService.addListener(_onServiceDataUpdated);

    if (_exerciseCatService.categories.isEmpty) {
      _exerciseCatService.fetchCategories();
    }
    if (_exercisesService.exercises.isEmpty) {
      _exercisesService.fetchExercises();
    }

    _updateFilteredList();
  }

  @override
  void dispose() {
    _exerciseCatService.removeListener(_onServiceDataUpdated);
    _exercisesService.removeListener(_onServiceDataUpdated);
    _titleController.dispose();
    _focusController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _onServiceDataUpdated() {
    if (mounted) {
      _updateFilteredList();
    }
  }

  void _updateFilteredList() {
    final categories = _exerciseCatService.activeCategories;
    final allExercises = _exercisesService.activeExercises;
    final query = _exerciseSearchQuery.trim().toLowerCase();
    final catFilter = _selectedCategoryFilter;

    final list = allExercises.where((ex) {
      final matchesCat = catFilter == 'All' ||
          (categories.isNotEmpty &&
              categories.any((c) =>
                  c.name == catFilter &&
                  (ex.categoryId == c.categoryId || ex.categoryId == c.id)));
      if (!matchesCat) return false;

      if (query.isEmpty) return true;
      return ex.title.toLowerCase().contains(query) ||
          ex.muscleGroup.toLowerCase().contains(query) ||
          ex.bodyPart.toLowerCase().contains(query) ||
          ex.target.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _cachedFilteredExercises = list;
    });
  }

  void _toggleExercise(ExerciseModel ex) {
    setState(() {
      final targetId = ex.exerciseId.isNotEmpty ? ex.exerciseId : ex.id;
      final isSel = _selectedExerciseIds.contains(targetId) ||
          _selectedExerciseIds.contains(ex.id) ||
          _selectedExerciseIds.contains(ex.exerciseId);

      if (isSel) {
        _selectedExerciseIds.remove(targetId);
        _selectedExerciseIds.remove(ex.id);
        _selectedExerciseIds.remove(ex.exerciseId);
        _selectedExerciseMap.remove(targetId);
        _selectedExerciseMap.remove(ex.id);
        _selectedExerciseMap.remove(ex.exerciseId);
        _selectedExercises.removeWhere((e) => e.exerciseId == targetId || e.exerciseId == ex.id || e.exerciseId == ex.exerciseId);
      } else {
        final newModel = WorkoutExerciseModel(
          exerciseId: targetId,
          title: ex.title,
          categoryId: ex.categoryId,
          muscleGroup: ex.muscleGroup.isNotEmpty ? ex.muscleGroup : ex.bodyPart,
          mediaUrl: ex.displayMediaUrl,
          mediaType: ex.mediaType,
          sets: 3,
          reps: 12,
          restSeconds: 45,
          instructions: ex.instructionText.isNotEmpty ? ex.instructionText : ex.instructions,
        );
        _selectedExercises.add(newModel);
        _selectedExerciseIds.add(targetId);
        _selectedExerciseMap[targetId] = newModel;
      }
    });
  }

  void _handleSave() {
    final updated = WorkoutDayModel(
      dayNumber: widget.day.dayNumber,
      weekNumber: widget.day.weekNumber,
      title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Day ${widget.day.dayNumber}',
      focus: _focusController.text.trim().isNotEmpty ? _focusController.text.trim() : 'Full Body Focus',
      durationMinutes: int.tryParse(_durationController.text.trim()) ?? 45,
      caloriesBurn: int.tryParse(_caloriesController.text.trim()) ?? 400,
      isRestDay: _isRestDay,
      exercises: _selectedExercises,
    );
    widget.onSave(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _exerciseCatService.activeCategories;
    final isExercisesLoading = _exercisesService.isLoading && _cachedFilteredExercises.isEmpty;

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.90,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Day ${widget.day.dayNumber} Routine',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: CustomScrollView(
                cacheExtent: 300,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(labelText: 'Day Title', border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _focusController,
                                  decoration: const InputDecoration(labelText: 'Target Focus (e.g. Upper Push)', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _durationController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Duration (Mins)', border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _caloriesController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Calories Burned', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Custom Rest Day Switch Card (Material Clean)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isRestDay ? const Color(0xFF6366F1).withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _isRestDay ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isRestDay ? Icons.bedtime_rounded : Icons.fitness_center_rounded,
                                  color: _isRestDay ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Rest / Recovery Day', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isRestDay ? 'Marked as an active rest or mobility day' : 'Active training day with structured exercises',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _isRestDay,
                                  activeThumbColor: const Color(0xFF6366F1),
                                  onChanged: (v) => setState(() => _isRestDay = v),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Select Exercises for this Day',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                              Text(
                                '${_selectedExercises.length} Selected',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Exercise Search Field
                          Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              onChanged: (v) {
                                _exerciseSearchQuery = v;
                                _updateFilteredList();
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search movements (e.g. Bench press, Squat, Cable)...',
                                hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Category Filter Chips
                          SizedBox(
                            height: 34,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: FilterChip(
                                    label: const Text('All'),
                                    selected: _selectedCategoryFilter == 'All',
                                    onSelected: (_) {
                                      _selectedCategoryFilter = 'All';
                                      _updateFilteredList();
                                    },
                                  ),
                                ),
                                ...categories.map((c) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: FilterChip(
                                      label: Text(c.name),
                                      selected: _selectedCategoryFilter == c.name,
                                      onSelected: (_) {
                                        _selectedCategoryFilter = c.name;
                                        _updateFilteredList();
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isExercisesLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF6366F1), strokeWidth: 2.5),
                        ),
                      ),
                    )
                  else if (_cachedFilteredExercises.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text('No matching exercises found.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.separated(
                        itemCount: _cachedFilteredExercises.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final ex = _cachedFilteredExercises[index];
                          final targetId = ex.exerciseId.isNotEmpty ? ex.exerciseId : ex.id;
                          final isSel = _selectedExerciseIds.contains(targetId) ||
                              _selectedExerciseIds.contains(ex.id) ||
                              _selectedExerciseIds.contains(ex.exerciseId);
                          final exModel = isSel
                              ? (_selectedExerciseMap[targetId] ??
                                  _selectedExerciseMap[ex.id] ??
                                  _selectedExerciseMap[ex.exerciseId])
                              : null;

                          return RepaintBoundary(
                            key: ValueKey(targetId),
                            child: Material(
                              color: isSel ? const Color(0xFF10B981).withValues(alpha: 0.06) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: isSel ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                                  width: isSel ? 1.5 : 1.0,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _toggleExercise(ex),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isSel,
                                            activeColor: const Color(0xFF10B981),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                            onChanged: (_) => _toggleExercise(ex),
                                          ),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: ExerciseMediaWidget(
                                                mediaUrl: ex.displayMediaUrl,
                                                fallbackUrl: ex.displayThumbnailUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ex.title,
                                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${ex.categoryName.isNotEmpty ? ex.categoryName : ex.bodyPart} • ${ex.muscleGroup.isNotEmpty ? ex.muscleGroup : ex.target}',
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isSel && exModel != null) ...[
                                        const Divider(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: exModel.sets.toString(),
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  labelText: 'Sets',
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (v) => exModel.sets = int.tryParse(v) ?? 3,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: exModel.reps.toString(),
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  labelText: 'Reps',
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (v) => exModel.reps = int.tryParse(v) ?? 12,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: TextFormField(
                                                initialValue: exModel.restSeconds.toString(),
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  labelText: 'Rest (s)',
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  border: OutlineInputBorder(),
                                                ),
                                                onChanged: (v) => exModel.restSeconds = int.tryParse(v) ?? 45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Day Configuration', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
