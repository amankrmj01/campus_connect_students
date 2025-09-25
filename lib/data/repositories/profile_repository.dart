// lib/data/repositories/profile_repository.dart
import 'dart:io';

import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class ProfileRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Get Student Profile
  Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final response = await _apiService.get('/profile');

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Get profile error: $e');

      // Try to return cached data
      final cachedData = await _storageService.getStudentData();
      if (cachedData != null) {
        return {'success': true, 'student': cachedData, 'cached': true};
      }

      return {'success': false, 'message': 'Failed to load profile data'};
    }
  }

  // Update Personal Details
  Future<Map<String, dynamic>> updatePersonalDetails(
    Map<String, dynamic> personalData,
  ) async {
    try {
      final response = await _apiService.put(
        '/profile/personal',
        data: personalData,
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);

        // Show success notification
        await _notificationService.showNotification(
          id: 'profile_update'.hashCode,
          title: 'Profile Updated',
          body: 'Your personal details have been updated successfully',
        );
      }

      return response;
    } catch (e) {
      print('Update personal details error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Failed to update personal details',
      };
    }
  }

  // Update Academic Details
  Future<Map<String, dynamic>> updateAcademicDetails(
    Map<String, dynamic> academicData,
  ) async {
    try {
      final response = await _apiService.put(
        '/profile/academic',
        data: academicData,
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);

        // Show success notification
        await _notificationService.showNotification(
          id: 'academic_update'.hashCode,
          title: 'Academic Details Updated',
          body: 'Your academic information has been updated successfully',
        );
      }

      return response;
    } catch (e) {
      print('Update academic details error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Failed to update academic details',
      };
    }
  }

  // Update Address
  Future<Map<String, dynamic>> updateAddress(
    Map<String, dynamic> addressData,
  ) async {
    try {
      final response = await _apiService.put(
        '/profile/address',
        data: addressData,
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Update address error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Failed to update address',
      };
    }
  }

  // Upload Profile Image
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final response = await _apiService.uploadFile(
        '/profile/image',
        imageFile.path,
        fieldName: 'profile_image',
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);

        // Show success notification
        await _notificationService.showNotification(
          id: 'profile_image_update'.hashCode,
          title: 'Profile Picture Updated',
          body: 'Your profile picture has been updated successfully',
        );
      }

      return response;
    } catch (e) {
      print('Upload profile image error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Failed to upload profile image',
      };
    }
  }

  // Upload Resume
  Future<Map<String, dynamic>> uploadResume(File resumeFile) async {
    try {
      final response = await _apiService.uploadFile(
        '/profile/resume',
        resumeFile.path,
        fieldName: 'resume',
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);

        // Show success notification
        await _notificationService.showNotification(
          id: 'resume_update'.hashCode,
          title: 'Resume Updated',
          body: 'Your resume has been uploaded successfully',
        );
      }

      return response;
    } catch (e) {
      print('Upload resume error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Failed to upload resume',
      };
    }
  }

  // Update Work Experiences
  Future<Map<String, dynamic>> updateWorkExperiences(
    List<Map<String, dynamic>> workExperiences,
  ) async {
    try {
      final response = await _apiService.put(
        '/profile/work-experience',
        data: {'work_experiences': workExperiences},
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Update work experiences error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Failed to update work experiences',
      };
    }
  }

  // Update Certifications
  Future<Map<String, dynamic>> updateCertifications(
    List<Map<String, dynamic>> certifications,
  ) async {
    try {
      final response = await _apiService.put(
        '/profile/certifications',
        data: {'certifications': certifications},
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Update certifications error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Failed to update certifications',
      };
    }
  }

  // Get Student Applications
  Future<Map<String, dynamic>> getStudentApplications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/profile/applications',
        queryParameters: {'page': page, 'limit': limit},
      );

      return response;
    } catch (e) {
      print('Get student applications error: $e');
      return {'success': false, 'message': 'Failed to load applications'};
    }
  }

  // Get Application Statistics
  Future<Map<String, dynamic>> getApplicationStats() async {
    try {
      final response = await _apiService.get('/profile/application-stats');
      return response;
    } catch (e) {
      print('Get application stats error: $e');
      return {
        'success': false,
        'message': 'Failed to load application statistics',
      };
    }
  }

  // Update Skills
  Future<Map<String, dynamic>> updateSkills(List<String> skills) async {
    try {
      final response = await _apiService.put(
        '/profile/skills',
        data: {'skills': skills},
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Update skills error: $e');
      return {'success': false, 'message': 'Failed to update skills'};
    }
  }

  // Get Profile Completion Status
  Future<Map<String, dynamic>> getProfileCompletionStatus() async {
    try {
      final response = await _apiService.get('/profile/completion-status');
      return response;
    } catch (e) {
      print('Get profile completion status error: $e');
      return {
        'success': false,
        'message': 'Failed to get profile completion status',
      };
    }
  }

  // Update Profile Visibility
  Future<Map<String, dynamic>> updateProfileVisibility(bool isVisible) async {
    try {
      final response = await _apiService.put(
        '/profile/visibility',
        data: {'is_visible': isVisible},
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Update profile visibility error: $e');
      return {
        'success': false,
        'message': 'Failed to update profile visibility',
      };
    }
  }

  // Add Project
  Future<Map<String, dynamic>> addProject(Map<String, dynamic> project) async {
    try {
      final response = await _apiService.post(
        '/profile/projects',
        data: project,
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Add project error: $e');
      return {'success': false, 'message': 'Failed to add project'};
    }
  }

  // Update Project
  Future<Map<String, dynamic>> updateProject(
    String projectId,
    Map<String, dynamic> project,
  ) async {
    try {
      final response = await _apiService.put(
        '/profile/projects/$projectId',
        data: project,
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Update project error: $e');
      return {'success': false, 'message': 'Failed to update project'};
    }
  }

  // Delete Project
  Future<Map<String, dynamic>> deleteProject(String projectId) async {
    try {
      final response = await _apiService.delete('/profile/projects/$projectId');

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Delete project error: $e');
      return {'success': false, 'message': 'Failed to delete project'};
    }
  }

  // Get Profile Analytics
  Future<Map<String, dynamic>> getProfileAnalytics() async {
    try {
      final response = await _apiService.get('/profile/analytics');
      return response;
    } catch (e) {
      print('Get profile analytics error: $e');
      return {'success': false, 'message': 'Failed to load profile analytics'};
    }
  }

  // Export Profile Data
  Future<Map<String, dynamic>> exportProfileData() async {
    try {
      final response = await _apiService.get('/profile/export');
      return response;
    } catch (e) {
      print('Export profile data error: $e');
      return {'success': false, 'message': 'Failed to export profile data'};
    }
  }

  // Update Preferences
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final response = await _apiService.put(
        '/profile/preferences',
        data: preferences,
      );

      if (response['success'] == true) {
        // Update local storage
        await _storageService.saveStudentData(response['student']);
      }

      return response;
    } catch (e) {
      print('Update preferences error: $e');
      return {'success': false, 'message': 'Failed to update preferences'};
    }
  }

  // Get Cached Profile Data
  Future<Map<String, dynamic>?> getCachedProfileData() async {
    return await _storageService.getStudentData();
  }

  // Clear Profile Cache
  Future<void> clearProfileCache() async {
    await _storageService.clearStudentData();
  }
}
