import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class CategoryModel {
  final String categoryId;
  final String id;
  String name;
  String title;
  String slug;
  String imageUrl;
  String imageKey;
  String bucketName;
  int itemCount;
  int productCount;
  int subCount;
  int subCategoryCount;
  String description;
  String status;
  bool isActive;
  int sortOrder;
  String createdBy;
  final DateTime createdAt;
  DateTime updatedAt;

  CategoryModel({
    required this.categoryId,
    String? id,
    required this.name,
    String? title,
    required this.slug,
    required this.imageUrl,
    this.imageKey = '',
    this.bucketName = 'neurofit',
    this.itemCount = 0,
    int? productCount,
    this.subCount = 0,
    int? subCategoryCount,
    this.description = '',
    this.status = 'Active',
    this.isActive = true,
    this.sortOrder = 1,
    this.createdBy = 'admin@neurofit.app',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? categoryId,
        title = title ?? name,
        productCount = productCount ?? itemCount,
        subCategoryCount = subCategoryCount ?? subCount,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final cId = json['id'] ?? json['categoryId'] ?? json['_id'] ?? '';
    return CategoryModel(
      categoryId: cId,
      name: json['name'] ?? '',
      title: json['name'] ?? '',
      slug: json['slug'] ?? (json['name'] ?? '').toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? 'active',
      isActive: (json['status'] ?? 'active') == 'active' || json['isActive'] == true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 1,
    );
  }

  factory CategoryModel.fromFirestoreDoc(Map<String, dynamic> doc) {
    final String path = doc['name'] ?? '';
    final String autoId = path.split('/').last;
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};

    return CategoryModel(
      categoryId: autoId,
      name: fields['name']?['stringValue'] ?? '',
      title: fields['name']?['stringValue'] ?? '',
      slug: fields['slug']?['stringValue'] ?? '',
      imageUrl: fields['imageUrl']?['stringValue'] ?? '',
      imageKey: fields['imageKey']?['stringValue'] ?? '',
      description: fields['description']?['stringValue'] ?? '',
      status: fields['status']?['stringValue'] ?? 'Active',
      isActive: (fields['status']?['stringValue'] ?? 'Active') == 'Active',
      sortOrder: int.tryParse(fields['sortOrder']?['integerValue']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toFirestoreFields() {
    return {
      'categoryId': {'stringValue': categoryId},
      'name': {'stringValue': name},
      'slug': {'stringValue': slug},
      'imageUrl': {'stringValue': imageUrl},
      'imageKey': {'stringValue': imageKey},
      'description': {'stringValue': description},
      'status': {'stringValue': status},
      'sortOrder': {'integerValue': sortOrder.toString()},
    };
  }
}

class SubCategoryModel {
  final String subCategoryId;
  final String id;
  final String parentCategoryId;
  final String parentCategoryName;
  String name;
  String title;
  String slug;
  String imageUrl;
  String imageKey;
  int productCount;
  String description;
  String status;
  bool isActive;
  int sortOrder;
  final DateTime createdAt;
  DateTime updatedAt;

  int get itemCount => productCount;
  set itemCount(int val) => productCount = val;

  SubCategoryModel({
    required this.subCategoryId,
    String? id,
    required this.parentCategoryId,
    required this.parentCategoryName,
    required this.name,
    String? title,
    required this.slug,
    required this.imageUrl,
    this.imageKey = '',
    this.productCount = 0,
    this.description = '',
    this.status = 'Active',
    this.isActive = true,
    this.sortOrder = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? subCategoryId,
        title = title ?? name,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    final sId = json['id'] ?? json['subCategoryId'] ?? json['_id'] ?? '';
    return SubCategoryModel(
      subCategoryId: sId,
      parentCategoryId: json['parentCategoryId'] ?? '',
      parentCategoryName: json['parentCategoryName'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? (json['name'] ?? '').toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      status: json['status'] ?? 'active',
      isActive: (json['status'] ?? 'active') == 'active' || json['isActive'] == true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 1,
    );
  }

  factory SubCategoryModel.fromFirestoreDoc(Map<String, dynamic> doc, String parentId, String parentName) {
    final String path = doc['name'] ?? '';
    final String autoId = path.split('/').last;
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};

    return SubCategoryModel(
      subCategoryId: autoId,
      parentCategoryId: parentId,
      parentCategoryName: parentName,
      name: fields['name']?['stringValue'] ?? '',
      slug: fields['slug']?['stringValue'] ?? '',
      imageUrl: fields['imageUrl']?['stringValue'] ?? '',
      imageKey: fields['imageKey']?['stringValue'] ?? '',
      description: fields['description']?['stringValue'] ?? '',
      status: fields['status']?['stringValue'] ?? 'Active',
      isActive: (fields['status']?['stringValue'] ?? 'Active') == 'Active',
      sortOrder: int.tryParse(fields['sortOrder']?['integerValue']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toFirestoreFields() {
    return {
      'subCategoryId': {'stringValue': subCategoryId},
      'parentCategoryId': {'stringValue': parentCategoryId},
      'parentCategoryName': {'stringValue': parentCategoryName},
      'name': {'stringValue': name},
      'slug': {'stringValue': slug},
      'imageUrl': {'stringValue': imageUrl},
      'imageKey': {'stringValue': imageKey},
      'description': {'stringValue': description},
      'status': {'stringValue': status},
      'sortOrder': {'integerValue': sortOrder.toString()},
    };
  }
}

class CategoryBackendService extends ChangeNotifier {
  static final CategoryBackendService _instance = CategoryBackendService._internal();
  factory CategoryBackendService() => _instance;

  CategoryBackendService._internal() {
    fetchCategoriesFromFirestore();
    fetchAllSubCategoriesFromFirestore();
  }

  static const String firebaseProjectId = "neurofit-52fe0";
  static const String firebaseApiKey = "AIzaSyDcGovQH3Sd_0kdNeSISK6eNCdtjA_g9vg";

  static const String r2AccountId = '61519b8c6a1a20d3535eb39e85687539';
  static const String r2BucketName = 'neurofit';
  static const String r2ApiToken = 'cfat_CUzcTemF5447Ag5mi2gIrcDGYyrMrHSrO9PY6q5Sc69f5185';
  static const String r2PublicDevUrl = 'https://pub-2faf8f45ef6f42afba49f3944feacff6.r2.dev';

  static String getDisplayableImageUrl(String url) {
    if (url.isEmpty) return '';

    // 1. If already formatted as active API endpoint, return as is
    if (url.contains('/api/media/file/') || url.contains('/api/media/proxy')) {
      return url;
    }

    final trimmed = url.trim();

    // 2. Handle local/backend exercise assets & videos/gifs
    if (trimmed.startsWith('assets/exercises') ||
        trimmed.startsWith('/assets/exercises') ||
        trimmed.startsWith('exercises/') ||
        trimmed.startsWith('/exercises/')) {
      final clean = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
      return '${ApiConstants.baseUrl}/$clean';
    }

    if (trimmed.endsWith('.gif') && !trimmed.startsWith('http')) {
      return '${ApiConstants.baseUrl}/assets/exercises/videos/$trimmed';
    }
    if ((trimmed.endsWith('.jpg') || trimmed.endsWith('.png') || trimmed.endsWith('.webp')) &&
        !trimmed.startsWith('http') &&
        !trimmed.contains('/')) {
      return '${ApiConstants.baseUrl}/assets/exercises/images/$trimmed';
    }

    // 3. Handle Cloudflare R2 images & local upload filenames:
    if (trimmed.contains('r2.dev') ||
        trimmed.contains('/uploads/') ||
        trimmed.contains('scaled_') ||
        trimmed.startsWith('1788')) {
      final fileName = trimmed.split('/').last.split('?').first;
      if (fileName.isNotEmpty && !fileName.contains(':')) {
        return '${ApiConstants.apiBaseUrl}/media/file/$fileName';
      }
      return '${ApiConstants.apiBaseUrl}/media/proxy?url=${Uri.encodeComponent(trimmed)}';
    }

    // 4. For Unsplash, Pexels, or standard external CDN image URLs, return directly
    return trimmed;
  }

  final List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => List.unmodifiable(_categories);

  final List<SubCategoryModel> _subCategories = [];
  List<SubCategoryModel> get subCategories => List.unmodifiable(_subCategories);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchCategoriesFromFirestore() async {
    _isLoading = true;
    notifyListeners();

    // 1. Fetch from MongoDB Atlas Backend
    final backendUrls = [
      '${ApiConstants.apiBaseUrl}/categories',
      ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/categories'),
    ];

    for (final url in backendUrls) {
      try {
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final items = data['data'] as List<dynamic>? ?? [];
          if (items.isNotEmpty) {
            _categories.clear();
            for (var item in items) {
              _categories.add(CategoryModel.fromJson(item));
            }
            _isLoading = false;
            notifyListeners();
            debugPrint('✅ [CATEGORIES LOADED FROM MONGODB ATLAS] ${_categories.length} live categories');
            return;
          }
        }
      } catch (_) {}
    }

    // 2. Fallback to Firestore
    try {
      final Uri uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories?key=$firebaseApiKey',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final documents = data['documents'] as List<dynamic>?;
        if (documents != null) {
          final List<CategoryModel> fetched = [];
          for (var doc in documents) {
            fetched.add(CategoryModel.fromFirestoreDoc(doc));
          }
          fetched.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          _categories.clear();
          _categories.addAll(fetched);
          debugPrint('✅ [CATEGORIES LOADED FROM FIRESTORE] ${_categories.length} live categories');
        }
      }
    } catch (e) {
      debugPrint('Firestore fetch categories error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllSubCategoriesFromFirestore() async {
    _isLoading = true;
    notifyListeners();

    // 1. Fetch from MongoDB Atlas Backend
    final backendUrls = [
      '${ApiConstants.apiBaseUrl}/subcategories',
      ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/subcategories'),
    ];

    for (final url in backendUrls) {
      try {
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final items = data['data'] as List<dynamic>? ?? [];
          if (items.isNotEmpty) {
            _subCategories.clear();
            for (var item in items) {
              _subCategories.add(SubCategoryModel.fromJson(item));
            }
            _isLoading = false;
            notifyListeners();
            debugPrint('✅ [SUBCATEGORIES LOADED FROM MONGODB ATLAS] ${_subCategories.length} live subcategories');
            return;
          }
        }
      } catch (_) {}
    }

    // 2. Fallback to Firestore
    try {
      final List<SubCategoryModel> allSubs = [];
      final List<Future<void>> futures = [];

      for (var cat in _categories) {
        futures.add(() async {
          final Uri subUri = Uri.parse(
            'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories/${cat.categoryId}/subcategories?key=$firebaseApiKey',
          );
          try {
            final res = await http.get(subUri).timeout(const Duration(seconds: 6));
            if (res.statusCode == 200) {
              final data = jsonDecode(res.body);
              final docs = data['documents'] as List<dynamic>?;
              if (docs != null) {
                for (var d in docs) {
                  allSubs.add(SubCategoryModel.fromFirestoreDoc(d, cat.categoryId, cat.name));
                }
              }
            }
          } catch (_) {}
        }());
      }

      await Future.wait(futures);
      _subCategories.clear();
      _subCategories.addAll(allSubs);
      debugPrint('✅ [SUBCATEGORIES LOADED FROM FIRESTORE] ${_subCategories.length} live subcategories');
    } catch (e) {
      debugPrint('Firestore fetch subcategories error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadRawImageToR2({
    required String fileName,
    required Uint8List imageBytes,
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      onProgress?.call(0.25, 'Connecting to Cloudflare R2...');
      final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final lowerName = cleanFileName.toLowerCase();
      String mimeType = 'image/jpeg';
      if (lowerName.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (lowerName.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (lowerName.endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (lowerName.endsWith('.mp4')) {
        mimeType = 'video/mp4';
      } else if (lowerName.endsWith('.mov')) {
        mimeType = 'video/quicktime';
      } else if (lowerName.endsWith('.webm')) {
        mimeType = 'video/webm';
      } else if (lowerName.endsWith('.mkv')) {
        mimeType = 'video/x-matroska';
      } else if (lowerName.endsWith('.avi')) {
        mimeType = 'video/x-msvideo';
      }

      // 1. Upload via Express Backend API (Bypasses browser CORS completely)
      final backendUploadUrls = [
        '${ApiConstants.apiBaseUrl}/media/upload',
        ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/media/upload'),
      ];

      for (final url in backendUploadUrls) {
        try {
          final res = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fileName': cleanFileName,
              'imageBase64': base64Encode(imageBytes),
              'mimeType': mimeType,
            }),
          ).timeout(const Duration(seconds: 15));

          if (res.statusCode == 200 || res.statusCode == 201) {
            final data = jsonDecode(res.body);
            if (data['success'] == true && data['url'] != null) {
              onProgress?.call(1.0, 'Uploaded to R2');
              return data['url'].toString();
            }
          }
        } catch (_) {}
      }

      // 2. Direct Cloudflare API Fallback
      final Uri r2Uri = Uri.parse(
        'https://api.cloudflare.com/client/v4/accounts/$r2AccountId/r2/buckets/$r2BucketName/objects/uploads/$cleanFileName',
      );

      final res = await http.put(
        r2Uri,
        headers: {
          'Authorization': 'Bearer $r2ApiToken',
          'Content-Type': mimeType,
        },
        body: imageBytes,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        onProgress?.call(1.0, 'Uploaded to R2');
        return '$r2PublicDevUrl/uploads/$cleanFileName';
      }
      return '$r2PublicDevUrl/uploads/$cleanFileName';
    } catch (e) {
      debugPrint('R2 Upload error: $e');
      return '$r2PublicDevUrl/uploads/$fileName';
    }
  }

  Future<bool> createCategory({
    required String name,
    required String slug,
    required String description,
    required String fileName,
    required Uint8List imageBytes,
    int sortOrder = 1,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uploadedUrl = await uploadRawImageToR2(fileName: fileName, imageBytes: imageBytes);
      if (uploadedUrl == null) return false;

      final catId = 'cat_${DateTime.now().millisecondsSinceEpoch}';
      final newCat = CategoryModel(
        categoryId: catId,
        name: name,
        slug: slug,
        description: description,
        imageUrl: uploadedUrl,
        imageKey: 'uploads/$fileName',
        sortOrder: sortOrder,
      );

      // 1. Save to MongoDB Atlas Backend
      final backendUrls = [
        '${ApiConstants.apiBaseUrl}/categories',
        ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/categories'),
      ];

      for (final url in backendUrls) {
        try {
          final res = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': catId,
              'name': name,
              'slug': slug,
              'description': description,
              'imageUrl': uploadedUrl,
              'sortOrder': sortOrder,
              'status': 'active',
            }),
          ).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200 || res.statusCode == 201) {
            debugPrint('✅ [CATEGORY SAVED TO MONGODB ATLAS] $name');
            await fetchCategoriesFromFirestore();
            return true;
          }
        } catch (_) {}
      }

      // 2. Fallback to Firestore
      final Uri uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories/$catId?key=$firebaseApiKey',
      );

      final res = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': newCat.toFirestoreFields()}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchCategoriesFromFirestore();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSubCategory({
    required String parentCategoryId,
    required String parentCategoryName,
    required String name,
    required String slug,
    required String fileName,
    required Uint8List imageBytes,
    int sortOrder = 1,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uploadedUrl = await uploadRawImageToR2(fileName: fileName, imageBytes: imageBytes);
      if (uploadedUrl == null) return false;

      final subId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
      final newSub = SubCategoryModel(
        subCategoryId: subId,
        parentCategoryId: parentCategoryId,
        parentCategoryName: parentCategoryName,
        name: name,
        slug: slug,
        imageUrl: uploadedUrl,
        imageKey: 'uploads/$fileName',
        sortOrder: sortOrder,
      );

      // 1. Save to MongoDB Atlas Backend
      final backendUrls = [
        '${ApiConstants.apiBaseUrl}/subcategories',
        ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/subcategories'),
      ];

      for (final url in backendUrls) {
        try {
          final res = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': subId,
              'parentCategoryId': parentCategoryId,
              'parentCategoryName': parentCategoryName,
              'name': name,
              'slug': slug,
              'imageUrl': uploadedUrl,
              'sortOrder': sortOrder,
              'status': 'active',
            }),
          ).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200 || res.statusCode == 201) {
            debugPrint('✅ [SUBCATEGORY SAVED TO MONGODB ATLAS] $name');
            await fetchAllSubCategoriesFromFirestore();
            return true;
          }
        } catch (_) {}
      }

      // 2. Fallback to Firestore
      final Uri uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories/$parentCategoryId/subcategories/$subId?key=$firebaseApiKey',
      );

      final res = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': newSub.toFirestoreFields()}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchAllSubCategoriesFromFirestore();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSubCategoryWithUrl({
    required String parentCategoryId,
    required String parentCategoryName,
    required String name,
    required String slug,
    required String imageUrl,
    int sortOrder = 1,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final subId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
      final newSub = SubCategoryModel(
        subCategoryId: subId,
        parentCategoryId: parentCategoryId,
        parentCategoryName: parentCategoryName,
        name: name,
        slug: slug,
        imageUrl: imageUrl,
        imageKey: '',
        sortOrder: sortOrder,
      );

      final backendUrls = [
        '${ApiConstants.apiBaseUrl}/subcategories',
        ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/subcategories'),
      ];

      for (final url in backendUrls) {
        try {
          final res = await http.post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': subId,
              'parentCategoryId': parentCategoryId,
              'parentCategoryName': parentCategoryName,
              'name': name,
              'slug': slug,
              'imageUrl': imageUrl,
              'sortOrder': sortOrder,
              'status': 'active',
            }),
          ).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200 || res.statusCode == 201) {
            await fetchAllSubCategoriesFromFirestore();
            return true;
          }
        } catch (_) {}
      }

      final Uri uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories/$parentCategoryId/subcategories/$subId?key=$firebaseApiKey',
      );

      final res = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': newSub.toFirestoreFields()}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchAllSubCategoriesFromFirestore();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Matching methods for MarketplaceCategoriesView
  Future<bool> createCategoryWithImage({
    required String title,
    required String fileName,
    required Uint8List imageBytes,
    String? description,
    int sortOrder = 1,
    void Function(double)? onProgress,
  }) async {
    final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return await createCategory(
      name: title,
      slug: slug,
      description: description ?? title,
      fileName: fileName,
      imageBytes: imageBytes,
      sortOrder: sortOrder,
    );
  }

  Future<bool> createCategoryWithUrl({
    required String title,
    required String imageUrl,
    String? description,
    int sortOrder = 1,
  }) async {
    final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final catId = 'cat_${DateTime.now().millisecondsSinceEpoch}';

    final newCat = CategoryModel(
      categoryId: catId,
      name: title,
      title: title,
      slug: slug,
      imageUrl: imageUrl,
      imageKey: '',
      description: description ?? title,
      sortOrder: sortOrder,
    );

    final backendUrls = [
      '${ApiConstants.apiBaseUrl}/categories',
      ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/categories'),
    ];

    for (final url in backendUrls) {
      try {
        final res = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': catId,
            'name': title,
            'slug': slug,
            'imageUrl': imageUrl,
            'description': description ?? title,
            'sortOrder': sortOrder,
            'status': 'active',
          }),
        ).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200 || res.statusCode == 201) {
          await fetchCategoriesFromFirestore();
          return true;
        }
      } catch (_) {}
    }

    final Uri uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories/$catId?key=$firebaseApiKey',
    );

    final res = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fields': newCat.toFirestoreFields()}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      await fetchCategoriesFromFirestore();
      return true;
    }
    return false;
  }

  Future<bool> updateCategory({
    required String id,
    String? newName,
    String? newImageUrl,
    String? newStatus,
    void Function(double)? onProgress,
  }) async {
    try {
      // 1. Update in MongoDB Atlas Backend
      final backendUrls = [
        '${ApiConstants.apiBaseUrl}/categories/$id',
        ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/categories/$id'),
      ];

      final updateMap = <String, dynamic>{'id': id};
      if (newName != null && newName.isNotEmpty) updateMap['name'] = newName;
      if (newImageUrl != null && newImageUrl.isNotEmpty) updateMap['imageUrl'] = newImageUrl;
      if (newStatus != null && newStatus.isNotEmpty) updateMap['status'] = newStatus;

      for (final url in backendUrls) {
        try {
          final res = await http.put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updateMap),
          ).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            debugPrint('✅ [CATEGORY UPDATED IN MONGODB ATLAS] $id');
            await fetchCategoriesFromFirestore();
            return true;
          }
        } catch (_) {}
      }

      // 2. Fallback to Firestore
      final fields = <String, dynamic>{};
      if (newName != null && newName.isNotEmpty) {
        fields['name'] = {'stringValue': newName};
        fields['slug'] = {'stringValue': newName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')};
      }
      if (newImageUrl != null && newImageUrl.isNotEmpty) {
        fields['imageUrl'] = {'stringValue': newImageUrl};
      }
      if (newStatus != null && newStatus.isNotEmpty) {
        fields['status'] = {'stringValue': newStatus};
      }

      final Uri uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories/$id?key=$firebaseApiKey&updateMask.fieldPaths=name&updateMask.fieldPaths=slug&updateMask.fieldPaths=imageUrl&updateMask.fieldPaths=status',
      );

      final res = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': fields}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchCategoriesFromFirestore();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      // 1. Delete from MongoDB Atlas Backend
      final backendUrls = [
        '${ApiConstants.apiBaseUrl}/categories/$id',
        ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/categories/$id'),
      ];

      for (final url in backendUrls) {
        try {
          final res = await http.delete(Uri.parse(url)).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200 || res.statusCode == 204) {
            debugPrint('✅ [CATEGORY DELETED FROM MONGODB ATLAS] $id');
            _categories.removeWhere((c) => c.categoryId == id || c.id == id);
            notifyListeners();
            return true;
          }
        } catch (_) {}
      }

      // 2. Fallback to Firestore
      final Uri uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories/$id?key=$firebaseApiKey',
      );
      final res = await http.delete(uri);
      if (res.statusCode == 200 || res.statusCode == 204) {
        await fetchCategoriesFromFirestore();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  Future<bool> createSubCategoryWithImage({
    required String parentCategoryId,
    required String parentCategoryName,
    required String title,
    required String fileName,
    required Uint8List imageBytes,
    int sortOrder = 1,
    void Function(double)? onProgress,
  }) async {
    final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return await createSubCategory(
      parentCategoryId: parentCategoryId,
      parentCategoryName: parentCategoryName,
      name: title,
      slug: slug,
      fileName: fileName,
      imageBytes: imageBytes,
      sortOrder: sortOrder,
    );
  }

  Future<bool> updateSubCategory({
    required String subId,
    required String parentCategoryId,
    String? newName,
    String? newImageUrl,
    String? newStatus,
    void Function(double)? onProgress,
  }) async {
    try {
      // 1. Update in MongoDB Atlas Backend
      final backendUrls = [
        '${ApiConstants.apiBaseUrl}/subcategories/$subId',
        ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/subcategories/$subId'),
      ];

      final updateMap = <String, dynamic>{'id': subId, 'parentCategoryId': parentCategoryId};
      if (newName != null && newName.isNotEmpty) updateMap['name'] = newName;
      if (newImageUrl != null && newImageUrl.isNotEmpty) updateMap['imageUrl'] = newImageUrl;
      if (newStatus != null && newStatus.isNotEmpty) updateMap['status'] = newStatus;

      for (final url in backendUrls) {
        try {
          final res = await http.put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(updateMap),
          ).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            debugPrint('✅ [SUBCATEGORY UPDATED IN MONGODB ATLAS] $subId');
            await fetchAllSubCategoriesFromFirestore();
            return true;
          }
        } catch (_) {}
      }

      // 2. Fallback to Firestore
      final fields = <String, dynamic>{};
      if (newName != null && newName.isNotEmpty) {
        fields['name'] = {'stringValue': newName};
        fields['slug'] = {'stringValue': newName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')};
      }
      if (newImageUrl != null && newImageUrl.isNotEmpty) {
        fields['imageUrl'] = {'stringValue': newImageUrl};
      }
      if (newStatus != null && newStatus.isNotEmpty) {
        fields['status'] = {'stringValue': newStatus};
      }

      final Uri uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories/$parentCategoryId/subcategories/$subId?key=$firebaseApiKey&updateMask.fieldPaths=name&updateMask.fieldPaths=slug&updateMask.fieldPaths=imageUrl&updateMask.fieldPaths=status',
      );

      final res = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': fields}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetchAllSubCategoriesFromFirestore();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating subcategory: $e');
      return false;
    }
  }

  Future<bool> deleteSubCategory({
    required String subId,
    required String parentCategoryId,
  }) async {
    try {
      // 1. Delete from MongoDB Atlas Backend
      final backendUrls = [
        '${ApiConstants.apiBaseUrl}/subcategories/$subId',
        ...ApiConstants.candidateBaseUrls.map((b) => '$b/api/subcategories/$subId'),
      ];

      for (final url in backendUrls) {
        try {
          final res = await http.delete(Uri.parse(url)).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200 || res.statusCode == 204) {
            debugPrint('✅ [SUBCATEGORY DELETED FROM MONGODB ATLAS] $subId');
            _subCategories.removeWhere((s) => s.subCategoryId == subId || s.id == subId);
            notifyListeners();
            return true;
          }
        } catch (_) {}
      }

      // 2. Fallback to Firestore
      final Uri uri = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$firebaseProjectId/databases/(default)/documents/categories/$parentCategoryId/subcategories/$subId?key=$firebaseApiKey',
      );
      final res = await http.delete(uri);
      if (res.statusCode == 200 || res.statusCode == 204) {
        await fetchAllSubCategoriesFromFirestore();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting subcategory: $e');
      return false;
    }
  }
}
