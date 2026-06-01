import 'package:get/get.dart';

class MainShellController extends GetxController {
  static MainShellController get to => Get.find();
  
  final RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
