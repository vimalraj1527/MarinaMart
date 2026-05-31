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
        categories.assignAll(data.map((e) => Category.fromJson(e)).toList());
      }

      // Fetch Featured Products
      final productRes = await _apiService.getData(AppConstants.productsUrl);
      if (productRes.statusCode == 200) {
        List data = jsonDecode(productRes.body);
        products.assignAll(data.map((e) => Product.fromJson(e)).toList());
      }
      
    } catch (e) {
      print("API_ERROR: $e");
      Get.snackbar(
        'Connection Error', 
        'Could not fetch data. Please check your internet or pull to refresh.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
