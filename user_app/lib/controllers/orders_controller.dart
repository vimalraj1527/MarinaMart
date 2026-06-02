import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';
import '../models/order_model.dart';

class OrdersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  Timer? _pollTimer;

  // Active order = the most recent non-delivered, non-cancelled order
  OrderModel? get activeOrder {
    final active = orders.where((o) =>
        o.status != 'Delivered' && o.status != 'Cancelled').toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return active.first;
  }

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    // Poll every 30 seconds to catch status changes from admin
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchQuietly();
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
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

  // Silent refresh — no loading spinner, used for polling
  Future<void> _fetchQuietly() async {
    try {
      final response = await _apiService.getData(AppConstants.ordersUrl);
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        orders.assignAll(data.map((e) => OrderModel.fromJson(e)).toList());
      }
    } catch (_) {}
  }
}

