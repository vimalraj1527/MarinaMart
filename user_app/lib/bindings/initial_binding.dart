import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/cart_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services setup
    // StorageService is already put in main.dart's Get.put(storage, permanent: true)
    Get.lazyPut(() => ApiService());
    
    // Controllers setup
    Get.put(ThemeController(), permanent: true);
    Get.put(LocationController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(SettingsController(), permanent: true);
  }
}
