import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../constants/api_constants.dart';
import '../models/recipe_model.dart';

class RecipeBackendService extends ChangeNotifier {
  static final RecipeBackendService _instance = RecipeBackendService._internal();
  factory RecipeBackendService() => _instance;

  RecipeBackendService._internal() {
    _initSocket();
    fetchRecipes();
  }

  socket_io.Socket? _socket;
  bool _isLoading = false;
  bool _isSearchingLive = false;
  String _errorMessage = '';

  final List<RecipeModel> _recipes = [];
  final List<RecipeModel> _liveSearchResults = [];
  int _totalCount = 0;

  bool get isLoading => _isLoading;
  bool get isSearchingLive => _isSearchingLive;
  String get errorMessage => _errorMessage;
  List<RecipeModel> get recipes => List.unmodifiable(_recipes);
  List<RecipeModel> get activeRecipes => _recipes.where((r) => r.isActive).toList();
  List<RecipeModel> get liveSearchResults => List.unmodifiable(_liveSearchResults);
  int get totalCount => _totalCount;

  // Real-Time Socket.IO Integration
  void _initSocket() {
    try {
      final socketUrl = ApiConstants.baseUrl;
      _socket = socket_io.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      _socket?.onConnect((_) {
        debugPrint('🍛 [RECIPES SOCKET CONNECTED] Realtime recipe sync active');
      });

      _socket?.on('recipe_created', (data) {
        if (data != null) {
          final newRec = RecipeModel.fromJson(Map<String, dynamic>.from(data));
          _recipes.removeWhere((r) => r.id == newRec.id);
          _recipes.insert(0, newRec);
          _totalCount++;
          notifyListeners();
        }
      });

      _socket?.on('recipe_updated', (data) {
        if (data != null) {
          final updated = RecipeModel.fromJson(Map<String, dynamic>.from(data));
          final idx = _recipes.indexWhere((r) => r.id == updated.id);
          if (idx != -1) {
            _recipes[idx] = updated;
          } else {
            _recipes.insert(0, updated);
          }
          notifyListeners();
        }
      });

      _socket?.on('recipe_deleted', (data) {
        if (data != null && data['id'] != null) {
          final id = data['id'].toString();
          _recipes.removeWhere((r) => r.id == id);
          _totalCount = _totalCount > 0 ? _totalCount - 1 : 0;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error initializing recipe socket: $e');
    }
  }

  /// Fetch Recipes from MongoDB via Express API
  Future<void> fetchRecipes({
    String? search,
    String? category,
    String? cuisine,
    String? dietaryType,
    int page = 1,
    int limit = 100,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
      if (category != null && category != 'All Recipes' && category != 'All') queryParams['category'] = category;
      if (cuisine != null && cuisine != 'All Cuisines' && cuisine != 'All') queryParams['cuisine'] = cuisine;
      if (dietaryType != null && dietaryType != 'All Diets' && dietaryType != 'All') queryParams['dietaryType'] = dietaryType;

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/recipes').replace(queryParameters: queryParams);
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        List<dynamic> list = [];
        if (body is Map && body['data'] is List) {
          list = body['data'];
          _totalCount = body['totalCount'] ?? list.length;
        } else if (body is List) {
          list = body;
          _totalCount = list.length;
        }

        _recipes.clear();
        for (var item in list) {
          _recipes.add(RecipeModel.fromJson(Map<String, dynamic>.from(item)));
        }
      } else {
        _errorMessage = 'Server error: ${res.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Unified Multi-Source Live Recipe Search (All, Indian, USDA, TheMealDB)
  Future<List<RecipeModel>> searchLiveRecipes(String query, {String source = 'all'}) async {
    _isSearchingLive = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'source': source,
      };
      if (query.trim().isNotEmpty) {
        queryParams['query'] = query.trim();
      }

      String endpoint = '/api/recipes/search-live';
      if (source == 'indian') {
        endpoint = '/api/recipes/search-indian';
      } else if (source == 'usda') {
        endpoint = '/api/recipes/search-usda';
      } else if (source == 'mealdb') {
        endpoint = '/api/recipes/search-mealdb';
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(queryParameters: queryParams);
      debugPrint('🍛 [LIVE RECIPE SEARCH - $source] Querying: $uri');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List? ?? [];
        _liveSearchResults.clear();
        for (var item in list) {
          _liveSearchResults.add(RecipeModel.fromJson(Map<String, dynamic>.from(item)));
        }
        debugPrint('🍛 [LIVE RECIPE SEARCH - $source] Found ${_liveSearchResults.length} recipes for "$query"');
        return _liveSearchResults;
      } else {
        debugPrint('🍛 [LIVE RECIPE SEARCH ERROR] Status: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('🍛 [LIVE RECIPE SEARCH EXCEPTION]: $e');
    } finally {
      _isSearchingLive = false;
      notifyListeners();
    }
    return [];
  }

  /// Search Live Indian Recipes
  Future<List<RecipeModel>> searchLiveIndianRecipes(String query) =>
      searchLiveRecipes(query, source: 'indian');

  /// Search USDA & Global Healthy Recipes
  Future<List<RecipeModel>> searchUsdaRecipes(String query) =>
      searchLiveRecipes(query, source: 'usda');

  /// Search TheMealDB Global Recipes
  Future<List<RecipeModel>> searchMealDbRecipes(String query) =>
      searchLiveRecipes(query, source: 'mealdb');

  /// Create a new Recipe
  Future<RecipeModel?> createRecipe(RecipeModel recipe) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/recipes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(recipe.toJson()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        final data = body['data'] ?? body;
        final created = RecipeModel.fromJson(Map<String, dynamic>.from(data));

        _recipes.removeWhere((r) => r.id == created.id);
        _recipes.insert(0, created);
        _totalCount++;
        notifyListeners();
        return created;
      }
    } catch (e) {
      debugPrint('Error creating recipe: $e');
    }
    return null;
  }

  /// Update an existing Recipe
  Future<bool> updateRecipe(RecipeModel recipe) async {
    try {
      final idx = _recipes.indexWhere((r) => r.id == recipe.id);
      if (idx != -1) {
        _recipes[idx] = recipe;
        notifyListeners();
      }

      final res = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/recipes/${recipe.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(recipe.toJson()),
      );

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating recipe: $e');
      return false;
    }
  }

  /// Delete a Recipe
  Future<bool> deleteRecipe(String recipeId) async {
    try {
      _recipes.removeWhere((r) => r.id == recipeId);
      _totalCount = _totalCount > 0 ? _totalCount - 1 : 0;
      notifyListeners();

      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/recipes/$recipeId'),
      );

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting recipe: $e');
      return false;
    }
  }
}
