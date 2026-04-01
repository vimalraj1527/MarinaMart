import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';
import '../models/order_model.dart';

class OrdersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getData(AppConstants.ordersUrl);
      
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        orders.assignAll(data.map((e) => OrderModel.fromJson(e)).toList());
      }
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
