import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<Category> categories = <Category>[].obs;
  final RxList banners = [].obs;
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      
      // Fetch Banners
      final bannerRes = await _apiService.getData(AppConstants.bannersUrl);
      if (bannerRes.statusCode == 200) {
        banners.value = jsonDecode(bannerRes.body);
      }

      // Fetch Categories
      final categoryRes = await _apiService.getData(AppConstants.categoriesUrl);
      if (categoryRes.statusCode == 200) {
        List data = jsonDecode(categoryRes.body);
        if (data.isNotEmpty) {
          categories.assignAll(data.map((e) => Category.fromJson(e)).toList());
        } else {
          _setFallbackCategories();
        }
      } else {
        _setFallbackCategories();
      }

      // Fetch Featured Products
      final productRes = await _apiService.getData(AppConstants.productsUrl);
      if (productRes.statusCode == 200) {
        List data = jsonDecode(productRes.body);
        products.assignAll(data.map((e) => Product.fromJson(e)).toList());
      }
      
    } catch (e) {
      _setFallbackCategories();
      Get.snackbar('Notice', 'Using offline categories');
    } finally {
      isLoading.value = false;
    }
  }

  void _setFallbackCategories() {
    final List<Map<String, String>> fallbackData = [
      {'id': '1', 'name': 'Fruits & Vegetables', 'image': ''},
      {'id': '2', 'name': 'Dairy, Bread & Eggs', 'image': ''},
      {'id': '3', 'name': 'Munchies & Chips', 'image': ''},
      {'id': '4', 'name': 'Cold Drinks & Juices', 'image': ''},
      {'id': '5', 'name': 'Tea, Coffee & Health', 'image': ''},
      {'id': '6', 'name': 'Atta, Rice & Dal', 'image': ''},
      {'id': '7', 'name': 'Masala, Oil & More', 'image': ''},
      {'id': '8', 'name': 'Chicken, Meat & Fish', 'image': ''},
      {'id': '9', 'name': 'Cleaning Essentials', 'image': ''},
      {'id': '10', 'name': 'Personal Care', 'image': ''},
      {'id': '11', 'name': 'Baby Care', 'image': ''},
      {'id': '12', 'name': 'Pet Care', 'image': ''},
    ];
    categories.assignAll(fallbackData.map((e) => Category.fromJson(e)).toList());
  }
}
