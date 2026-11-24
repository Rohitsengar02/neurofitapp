import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../constants/api_constants.dart';
import '../models/food_model.dart';

class NutritionBackendService extends ChangeNotifier {
  static final NutritionBackendService _instance = NutritionBackendService._internal();
  factory NutritionBackendService() => _instance;

  NutritionBackendService._internal() {
    _initSocket();
    fetchFoods();
  }

  socket_io.Socket? _socket;
  bool _isLoading = false;
  bool _isSearchingOff = false;
  bool _isSearchingLive = false;
  String _errorMessage = '';
  String _activeLiveSource = 'all'; // 'all', 'ifct', 'usda', 'off'

  final List<FoodItemModel> _foods = [];
  final List<FoodItemModel> _offSearchResults = [];
  final List<FoodItemModel> _liveNutritionResults = [];
  int _totalCount = 0;

  bool get isLoading => _isLoading;
  bool get isSearchingOff => _isSearchingOff;
  bool get isSearchingLive => _isSearchingLive;
  String get errorMessage => _errorMessage;
  String get activeLiveSource => _activeLiveSource;
  List<FoodItemModel> get foods => List.unmodifiable(_foods);
  List<FoodItemModel> get activeFoods => _foods.where((f) => f.isActive).toList();
  List<FoodItemModel> get offSearchResults => List.unmodifiable(_offSearchResults);
  List<FoodItemModel> get liveNutritionResults => List.unmodifiable(_liveNutritionResults);
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
        debugPrint('🥗 [NUTRITION SOCKET CONNECTED] Real-time Food sync active');
      });

      _socket?.on('food_created', (data) {
        if (data != null) {
          final newFood = FoodItemModel.fromJson(Map<String, dynamic>.from(data));
          _foods.removeWhere((f) => f.id == newFood.id);
          _foods.insert(0, newFood);
          _totalCount++;
          notifyListeners();
        }
      });

      _socket?.on('food_updated', (data) {
        if (data != null) {
          final updatedFood = FoodItemModel.fromJson(Map<String, dynamic>.from(data));
          final idx = _foods.indexWhere((f) => f.id == updatedFood.id);
          if (idx != -1) {
            _foods[idx] = updatedFood;
          } else {
            _foods.insert(0, updatedFood);
          }
          notifyListeners();
        }
      });

      _socket?.on('food_deleted', (data) {
        if (data != null && data['id'] != null) {
          final id = data['id'].toString();
          _foods.removeWhere((f) => f.id == id);
          _totalCount = _totalCount > 0 ? _totalCount - 1 : 0;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error initializing nutrition socket: $e');
    }
  }

  /// Fetch Foods from MongoDB via Express API
  Future<void> fetchFoods({
    String? search,
    String? category,
    String? nutriscore,
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
      if (category != null && category != 'All Foods' && category != 'All') queryParams['category'] = category;
      if (nutriscore != null && nutriscore != 'All') queryParams['nutriscore'] = nutriscore;

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/foods').replace(queryParameters: queryParams);
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

        _foods.clear();
        for (var item in list) {
          _foods.add(FoodItemModel.fromJson(Map<String, dynamic>.from(item)));
        }
      } else {
        _errorMessage = 'Server error: ${res.statusCode}';
      }
    } catch (e) {
      debugPrint('Error fetching foods: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Unified Live Nutrition Search (IFCT + USDA + Open Food Facts)
  Future<List<FoodItemModel>> searchLiveNutrition(String query, {String source = 'all'}) async {
    _isSearchingLive = true;
    _activeLiveSource = source;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'source': source,
      };
      if (query.trim().isNotEmpty) queryParams['query'] = query.trim();

      String endpoint = '/api/foods/search-live';
      if (source == 'ifct') {
        endpoint = '/api/foods/search-ifct';
      } else if (source == 'usda') {
        endpoint = '/api/foods/search-usda';
      } else if (source == 'off') {
        endpoint = '/api/foods/search-off';
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(queryParameters: queryParams);
      debugPrint('🥗 [LIVE NUTRITION SEARCH - $source] Querying: $uri');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List? ?? [];
        _liveNutritionResults.clear();
        _offSearchResults.clear();

        for (var item in list) {
          final food = FoodItemModel.fromJson(Map<String, dynamic>.from(item));
          _liveNutritionResults.add(food);
          _offSearchResults.add(food);
        }
        debugPrint('🥗 [LIVE NUTRITION SEARCH - $source] Found ${_liveNutritionResults.length} items for "$query"');
        return _liveNutritionResults;
      } else {
        debugPrint('🥗 [LIVE NUTRITION SEARCH ERROR] Status: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('🥗 [LIVE NUTRITION SEARCH EXCEPTION]: $e');
    } finally {
      _isSearchingLive = false;
      _isSearchingOff = false;
      notifyListeners();
    }
    return [];
  }

  /// Search Open Food Facts Database Live
  Future<List<FoodItemModel>> searchOpenFoodFacts(String query) async {
    return searchLiveNutrition(query, source: 'off');
  }

  /// Search ICMR-NIN Indian Food Composition Tables
  Future<List<FoodItemModel>> searchIndianIfct(String query) async {
    return searchLiveNutrition(query, source: 'ifct');
  }

  /// Search USDA FoodData Central
  Future<List<FoodItemModel>> searchUsda(String query) async {
    return searchLiveNutrition(query, source: 'usda');
  }

  /// Create a new Food Item
  Future<FoodItemModel?> createFood(FoodItemModel food) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/foods'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(food.toJson()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        final data = body['data'] ?? body;
        final created = FoodItemModel.fromJson(Map<String, dynamic>.from(data));

        _foods.removeWhere((f) => f.id == created.id);
        _foods.insert(0, created);
        _totalCount++;
        notifyListeners();
        return created;
      }
    } catch (e) {
      debugPrint('Error creating food: $e');
    }
    return null;
  }

  /// Update an existing Food Item
  Future<bool> updateFood(FoodItemModel food) async {
    try {
      final idx = _foods.indexWhere((f) => f.id == food.id);
      if (idx != -1) {
        _foods[idx] = food;
        notifyListeners();
      }

      final res = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/foods/${food.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(food.toJson()),
      );

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating food: $e');
      return false;
    }
  }

  /// Delete a Food Item
  Future<bool> deleteFood(String foodId) async {
    try {
      _foods.removeWhere((f) => f.id == foodId);
      _totalCount = _totalCount > 0 ? _totalCount - 1 : 0;
      notifyListeners();

      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/foods/$foodId'),
      );

      return res.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting food: $e');
      return false;
    }
  }
}
