// lib/presentation/settings/settings.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/settings.controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade700, Colors.blue.shade900],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildProfileSection(),
                  const SizedBox(height: 16),

                  // Notifications Section
                  _buildNotificationsSection(),
                  const SizedBox(height: 16),

                  // Appearance Section
                  _buildAppearanceSection(),
                  const SizedBox(height: 16),

                  // Security Section
                  _buildSecuritySection(),
                  const SizedBox(height: 16),

                  // Data & Storage Section
                  _buildDataStorageSection(),
                  const SizedBox(height: 16),

                  // About Section
                  _buildAboutSection(),
                  const SizedBox(height: 16),

                  // Danger Zone Section
                  _buildDangerZoneSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Profile Info
            Obx(
              () => Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade100,
                    ),
                    child:
                        controller.currentStudent.value?.profilePicture != null
                        ? ClipOval(
                            child: Image.network(
                              controller.currentStudent.value!.profilePicture!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.person,
                                    color: Colors.blue.shade700,
                                    size: 30,
                                  ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: Colors.blue.shade700,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.currentStudent.value?.name ??
                              'Student Name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          controller.currentStudent.value?.email ??
                              'student@college.edu',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: controller.goToProfile,
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Master notification toggle
            Obx(
              () => SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Enable all notifications'),
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const Divider(),

            // Job Alerts
            Obx(
              () => SwitchListTile(
                title: const Text('Job Alerts'),
                subtitle: const Text(
                  'New job opportunities matching your profile',
                ),
                value: controller.jobAlertsEnabled.value,
                onChanged: controller.notificationsEnabled.value
                    ? controller.toggleJobAlerts
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            // Application Updates
            Obx(
              () => SwitchListTile(
                title: const Text('Application Updates'),
                subtitle: const Text('Status changes for your applications'),
                value: controller.applicationUpdatesEnabled.value,
                onChanged: controller.notificationsEnabled.value
                    ? controller.toggleApplicationUpdates
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            // Group Messages
            Obx(
              () => SwitchListTile(
                title: const Text('Group Messages'),
                subtitle: const Text('New messages in recruitment groups'),
                value: controller.groupMessagesEnabled.value,
                onChanged: controller.notificationsEnabled.value
                    ? controller.toggleGroupMessages
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            // System Announcements
            Obx(
              () => SwitchListTile(
                title: const Text('System Announcements'),
                subtitle: const Text('Important updates from your college'),
                value: controller.systemAnnouncementsEnabled.value,
                onChanged: controller.notificationsEnabled.value
                    ? controller.toggleSystemAnnouncements
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dark Mode
            Obx(
              () => SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                value: controller.darkModeEnabled.value,
                onChanged: controller.toggleDarkMode,
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.dark_mode),
              ),
            ),

            const Divider(),

            // Language Selection
            ListTile(
              title: const Text('Language'),
              subtitle: Obx(
                () => Text('Current: ${controller.selectedLanguage.value}'),
              ),
              leading: const Icon(Icons.language),
              trailing: const Icon(Icons.arrow_forward_ios),
              contentPadding: EdgeInsets.zero,
              onTap: _showLanguageDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Change Password
            ListTile(
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              leading: const Icon(Icons.lock),
              trailing: const Icon(Icons.arrow_forward_ios),
              contentPadding: EdgeInsets.zero,
              onTap: controller.goToChangePassword,
            ),

            const Divider(),

            // Biometric Authentication
            Obx(
              () => SwitchListTile(
                title: const Text('Biometric Login'),
                subtitle: const Text('Use fingerprint or face recognition'),
                value: controller.biometricEnabled.value,
                onChanged: controller.toggleBiometric,
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.fingerprint),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataStorageSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data & Storage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Clear Cache
            ListTile(
              title: const Text('Clear Cache'),
              subtitle: const Text('Free up storage space'),
              leading: const Icon(Icons.cleaning_services),
              trailing: Obx(
                () => controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios),
              ),
              contentPadding: EdgeInsets.zero,
              onTap: controller.isLoading.value ? null : controller.clearCache,
            ),

            const Divider(),

            // Export Data
            ListTile(
              title: const Text('Export Data'),
              subtitle: const Text('Download your personal data'),
              leading: const Icon(Icons.download),
              trailing: const Icon(Icons.arrow_forward_ios),
              contentPadding: EdgeInsets.zero,
              onTap: controller.exportData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // App Info
            ListTile(
              title: const Text('About P Connect'),
              subtitle: const Text('Version info and details'),
              leading: const Icon(Icons.info),
              trailing: const Icon(Icons.arrow_forward_ios),
              contentPadding: EdgeInsets.zero,
              onTap: controller.showAboutDialog,
            ),

            const Divider(),

            // Privacy Policy
            ListTile(
              title: const Text('Privacy Policy'),
              subtitle: const Text('How we handle your data'),
              leading: const Icon(Icons.privacy_tip),
              trailing: const Icon(Icons.arrow_forward_ios),
              contentPadding: EdgeInsets.zero,
              onTap: controller.showPrivacyPolicy,
            ),

            const Divider(),

            // Terms of Service
            ListTile(
              title: const Text('Terms of Service'),
              subtitle: const Text('Terms and conditions'),
              leading: const Icon(Icons.description),
              trailing: const Icon(Icons.arrow_forward_ios),
              contentPadding: EdgeInsets.zero,
              onTap: controller.showTermsOfService,
            ),

            const Divider(),

            // Contact Support
            ListTile(
              title: const Text('Contact Support'),
              subtitle: const Text('Get help and support'),
              leading: const Icon(Icons.support_agent),
              trailing: const Icon(Icons.arrow_forward_ios),
              contentPadding: EdgeInsets.zero,
              onTap: controller.contactSupport,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Delete Account
            ListTile(
              title: Text(
                'Delete Account',
                style: TextStyle(color: Colors.red.shade600),
              ),
              subtitle: const Text('Permanently delete your account and data'),
              leading: Icon(Icons.delete_forever, color: Colors.red.shade600),
              trailing: const Icon(Icons.arrow_forward_ios),
              contentPadding: EdgeInsets.zero,
              onTap: controller.deleteAccount,
            ),

            const Divider(),

            // Logout
            ListTile(
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.orange.shade600),
              ),
              subtitle: const Text('Sign out of your account'),
              leading: Icon(Icons.logout, color: Colors.orange.shade600),
              trailing: const Icon(Icons.arrow_forward_ios),
              contentPadding: EdgeInsets.zero,
              onTap: controller.logout,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.availableLanguages.length,
            itemBuilder: (context, index) {
              final language = controller.availableLanguages[index];
              return Obx(
                () => RadioListTile<String>(
                  title: Text(language),
                  value: language,
                  groupValue: controller.selectedLanguage.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeLanguage(value);
                      Get.back();
                    }
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }
}
