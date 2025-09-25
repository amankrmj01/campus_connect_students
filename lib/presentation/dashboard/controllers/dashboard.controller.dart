// lib/presentation/dashboard/controllers/dashboard.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/application_model.dart';
import '../../../data/models/enum.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../infrastructure/navigation/routes.dart';

// Rest of the controller code remains the same...

class DashboardController extends GetxController {
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();
  final JobRepository _jobRepository = Get.find<JobRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Reactive variables
  final Rx<Student?> currentStudent = Rx<Student?>(null);
  final RxList<Application> recentApplications = <Application>[].obs;
  final RxList<Job> recommendedJobs = <Job>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxInt profileCompletionPercentage = 0.obs;
  final RxInt totalApplications = 0.obs;
  final RxInt activeApplications = 0.obs;
  final RxInt shortlistedApplications = 0.obs;

  // Current time
  final RxString currentGreeting = ''.obs;
  final RxString currentTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeDashboard();
    updateGreeting();
    startTimeUpdater();
  }

  // Initialize dashboard data
  void initializeDashboard() async {
    try {
      isLoading.value = true;
      await loadStudentData();
      await loadDashboardData();
    } catch (e) {
      print('Dashboard initialization error: $e');
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load current student data
  Future<void> loadStudentData() async {
    try {
      final studentData = await _storageService.getStudentData();
      if (studentData != null) {
        currentStudent.value = Student.fromJson(studentData);
        calculateProfileCompletion();
      }
    } catch (e) {
      print('Load student data error: $e');
    }
  }

  // Load dashboard specific data
  Future<void> loadDashboardData() async {
    try {
      await Future.wait([
        loadRecentApplications(),
        loadRecommendedJobs(),
        loadApplicationStats(),
      ]);
    } catch (e) {
      print('Load dashboard data error: $e');
    }
  }

  // Load recent applications
  Future<void> loadRecentApplications() async {
    try {
      final response = await _profileRepository.getStudentApplications(
        limit: 5,
      );

      if (response['success'] == true) {
        final applications = (response['applications'] as List)
            .map((app) => Application.fromJson(app))
            .toList();
        recentApplications.assignAll(applications);
      }
    } catch (e) {
      print('Load recent applications error: $e');
    }
  }

  // Load recommended jobs
  Future<void> loadRecommendedJobs() async {
    try {
      if (currentStudent.value == null) return;

      final response = await _jobRepository.getFilteredJobs(
        cgpa: currentStudent.value!.academicDetails?.cgpa ?? 0.0,
        branch: currentStudent.value!.branch,
        degreeType: currentStudent.value!.degreeType,
        graduationYear:
            currentStudent.value!.academicDetails?.graduationYear ??
            DateTime.now().year,
        limit: 3,
      );

      if (response['success'] == true) {
        final jobs = (response['eligible'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
        recommendedJobs.assignAll(jobs);
      }
    } catch (e) {
      print('Load recommended jobs error: $e');
    }
  }

  // Load application statistics
  Future<void> loadApplicationStats() async {
    try {
      final response = await _profileRepository.getApplicationStats();

      if (response['success'] == true) {
        totalApplications.value = response['total'] ?? 0;
        activeApplications.value = response['active'] ?? 0;
        shortlistedApplications.value = response['shortlisted'] ?? 0;
      }
    } catch (e) {
      print('Load application stats error: $e');
    }
  }

  // Calculate profile completion percentage
  void calculateProfileCompletion() {
    if (currentStudent.value == null) return;

    int completedFields = 0;
    int totalFields = 10; // Total required fields

    final student = currentStudent.value!;

    // Basic info (always completed from college)
    if (student.name.isNotEmpty) completedFields++;
    if (student.email.isNotEmpty) completedFields++;
    if (student.regNumber.isNotEmpty) completedFields++;

    // Academic details
    if (student.academicDetails?.cgpa != null) completedFields++;
    if (student.academicDetails?.tenthMarks != null) completedFields++;
    if (student.academicDetails?.twelfthMarks != null) completedFields++;

    // Additional info
    if (student.address != null) completedFields++;
    if (student.resumeUrl != null && student.resumeUrl!.isNotEmpty)
      completedFields++;
    if (student.workExperience.isNotEmpty) completedFields++;
    if (student.certifications.isNotEmpty) completedFields++;

    profileCompletionPercentage.value = ((completedFields / totalFields) * 100)
        .round();
  }

  // Update greeting based on time
  void updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      currentGreeting.value = 'Good Morning';
    } else if (hour < 17) {
      currentGreeting.value = 'Good Afternoon';
    } else {
      currentGreeting.value = 'Good Evening';
    }
  }

  // Start time updater
  void startTimeUpdater() {
    updateCurrentTime();
    // Update every minute
    Stream.periodic(const Duration(minutes: 1)).listen((_) {
      updateCurrentTime();
      updateGreeting();
    });
  }

  // Update current time
  void updateCurrentTime() {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    currentTime.value = timeString;
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;
      await loadDashboardData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // Navigation methods
  void goToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  void goToJobs() {
    Get.toNamed(Routes.JOBS);
  }

  void goToApplications() {
    Get.toNamed(Routes.APPLICATIONS);
  }

  void goToJobDetails(String jobId) {
    Get.toNamed(Routes.JOBS, arguments: {'jobId': jobId});
  }

  void goToApplicationDetails(String applicationId) {
    Get.toNamed(
      Routes.APPLICATIONS,
      arguments: {'applicationId': applicationId},
    );
  }

  void goToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  // Logout
  Future<void> logout() async {
    try {
      await _storageService.clearAll();
      Get.offAllNamed(Routes.AUTH);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Get status color
  Color getApplicationStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.APPLIED:
        return Colors.blue;
      case ApplicationStatus.UNDER_REVIEW:
        return Colors.orange;
      case ApplicationStatus.SHORTLISTED:
        return Colors.green;
      case ApplicationStatus.REJECTED:
        return Colors.red;
      case ApplicationStatus.WITHDRAWN:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  String getApplicationStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.APPLIED:
        return 'Applied';
      case ApplicationStatus.UNDER_REVIEW:
        return 'Under Review';
      case ApplicationStatus.SHORTLISTED:
        return 'Shortlisted';
      case ApplicationStatus.REJECTED:
        return 'Rejected';
      case ApplicationStatus.WITHDRAWN:
        return 'Withdrawn';
      default:
        return 'Unknown';
    }
  }
}
