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
  
  final RxDouble storeLat = 12.9716.obs; // Bangalore default
  final RxDouble storeLong = 77.5946.obs; // Bangalore default
  
  final RxString storeName = "MaRinaMaRt".obs;
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
        _applySettings(jsonDecode(response.body));
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
       final s = data['store'];
       storeName.value = s['name'] ?? "MaRinaMaRt";
       storeLat.value = (s['latitude'] ?? 12.9716).toDouble();
       storeLong.value = (s['longitude'] ?? 77.5946).toDouble();
    }
  }

  // Set the current user location as the Store Location (Admin Sync)
  Future<void> syncStoreToCurrentLocation(double lat, double lng) async {
    try {
      isLoading.value = true;
      final response = await _api.postData('/settings/bulk', {
        'store': {
          'latitude': lat,
          'longitude': lng,
        }
      });
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        storeLat.value = lat;
        storeLong.value = lng;
        Get.snackbar("Sync Success", "Store location updated to your current spot.");
      }
    } catch (e) {
      Get.snackbar("Sync Failed", "Could not update store location registry.");
    } finally {
      isLoading.value = false;
    }
  }
}
