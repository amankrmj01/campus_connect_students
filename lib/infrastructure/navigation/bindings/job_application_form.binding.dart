// lib/infrastructure/navigation/bindings/job_application_form.binding.dart
import 'package:get/get.dart';

import '../../../presentation/jobs/controllers/job_application_form.controller.dart';

class JobApplicationFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobApplicationFormController>(
      () => JobApplicationFormController(),
    );
  }
}
