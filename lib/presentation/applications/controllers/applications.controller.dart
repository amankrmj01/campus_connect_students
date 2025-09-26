// lib/presentation/applications/controllers/applications.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/application_model.dart';
import '../../../data/models/enum.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../infrastructure/navigation/routes.dart';

class ApplicationsController extends GetxController
    with GetTickerProviderStateMixin {
  final JobRepository _jobRepository = Get.find<JobRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Reactive variables
  final RxList<Application> allApplications = <Application>[].obs;
  final RxList<Application> filteredApplications = <Application>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxString selectedFilter = 'ALL'.obs;
  final RxString searchQuery = ''.obs;

  // Tab controller
  late TabController tabController;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Application status filters
  final List<String> statusFilters = [
    'ALL',
    'APPLIED',
    'UNDER_REVIEW',
    'SHORTLISTED',
    'REJECTED',
    'WITHDRAWN',
  ];

  // Statistics
  final RxInt totalApplications = 0.obs;
  final RxInt appliedCount = 0.obs;
  final RxInt underReviewCount = 0.obs;
  final RxInt shortlistedCount = 0.obs;
  final RxInt rejectedCount = 0.obs;
  final RxInt withdrawnCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 6, vsync: this);
    setupSearchListener();
    initializeApplications();
  }

  @override
  void onClose() {
    searchController.dispose();
    tabController.dispose();
    super.onClose();
  }

  // Setup search listener
  void setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      applyFilters();
    });
  }

  // Initialize applications
  void initializeApplications() async {
    try {
      isLoading.value = true;
      await loadApplications();
      calculateStatistics();
      applyFilters();
    } catch (e) {
      print('Initialize applications error: $e');
      Get.snackbar(
        'Error',
        'Failed to load applications',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load applications from repository
  Future<void> loadApplications() async {
    try {
      // Get current student data to get the student ID
      final studentData = await _storageService.getStudentData();
      if (studentData == null) {
        allApplications.clear();
        return;
      }

      final studentId = studentData['userId'] ?? studentData['id'];
      if (studentId == null) {
        allApplications.clear();
        return;
      }

      final response = await _jobRepository.getStudentApplications(
        studentId: studentId,
        page: 1,
        limit: 100, // Load all applications
      );

      if (response['success'] == true && response['data'] != null) {
        final applicationsData =
            response['data']['applications'] as List? ?? [];
        final applications = applicationsData
            .map((app) => Application.fromJson(app))
            .toList();

        // Sort by application date (newest first)
        applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));

        allApplications.assignAll(applications);
      } else {
        // If no applications or error, initialize with empty list
        allApplications.clear();
      }
    } catch (e) {
      print('Load applications error: $e');
      // Ensure applications list is empty on error
      allApplications.clear();
    }
  }

  // Calculate statistics
  void calculateStatistics() {
    totalApplications.value = allApplications.length;
    appliedCount.value = allApplications
        .where((app) => app.status == ApplicationStatus.APPLIED)
        .length;
    underReviewCount.value = allApplications
        .where((app) => app.status == ApplicationStatus.UNDER_REVIEW)
        .length;
    shortlistedCount.value = allApplications
        .where((app) => app.status == ApplicationStatus.SHORTLISTED)
        .length;
    rejectedCount.value = allApplications
        .where((app) => app.status == ApplicationStatus.REJECTED)
        .length;
    withdrawnCount.value = allApplications
        .where((app) => app.status == ApplicationStatus.WITHDRAWN)
        .length;
  }

  // Apply filters
  void applyFilters() {
    List<Application> filtered = List.from(allApplications);

    // Apply status filter
    if (selectedFilter.value != 'ALL') {
      final status = ApplicationStatusExtension.fromString(
        selectedFilter.value,
      );
      filtered = filtered.where((app) => app.status == status).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered
          .where(
            (app) =>
                app.jobDetails.title.toLowerCase().contains(query) ||
                app.jobDetails.companyName.toLowerCase().contains(query),
          )
          .toList();
    }

    filteredApplications.assignAll(filtered);
  }

  // Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    applyFilters();
  }

  // Refresh applications
  Future<void> refreshApplications() async {
    try {
      isRefreshing.value = true;
      await loadApplications();
      calculateStatistics();
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh applications',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // Navigate to application details
  void goToApplicationDetails(Application application) {
    Get.toNamed(
      '${Routes.APPLICATIONS}/details',
      arguments: {'application': application},
    );
  }

  // Navigate to job details
  void goToJobDetails(Application application) {
    Get.toNamed(
      '${Routes.JOBS}/details',
      arguments: {'job': application.jobDetails},
    );
  }

  // Withdraw application
  Future<void> withdrawApplication(Application application) async {
    if (!application.canWithdraw) {
      Get.snackbar(
        'Cannot Withdraw',
        'This application cannot be withdrawn at this stage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Withdraw Application'),
        content: Text(
          'Are you sure you want to withdraw your application for ${application.jobDetails.title} at ${application.jobDetails.companyName}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performWithdraw(application);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  // Perform withdraw
  Future<void> _performWithdraw(Application application) async {
    try {
      final response = await _jobRepository.withdrawApplication(
        application.applicationId,
      );

      if (response['success'] == true) {
        // Update local application status
        final index = allApplications.indexWhere(
          (app) => app.applicationId == application.applicationId,
        );
        if (index != -1) {
          allApplications[index] = allApplications[index].copyWith(
            status: ApplicationStatus.WITHDRAWN,
            lastUpdatedAt: DateTime.now(),
          );
        }

        calculateStatistics();
        applyFilters();

        Get.snackbar(
          'Application Withdrawn',
          'Your application has been withdrawn successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to withdraw application',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Withdraw application error: $e');
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get status color
  Color getStatusColor(ApplicationStatus status) {
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
    }
  }

  // Get status icon
  IconData getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.APPLIED:
        return Icons.send;
      case ApplicationStatus.UNDER_REVIEW:
        return Icons.hourglass_empty;
      case ApplicationStatus.SHORTLISTED:
        return Icons.check_circle;
      case ApplicationStatus.REJECTED:
        return Icons.cancel;
      case ApplicationStatus.WITHDRAWN:
        return Icons.undo;
    }
  }

  // Format date
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Get count for filter
  int getCountForFilter(String filter) {
    switch (filter) {
      case 'ALL':
        return totalApplications.value;
      case 'APPLIED':
        return appliedCount.value;
      case 'UNDER_REVIEW':
        return underReviewCount.value;
      case 'SHORTLISTED':
        return shortlistedCount.value;
      case 'REJECTED':
        return rejectedCount.value;
      case 'WITHDRAWN':
        return withdrawnCount.value;
      default:
        return 0;
    }
  }

  // Get filter display name
  String getFilterDisplayName(String filter) {
    switch (filter) {
      case 'ALL':
        return 'All';
      case 'APPLIED':
        return 'Applied';
      case 'UNDER_REVIEW':
        return 'Under Review';
      case 'SHORTLISTED':
        return 'Shortlisted';
      case 'REJECTED':
        return 'Rejected';
      case 'WITHDRAWN':
        return 'Withdrawn';
      default:
        return filter;
    }
  }

  // Show filter menu
  void showFilterMenu() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Applications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...statusFilters.map(
              (filter) => Obx(
                () => ListTile(
                  title: Text(getFilterDisplayName(filter)),
                  trailing: Text(
                    '(${getCountForFilter(filter)})',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  leading: Icon(
                    selectedFilter.value == filter
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selectedFilter.value == filter
                        ? Theme.of(Get.context!).primaryColor
                        : Colors.grey,
                  ),
                  onTap: () {
                    setFilter(filter);
                    Get.back();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
