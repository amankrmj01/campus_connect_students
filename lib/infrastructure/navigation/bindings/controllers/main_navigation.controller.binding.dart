// lib/infrastructure/navigation/bindings/controllers/main_navigation.controller.binding.dart
import 'package:get/get.dart';

import '../../../../presentation/main_navigation/controllers/main_navigation.controller.dart';

class MainNavigationControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
  }
}
