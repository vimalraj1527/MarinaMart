import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';
import '../models/product_model.dart';

class ProductListController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxList<Product> categoryProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> fetchProductsByCategory(String category) async {
    try {
      isLoading.value = true;
      categoryProducts.clear();
      
      // We pass the category name as a query param to the backend
      final query = category.toLowerCase().contains("dairy") || category.toLowerCase().contains("diary") ? "dairy" : category;
      
      final response = await _apiService.getData("${AppConstants.productsUrl}?category=$query");
      
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        categoryProducts.assignAll(data.map((e) => Product.fromJson(e)).toList());
      }
    } catch (e) {
      print("Error fetching category products: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
