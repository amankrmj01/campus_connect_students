// lib/presentation/auth/auth.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth.controller.dart';
import 'views/change_password_screen_view.dart';
import 'views/login_screen_view.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Use controller's reactive variable instead of Get.arguments
        if (controller.requiresPasswordChange.value) {
          return const ChangePasswordScreenView();
        }

        return const LoginScreenView();
      }),
    );
  }
}
