// lib/data/repositories/job_repository.dart
import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class JobRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Cache keys
  static const String _jobsCacheKey = 'cache_jobs';
  static const String _eligibleJobsCacheKey = 'cache_eligible_jobs';

  // Cache duration
  static const Duration _cacheDuration = Duration(minutes: 15);

  // Get Filtered Jobs (Eligible and Not Eligible)
  Future<Map<String, dynamic>> getFilteredJobs({
    required double cgpa,
    required String branch,
    required String degreeType,
    required int graduationYear,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      // Try cache first
      final cachedJobs = await _storageService
          .getCacheWithTTL<Map<String, dynamic>>(_jobsCacheKey);
      if (cachedJobs != null) {
        return cachedJobs;
      }

      final response = await _apiService.get(
        '/jobs/filtered',
        queryParameters: {
          'cgpa': cgpa,
          'branch': branch,
          'degree_type': degreeType,
          'graduation_year': graduationYear,
          'page': page,
          'limit': limit,
        },
      );

      if (response['success'] == true) {
        // Cache the response
        await _storageService.setCacheWithTTL(
          _jobsCacheKey,
          response,
          _cacheDuration,
        );

        // Schedule deadline reminders for eligible jobs
        await _scheduleDeadlineReminders(response['eligible'] ?? []);
      }

      return response;
    } catch (e) {
      print('Get filtered jobs error: $e');

      // Try to return cached data even if expired
      final cachedJobs = await _storageService.getMap(_jobsCacheKey);
      if (cachedJobs != null) {
        return {
          'success': true,
          'eligible': cachedJobs['eligible'] ?? [],
          'notEligible': cachedJobs['notEligible'] ?? [],
          'cached': true,
        };
      }

      return {
        'success': false,
        'message': 'Failed to load jobs',
        'eligible': [],
        'notEligible': [],
      };
    }
  }

  // Get All Jobs (Without Filtering)
  Future<Map<String, dynamic>> getAllJobs({
    int page = 1,
    int limit = 20,
    String? search,
    String? jobType,
    String? location,
    double? minCgpa,
    double? maxCgpa,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (jobType != null && jobType != 'ALL') {
        queryParams['job_type'] = jobType;
      }
      if (location != null && location != 'ALL') {
        queryParams['location'] = location;
      }
      if (minCgpa != null) {
        queryParams['min_cgpa'] = minCgpa;
      }
      if (maxCgpa != null) {
        queryParams['max_cgpa'] = maxCgpa;
      }

      final response = await _apiService.get(
        '/jobs',
        queryParameters: queryParams,
      );
      return response;
    } catch (e) {
      print('Get all jobs error: $e');
      return {'success': false, 'message': 'Failed to load jobs'};
    }
  }

  // Get Job Details
  Future<Map<String, dynamic>> getJobDetails(String jobId) async {
    try {
      final response = await _apiService.get('/jobs/$jobId');
      return response;
    } catch (e) {
      print('Get job details error: $e');
      return {'success': false, 'message': 'Failed to load job details'};
    }
  }

  // Apply for Job
  Future<Map<String, dynamic>> applyForJob(
    String jobId,
    Map<String, dynamic> applicationData,
  ) async {
    try {
      final response = await _apiService.post(
        '/jobs/$jobId/apply',
        data: applicationData,
      );

      if (response['success'] == true) {
        // Clear jobs cache to refresh applied status
        await _clearJobsCache();

        // Show success notification
        await _notificationService.showNotification(
          id: 'job_applied_$jobId'.hashCode,
          title: 'Application Submitted!',
          body: 'Your job application has been submitted successfully',
        );

        // Get job details for notification
        final jobDetails = response['job'];
        if (jobDetails != null) {
          await _notificationService.showApplicationUpdate(
            applicationId: response['application_id'] ?? '',
            companyName: jobDetails['company_name'] ?? 'Company',
            status: 'Application Submitted',
          );
        }
      }

      return response;
    } catch (e) {
      print('Apply for job error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Failed to apply for job',
      };
    }
  }

  // Get My Applications
  Future<Map<String, dynamic>> getMyApplications({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        '/jobs/my-applications',
        queryParameters: queryParams,
      );
      return response;
    } catch (e) {
      print('Get my applications error: $e');
      return {'success': false, 'message': 'Failed to load applications'};
    }
  }

  // Withdraw Application
  Future<Map<String, dynamic>> withdrawApplication(String applicationId) async {
    try {
      final response = await _apiService.put(
        '/applications/$applicationId/withdraw',
      );

      if (response['success'] == true) {
        // Clear jobs cache to refresh status
        await _clearJobsCache();

        // Show notification
        await _notificationService.showNotification(
          id: 'application_withdrawn_$applicationId'.hashCode,
          title: 'Application Withdrawn',
          body: 'Your job application has been withdrawn',
        );
      }

      return response;
    } catch (e) {
      print('Withdraw application error: $e');
      return {'success': false, 'message': 'Failed to withdraw application'};
    }
  }

  // Get Application Details
  Future<Map<String, dynamic>> getApplicationDetails(
    String applicationId,
  ) async {
    try {
      final response = await _apiService.get('/applications/$applicationId');
      return response;
    } catch (e) {
      print('Get application details error: $e');
      return {
        'success': false,
        'message': 'Failed to load application details',
      };
    }
  }

  // Get Job Categories
  Future<Map<String, dynamic>> getJobCategories() async {
    try {
      final response = await _apiService.get('/jobs/categories');
      return response;
    } catch (e) {
      print('Get job categories error: $e');
      return {'success': false, 'message': 'Failed to load job categories'};
    }
  }

  // Get Job Locations
  Future<Map<String, dynamic>> getJobLocations() async {
    try {
      final response = await _apiService.get('/jobs/locations');
      return response;
    } catch (e) {
      print('Get job locations error: $e');
      return {'success': false, 'message': 'Failed to load job locations'};
    }
  }

  // Save Job (Bookmark)
  Future<Map<String, dynamic>> saveJob(String jobId) async {
    try {
      final response = await _apiService.post('/jobs/$jobId/save');

      if (response['success'] == true) {
        await _notificationService.showNotification(
          id: 'job_saved_$jobId'.hashCode,
          title: 'Job Saved',
          body: 'Job has been added to your saved list',
        );
      }

      return response;
    } catch (e) {
      print('Save job error: $e');
      return {'success': false, 'message': 'Failed to save job'};
    }
  }

  // Unsave Job (Remove Bookmark)
  Future<Map<String, dynamic>> unsaveJob(String jobId) async {
    try {
      final response = await _apiService.delete('/jobs/$jobId/save');
      return response;
    } catch (e) {
      print('Unsave job error: $e');
      return {'success': false, 'message': 'Failed to unsave job'};
    }
  }

  // Get Saved Jobs
  Future<Map<String, dynamic>> getSavedJobs({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/jobs/saved',
        queryParameters: {'page': page, 'limit': limit},
      );

      return response;
    } catch (e) {
      print('Get saved jobs error: $e');
      return {'success': false, 'message': 'Failed to load saved jobs'};
    }
  }

  // Get Job Recommendations
  Future<Map<String, dynamic>> getJobRecommendations({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/jobs/recommendations',
        queryParameters: {'limit': limit},
      );

      return response;
    } catch (e) {
      print('Get job recommendations error: $e');
      return {
        'success': false,
        'message': 'Failed to load job recommendations',
      };
    }
  }

  // Get Company Jobs
  Future<Map<String, dynamic>> getCompanyJobs(
    String companyName, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/jobs/company/$companyName',
        queryParameters: {'page': page, 'limit': limit},
      );

      return response;
    } catch (e) {
      print('Get company jobs error: $e');
      return {'success': false, 'message': 'Failed to load company jobs'};
    }
  }

  // Get Similar Jobs
  Future<Map<String, dynamic>> getSimilarJobs(
    String jobId, {
    int limit = 5,
  }) async {
    try {
      final response = await _apiService.get(
        '/jobs/$jobId/similar',
        queryParameters: {'limit': limit},
      );

      return response;
    } catch (e) {
      print('Get similar jobs error: $e');
      return {'success': false, 'message': 'Failed to load similar jobs'};
    }
  }

  // Report Job
  Future<Map<String, dynamic>> reportJob(
    String jobId,
    String reason,
    String? description,
  ) async {
    try {
      final response = await _apiService.post(
        '/jobs/$jobId/report',
        data: {'reason': reason, 'description': description},
      );

      return response;
    } catch (e) {
      print('Report job error: $e');
      return {'success': false, 'message': 'Failed to report job'};
    }
  }

  // Get Application Statistics
  Future<Map<String, dynamic>> getApplicationStatistics() async {
    try {
      final response = await _apiService.get('/jobs/application-stats');
      return response;
    } catch (e) {
      print('Get application statistics error: $e');
      return {
        'success': false,
        'message': 'Failed to load application statistics',
      };
    }
  }

  // Search Jobs
  Future<Map<String, dynamic>> searchJobs(
    String query, {
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'limit': limit,
      };

      if (filters != null) {
        queryParams.addAll(filters);
      }

      final response = await _apiService.get(
        '/jobs/search',
        queryParameters: queryParams,
      );
      return response;
    } catch (e) {
      print('Search jobs error: $e');
      return {'success': false, 'message': 'Search failed'};
    }
  }

  // Schedule deadline reminders for eligible jobs
  Future<void> _scheduleDeadlineReminders(List<dynamic> eligibleJobs) async {
    try {
      for (final jobData in eligibleJobs) {
        final job = jobData as Map<String, dynamic>;
        final deadlineStr = job['application_deadline'];
        if (deadlineStr != null) {
          final deadline = DateTime.parse(deadlineStr);
          await _notificationService.scheduleApplicationDeadlineReminder(
            jobId: job['job_id'] ?? '',
            companyName: job['company_name'] ?? '',
            jobTitle: job['title'] ?? '',
            deadline: deadline,
          );
        }
      }
    } catch (e) {
      print('Schedule deadline reminders error: $e');
    }
  }

  // Clear jobs cache
  Future<void> _clearJobsCache() async {
    await _storageService.setString(_jobsCacheKey, '');
    await _storageService.setString(_eligibleJobsCacheKey, '');
  }

  // Clear all job cache
  Future<void> clearJobsCache() async {
    await _clearJobsCache();
  }

  // Get cached jobs
  Future<Map<String, dynamic>?> getCachedJobs() async {
    return await _storageService.getCacheWithTTL<Map<String, dynamic>>(
      _jobsCacheKey,
    );
  }
}
