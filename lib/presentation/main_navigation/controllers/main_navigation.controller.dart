// lib/presentation/main_navigation/controllers/main_navigation.controller.dart
import 'package:get/get.dart';

class MainNavigationController extends GetxController {
  // Current selected tab index
  final RxInt selectedIndex = 0.obs;

  // Change tab method
  void changeTab(int index) {
    selectedIndex.value = index;
  }

  // Navigate to specific tab from other parts of the app
  void navigateToTab(int index) {
    selectedIndex.value = index;
  }

  // Quick navigation methods for easy access
  void goToHome() => changeTab(0);

  void goToJobs() => changeTab(1);

  void goToApplications() => changeTab(2);

  void goToGroups() => changeTab(3);

  void goToProfile() => changeTab(4);

  // Get current tab name (useful for analytics or debugging)
  String getCurrentTabName() {
    switch (selectedIndex.value) {
      case 0:
        return 'Home';
      case 1:
        return 'Jobs';
      case 2:
        return 'Applications';
      case 3:
        return 'Groups';
      case 4:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with home tab
    selectedIndex.value = 0;
  }
}
