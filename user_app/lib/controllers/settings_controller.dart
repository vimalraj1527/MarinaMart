import 'dart:convert';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SettingsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final StorageService _storage = Get.find<StorageService>();

  final RxDouble freeDeliveryThreshold = 499.0.obs;
  final RxDouble baseDeliveryCharge = 25.0.obs; // Scheduled
  final RxDouble instantBaseFee = 50.0.obs;    // Instant Base
  final RxDouble perKmCharge = 5.0.obs;       // Instant Per KM
  
  final RxString storeName = "Bloomarina Instamart".obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLocalSettings();
    fetchRemoteSettings();
  }

  void loadLocalSettings() {
    String? local = _storage.getSettings();
    if (local != null) {
      try {
        final data = jsonDecode(local);
        _applySettings(data);
      } catch (e) {
        print("Error parsing local settings: $e");
      }
    }
  }

  Future<void> fetchRemoteSettings() async {
    try {
      isLoading.value = true;
      final response = await _api.getData('/settings');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _applySettings(data);
        // Persist for offline/next launch
        await _storage.setSettings(response.body);
      }
    } catch (e) {
       print("Failed to sync remote settings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _applySettings(Map<String, dynamic> data) {
    if (data['delivery'] != null) {
       final d = data['delivery'];
       freeDeliveryThreshold.value = (d['freeThreshold'] ?? 499.0).toDouble();
       baseDeliveryCharge.value = (d['baseCharge'] ?? 25.0).toDouble();
       instantBaseFee.value = (d['instantBase'] ?? 50.0).toDouble();
       perKmCharge.value = (d['perKmCharge'] ?? 5.0).toDouble();
    }
    if (data['store'] != null) {
       storeName.value = data['store']['name'] ?? "Bloomarina Instamart";
    }
  }
}
