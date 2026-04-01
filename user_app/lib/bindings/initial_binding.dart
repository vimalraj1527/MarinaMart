import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../controllers/cart_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services setup
    Get.lazyPut(() => StorageService());
    Get.lazyPut(() => ApiService());
    
    // Controllers setup
    Get.put(LocationController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(AuthController(), permanent: true);
  }
}
