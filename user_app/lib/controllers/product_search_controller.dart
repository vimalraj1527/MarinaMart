import 'dart:convert';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../models/product_model.dart';
import 'home_controller.dart';

class ProductSearchController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  var searchResults = <Product>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  
  // Recent searches and autocompletion suggestions
  var recentSearches = <String>[].obs;
  var suggestions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
  }

  void loadRecentSearches() {
    try {
      recentSearches.assignAll(_storageService.getRecentSearches());
    } catch (e) {
      print("ERROR_LOADING_RECENT_SEARCHES: $e");
    }
  }

  void addRecentSearch(String query) {
    final cleaned = query.trim();
    if (cleaned.isEmpty) return;
    
    // Remove if already exists (case-insensitive) to move it to the top
    recentSearches.removeWhere((element) => element.toLowerCase() == cleaned.toLowerCase());
    recentSearches.insert(0, cleaned);
    
    // Limit to top 10 recent searches
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
    
    _storageService.saveRecentSearches(recentSearches);
  }

  void removeRecentSearch(String query) {
    recentSearches.remove(query);
    _storageService.saveRecentSearches(recentSearches);
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _storageService.saveRecentSearches([]);
  }

  void updateSuggestions(String query) {
    if (query.trim().isEmpty) {
      suggestions.clear();
      return;
    }
    
    final normalizedQuery = query.toLowerCase().trim();
    final uniqueSuggestions = <String>{};
    
    try {
      final homeController = Get.find<HomeController>();
      
      // 1. Match against categories
      for (var cat in homeController.categories) {
        if (cat.name.toLowerCase().contains(normalizedQuery)) {
          uniqueSuggestions.add(cat.name);
        }
      }
      
      // 2. Match against products
      for (var prod in homeController.products) {
        if (prod.name.toLowerCase().contains(normalizedQuery)) {
          uniqueSuggestions.add(prod.name);
        }
        if (prod.category.toLowerCase().contains(normalizedQuery)) {
          uniqueSuggestions.add(prod.category);
        }
      }
    } catch (e) {
      print("ERROR_UPDATING_SUGGESTIONS: $e");
    }
    
    // Sort suggestions: starts-with matches first, then alphabetic
    final sortedList = uniqueSuggestions.toList();
    sortedList.sort((a, b) {
      final aStart = a.toLowerCase().startsWith(normalizedQuery);
      final bStart = b.toLowerCase().startsWith(normalizedQuery);
      if (aStart && !bStart) return -1;
      if (!aStart && bStart) return 1;
      return a.compareTo(b);
    });
    
    suggestions.assignAll(sortedList.take(6).toList());
  }

  void searchProducts(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      searchQuery('');
      return;
    }
    
    try {
      isLoading(true);
      searchQuery(query);
      
      // Save query to recent searches
      addRecentSearch(query);
      
      final response = await _apiService.getData('/products?search=$query');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        searchResults.assignAll(data.map((e) => Product.fromJson(e)).toList());
      } else {
        searchResults.clear();
      }
    } catch (e) {
      print("SEARCH_ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  void searchByCategory(String categoryId) async {
    try {
      isLoading(true);
      searchQuery(''); // Clear general search query
      final response = await _apiService.getData('/products?categoryId=$categoryId');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        searchResults.assignAll(data.map((e) => Product.fromJson(e)).toList());
      } else {
        searchResults.clear();
      }
    } catch (e) {
      print("CATEGORY_SEARCH_ERROR: $e");
    } finally {
      isLoading(false);
    }
  }

  void clearSearch() {
    searchQuery('');
    searchResults.clear();
    suggestions.clear();
  }
}
