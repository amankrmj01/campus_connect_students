// lib/presentation/jobs/controllers/jobs.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/enum.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../infrastructure/navigation/routes.dart';

class JobsController extends GetxController with GetTickerProviderStateMixin {
  final JobRepository _jobRepository = Get.find<JobRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Reactive variables
  final RxList<Job> eligibleJobs = <Job>[].obs;
  final RxList<Job> notEligibleJobs = <Job>[].obs;
  final RxList<Job> allJobs = <Job>[].obs;
  final RxList<Job> filteredJobs = <Job>[].obs;
  final Rx<Student?> currentStudent = Rx<Student?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool showEligibleOnly = true.obs;
  final RxString selectedJobType = 'ALL'.obs;
  final RxString selectedLocation = 'ALL'.obs;
  final RxDouble minCgpaFilter = 0.0.obs;
  final RxDouble maxCgpaFilter = 10.0.obs;

  // Search and filter
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  late TabController tabController;

  // Lists for filters
  final RxList<String> jobTypes = <String>[
    'ALL',
    'INTERNSHIP',
    'FULL_TIME',
    'BOTH',
  ].obs;
  final RxList<String> locations = <String>['ALL'].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    initializeJobs();
    setupSearchListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    tabController.dispose();
    super.onClose();
  }

  // Initialize jobs data
  void initializeJobs() async {
    try {
      isLoading.value = true;
      await loadStudentData();
      await loadJobs();
      filterJobs();
    } catch (e) {
      print('Initialize jobs error: $e');
      Get.snackbar(
        'Error',
        'Failed to load jobs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  // Load jobs
  Future<void> loadJobs() async {
    try {
      final response = await _jobRepository.getAllJobs();
      if (response['success'] == true) {
        final data = response['data'];

        // Get all jobs from the API (whether it returns categorized or uncategorized)
        List<Job> allJobsList = [];

        if (data.containsKey('jobs') && data['jobs'] is List) {
          // If API returns all jobs in a single array
          allJobsList = (data['jobs'] as List)
              .map((job) => Job.fromJson(job))
              .toList();
        } else {
          // If API returns categorized jobs, combine them
          final eligibleJobsData = data['eligible'] as List? ?? [];
          final notEligibleJobsData = data['notEligible'] as List? ?? [];

          allJobsList = [
            ...eligibleJobsData.map((job) => Job.fromJson(job)),
            ...notEligibleJobsData.map((job) => Job.fromJson(job)),
          ];
        }

        // Use the manual categorization function
        _categorizeJobsManually(allJobsList);

        // Update locations filter
        final uniqueLocations =
            allJobs.map((job) => job.location).toSet().toList()..sort();
        locations.assignAll(['ALL', ...uniqueLocations]);
      }
    } catch (e) {
      print('Load jobs error: $e');
    }
  }

  // Manually categorize jobs - first 2 in eligible, rest in not eligible
  void _categorizeJobsManually(List<Job> allJobsList) {
    final eligible = <Job>[];
    final notEligible = <Job>[];

    // Simple distribution: first 2 jobs go to eligible, rest go to not eligible
    for (int i = 0; i < allJobsList.length; i++) {
      if (i < 2) {
        eligible.add(allJobsList[i]);
      } else {
        notEligible.add(allJobsList[i]);
      }
    }

    // Update reactive lists
    eligibleJobs.assignAll(eligible);
    notEligibleJobs.assignAll(notEligible);
    allJobs.assignAll([...eligible, ...notEligible]);

    print(
      'Categorized jobs: ${eligible.length} eligible, ${notEligible.length} not eligible',
    );
  }

  // Check if student is eligible for a specific job based on CGPA and graduation year
  bool _isStudentEligibleForJob(Job job) {
    if (currentStudent.value == null) return false;

    final student = currentStudent.value!;
    final studentCgpa = student.cgpa;
    final studentGraduationYear = student.graduationYear;
    final currentYear = DateTime.now().year;

    // Check minimum CGPA requirement
    if (studentCgpa < job.requirements.minCgpa) {
      return false;
    }

    // Check graduation year eligibility
    // For internships: current students (graduation year >= current year)
    // For full-time: recent graduates or final year students
    if (job.type == JobType.INTERNSHIP) {
      // Internships are for current students
      if (studentGraduationYear < currentYear) {
        return false; // Already graduated
      }
    } else if (job.type == JobType.FULL_TIME) {
      // Full-time jobs are for final year students and recent graduates
      if (studentGraduationYear < currentYear - 1 ||
          studentGraduationYear > currentYear + 1) {
        return false;
      }
    }

    // Check branch/stream requirements if specified
    if (job.requirements.allowedBranches.isNotEmpty) {
      final studentBranch = student.branch.toLowerCase();
      final allowedBranches = job.requirements.allowedBranches
          .map((branch) => branch.toLowerCase())
          .toList();

      if (!allowedBranches.contains(studentBranch)) {
        return false;
      }
    }

    return true;
  }

  // Get filtered jobs based on current tab and filters
  List<Job> getFilteredJobs(RxList<Job> jobsList) {
    return jobsList.where((job) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!job.title.toLowerCase().contains(query) &&
            !job.companyName.toLowerCase().contains(query) &&
            !job.location.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Job type filter
      if (selectedJobType.value != 'ALL') {
        if (job.type.value != selectedJobType.value) {
          return false;
        }
      }

      // Location filter
      if (selectedLocation.value != 'ALL') {
        if (job.location != selectedLocation.value) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Apply for job with conditional flow
  Future<void> applyForJob(Job job) async {
    try {
      if (currentStudent.value == null) {
        Get.snackbar(
          'Error',
          'Please login to apply for jobs',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Check if student is eligible
      if (!isStudentEligible(job)) {
        Get.snackbar(
          'Not Eligible',
          'You are not eligible for this job based on the requirements',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Check if job has additional application questions
      final hasQuestions = job.customForm.questions.isNotEmpty;

      if (hasQuestions) {
        // Navigate to application form if job has additional questions
        Get.toNamed(Routes.JOB_APPLICATION, arguments: {'job': job});
      } else {
        // Direct apply if no additional questions
        await _directApply(job);
      }
    } catch (e) {
      print('Apply for job error: $e');
      Get.snackbar(
        'Error',
        'Failed to apply for job. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Direct apply without additional questions
  Future<void> _directApply(Job job) async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Submitting application...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final applicationData = {
        'jobId': job.jobId,
        'candidateId':
            currentStudent.value?.studentId ??
            currentStudent.value?.userId ??
            '',
        'answers': <Map<String, dynamic>>[], // No additional questions
        'appliedAt': DateTime.now().toIso8601String(),
      };

      // Submit application
      final response = await _submitApplication(applicationData);

      // Close loading dialog
      Get.back();

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Application submitted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh jobs to update application status
        await refreshJobs();
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to submit application',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print('Direct apply error: $e');
      Get.snackbar(
        'Error',
        'Failed to submit application. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Submit application (handles both mock and real API)
  Future<Map<String, dynamic>> _submitApplication(
    Map<String, dynamic> applicationData,
  ) async {
    try {
      if (Get.find<ApiService>().isUsingMockData) {
        // Mock submission
        await Future.delayed(
          const Duration(seconds: 2),
        ); // Simulate network delay
        return {
          'success': true,
          'message': 'Application submitted successfully',
          'data': {
            'applicationId': 'mock_${DateTime.now().millisecondsSinceEpoch}',
          },
        };
      } else {
        // Real API submission
        return await _jobRepository.submitJobApplication(applicationData);
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit application: $e'};
    }
  }

  // Check if student is eligible for job (fix CGPA access)
  bool isStudentEligible(Job job) {
    if (currentStudent.value == null) return false;

    final student = currentStudent.value!;
    final requirements = job.requirements;

    // Check CGPA - use direct cgpa property from Student
    if (student.cgpa < requirements.minCgpa) return false;

    // Check branch
    if (requirements.allowedBranches.isNotEmpty &&
        !requirements.allowedBranches.contains(student.branch))
      return false;

    // Check degree type
    if (requirements.allowedDegreeTypes.isNotEmpty &&
        !requirements.allowedDegreeTypes.contains(student.degreeType))
      return false;

    // Check graduation year
    if (!requirements.isGraduationYearAllowed(student.graduationYear))
      return false;

    // Check backlogs
    if (student.currentBacklogs > requirements.maxBacklogs) return false;

    return true;
  }

  // Check if student has already applied for job
  bool hasAlreadyApplied(Job job) {
    if (currentStudent.value == null) return false;
    final studentId =
        currentStudent.value?.studentId ?? currentStudent.value?.userId ?? '';
    return job.appliedCandidates.contains(studentId);
  }

  // Get days left for application
  int getDaysLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  // Helper methods for UI
  bool isEligibleForJob(Job job) => isStudentEligible(job);

  String formatJobType(JobType type) {
    switch (type) {
      case JobType.INTERNSHIP:
        return 'Internship';
      case JobType.FULL_TIME:
        return 'Full Time';
      case JobType.BOTH:
        return 'Both';
    }
  }

  String formatSalary(SalaryRange? salary) {
    if (salary == null) return 'Not disclosed';
    return '${salary.currency} ${salary.min.toStringAsFixed(0)} - ${salary.max.toStringAsFixed(0)}';
  }

  // Get application status text based on tab context
  String getApplicationStatusTextForTab(
    Job job, {
    bool isInEligibleTab = false,
  }) {
    if (hasAlreadyApplied(job)) return 'Applied';
    if (getDaysLeft(job.applicationDeadline) < 0) return 'Expired';

    // If the job is in the eligible tab, it should show as eligible
    if (isInEligibleTab) {
      return 'Apply';
    } else {
      // If in not eligible tab, show not eligible
      return 'Not Eligible';
    }
  }

  // Get application status color based on tab context
  Color getApplicationStatusColorForTab(
    Job job, {
    bool isInEligibleTab = false,
  }) {
    if (hasAlreadyApplied(job)) return Colors.grey;
    if (getDaysLeft(job.applicationDeadline) < 0) return Colors.red;

    // If the job is in the eligible tab, show as eligible
    if (isInEligibleTab) {
      return Colors.blue;
    } else {
      // If in not eligible tab, show orange
      return Colors.orange;
    }
  }

  String getApplicationStatusText(Job job) {
    if (hasAlreadyApplied(job)) return 'Applied';
    if (getDaysLeft(job.applicationDeadline) < 0) return 'Expired';
    if (!isEligibleForJob(job)) return 'Not Eligible';
    return 'Apply';
  }

  Color getApplicationStatusColor(Job job) {
    if (hasAlreadyApplied(job)) return Colors.grey;
    if (getDaysLeft(job.applicationDeadline) < 0) return Colors.red;
    if (!isEligibleForJob(job)) return Colors.orange;
    return Colors.blue;
  }

  // Filter and search methods
  void setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  void setJobTypeFilter(String type) {
    selectedJobType.value = type;
  }

  void setLocationFilter(String location) {
    selectedLocation.value = location;
  }

  void toggleEligibleOnly() {
    showEligibleOnly.value = !showEligibleOnly.value;
  }

  void clearFilters() {
    searchController.clear();
    selectedJobType.value = 'ALL';
    selectedLocation.value = 'ALL';
    showEligibleOnly.value = true;
  }

  void filterJobs() {
    // This method is called when filters change
    // The actual filtering is now done in getFilteredJobs method
  }

  // Refresh jobs
  Future<void> refreshJobs() async {
    isRefreshing.value = true;
    await loadJobs();
    isRefreshing.value = false;
  }

  // Navigation methods
  void goToJobDetails(Job job) {
    // Use a safe route name or create job details route
    Get.toNamed('/job-details', arguments: {'job': job});
  }

  void showFiltersBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Job Type Filter
            const Text(
              'Job Type',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                children: jobTypes
                    .map(
                      (type) => FilterChip(
                        label: Text(type.replaceAll('_', ' ')),
                        selected: selectedJobType.value == type,
                        onSelected: (selected) => setJobTypeFilter(type),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Location Filter
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                children: locations
                    .take(10)
                    .map(
                      (location) => FilterChip(
                        label: Text(location),
                        selected: selectedLocation.value == location,
                        onSelected: (selected) => setLocationFilter(location),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: clearFilters,
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
