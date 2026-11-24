import 'package:flutter/material.dart';
import '../services/exercises_backend_service.dart' hide ExerciseCategoryModel;
import '../services/exercise_category_backend_service.dart';
import 'exercise_media_widget.dart';

class ExerciseDetailModal extends StatefulWidget {
  final ExerciseModel exercise;
  final VoidCallback onUpdated;

  const ExerciseDetailModal({
    super.key,
    required this.exercise,
    required this.onUpdated,
  });

  static void show(BuildContext context, ExerciseModel exercise, VoidCallback onUpdated) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExerciseDetailModal(
        exercise: exercise,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  State<ExerciseDetailModal> createState() => _ExerciseDetailModalState();
}

class _ExerciseDetailModalState extends State<ExerciseDetailModal> {
  bool _isEditing = false;
  late TextEditingController _titleCtrl;
  late TextEditingController _muscleCtrl;
  late TextEditingController _targetCtrl;
  late TextEditingController _equipmentCtrl;
  late TextEditingController _setsCtrl;
  late TextEditingController _repsCtrl;
  late TextEditingController _tipsCtrl;
  final List<TextEditingController> _stepCtrls = [];
  late String _difficulty;
  late String _status;
  late String _selectedCategoryId;
  late String _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    _titleCtrl = TextEditingController(text: ex.title);
    _muscleCtrl = TextEditingController(text: ex.muscleGroup);
    _targetCtrl = TextEditingController(text: ex.target);
    _equipmentCtrl = TextEditingController(text: ex.equipment);
    _setsCtrl = TextEditingController(text: ex.sets.toString());
    _repsCtrl = TextEditingController(text: ex.reps);
    _tipsCtrl = TextEditingController(text: ex.tips);
    _difficulty = ex.difficulty;
    _status = ex.status;
    _selectedCategoryId = ex.categoryId;
    _selectedCategoryName = ex.categoryName;

    final steps = ex.instructionSteps.isNotEmpty
        ? ex.instructionSteps
        : ex.instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();

