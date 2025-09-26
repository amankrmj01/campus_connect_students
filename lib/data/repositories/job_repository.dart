// lib/data/repositories/job_repository.dart
import 'package:get/get.dart';

import '../mock_data/job_mock_data.dart';
import '../services/api_service.dart';
import '../services/mock_api_service.dart';
import '../services/storage_service.dart';

class JobRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Cache keys
  static const String _jobsCacheKey = 'cache_jobs';
  static const String _applicationsCacheKey = 'cache_applications';

  // Cache duration
  static const Duration _cacheDuration = Duration(minutes: 15);

  // Get jobs with student eligibility filtering
  Future<Map<String, dynamic>> getAllJobs({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      // Get student data for eligibility check
      final studentData = await _storageService.getStudentData();
      if (studentData == null) {
        return {
          'success': false,
          'message': 'Student data not found',
          'data': {'jobs': [], 'eligible': [], 'notEligible': []},
        };
      }

      final cgpa = (studentData['cgpa'] ?? 0.0).toDouble();
      final branch = studentData['branch'] ?? '';
      final degreeType = studentData['degreeType'] ?? '';
      final graduationYear =
          studentData['graduationYear'] ?? DateTime.now().year;

      if (_apiService.isUsingMockData) {
        return await MockApiService.getJobs(
          cgpa: cgpa,
          branch: branch,
          degreeType: degreeType,
          graduationYear: graduationYear,
          page: page,
          limit: limit,
        );
      } else {
        final response = await _apiService.get(
          '/jobs',
          queryParameters: {
            'cgpa': cgpa,
            'branch': branch,
            'degreeType': degreeType,
            'graduationYear': graduationYear,
            'page': page,
            'limit': limit,
            'currentTimestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );

        if (response['success'] == true) {
          // Cache the response
          await _storageService.setCacheWithTTL(
            _jobsCacheKey,
            response,
            _cacheDuration,
          );
          return response;
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Failed to fetch jobs',
            'data': {'jobs': [], 'eligible': [], 'notEligible': []},
          };
        }
      }
    } catch (e) {
      print('Get all jobs error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch jobs: $e',
        'data': {'jobs': [], 'eligible': [], 'notEligible': []},
      };
    }
  }

  // Submit job application
  Future<Map<String, dynamic>> submitJobApplication(
    Map<String, dynamic> applicationData,
  ) async {
    try {
      if (_apiService.isUsingMockData) {
        return await MockApiService.submitJobApplication(
          jobId: applicationData['jobId'],
          candidateId: applicationData['candidateId'],
          answers: List<Map<String, dynamic>>.from(
            applicationData['answers'] ?? [],
          ),
        );
      } else {
        final response = await _apiService.post(
          '/jobs/applications',
          data: applicationData,
        );

        if (response['success'] == true) {
          // Clear applications cache to refresh data
          await _storageService.removeCache(_applicationsCacheKey);
          return response;
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Failed to submit application',
          };
        }
      }
    } catch (e) {
      print('Submit job application error: $e');
      return {'success': false, 'message': 'Failed to submit application: $e'};
    }
  }

  // Get student applications with status
  Future<Map<String, dynamic>> getStudentApplications({
    required String studentId,
    int page = 1,
    int limit = 50,
    String? status,
  }) async {
    try {
      if (_apiService.isUsingMockData) {
        return await MockApiService.getStudentApplications(
          studentId: studentId,
          page: page,
          limit: limit,
          status: status,
        );
      } else {
        // Try cache first
        final cacheKey = '${_applicationsCacheKey}_$studentId';
        final cachedApplications = await _storageService
            .getCacheWithTTL<Map<String, dynamic>>(cacheKey);
        if (cachedApplications != null) {
          return cachedApplications;
        }

        final queryParams = <String, dynamic>{'page': page, 'limit': limit};
        if (status != null) queryParams['status'] = status;

        final response = await _apiService.get(
          '/students/$studentId/applications',
          queryParameters: queryParams,
        );

        if (response['success'] == true) {
          // Cache the response
          await _storageService.setCacheWithTTL(
            cacheKey,
            response,
            _cacheDuration,
          );
          return response;
        } else {
          return {
            'success': false,
            'message': response['message'] ?? 'Failed to fetch applications',
            'data': {'applications': []},
          };
        }
      }
    } catch (e) {
      print('Get student applications error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch applications: $e',
        'data': {'applications': []},
      };
    }
  }

  // Get job application questions
  Future<Map<String, dynamic>> getJobApplicationQuestions(String jobId) async {
    try {
      if (_apiService.isUsingMockData) {
        final jobData = JobMockData.getJobById(jobId);
        final customForm = jobData['customForm'] as Map<String, dynamic>? ?? {};
        final questions = customForm['questions'] as List? ?? [];

        return {
          'success': true,
          'message': 'Application questions fetched successfully',
          'data': {
            'questions': questions,
            'additionalLinks': customForm['additionalLinks'] ?? [],
            'instructions': customForm['instructions'] ?? '',
          },
        };
      } else {
        final response = await _apiService.get('/jobs/$jobId/questions');
        return response;
      }
    } catch (e) {
      print('Get job application questions error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch application questions: $e',
        'data': {'questions': []},
      };
    }
  }

  // Get job by ID
  Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      if (_apiService.isUsingMockData) {
        final jobData = JobMockData.getJobById(jobId);
        return {
          'success': true,
          'message': 'Job fetched successfully',
          'data': {'job': jobData},
        };
      } else {
        final response = await _apiService.get('/jobs/$jobId');
        return response;
      }
    } catch (e) {
      print('Get job by ID error: $e');
      return {'success': false, 'message': 'Failed to fetch job details: $e'};
    }
  }

  // Update application status
  Future<Map<String, dynamic>> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      if (_apiService.isUsingMockData) {
        return await MockApiService.updateApplicationStatus(
          applicationId: applicationId,
          status: status,
        );
      } else {
        final response = await _apiService.put(
          '/applications/$applicationId/status',
          data: {'status': status},
        );

        if (response['success'] == true) {
          // Clear applications cache to refresh data
          await _storageService.removeCache(_applicationsCacheKey);
        }

        return response;
      }
    } catch (e) {
      print('Update application status error: $e');
      return {
        'success': false,
        'message': 'Failed to update application status: $e',
      };
    }
  }

  // Withdraw application
  Future<Map<String, dynamic>> withdrawApplication(String applicationId) async {
    try {
      if (_apiService.isUsingMockData) {
        return await MockApiService.updateApplicationStatus(
          applicationId: applicationId,
          status: 'WITHDRAWN',
        );
      } else {
        final response = await _apiService.delete(
          '/applications/$applicationId',
        );

        if (response['success'] == true) {
          // Clear applications cache to refresh data
          await _storageService.removeCache(_applicationsCacheKey);
        }

        return response;
      }
    } catch (e) {
      print('Withdraw application error: $e');
      return {
        'success': false,
        'message': 'Failed to withdraw application: $e',
      };
    }
  }

  // Search jobs
  Future<Map<String, dynamic>> searchJobs({
    required String query,
    String? jobType,
    String? location,
    double? minCgpa,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      if (_apiService.isUsingMockData) {
        // Mock search implementation
        final allJobs = JobMockData.getAllJobs();
        final filteredJobs = allJobs.where((job) {
          final title = job['title']?.toString().toLowerCase() ?? '';
          final company = job['companyName']?.toString().toLowerCase() ?? '';
          final jobLocation = job['location']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          return title.contains(searchQuery) ||
              company.contains(searchQuery) ||
              jobLocation.contains(searchQuery);
        }).toList();

        return {
          'success': true,
          'message': 'Jobs searched successfully',
          'data': {
            'jobs': filteredJobs,
            'pagination': {
              'currentPage': page,
              'totalPages': 1,
              'totalItems': filteredJobs.length,
            },
          },
        };
      } else {
        final queryParams = <String, dynamic>{
          'q': query,
          'page': page,
          'limit': limit,
        };

        if (jobType != null) queryParams['job_type'] = jobType;
        if (location != null) queryParams['location'] = location;
        if (minCgpa != null) queryParams['min_cgpa'] = minCgpa;

        final response = await _apiService.get(
          '/jobs/search',
          queryParameters: queryParams,
        );
        return response;
      }
    } catch (e) {
      print('Search jobs error: $e');
      return {
        'success': false,
        'message': 'Failed to search jobs: $e',
        'data': {'jobs': []},
      };
    }
  }

  // Get job filters
  Future<Map<String, dynamic>> getJobFilters() async {
    try {
      if (_apiService.isUsingMockData) {
        return {
          'success': true,
          'message': 'Filters fetched successfully',
          'data': {
            'jobTypes': ['INTERNSHIP', 'FULL_TIME', 'BOTH'],
            'locations': ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Pune'],
            'companies': ['TCS', 'Infosys', 'Wipro', 'Accenture', 'Cognizant'],
          },
        };
      } else {
        final response = await _apiService.get('/jobs/filters');
        return response;
      }
    } catch (e) {
      print('Get job filters error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch filters: $e',
        'data': {'jobTypes': [], 'locations': [], 'companies': []},
      };
    }
  }

  // Clear cache
  Future<void> clearJobsCache() async {
    try {
      await _storageService.removeCache(_jobsCacheKey);
      await _storageService.removeCache(_applicationsCacheKey);
    } catch (e) {
      print('Clear cache error: $e');
    }
  }

  // Get cached jobs
  Future<Map<String, dynamic>?> getCachedJobs() async {
    return await _storageService.getCacheWithTTL<Map<String, dynamic>>(
      _jobsCacheKey,
    );
  }

  // Get cached applications
  Future<Map<String, dynamic>?> getCachedApplications(String studentId) async {
    final cacheKey = '${_applicationsCacheKey}_$studentId';
    return await _storageService.getCacheWithTTL<Map<String, dynamic>>(
      cacheKey,
    );
  }
}
