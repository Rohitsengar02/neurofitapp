import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';
import '../widgets/upload_progress_overlay.dart';
import 'category_backend_service.dart';

class ExerciseCategoryModel {
  final String categoryId;
  final String id;
  String name;
  String imageUrl;
  int exerciseCount;
  String status;
  final DateTime createdAt;
  DateTime updatedAt;

  ExerciseCategoryModel({
    required this.categoryId,
    String? id,
    required this.name,
    required this.imageUrl,
    this.exerciseCount = 0,
    this.status = 'Active',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? categoryId,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ExerciseCategoryModel.fromJson(Map<String, dynamic> json) {
    final String cId = json['categoryId'] ?? json['id'] ?? json['_id'] ?? '';
    final String name = json['name'] ?? json['title'] ?? 'Category';
    final String imageUrl = json['imageUrl'] ?? json['image'] ?? '';
    final int count = json['exerciseCount'] is int ? json['exerciseCount'] : int.tryParse(json['exerciseCount']?.toString() ?? '0') ?? 0;
    final String status = json['status'] ?? (json['isActive'] == false ? 'Inactive' : 'Active');

    return ExerciseCategoryModel(
      categoryId: cId,
      id: cId,
      name: name,
      imageUrl: imageUrl,
      exerciseCount: count,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'imageUrl': imageUrl,
      'exerciseCount': exerciseCount,
      'status': status,
    };
  }

  Map<String, dynamic> toFirestoreFields() => toJson();
  factory ExerciseCategoryModel.fromFirestoreDoc(Map<String, dynamic> doc) => ExerciseCategoryModel.fromJson(doc);
}

class ExerciseModel {
  String exerciseId;
  String id;
  String title;
  String name;
  String categoryId;
  String categoryName;
  String bodyPart;
  String muscleGroup;
  String target;
  List<String> secondaryMuscles;
  String equipment;
  String difficulty; // 'Beginner', 'Intermediate', 'Advanced'
  int sets;
  String reps;
  String mediaType; // 'gif', 'video', 'image'
  String mediaUrl;
  String imageUrl;
  String gifUrl;
  String mediaId;
  String mediaKey;
  String instructions;
  List<String> instructionSteps;
  String instructionText;
  String tips;
  String status;
  bool isActive;
  final DateTime createdAt;
  DateTime updatedAt;

  ExerciseModel({
    required this.exerciseId,
    String? id,
    required this.title,
    String? name,
    required this.categoryId,
    required this.categoryName,
    this.bodyPart = 'General',
    this.muscleGroup = 'Full Body',
    this.target = '',
    this.secondaryMuscles = const [],
    this.equipment = 'Bodyweight',
    this.difficulty = 'Intermediate',
    this.sets = 3,
    this.reps = '10-12 reps',
    this.mediaType = 'gif',
    required this.mediaUrl,
    this.imageUrl = '',
    this.gifUrl = '',
    this.mediaId = '',
    this.mediaKey = '',
    this.instructions = '',
    this.instructionSteps = const [],
    this.instructionText = '',
    this.tips = '',
    this.status = 'Active',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? exerciseId,
        name = name ?? title,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    final rawUrl = (json['mediaUrl'] ?? json['gifUrl'] ?? json['imageUrl'] ?? json['videoUrl'] ?? '').toString();
    final img = (json['imageUrl'] ?? json['image'] ?? '').toString();
    final gif = (json['gifUrl'] ?? json['gif_url'] ?? '').toString();

    String mType = (json['mediaType'] ?? 'image').toString();
    if (gif.isNotEmpty || rawUrl.toLowerCase().endsWith('.gif')) {
      mType = 'gif';
    } else if (rawUrl.toLowerCase().endsWith('.mp4') || rawUrl.toLowerCase().endsWith('.mov') || rawUrl.toLowerCase().endsWith('.webm')) {
      mType = 'video';
    }

    List<String> steps = [];
    String inst = '';
    if (json['instructions'] is List) {
      steps = (json['instructions'] as List).map((e) => e.toString()).toList();
      inst = steps.join('\n');
    } else if (json['instructions'] != null) {
      inst = json['instructions'].toString();
      steps = inst.split('\n').where((s) => s.trim().isNotEmpty).toList();
    }

    if (json['instructionSteps'] is List) {
      steps = (json['instructionSteps'] as List).map((e) => e.toString()).toList();
    }

    List<String> secMuscles = [];
    if (json['secondaryMuscles'] is List) {
      secMuscles = (json['secondaryMuscles'] as List).map((e) => e.toString()).toList();
    }

    final idVal = (json['id'] ?? json['exerciseId'] ?? json['_id'] ?? '').toString();
    final titleVal = (json['title'] ?? json['name'] ?? 'Exercise').toString();

    return ExerciseModel(
      exerciseId: idVal,
      id: idVal,
      title: titleVal,
      name: (json['name'] ?? titleVal).toString(),
      categoryId: (json['categoryId'] ?? '').toString(),
      categoryName: (json['categoryName'] ?? json['category'] ?? json['bodyPart'] ?? 'General').toString(),
      bodyPart: (json['bodyPart'] ?? json['body_part'] ?? 'General').toString(),
      muscleGroup: (json['muscleGroup'] ?? json['muscle_group'] ?? json['target'] ?? 'Full Body').toString(),
      target: (json['target'] ?? '').toString(),
      secondaryMuscles: secMuscles,
      equipment: (json['equipment'] ?? 'Bodyweight').toString(),
      difficulty: (json['difficulty'] ?? 'Intermediate').toString(),
      sets: json['sets'] is int ? json['sets'] : (int.tryParse(json['sets']?.toString() ?? '3') ?? 3),
      reps: (json['reps'] ?? '10-12 reps').toString(),
      mediaType: mType,
      mediaUrl: rawUrl.isNotEmpty ? rawUrl : (gif.isNotEmpty ? gif : img),
      imageUrl: img,
      gifUrl: gif,
      mediaId: (json['mediaId'] ?? json['media_id'] ?? '').toString(),
      mediaKey: (json['mediaKey'] ?? '').toString(),
      instructions: inst,
      instructionSteps: steps,
      instructionText: (json['instructionText'] ?? inst).toString(),
      tips: (json['tips'] ?? '').toString(),
      status: json['isActive'] == false ? 'Inactive' : 'Active',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isNotEmpty ? id : exerciseId,
      'exerciseId': exerciseId.isNotEmpty ? exerciseId : id,
      'title': title,
      'name': name.isNotEmpty ? name : title,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'category': categoryName,
      'bodyPart': bodyPart,
      'muscleGroup': muscleGroup,
      'target': target,
      'secondaryMuscles': secondaryMuscles,
      'equipment': equipment,
      'difficulty': difficulty,
      'sets': sets,
      'reps': reps,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'imageUrl': imageUrl.isNotEmpty ? imageUrl : mediaUrl,
      'gifUrl': gifUrl,
      'mediaId': mediaId,
      'mediaKey': mediaKey,
      'instructions': instructionSteps.isNotEmpty ? instructionSteps : instructions.split('\n'),
      'instructionText': instructionText.isNotEmpty ? instructionText : instructions,
      'tips': tips,
      'status': status,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toFirestoreFields() => toJson();
  factory ExerciseModel.fromFirestoreDoc(Map<String, dynamic> doc) => ExerciseModel.fromJson(doc);

  /// Helper to get the best media asset / URL path
  String get displayMediaUrl {
    if (gifUrl.isNotEmpty) return gifUrl;
    if (mediaUrl.isNotEmpty) return mediaUrl;
    if (imageUrl.isNotEmpty) return imageUrl;
    return '';
  }

  /// Helper to get the static image thumbnail
  String get displayThumbnailUrl {
    if (imageUrl.isNotEmpty) return imageUrl;
    if (mediaUrl.isNotEmpty && !mediaUrl.endsWith('.gif')) return mediaUrl;
    if (gifUrl.isNotEmpty) return gifUrl;
    return '';
  }
}

class ExercisesBackendService extends ChangeNotifier {
  static final ExercisesBackendService _instance = ExercisesBackendService._internal();
  factory ExercisesBackendService() => _instance;

  ExercisesBackendService._internal() {
    _initSocket();
    fetchExercises();
  }

  IO.Socket? _socket;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<ExerciseCategoryModel> _categories = [];
  final List<ExerciseModel> _exercises = [];

  List<ExerciseCategoryModel> get categories => List.unmodifiable(_categories);
  List<ExerciseCategoryModel> get activeCategories => _categories;
  List<ExerciseModel> get exercises => List.unmodifiable(_exercises);
  List<ExerciseModel> get activeExercises => _exercises.where((e) => e.isActive).toList();

  // Socket.IO Connection for Real-Time CRUD Updates
  void _initSocket() {
    try {
      final socketUrl = ApiConstants.baseUrl;
      _socket = IO.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket?.onConnect((_) {
        debugPrint('⚡ [ADMIN EXERCISES SOCKET CONNECTED] Realtime active');
      });

      _socket?.on('exercise_created', (data) {
        if (data != null) {
          final newEx = ExerciseModel.fromJson(Map<String, dynamic>.from(data));
          _exercises.removeWhere((e) => e.id == newEx.id || e.exerciseId == newEx.exerciseId);
          _exercises.insert(0, newEx);
          notifyListeners();
        }
      });

      _socket?.on('exercise_updated', (data) {
        if (data != null) {
          final updatedEx = ExerciseModel.fromJson(Map<String, dynamic>.from(data));
          final idx = _exercises.indexWhere((e) => e.id == updatedEx.id || e.exerciseId == updatedEx.exerciseId);
          if (idx != -1) {
            _exercises[idx] = updatedEx;
          } else {
            _exercises.insert(0, updatedEx);
          }
          notifyListeners();
        }
      });

      _socket?.on('exercise_deleted', (data) {
        if (data != null && data['id'] != null) {
          final id = data['id'].toString();
          _exercises.removeWhere((e) => e.id == id || e.exerciseId == id);
          notifyListeners();
        }
      });

      _socket?.on('exercises_updated', (data) {
        if (data is List) {
          _exercises.clear();
          for (var item in data) {
            _exercises.add(ExerciseModel.fromJson(Map<String, dynamic>.from(item)));
          }
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error initializing admin exercises socket: $e');
    }
  }

  // Backwards compatibility aliases
  Future<void> fetchCategoriesFromFirestore() async {}
  Future<void> fetchExercisesFromFirestore() => fetchExercises();

  /// Fetch all exercises from Express MongoDB API
  Future<void> fetchExercises() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/api/exercises'));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        List<dynamic> list = [];
        if (body is Map && body['data'] is List) {
          list = body['data'];
        } else if (body is List) {
          list = body;
        }

        _exercises.clear();
        for (var item in list) {
          _exercises.add(ExerciseModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } catch (e) {
      debugPrint('Error fetching exercises from Express API: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create Exercise with Media Upload
  Future<ExerciseModel?> createExercise({
    required String title,
    required String categoryId,
    required String categoryName,
    required String mediaType,
    required String muscleGroup,
    required String difficulty,
    required String equipment,
    required String instructions,
    required String mediaFileName,
    required Uint8List mediaBytes,
  }) async {
    final notifier = UploadProgressNotifier();
    try {
      notifier.startUpload(mediaFileName);

      final mediaUrl = await CategoryBackendService().uploadRawImageToR2(
        fileName: mediaFileName,
        imageBytes: mediaBytes,
        onProgress: (p, s) => notifier.updateProgress(p, customStatus: 'Uploading $mediaType media: $s'),
      );

      if (mediaUrl == null) throw Exception('Failed to upload $mediaType to Cloudflare R2');

      notifier.updateProgress(0.90, customStatus: 'Saving exercise to database...');

      final eId = 'ex_${DateTime.now().millisecondsSinceEpoch}';
      final newExercise = ExerciseModel(
        exerciseId: eId,
        id: eId,
        title: title,
        categoryId: categoryId,
        categoryName: categoryName,
        mediaType: mediaType,
        mediaUrl: mediaUrl,
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        equipment: equipment,
        instructions: instructions,
        status: 'Active',
        isActive: true,
      );

      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/exercises'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newExercise.toJson()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        final createdData = body['data'] ?? body;
        final createdEx = ExerciseModel.fromJson(Map<String, dynamic>.from(createdData));

        _exercises.removeWhere((e) => e.id == createdEx.id);
        _exercises.insert(0, createdEx);

        notifier.completeUpload(mediaUrl);
        notifyListeners();
        return createdEx;
      } else {
        throw Exception('Server error (${res.statusCode}): ${res.body}');
      }
    } catch (e) {
      notifier.failUpload(e.toString());
      debugPrint('Create exercise error: $e');
      return null;
    }
  }

  /// Create Exercise using existing R2 URL
  Future<ExerciseModel?> createExerciseWithUrl({
    required String title,
    required String categoryId,
    required String categoryName,
    required String mediaType,
    required String muscleGroup,
    required String difficulty,
    required String equipment,
    required String instructions,
    required String mediaUrl,
  }) async {
    try {
      final eId = 'ex_${DateTime.now().millisecondsSinceEpoch}';
      final newExercise = ExerciseModel(
        exerciseId: eId,
        id: eId,
        title: title,
        categoryId: categoryId,
        categoryName: categoryName,
        mediaType: mediaType,
        mediaUrl: mediaUrl,
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        equipment: equipment,
        instructions: instructions,
        status: 'Active',
        isActive: true,
      );

      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/exercises'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newExercise.toJson()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        final createdData = body['data'] ?? body;
        final createdEx = ExerciseModel.fromJson(Map<String, dynamic>.from(createdData));

        _exercises.removeWhere((e) => e.id == createdEx.id);
        _exercises.insert(0, createdEx);
        notifyListeners();
        return createdEx;
      }
    } catch (e) {
      debugPrint('Error creating exercise with URL: $e');
    }
    return null;
  }

  /// Update Exercise
  Future<void> updateExercise(ExerciseModel ex) async {
    final targetId = ex.id.isNotEmpty ? ex.id : ex.exerciseId;
    final index = _exercises.indexWhere((e) => e.id == targetId || e.exerciseId == targetId);
    if (index != -1) {
      _exercises[index] = ex;
      notifyListeners();
    }

    try {
      await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/exercises/$targetId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ex.toJson()),
      );
    } catch (e) {
      debugPrint('Update exercise error: $e');
    }
  }

  /// Delete Exercise
  Future<void> deleteExercise(String exerciseId) async {
    _exercises.removeWhere((e) => e.exerciseId == exerciseId || e.id == exerciseId);
    notifyListeners();

    try {
      await http.delete(Uri.parse('${ApiConstants.baseUrl}/api/exercises/$exerciseId'));
    } catch (e) {
      debugPrint('Delete exercise error: $e');
    }
  }

  // Category dummy methods
  Future<ExerciseCategoryModel?> createCategory({required String name, required String imageFileName, required Uint8List imageBytes}) async => null;
  Future<void> updateCategory({required String categoryId, required String newName, String? newImageUrl}) async {}
  Future<void> deleteCategory(String categoryId) async {}
}
