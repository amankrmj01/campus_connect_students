import 'package:get/get.dart';

import '../../../../presentation/jobs/controllers/jobs.controller.dart';

class JobsControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobsController>(
      () => JobsController(),
    );
  }
}
