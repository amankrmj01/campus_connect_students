// lib/data/services/mock_api_service.dart
import 'dart:async';
import 'dart:math';

import '../mock_data/application_mock_data.dart';
import '../mock_data/group_mock_data.dart';
import '../mock_data/job_mock_data.dart';
import '../mock_data/user_mock_data.dart';

class MockApiService {
  // Store submitted applications with status
  static final Map<String, Map<String, dynamic>> _submittedApplications = {};

  // Simulate network delay
  static Future<void> _simulateDelay([int? milliseconds]) async {
    final delay = milliseconds ?? Random().nextInt(1000) + 500; // 500-1500ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  // Auth APIs
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    await _simulateDelay(800);

    // Check credentials
    if (email == UserMockData.loginCredentials['email'] &&
        password == UserMockData.loginCredentials['password']) {
      return {
        'success': true,
        'message': 'Login successful',
        'token': UserMockData.authTokens['access_token'],
        'refresh_token': UserMockData.authTokens['refresh_token'],
        'student': UserMockData.currentUser,
      };
    } else {
      return {'success': false, 'message': 'Invalid email or password'};
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    await _simulateDelay(1000);

    // TODO: Replace with actual API call
    return {
      'success': true,
      'message': 'Registration successful',
      'data': {
        'user': {
          ...UserMockData.currentUser,
          ...userData,
          'id': 'user_${Random().nextInt(9999).toString().padLeft(4, '0')}',
        },
        'tokens': UserMockData.authTokens,
      },
    };
  }

  static Future<Map<String, dynamic>> logout() async {
    await _simulateDelay(300);

    // TODO: Replace with actual API call
    return {'success': true, 'message': 'Logged out successfully'};
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    await _simulateDelay(500);

    // TODO: Replace with actual API call
    return {
      'success': true,
      'message': 'User data retrieved successfully',
      'student': UserMockData.currentUser,
    };
  }

  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    await _simulateDelay(500);

    // TODO: Replace with actual API call
    return {'success': true, 'data': UserMockData.authTokens};
  }

  // User Profile APIs
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    final user = UserMockData.mockStudents.firstWhere(
      (user) => user['id'] == userId,
      orElse: () => UserMockData.currentUser,
    );

