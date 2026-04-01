import 'dart:convert';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';

class ProductSearchController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  var searchResults = <Product>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  void searchProducts(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      searchQuery('');
      return;
    }
    
    try {
      isLoading(true);
      searchQuery(query);
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
  }
}
