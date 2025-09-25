// lib/presentation/jobs/controllers/jobs.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/enum.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../infrastructure/navigation/routes.dart';

class JobsController extends GetxController with GetTickerProviderStateMixin {
  final JobRepository _jobRepository = Get.find<JobRepository>();
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Reactive variables
  final RxList<Job> eligibleJobs = <Job>[].obs;
  final RxList<Job> notEligibleJobs = <Job>[].obs;
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
    tabController = TabController(length: 2, vsync: this);
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
      await loadCurrentStudent();
      await loadJobs();
      setupFilters();
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

  // Load current student data
  Future<void> loadCurrentStudent() async {
    try {
      final studentData = await _storageService.getStudentData();
      if (studentData != null) {
        currentStudent.value = Student.fromJson(studentData);
      }
    } catch (e) {
      print('Load current student error: $e');
    }
  }

  // Load jobs from API
  Future<void> loadJobs() async {
    try {
      if (currentStudent.value == null) return;

      final student = currentStudent.value!;
      final response = await _jobRepository.getFilteredJobs(
        cgpa: student.academicDetails?.cgpa ?? 0.0,
        branch: student.branch,
        degreeType: student.degreeType,
        graduationYear:
            student.academicDetails?.graduationYear ?? DateTime.now().year,
      );

      if (response['success'] == true) {
        final eligible = (response['eligible'] as List)
            .map((job) => Job.fromJson(job))
            .toList();
        final notEligible = (response['notEligible'] as List)
            .map((job) => Job.fromJson(job))
            .toList();

        eligibleJobs.assignAll(eligible);
        notEligibleJobs.assignAll(notEligible);

        applyFilters();
      }
    } catch (e) {
      print('Load jobs error: $e');
    }
  }

  // Setup filters based on loaded jobs
  void setupFilters() {
    final allJobs = [...eligibleJobs, ...notEligibleJobs];
    final uniqueLocations = allJobs.map((job) => job.location).toSet().toList();
    uniqueLocations.sort();
    locations.assignAll(['ALL', ...uniqueLocations]);
  }

  // Setup search listener
  void setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      applyFilters();
    });
  }

  // Apply filters to jobs
  void applyFilters() {
    List<Job> jobsToFilter = showEligibleOnly.value
        ? eligibleJobs
        : [...eligibleJobs, ...notEligibleJobs];

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      jobsToFilter = jobsToFilter
          .where(
            (job) =>
                job.title.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                job.companyName.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                job.description.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
          )
          .toList();
    }

    // Apply job type filter
    if (selectedJobType.value != 'ALL') {
      jobsToFilter = jobsToFilter
          .where((job) => job.type.value == selectedJobType.value)
          .toList();
    }

    // Apply location filter
    if (selectedLocation.value != 'ALL') {
      jobsToFilter = jobsToFilter
          .where((job) => job.location == selectedLocation.value)
          .toList();
    }

    // Apply CGPA filter
    jobsToFilter = jobsToFilter
        .where(
          (job) =>
              job.requirements.minCgpa >= minCgpaFilter.value &&
              job.requirements.minCgpa <= maxCgpaFilter.value,
        )
        .toList();

    // Sort by application deadline (closest first)
    jobsToFilter.sort(
      (a, b) => a.applicationDeadline.compareTo(b.applicationDeadline),
    );

    filteredJobs.assignAll(jobsToFilter);
  }

  // Toggle between eligible and all jobs
  void toggleEligibleOnly() {
    showEligibleOnly.value = !showEligibleOnly.value;
    applyFilters();
  }

  // Set job type filter
  void setJobTypeFilter(String type) {
    selectedJobType.value = type;
    applyFilters();
  }

  // Set location filter
  void setLocationFilter(String location) {
    selectedLocation.value = location;
    applyFilters();
  }

  // Set CGPA range filter
  void setCgpaRangeFilter(double min, double max) {
    minCgpaFilter.value = min;
    maxCgpaFilter.value = max;
    applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    searchController.clear();
    selectedJobType.value = 'ALL';
    selectedLocation.value = 'ALL';
    minCgpaFilter.value = 0.0;
    maxCgpaFilter.value = 10.0;
    showEligibleOnly.value = true;
    applyFilters();
  }

  // Refresh jobs
  Future<void> refreshJobs() async {
    try {
      isRefreshing.value = true;
      await loadJobs();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh jobs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // Navigate to job details
  void goToJobDetails(Job job) {
    Get.toNamed(Routes.JOBS + '/details', arguments: {'job': job});
  }

  // Apply for job
  Future<void> applyForJob(Job job) async {
    try {
      // Check if profile is complete
      if (currentStudent.value?.profileCompleted != true) {
        Get.snackbar(
          'Profile Incomplete',
          'Please complete your profile before applying',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        Get.toNamed(Routes.PROFILE);
        return;
      }

      // Check application deadline
      if (job.applicationDeadline.isBefore(DateTime.now())) {
        Get.snackbar(
          'Deadline Passed',
          'Application deadline has passed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Navigate to application form
      Get.toNamed(Routes.JOBS + '/apply', arguments: {'job': job});
    } catch (e) {
      print('Apply for job error: $e');
    }
  }

  // Check if student is eligible for job
  bool isEligibleForJob(Job job) {
    return eligibleJobs.any((eligibleJob) => eligibleJob.jobId == job.jobId);
  }

  // Check if already applied
  bool hasAlreadyApplied(Job job) {
    if (currentStudent.value == null) return false;
    return job.appliedCandidates.contains(currentStudent.value!.userId);
  }

  // Get days left for application
  int getDaysLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  // Get application status text
  String getApplicationStatusText(Job job) {
    if (hasAlreadyApplied(job)) {
      return 'Applied';
    }

    if (job.applicationDeadline.isBefore(DateTime.now())) {
      return 'Deadline Passed';
    }

    if (!isEligibleForJob(job)) {
      return 'Not Eligible';
    }

    return 'Apply Now';
  }

  // Get application status color
  Color getApplicationStatusColor(Job job) {
    if (hasAlreadyApplied(job)) {
      return Colors.green;
    }

    if (job.applicationDeadline.isBefore(DateTime.now())) {
      return Colors.red;
    }

    if (!isEligibleForJob(job)) {
      return Colors.orange;
    }

    return Colors.blue;
  }

  // Show filters bottom sheet
  void showFiltersBottomSheet() {
    Get.bottomSheet(
      _buildFiltersBottomSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Widget _buildFiltersBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Job Type Filter
          const Text('Job Type', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              children: jobTypes
                  .map(
                    (type) => FilterChip(
                      label: Text(
                        type == 'ALL' ? 'All Types' : type.replaceAll('_', ' '),
                      ),
                      selected: selectedJobType.value == type,
                      onSelected: (selected) => setJobTypeFilter(type),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Location Filter
          const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(
            () => DropdownButtonFormField<String>(
              value: selectedLocation.value,
              items: locations
                  .map(
                    (location) => DropdownMenuItem(
                      value: location,
                      child: Text(
                        location == 'ALL' ? 'All Locations' : location,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setLocationFilter(value!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Eligibility Filter
          Obx(
            () => SwitchListTile(
              title: const Text('Show Eligible Jobs Only'),
              value: showEligibleOnly.value,
              onChanged: (value) => toggleEligibleOnly(),
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }

  // Format job type display
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

  // Format salary range
  String formatSalary(SalaryRange? salary) {
    if (salary == null) return 'Not disclosed';
    return '${salary.currency} ${salary.min.toStringAsFixed(0)} - ${salary.max.toStringAsFixed(0)}';
  }
}
