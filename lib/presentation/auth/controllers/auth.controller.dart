// lib/presentation/auth/controllers/auth.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/student_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../infrastructure/navigation/routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Reactive variables
  final Rx<Student?> currentStudent = Rx<Student?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool requiresPasswordChange = false.obs;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
    // Check route arguments for password change requirement
    final args = Get.arguments as Map<String, dynamic>?;
    if (args?['requiresPasswordChange'] == true) {
      requiresPasswordChange.value = true;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Check if user is already logged in
  void checkAuthStatus() async {
    try {
      final token = await _storageService.getToken();
      final studentData = await _storageService.getStudentData();

      if (token != null && studentData != null) {
        currentStudent.value = Student.fromJson(studentData);
        isLoggedIn.value = true;

        // Navigate to home screen if user is already logged in
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      print('Auth check error: $e');
    }
  }

  // Login method
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response['success'] == true) {
        // Store token and user data
        await _storageService.saveToken(response['token']);
        await _storageService.saveStudentData(response['student']);

        currentStudent.value = Student.fromJson(response['student']);
        isLoggedIn.value = true;

        // Show success message
        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to home screen after successful login
        Get.offAllNamed(Routes.HOME);

        // Clear form
        clearLoginForm();
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Login failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Change password method
  Future<void> changePassword() async {
    if (!changePasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final response = await _authRepository.changePassword(
        passwordController.text,
        newPasswordController.text,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Password changed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to dashboard
        Get.offAllNamed(Routes.DASHBOARD);
        clearChangePasswordForm();
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Password change failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Change password error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      await _storageService.clearAll();

      currentStudent.value = null;
      isLoggedIn.value = false;

      Get.offAllNamed(Routes.AUTH);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // Clear login form
  void clearLoginForm() {
    emailController.clear();
    passwordController.clear();
  }

  // Clear change password form
  void clearChangePasswordForm() {
    passwordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  // Form validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
