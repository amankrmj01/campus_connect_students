// lib/presentation/settings/controllers/settings.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/student_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../infrastructure/navigation/routes.dart';

class SettingsController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();

  // Reactive variables
  final Rx<Student?> currentStudent = Rx<Student?>(null);
  final RxBool isLoading = false.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool jobAlertsEnabled = true.obs;
  final RxBool applicationUpdatesEnabled = true.obs;
  final RxBool groupMessagesEnabled = true.obs;
  final RxBool systemAnnouncementsEnabled = true.obs;
  final RxBool darkModeEnabled = false.obs;
  final RxString selectedLanguage = 'English'.obs;
  final RxBool biometricEnabled = false.obs;

  // App info
  final RxString appVersion = '1.0.0'.obs;
  final RxString buildNumber = '1'.obs;

  // Available languages
  final List<String> availableLanguages = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
  ];

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadStudentData();
  }

  // Load current student data
  Future<void> loadStudentData() async {
    try {
      final studentData = await _storageService.getStudentData();
      if (studentData != null) {
        currentStudent.value = Student.fromJson(studentData);
      }
    } catch (e) {
      print('Load student data error: $e');
    }
  }

  // Load settings from storage
  Future<void> loadSettings() async {
    try {
      notificationsEnabled.value =
          await _storageService.getBool('notifications_enabled') ?? true;
      jobAlertsEnabled.value =
          await _storageService.getBool('job_alerts_enabled') ?? true;
      applicationUpdatesEnabled.value =
          await _storageService.getBool('application_updates_enabled') ?? true;
      groupMessagesEnabled.value =
          await _storageService.getBool('group_messages_enabled') ?? true;
      systemAnnouncementsEnabled.value =
          await _storageService.getBool('system_announcements_enabled') ?? true;
      darkModeEnabled.value =
          await _storageService.getBool('dark_mode_enabled') ?? false;
      selectedLanguage.value =
          await _storageService.getString('selected_language') ?? 'English';
      biometricEnabled.value =
          await _storageService.getBool('biometric_enabled') ?? false;
    } catch (e) {
      print('Load settings error: $e');
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    try {
      notificationsEnabled.value = value;
      await _storageService.setBool('notifications_enabled', value);

      if (!value) {
        // If notifications are disabled, disable all sub-notifications
        jobAlertsEnabled.value = false;
        applicationUpdatesEnabled.value = false;
        groupMessagesEnabled.value = false;
        systemAnnouncementsEnabled.value = false;

        await _storageService.setBool('job_alerts_enabled', false);
        await _storageService.setBool('application_updates_enabled', false);
        await _storageService.setBool('group_messages_enabled', false);
        await _storageService.setBool('system_announcements_enabled', false);
      }

      Get.snackbar(
        'Settings Updated',
        'Notification settings have been updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Toggle notifications error: $e');
    }
  }

  // Toggle job alerts
  Future<void> toggleJobAlerts(bool value) async {
    try {
      jobAlertsEnabled.value = value;
      await _storageService.setBool('job_alerts_enabled', value);
    } catch (e) {
      print('Toggle job alerts error: $e');
    }
  }

  // Toggle application updates
  Future<void> toggleApplicationUpdates(bool value) async {
    try {
      applicationUpdatesEnabled.value = value;
      await _storageService.setBool('application_updates_enabled', value);
    } catch (e) {
      print('Toggle application updates error: $e');
    }
  }

  // Toggle group messages
  Future<void> toggleGroupMessages(bool value) async {
    try {
      groupMessagesEnabled.value = value;
      await _storageService.setBool('group_messages_enabled', value);
    } catch (e) {
      print('Toggle group messages error: $e');
    }
  }

  // Toggle system announcements
  Future<void> toggleSystemAnnouncements(bool value) async {
    try {
      systemAnnouncementsEnabled.value = value;
      await _storageService.setBool('system_announcements_enabled', value);
    } catch (e) {
      print('Toggle system announcements error: $e');
    }
  }

  // Toggle dark mode
  Future<void> toggleDarkMode(bool value) async {
    try {
      darkModeEnabled.value = value;
      await _storageService.setBool('dark_mode_enabled', value);

      // Apply theme change
      if (value) {
        Get.changeTheme(ThemeData.dark());
      } else {
        Get.changeTheme(ThemeData.light());
      }

      Get.snackbar(
        'Theme Updated',
        'App theme has been changed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Toggle dark mode error: $e');
    }
  }

  // Change language
  Future<void> changeLanguage(String language) async {
    try {
      selectedLanguage.value = language;
      await _storageService.setString('selected_language', language);

      // TODO: Implement actual language change
      Get.snackbar(
        'Language Updated',
        'Language has been changed to $language',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Change language error: $e');
    }
  }

  // Toggle biometric authentication
  Future<void> toggleBiometric(bool value) async {
    try {
      // TODO: Check if biometric is available on device
      biometricEnabled.value = value;
      await _storageService.setBool('biometric_enabled', value);

      Get.snackbar(
        'Security Updated',
        'Biometric authentication has been ${value ? 'enabled' : 'disabled'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Toggle biometric error: $e');
    }
  }

  // Navigate to profile
  void goToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  // Navigate to change password
  void goToChangePassword() {
    Get.toNamed(Routes.AUTH + '/change-password');
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      isLoading.value = true;

      // Simulate cache clearing
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Cache Cleared',
        'App cache has been cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear cache',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Show about dialog
  void showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('About P Connect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${appVersion.value}'),
            Text('Build: ${buildNumber.value}'),
            const SizedBox(height: 16),
            const Text(
              'P Connect is a comprehensive recruitment platform designed to streamline the placement process for students, colleges, and recruiters.',
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2024 P Connect. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  // Show privacy policy
  void showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'Last updated: January 2024\n\n'
            '1. Information We Collect\n'
            'We collect information you provide directly to us, such as when you create an account, update your profile, or communicate with us.\n\n'
            '2. How We Use Your Information\n'
            'We use the information we collect to provide, maintain, and improve our services.\n\n'
            '3. Information Sharing\n'
            'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent.\n\n'
            '4. Data Security\n'
            'We implement appropriate security measures to protect your personal information.\n\n'
            '5. Contact Us\n'
            'If you have any questions about this Privacy Policy, please contact us.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  // Show terms of service
  void showTermsOfService() {
    Get.dialog(
      AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service\n\n'
            'Last updated: January 2024\n\n'
            '1. Acceptance of Terms\n'
            'By accessing and using P Connect, you accept and agree to be bound by the terms and provision of this agreement.\n\n'
            '2. User Accounts\n'
            'You are responsible for maintaining the confidentiality of your account information.\n\n'
            '3. Prohibited Uses\n'
            'You may not use our service for any unlawful purpose or to solicit others to perform unlawful acts.\n\n'
            '4. Termination\n'
            'We may terminate your account at any time without notice for conduct that we believe violates these Terms.\n\n'
            '5. Changes to Terms\n'
            'We reserve the right to update these terms at any time.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  // Contact support
  void contactSupport() {
    Get.dialog(
      AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact our support team:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, size: 16),
                SizedBox(width: 8),
                Text('support@pconnect.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16),
                SizedBox(width: 8),
                Text('+91 12345 67890'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 8),
                Text('Mon-Fri: 9 AM - 6 PM'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Open email client
              Get.snackbar(
                'Opening Email',
                'Opening your email client...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  // Export data
  Future<void> exportData() async {
    try {
      isLoading.value = true;

      // Simulate data export
      await Future.delayed(const Duration(seconds: 3));

      Get.snackbar(
        'Data Exported',
        'Your data has been exported successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete account
  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _confirmDeleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Confirm delete account
  void _confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'This will permanently delete your account and all associated data. Type "DELETE" to confirm.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Type DELETE to confirm',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // TODO: Enable delete button only when "DELETE" is typed
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: null, // TODO: Enable based on confirmation text
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Account'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Logout
  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              try {
                await _storageService.clearAll();
                Get.offAllNamed(Routes.AUTH);
                Get.snackbar(
                  'Logged Out',
                  'You have been logged out successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to logout. Please try again.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