    if (steps.isEmpty) {
      _stepCtrls.add(TextEditingController(text: ''));
    } else {
      for (var s in steps) {
        _stepCtrls.add(TextEditingController(text: s.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')));
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _muscleCtrl.dispose();
    _targetCtrl.dispose();
    _equipmentCtrl.dispose();
    _setsCtrl.dispose();
    _repsCtrl.dispose();
    _tipsCtrl.dispose();
    for (var c in _stepCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() => _stepCtrls.add(TextEditingController()));
  }

  void _removeStep(int index) {
    if (_stepCtrls.length > 1) {
      setState(() {
        final c = _stepCtrls.removeAt(index);
        c.dispose();
      });
    }
  }

  Future<void> _handleSave() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final steps = _stepCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();

    widget.exercise.title = title;
    widget.exercise.name = title;
    widget.exercise.muscleGroup = _muscleCtrl.text.trim();
    widget.exercise.target = _targetCtrl.text.trim();
    widget.exercise.equipment = _equipmentCtrl.text.trim();
    widget.exercise.sets = int.tryParse(_setsCtrl.text.trim()) ?? 3;
    widget.exercise.reps = _repsCtrl.text.trim();
    widget.exercise.tips = _tipsCtrl.text.trim();
    widget.exercise.difficulty = _difficulty;
    widget.exercise.status = _status;
    widget.exercise.isActive = _status == 'Active';
    widget.exercise.categoryId = _selectedCategoryId;
    widget.exercise.categoryName = _selectedCategoryName;
    widget.exercise.instructionSteps = steps;
    widget.exercise.instructions = steps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
    widget.exercise.updatedAt = DateTime.now();

    await ExercisesBackendService().updateExercise(widget.exercise);
    widget.onUpdated();
    setState(() => _isEditing = false);
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Exercise?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Text('Are you sure you want to delete "${widget.exercise.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              await ExercisesBackendService().deleteExercise(widget.exercise.id);
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
    final ex = widget.exercise;
    final categories = ExerciseCategoryBackendService().categories;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle & Top Bar
          const SizedBox(height: 12),
          Container(width: 44, height: 4.5, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        'ID: ${ex.id}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ex.isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ex.isActive ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(
                          color: ex.isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(_isEditing ? Icons.visibility_rounded : Icons.edit_rounded, color: const Color(0xFF6366F1), size: 20),
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 12, color: Color(0xFFF1F5F9)),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _isEditing ? _buildEditForm(categories) : _buildDetailsView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView() {
    final ex = widget.exercise;

    Color diffColor = const Color(0xFF10B981);
    if (ex.difficulty == 'Intermediate') diffColor = const Color(0xFFF59E0B);
    if (ex.difficulty == 'Advanced') diffColor = const Color(0xFFEF4444);

    final steps = ex.instructionSteps.isNotEmpty
        ? ex.instructionSteps
        : ex.instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero GIF / Video Interactive Animation Demo
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ExerciseMediaWidget(
                mediaUrl: ex.displayMediaUrl,
                fallbackUrl: ex.displayThumbnailUrl,
                fit: BoxFit.contain,
              ),
              // Gradient Overlay
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.motion_photos_on_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        ex.mediaType.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    ex.mediaKey.isNotEmpty ? ex.mediaKey : ex.id,
                    style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Title & Category Badges
        Text(
          ex.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.4),
        ),
        const SizedBox(height: 10),

        // Badges Row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPill(Icons.category_rounded, ex.categoryName, const Color(0xFF6366F1), const Color(0xFFEEF2FF)),
            _buildPill(Icons.fitness_center_rounded, ex.equipment, const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
            _buildPill(Icons.speed_rounded, ex.difficulty, diffColor, diffColor.withValues(alpha: 0.12)),
            _buildPill(Icons.accessibility_new_rounded, ex.bodyPart, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
          ],
        ),
        const SizedBox(height: 20),

        // 3. Muscle Group Breakdown Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.sports_gymnastics_rounded, size: 18, color: Color(0xFF6366F1)),
                  SizedBox(width: 8),
                  Text('Muscles Activated', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PRIMARY TARGET', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          ex.target.isNotEmpty ? ex.target : ex.muscleGroup,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MUSCLE GROUP', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(
                          ex.muscleGroup,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (ex.secondaryMuscles.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 12, color: Color(0xFFE2E8F0)),
                const Text('SECONDARY SYNERGISTS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ex.secondaryMuscles
                      .map((m) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: Text(m, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Recommended Routine Parameters
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SETS', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    Text('${ex.sets} Working Sets', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('REPS / TARGET', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    Text(ex.reps, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 5. Step-by-Step Instructions
        const Text('Step-by-Step Execution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 10),
        if (steps.isEmpty)
          const Text('No instructions specified.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(8)),
                    child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      steps[i].replaceFirst(RegExp(r'^\d+[\.\)]\s*'), ''),
                      style: const TextStyle(fontSize: 12.5, height: 1.45, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 20),

        // 6. Pro Coaching Tip
        if (ex.tips.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: Color(0xFFD97706), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Coach Form Cue', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFB45309))),
                      const SizedBox(height: 2),
                      Text(ex.tips, style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F), height: 1.4, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  foregroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete Exercise', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEditForm(List<ExerciseCategoryModel> categories) {
    final bool hasMatch = categories.any((c) => c.categoryId == _selectedCategoryId);
    final String? dropVal = hasMatch ? _selectedCategoryId : (categories.isNotEmpty ? categories.first.categoryId : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Exercise Movement Title',
            filled: true,
            fillColor: Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        const SizedBox(height: 12),

        // Category dropdown
        const Text('Exercise Category', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: dropVal,
              items: categories
                  .map((c) => DropdownMenuItem<String>(value: c.categoryId, child: Text(c.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  final found = categories.firstWhere((c) => c.categoryId == val, orElse: () => categories.first);
                  setState(() {
                    _selectedCategoryId = val;
                    _selectedCategoryName = found.name;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _targetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Target Muscle (e.g. Abs)',
                  filled: true,
                  fillColor: Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _muscleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Muscle Group',
                  filled: true,
                  fillColor: Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _equipmentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Equipment',
                  filled: true,
                  fillColor: Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _setsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sets',
                  filled: true,
                  fillColor: Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _repsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  filled: true,
                  fillColor: Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Difficulty Chips
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
        const SizedBox(height: 14),

        // Tips
        TextField(
          controller: _tipsCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Coach Form Cue & Breathing Tip',
            filled: true,
            fillColor: Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        const SizedBox(height: 14),

        // Step Instructions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Execution Steps', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
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
          itemBuilder: (ctx, i) {
            return Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _stepCtrls[i],
                    decoration: InputDecoration(
                      hintText: 'Step ${i + 1} instruction cue...',
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
                    onPressed: () => _removeStep(i),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(_status == 'Active' ? 'Status: Active (Visible in App)' : 'Status: Deactivated', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          value: _status == 'Active',
          activeTrackColor: const Color(0xFF10B981),
          onChanged: (v) => setState(() => _status = v ? 'Active' : 'Deactivated'),
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => setState(() => _isEditing = false),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800)),
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
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPill(IconData icon, String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
