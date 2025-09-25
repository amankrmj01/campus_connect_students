import 'package:get/get.dart';

import '../../../../presentation/groups/controllers/groups.controller.dart';

class GroupsControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupsController>(
      () => GroupsController(),
    );
  }
}
