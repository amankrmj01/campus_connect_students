// lib/presentation/home/controllers/home.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/job_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../infrastructure/navigation/routes.dart';

class HomeController extends GetxController {
  final JobRepository _jobRepository = Get.find<JobRepository>();
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Reactive variables
  final Rx<Student?> currentStudent = Rx<Student?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxInt profileCompletionPercentage = 0.obs;

  // Dashboard stats
  final RxInt totalApplications = 0.obs;
  final RxInt pendingApplications = 0.obs;
  final RxInt shortlistedApplications = 0.obs;
  final RxInt eligibleJobs = 0.obs;

  // Recent data
  final RxList<Job> recentJobs = <Job>[].obs;
  final RxList<Map<String, dynamic>> recentApplications =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> upcomingDeadlines =
      <Map<String, dynamic>>[].obs;

  // Quick actions
  final List<Map<String, dynamic>> quickActions = [
    {
      'title': 'Browse Jobs',
      'icon': Icons.work_outline,
      'color': Colors.blue,
      'route': Routes.JOBS,
    },
    {
      'title': 'My Applications',
      'icon': Icons.assignment_outlined,
      'color': Colors.green,
      'route': Routes.APPLICATIONS,
    },
    {
      'title': 'Profile',
      'icon': Icons.person_outline,
      'color': Colors.purple,
      'route': Routes.PROFILE,
    },
    {
      'title': 'Groups',
      'icon': Icons.group_outlined,
      'color': Colors.orange,
      'route': Routes.GROUPS,
    },
  ];

  @override
  void onInit() {
    super.onInit();
    initializeHome();
  }

  // Initialize home data
  void initializeHome() async {
    try {
      isLoading.value = true;
      await loadStudentData();
      await loadDashboardStats();
      await loadRecentData();
      calculateProfileCompletion();
    } catch (e) {
      print('Initialize home error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load student data
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

  // Load dashboard statistics
  Future<void> loadDashboardStats() async {
    try {
      if (currentStudent.value == null) return;

      // Load application stats
      final appStatsResponse = await _jobRepository.getApplicationStatistics();
      if (appStatsResponse['success'] == true) {
        final stats = appStatsResponse['statistics'];
        totalApplications.value = stats['total'] ?? 0;
        pendingApplications.value = stats['pending'] ?? 0;
        shortlistedApplications.value = stats['shortlisted'] ?? 0;
      }

      // Load eligible jobs count
      final jobsResponse = await _jobRepository.getFilteredJobs(
        cgpa: currentStudent.value!.academicDetails?.cgpa ?? 0.0,
        branch: currentStudent.value!.branch,
        degreeType: currentStudent.value!.degreeType,
        graduationYear:
            currentStudent.value!.academicDetails?.graduationYear ??
            DateTime.now().year,
        limit: 1, // Just to get count
      );

      if (jobsResponse['success'] == true) {
        eligibleJobs.value = (jobsResponse['eligible'] as List).length;
      }
    } catch (e) {
      print('Load dashboard stats error: $e');
    }
  }

  // Load recent data
  Future<void> loadRecentData() async {
    try {
      // Load recent jobs
      final recentJobsResponse = await _jobRepository.getJobRecommendations(
        limit: 5,
      );
      if (recentJobsResponse['success'] == true) {
        final jobs = (recentJobsResponse['jobs'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
        recentJobs.assignAll(jobs);
      }

      // Load recent applications
      final applicationsResponse = await _jobRepository.getMyApplications(
        limit: 3,
      );
      if (applicationsResponse['success'] == true) {
        recentApplications.assignAll(
          List<Map<String, dynamic>>.from(
            applicationsResponse['applications'] ?? [],
          ),
        );
      }

      // Load upcoming deadlines
      final deadlinesResponse = await _jobRepository.getFilteredJobs(
        cgpa: currentStudent.value?.academicDetails?.cgpa ?? 0.0,
        branch: currentStudent.value?.branch ?? '',
        degreeType: currentStudent.value?.degreeType ?? '',
        graduationYear:
            currentStudent.value?.academicDetails?.graduationYear ??
            DateTime.now().year,
        limit: 10,
      );

      if (deadlinesResponse['success'] == true) {
        final jobs = deadlinesResponse['eligible'] as List;
        final deadlines = jobs
            .where((job) {
              final deadline = DateTime.parse(job['application_deadline']);
              final daysLeft = deadline.difference(DateTime.now()).inDays;
              return daysLeft >= 0 && daysLeft <= 7; // Next 7 days
            })
            .map(
              (job) => {
                'job_title': job['title'],
                'company_name': job['company_name'],
                'deadline': job['application_deadline'],
                'days_left': DateTime.parse(
                  job['application_deadline'],
                ).difference(DateTime.now()).inDays,
              },
            )
            .toList();

        upcomingDeadlines.assignAll(List<Map<String, dynamic>>.from(deadlines));
      }
    } catch (e) {
      print('Load recent data error: $e');
    }
  }

  // Calculate profile completion
  void calculateProfileCompletion() {
    if (currentStudent.value == null) return;

    int completedFields = 0;
    int totalFields = 10;

    final student = currentStudent.value!;

    // Basic info
    if (student.name.isNotEmpty) completedFields++;
    if (student.email.isNotEmpty) completedFields++;

    // Academic details
    if (student.academicDetails?.cgpa != null) completedFields++;
    if (student.academicDetails?.tenthMarks != null) completedFields++;
    if (student.academicDetails?.twelfthMarks != null) completedFields++;

    // Address
    if (student.address?.city.isNotEmpty == true) completedFields++;
    if (student.address?.state.isNotEmpty == true) completedFields++;

    // Profile extras
    if (student.resumeUrl?.isNotEmpty == true) completedFields++;
    if (student.workExperience.isNotEmpty) completedFields++;
    if (student.certifications.isNotEmpty) completedFields++;

    profileCompletionPercentage.value = ((completedFields / totalFields) * 100)
        .round();
  }

  // Refresh dashboard
  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;
      await loadDashboardStats();
      await loadRecentData();
      calculateProfileCompletion();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh dashboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // Navigate to route
  void navigateToRoute(String route) {
    Get.toNamed(route);
  }

  // Navigate to job details
  void navigateToJobDetails(Job job) {
    Get.toNamed('${Routes.JOBS}/details', arguments: {'job': job});
  }

  // Navigate to complete profile
  void navigateToCompleteProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  // Get greeting based on time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Get days left text
  String getDaysLeftText(int days) {
    if (days == 0) {
      return 'Today!';
    } else if (days == 1) {
      return 'Tomorrow';
    } else {
      return '$days days left';
    }
  }

  // Get application status color
  Color getApplicationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'shortlisted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'selected':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
