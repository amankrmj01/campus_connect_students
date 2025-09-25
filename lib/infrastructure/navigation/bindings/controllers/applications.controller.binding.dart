import 'package:get/get.dart';

import '../../../../presentation/applications/controllers/applications.controller.dart';

class ApplicationsControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicationsController>(
      () => ApplicationsController(),
    );
  }
}
