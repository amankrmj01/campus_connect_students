// lib/data/services/mock_api_service.dart
import 'dart:async';
import 'dart:math';

import '../mock_data/application_mock_data.dart';
import '../mock_data/group_mock_data.dart';
import '../mock_data/job_mock_data.dart';
import '../mock_data/user_mock_data.dart';

class MockApiService {
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

  // Job APIs
  static Future<Map<String, dynamic>> getJobs({
    int page = 1,
    int limit = 10,
    String? search,
    String? type,
    String? location,
    String? company,
  }) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    List<Map<String, dynamic>> jobs = List.from(JobMockData.jobs);

    // Apply filters
    if (search != null && search.isNotEmpty) {
      jobs = JobMockData.searchJobs(search);
    }
    if (type != null && type != 'ALL') {
      jobs = jobs.where((job) => job['type'] == type).toList();
    }
    if (location != null && location != 'ALL') {
      jobs = jobs
          .where((job) => job['location'].toString().contains(location))
          .toList();
    }
    if (company != null && company.isNotEmpty) {
      jobs = jobs
          .where(
            (job) => job['companyName'].toString().toLowerCase().contains(
              company.toLowerCase(),
            ),
          )
          .toList();
    }

    // Pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedJobs = jobs.skip(startIndex).take(limit).toList();

    return {
      'success': true,
      'data': {
        'jobs': paginatedJobs,
        'pagination': {
          'currentPage': page,
          'totalPages': (jobs.length / limit).ceil(),
          'totalJobs': jobs.length,
          'hasNextPage': endIndex < jobs.length,
        },
      },
    };
  }

  static Future<Map<String, dynamic>> getJobById(String jobId) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    final job = JobMockData.getJobById(jobId);
    if (job.isEmpty) {
      throw Exception('Job not found');
    }

    return {'success': true, 'data': job};
  }

  static Future<Map<String, dynamic>> getJobFilters() async {
    await _simulateDelay(300);

    // TODO: Replace with actual API call
    return {'success': true, 'data': JobMockData.jobFilters};
  }

  // Application APIs
  static Future<Map<String, dynamic>> applyForJob(
    String jobId,
    Map<String, dynamic> applicationData,
  ) async {
    await _simulateDelay(1500);

    // TODO: Replace with actual API call
    final newApplication = {
      'id': 'app_${Random().nextInt(9999).toString().padLeft(4, '0')}',
      'studentId': UserMockData.currentUser['id'],
      'jobId': jobId,
      ...applicationData,
      'appliedDate': DateTime.now().toIso8601String(),
      'status': 'APPLIED',
      'statusHistory': [
        {
          'status': 'APPLIED',
          'date': DateTime.now().toIso8601String(),
          'note': 'Application submitted successfully',
        },
      ],
    };

    return {
      'success': true,
      'message': 'Application submitted successfully',
      'data': newApplication,
    };
  }

  static Future<Map<String, dynamic>> getApplications(
    String studentId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    List<Map<String, dynamic>> applications =
        ApplicationMockData.getApplicationsByStudentId(studentId);

    if (status != null && status != 'ALL') {
      applications = applications
          .where((app) => app['status'] == status)
          .toList();
    }

    // Sort by applied date (newest first)
    applications.sort(
      (a, b) => DateTime.parse(
        b['appliedDate'],
      ).compareTo(DateTime.parse(a['appliedDate'])),
    );

    // Pagination
    final startIndex = (page - 1) * limit;
    final paginatedApps = applications.skip(startIndex).take(limit).toList();

    return {
      'success': true,
      'data': {
        'applications': paginatedApps,
        'pagination': {
          'currentPage': page,
          'totalPages': (applications.length / limit).ceil(),
          'totalApplications': applications.length,
          'hasNextPage': startIndex + limit < applications.length,
        },
        'stats': ApplicationMockData.getApplicationStats(studentId),
      },
    };
  }

  static Future<Map<String, dynamic>> getApplicationById(
    String applicationId,
  ) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    final application = ApplicationMockData.getApplicationById(applicationId);
    if (application.isEmpty) {
      throw Exception('Application not found');
    }

    return {'success': true, 'data': application};
  }

  static Future<Map<String, dynamic>> withdrawApplication(
    String applicationId,
  ) async {
    await _simulateDelay(800);

    // TODO: Replace with actual API call
    return {'success': true, 'message': 'Application withdrawn successfully'};
  }

  static Future<Map<String, dynamic>> getUpcomingInterviews(
    String studentId,
  ) async {
    await _simulateDelay();

    // TODO: Replace with actual API call
    final interviews = ApplicationMockData.getUpcomingInterviews(studentId);

    return {'success': true, 'data': interviews};
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
}