    return {'success': true, 'data': user};
  }

  static Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _simulateDelay(1200);

    // TODO: Replace with actual API call
    return {
      'success': true,
      'message': 'Profile updated successfully',
      'data': {...UserMockData.currentUser, ...updates},
    };
  }

  static Future<Map<String, dynamic>> uploadProfileImage(
    String userId,
    String imagePath,
  ) async {
    await _simulateDelay(2000);

    // TODO: Replace with actual API call
    return {
      'success': true,
      'message': 'Profile image updated successfully',
      'data': {'profileImage': 'https://via.placeholder.com/150?text=Updated'},
    };
  }

  // Job APIs - Returns eligible/not eligible jobs based on student criteria
  static Future<Map<String, dynamic>> getJobs({
    required double cgpa,
    required String branch,
    required String degreeType,
    required int graduationYear,
    int page = 1,
    int limit = 50,
  }) async {
    await _simulateDelay(800);

    try {
      final currentTime = DateTime.now();
      final allJobs = JobMockData.getAllJobs();

      final List<Map<String, dynamic>> eligibleJobs = [];
      final List<Map<String, dynamic>> notEligibleJobs = [];

      for (final job in allJobs) {
        // Check if job is still open (before deadline)
        final deadline = DateTime.parse(job['applicationDeadline']);
        if (deadline.isBefore(currentTime)) {
          continue; // Skip expired jobs
        }

        final requirements = job['requirements'] as Map<String, dynamic>;
        bool isEligible = true;

        // Check eligibility criteria
        // CGPA check
        if (cgpa < (requirements['minCgpa'] ?? 0.0)) {
          isEligible = false;
        }

        // Branch check
        final allowedBranches = List<String>.from(
          requirements['allowedBranches'] ?? [],
        );
        if (allowedBranches.isNotEmpty && !allowedBranches.contains(branch)) {
          isEligible = false;
        }

        // Degree type check
        final allowedDegreeTypes = List<String>.from(
          requirements['allowedDegreeTypes'] ?? [],
        );
        if (allowedDegreeTypes.isNotEmpty &&
            !allowedDegreeTypes.contains(degreeType)) {
          isEligible = false;
        }

        // Graduation year check
        final graduationYears = List<int>.from(
          requirements['graduationYears'] ?? [],
        );
        if (graduationYears.isNotEmpty &&
            !graduationYears.contains(graduationYear)) {
          isEligible = false;
        }

        // Add to appropriate list
        if (isEligible) {
          eligibleJobs.add(job);
        } else {
          notEligibleJobs.add(job);
        }
      }

      return {
        'success': true,
        'message': 'Jobs fetched successfully',
        'data': {
          'jobs': [...eligibleJobs, ...notEligibleJobs],
          // All jobs for compatibility
          'eligible': eligibleJobs,
          'notEligible': notEligibleJobs,
          'pagination': {
            'currentPage': page,
            'totalPages': 1,
            'totalItems': eligibleJobs.length + notEligibleJobs.length,
            'itemsPerPage': limit,
          },
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch jobs: $e',
        'data': {'jobs': [], 'eligible': [], 'notEligible': []},
      };
    }
  }

  // Submit job application
  static Future<Map<String, dynamic>> submitJobApplication({
    required String jobId,
    required String candidateId,
    required List<Map<String, dynamic>> answers,
  }) async {
    await _simulateDelay(1500);

    try {
      final applicationId =
          'APP_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

      // Determine initial status (simulate real-world scenarios)
      final statusOptions = ['UNDER_REVIEW', 'PENDING'];
      final status = statusOptions[Random().nextInt(statusOptions.length)];

      final application = {
        'applicationId': applicationId,
        'jobId': jobId,
        'candidateId': candidateId,
        'answers': answers,
        'status': status,
        'appliedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Store the application
      _submittedApplications[applicationId] = application;

      // Add to candidate's applied jobs list (simulate updating user data)
      _addToStudentApplications(candidateId, jobId, applicationId, status);

      return {
        'success': true,
        'message': 'Application submitted successfully',
        'data': {
          'applicationId': applicationId,
          'status': status,
          'submittedAt': application['appliedAt'],
        },
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit application: $e'};
    }
  }

  // Get student applications
  static Future<Map<String, dynamic>> getStudentApplications({
    required String studentId,
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    await _simulateDelay(600);

    try {
      // Get applications for this student
      final studentApplications = _submittedApplications.values
          .where((app) => app['candidateId'] == studentId)
          .toList();

      // Filter by status if provided
      final filteredApplications = status != null
          ? studentApplications.where((app) => app['status'] == status).toList()
          : studentApplications;

      // Sort by applied date (newest first)
      filteredApplications.sort(
        (a, b) => DateTime.parse(
          b['appliedAt'],
        ).compareTo(DateTime.parse(a['appliedAt'])),
      );

      // Add job details to each application
      final enrichedApplications = filteredApplications.map((app) {
        final job = JobMockData.getJobById(app['jobId']);
        return {...app, 'job': job};
      }).toList();

      return {
        'success': true,
        'message': 'Applications fetched successfully',
        'data': {
          'applications': enrichedApplications,
          'pagination': {
            'currentPage': page,
            'totalPages': (enrichedApplications.length / limit).ceil(),
            'totalItems': enrichedApplications.length,
            'itemsPerPage': limit,
          },
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to fetch applications: $e',
        'data': {'applications': []},
      };
    }
  }

  // Update application status (simulate status changes over time)
  static Future<Map<String, dynamic>> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    await _simulateDelay(400);

    try {
      if (_submittedApplications.containsKey(applicationId)) {
        _submittedApplications[applicationId]!['status'] = status;
        _submittedApplications[applicationId]!['updatedAt'] = DateTime.now()
            .toIso8601String();

        return {
          'success': true,
          'message': 'Application status updated successfully',
          'data': _submittedApplications[applicationId],
        };
      } else {
        return {'success': false, 'message': 'Application not found'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update application status: $e',
      };
    }
  }

  // Helper method to add application to student's list
  static void _addToStudentApplications(
    String candidateId,
    String jobId,
    String applicationId,
    String status,
  ) {
    // In a real app, this would update the user's data in the database
    // For mock, we're just storing in the applications map
    print(
      'Added application $applicationId for student $candidateId to job $jobId with status $status',
    );
  }

  // Simulate status changes for demo (call this periodically)
  static void simulateStatusUpdates() {
    final random = Random();
    final statusOptions = [
      'UNDER_REVIEW',
      'SHORTLISTED',
      'REJECTED',
      'SELECTED',
    ];

    for (final application in _submittedApplications.values) {
      if (random.nextBool() && random.nextBool()) {
        // 25% chance
        final newStatus = statusOptions[random.nextInt(statusOptions.length)];
        application['status'] = newStatus;
        application['updatedAt'] = DateTime.now().toIso8601String();
      }
    }
  }

  // Group APIs
  static Future<Map<String, dynamic>> getGroups(
    String studentId, {
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    List<Map<String, dynamic>> groups = List.from(GroupMockData.groups);

    if (search != null && search.isNotEmpty) {
      groups = GroupMockData.searchGroups(search);
    }

    // Pagination
    final startIndex = (page - 1) * limit;
    final paginatedGroups = groups.skip(startIndex).take(limit).toList();

    return {
      'success': true,
      'data': {
        'groups': paginatedGroups,
        'pagination': {
          'currentPage': page,
          'totalPages': (groups.length / limit).ceil(),
          'totalGroups': groups.length,
          'hasNextPage': startIndex + limit < groups.length,
        },
        'unreadCount': GroupMockData.getTotalUnreadMessages(studentId),
      },
    };
  }

  static Future<Map<String, dynamic>> getGroupById(String groupId) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    final group = GroupMockData.getGroupById(groupId);
    if (group.isEmpty) {
      throw Exception('Group not found');
    }

    return {'success': true, 'data': group};
  }

  static Future<Map<String, dynamic>> joinGroup(
    String groupId,
    String studentId,
  ) async {
    await _simulateDelay(600);

    // TODO: Replace with actual API call
    return {'success': true, 'message': 'Successfully joined the group'};
  }

  static Future<Map<String, dynamic>> leaveGroup(
    String groupId,
    String studentId,
  ) async {
    await _simulateDelay(600);

    // TODO: Replace with actual API call
    return {'success': true, 'message': 'Successfully left the group'};
  }

  static Future<Map<String, dynamic>> getGroupMessages(
    String groupId, {
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    final messages = GroupMockData.getMessagesByGroupId(groupId);

    // Sort by timestamp (newest first)
    messages.sort(
      (a, b) => DateTime.parse(
        b['timestamp'],
      ).compareTo(DateTime.parse(a['timestamp'])),
    );

    // Pagination
    final startIndex = (page - 1) * limit;
    final paginatedMessages = messages.skip(startIndex).take(limit).toList();

    return {
      'success': true,
      'data': {
        'messages': paginatedMessages,
        'pagination': {
          'currentPage': page,
          'totalPages': (messages.length / limit).ceil(),
          'totalMessages': messages.length,
          'hasNextPage': startIndex + limit < messages.length,
        },
      },
    };
  }

  static Future<Map<String, dynamic>> sendMessage(
    String groupId,
    String studentId,
    String message,
  ) async {
    await _simulateDelay(400);

    // TODO: Replace with actual API call
    final newMessage = {
      'id': 'msg_${Random().nextInt(9999).toString().padLeft(4, '0')}',
      'groupId': groupId,
      'senderId': studentId,
      'senderName': UserMockData.currentUser['name'],
      'senderAvatar': UserMockData.currentUser['profileImage'],
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'TEXT',
      'edited': false,
      'reactions': [],
      'replies': [],
    };

    return {
      'success': true,
      'message': 'Message sent successfully',
      'data': newMessage,
    };
  }

  // Dashboard APIs
  static Future<Map<String, dynamic>> getDashboardData(String studentId) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    final stats = ApplicationMockData.getApplicationStats(studentId);
    final upcomingInterviews = ApplicationMockData.getUpcomingInterviews(
      studentId,
    );
    final recentJobs = JobMockData.jobs.take(5).toList();
    final userGroups = GroupMockData.getGroupsByStudentId(studentId);

    return {
      'success': true,
      'data': {
        'applicationStats': stats,
        'upcomingInterviews': upcomingInterviews,
        'recentJobs': recentJobs,
        'groups': userGroups,
        'notifications': [
          {
            'id': 'notif_001',
            'title': 'Interview Scheduled',
            'message':
                'Your interview with Meta has been scheduled for tomorrow',
            'type': 'INTERVIEW',
            'timestamp': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
            'read': false,
          },
          {
            'id': 'notif_002',
            'title': 'New Job Alert',
            'message': '5 new jobs matching your preferences',
            'type': 'JOB_ALERT',
            'timestamp': DateTime.now()
                .subtract(const Duration(hours: 6))
                .toIso8601String(),
            'read': false,
          },
        ],
      },
    };
  }

  // File Upload APIs
  static Future<Map<String, dynamic>> uploadDocument(
    String filePath,
    String type,
  ) async {
    await _simulateDelay(3000); // Simulate longer upload time

    // TODO: Replace with actual API call
    return {
      'success': true,
      'message': 'Document uploaded successfully',
      'data': {
        'fileName': filePath.split('/').last,
        'fileUrl':
            'https://example.com/documents/${Random().nextInt(9999)}.pdf',
        'uploadDate': DateTime.now().toIso8601String(),
        'type': type,
      },
    };
  }

  // Settings APIs
  static Future<Map<String, dynamic>> updateNotificationSettings(
    String studentId,
    Map<String, bool> settings,
  ) async {
    await _simulateDelay(500);

    // TODO: Replace with actual API call
    return {
      'success': true,
      'message': 'Notification settings updated successfully',
      'data': settings,
    };
  }

  static Future<Map<String, dynamic>> changePassword(
    String studentId,
    String oldPassword,
    String newPassword,
  ) async {
    await _simulateDelay(800);

    // TODO: Replace with actual API call
    return {'success': true, 'message': 'Password changed successfully'};
  }

  static Future<Map<String, dynamic>> deleteAccount(String studentId) async {
    await _simulateDelay(1000);

    // TODO: Replace with actual API call
    return {'success': true, 'message': 'Account deleted successfully'};
  }

  // Job Application Questions API
  static Future<Map<String, dynamic>> getJobApplicationQuestions(
    String jobId,
  ) async {
    await _simulateDelay(400);

    // Get job data and return application questions
    final jobData = JobMockData.getJobById(jobId);
    if (jobData.isEmpty) {
      return {'success': false, 'message': 'Job not found'};
    }

    final questions = jobData['applicationQuestions'] as List? ?? [];

    return {
      'success': true,
      'data': {'questions': questions, 'jobId': jobId},
    };
  }
}
