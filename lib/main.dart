import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/job_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/notification_service.dart';
// Import all services and repositories
import 'data/services/storage_service.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all services and repositories
  await initializeServices();

  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));
}

Future<void> initializeServices() async {
  // Initialize storage service first (required by others)
  await Get.putAsync(() => StorageService().init());

  // Initialize API service
  Get.put(ApiService());

  // Initialize notification service
  await Get.putAsync(() => NotificationService().init());

  // Initialize repositories
  Get.put(AuthRepository());
  Get.put(ProfileRepository());
  Get.put(JobRepository());
  Get.put(ChatRepository());
}

// Extension to handle async initialization
extension ServiceInitializer on StorageService {
  Future<StorageService> init() async {
    await onInit();
    return this;
  }
}

extension NotificationServiceInitializer on NotificationService {
  Future<NotificationService> init() async {
    await onInit();
    return this;
  }
}

class Main extends StatelessWidget {
  final String initialRoute;

  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: Nav.routes,
    );
  }
}
