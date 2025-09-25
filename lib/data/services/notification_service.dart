// lib/data/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;

import 'storage_service.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StorageService _storageService = Get.find<StorageService>();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Android initialization
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Android permissions (13+)
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
    // iOS permissions are commented out for now
    // final iosImplementation = _flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //     IOSFlutterLocalNotificationsPlugin
    // >();
    // if (iosImplementation != null) {
    //   await iosImplementation.requestPermissions(
    //     alert: true,
    //     badge: true,
    //     sound: true,
    //   );
    // }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  void _handleNotificationPayload(String payload) {
    try {
      // Parse payload and navigate accordingly
      if (payload.contains('job_')) {
        final jobId = payload.split('_')[1];
        Get.toNamed('/jobs/details', arguments: {'jobId': jobId});
      } else if (payload.contains('application_')) {
        final applicationId = payload.split('_')[1];
        Get.toNamed(
          '/applications',
          arguments: {'applicationId': applicationId},
        );
      } else if (payload.contains('group_')) {
        final groupId = payload.split('_')[1];
        Get.toNamed('/groups', arguments: {'groupId': groupId});
      } else {
        Get.toNamed('/dashboard');
      }
    } catch (e) {
      print('Error handling notification payload: $e');
      Get.toNamed('/dashboard');
    }
  }

  // Show instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
  }) async {
    final isEnabled =
        await _storageService.getBool('notifications_enabled') ?? true;
    if (!isEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: channel.priority,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF2196F3),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Show job alert notification
  Future<void> showJobAlert({
    required String jobId,
    required String companyName,
    required String jobTitle,
  }) async {
    final isEnabled =
        await _storageService.getBool('job_alerts_enabled') ?? true;
    if (!isEnabled) return;

    await showNotification(
      id: jobId.hashCode,
      title: 'New Job Opportunity',
      body: '$jobTitle at $companyName',
      payload: 'job_$jobId',
      channel: NotificationChannel.jobAlerts,
    );
  }

  // Show application update notification
  Future<void> showApplicationUpdate({
    required String applicationId,
    required String companyName,
    required String status,
  }) async {
    final isEnabled =
        await _storageService.getBool('application_updates_enabled') ?? true;
    if (!isEnabled) return;

    String title = 'Application Update';
    String body = 'Your application at $companyName has been updated: $status';

    if (status.toLowerCase().contains('shortlist')) {
      title = '🎉 Congratulations!';
      body = 'You have been shortlisted by $companyName';
    } else if (status.toLowerCase().contains('selected')) {
      title = '🎊 You got the job!';
      body = 'Congratulations! You have been selected by $companyName';
    }

    await showNotification(
      id: applicationId.hashCode,
      title: title,
      body: body,
      payload: 'application_$applicationId',
      channel: NotificationChannel.applicationUpdates,
    );
  }

  // Show group message notification
  Future<void> showGroupMessage({
    required String groupId,
    required String senderName,
    required String message,
    required String jobTitle,
  }) async {
    final isEnabled =
        await _storageService.getBool('group_messages_enabled') ?? true;
    if (!isEnabled) return;

    await showNotification(
      id: groupId.hashCode,
      title: '$senderName in $jobTitle',
      body: message.length > 100 ? '${message.substring(0, 100)}...' : message,
      payload: 'group_$groupId',
      channel: NotificationChannel.groupMessages,
    );
  }

  // Show system announcement
  Future<void> showSystemAnnouncement({
    required String title,
    required String message,
  }) async {
    final isEnabled =
        await _storageService.getBool('system_announcements_enabled') ?? true;
    if (!isEnabled) return;

    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: message,
      payload: 'announcement',
      channel: NotificationChannel.systemAnnouncements,
    );
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
  }) async {
    final isEnabled =
        await _storageService.getBool('notifications_enabled') ?? true;
    if (!isEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: channel.priority,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF2196F3),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Schedule application deadline reminder
  Future<void> scheduleApplicationDeadlineReminder({
    required String jobId,
    required String companyName,
    required String jobTitle,
    required DateTime deadline,
  }) async {
    final reminderTime = deadline.subtract(const Duration(days: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    await scheduleNotification(
      id: 'deadline_$jobId'.hashCode,
      title: 'Application Deadline Tomorrow',
      body: 'Don\'t forget to apply for $jobTitle at $companyName',
      scheduledDate: reminderTime,
      payload: 'job_$jobId',
      channel: NotificationChannel.jobAlerts,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Clear badge count (iOS)
  // Future<void> clearBadgeCount() async {
  //   final iosImplementation = _flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //       IOSFlutterLocalNotificationsPlugin
  //   >();
  //
  //   if (iosImplementation != null) {
  //     // For newer versions, use setBadgeCount
  //     try {
  //       await iosImplementation.setBadgeCount(0);
  //     } catch (e) {
  //       print('Error clearing badge count: $e');
  //     }
  //   }
  // }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (GetPlatform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    // iOS implementation commented out for now
    // else if (GetPlatform.isIOS) {
    //   final iosImplementation = _flutterLocalNotificationsPlugin
    //       .resolvePlatformSpecificImplementation<
    //       IOSFlutterLocalNotificationsPlugin
    //   >();
    //   if (iosImplementation != null) {
    //     final settings = await iosImplementation.getNotificationSettings();
    //     return settings?.authorizationStatus == AuthorizationStatus.authorized;
    //   }
    // }
    return false;
  }

  // Request exact alarm permission (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    if (GetPlatform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidImplementation?.requestExactAlarmsPermission() ??
          false;
    }
    return true; // Not needed on iOS
  }

  // Show notification with actions (Android)
  Future<void> showNotificationWithActions({
    required int id,
    required String title,
    required String body,
    required List<AndroidNotificationAction> actions,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: channel.priority,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF2196F3),
      actions: actions,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Show big text notification (Android)
  Future<void> showBigTextNotification({
    required int id,
    required String title,
    required String body,
    required String bigText,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: channel.priority,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF2196F3),
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: title,
        summaryText: 'P Connect',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Show progress notification (Android)
  Future<void> showProgressNotification({
    required int id,
    required String title,
    required int progress,
    required int maxProgress,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'progress',
      'Progress Notifications',
      channelDescription: 'Shows progress for ongoing operations',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      indeterminate: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      '$progress/$maxProgress',
      details,
      payload: payload,
    );
  }

  // Test notification (for debugging)
  Future<void> showTestNotification() async {
    await showNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification from P Connect',
      payload: 'test',
    );
  }
}

// Notification Channels
class NotificationChannel {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  final Priority priority;

  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = Importance.defaultImportance,
    this.priority = Priority.defaultPriority,
  });

  static const general = NotificationChannel(
    id: 'general',
    name: 'General Notifications',
    description: 'General app notifications',
  );

  static const jobAlerts = NotificationChannel(
    id: 'job_alerts',
    name: 'Job Alerts',
    description: 'New job opportunities and application deadlines',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const applicationUpdates = NotificationChannel(
    id: 'application_updates',
    name: 'Application Updates',
    description: 'Status changes for your job applications',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const groupMessages = NotificationChannel(
    id: 'group_messages',
    name: 'Group Messages',
    description: 'Messages in recruitment groups',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  static const systemAnnouncements = NotificationChannel(
    id: 'system_announcements',
    name: 'System Announcements',
    description: 'Important updates from your college',
    importance: Importance.high,
    priority: Priority.high,
  );
}
