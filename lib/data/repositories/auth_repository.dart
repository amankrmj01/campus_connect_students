// lib/data/repositories/auth_repository.dart
import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class AuthRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      if (response['success'] == true) {
        // Store authentication data
        await _storageService.saveToken(response['token']);
        if (response['refresh_token'] != null) {
          await _storageService.saveRefreshToken(response['refresh_token']);
        }

        // Store student data
        if (response['student'] != null) {
          await _storageService.saveStudentData(response['student']);
        }

        // Setup notifications if enabled
        final notificationsEnabled =
            await _storageService.getBool('notifications_enabled') ?? true;
        if (notificationsEnabled) {
          await _setupNotifications();
        }
      }

      return response;
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Login failed. Please try again.',
      };
    }
  }

  // Change Password (First Time Login)
  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response['success'] == true) {
        // Update stored tokens if provided
        if (response['token'] != null) {
          await _storageService.saveToken(response['token']);
        }
        if (response['refresh_token'] != null) {
          await _storageService.saveRefreshToken(response['refresh_token']);
        }

        // Update student data if provided
        if (response['student'] != null) {
          await _storageService.saveStudentData(response['student']);
        }
      }

      return response;
    } catch (e) {
      print('Change password error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Password change failed. Please try again.',
      };
    }
  }

  // Forgot Password (Request Reset)
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      return response;
    } catch (e) {
      print('Forgot password error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Password reset request failed. Please try again.',
      };
    }
  }

  // Reset Password (With Token)
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.post(
        '/auth/reset-password',
        data: {'token': token, 'new_password': newPassword},
      );

      return response;
    } catch (e) {
      print('Reset password error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Password reset failed. Please try again.',
      };
    }
  }

  // Verify Email (If needed)
  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-email',
        data: {'token': token},
      );

      return response;
    } catch (e) {
      print('Email verification error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Email verification failed. Please try again.',
      };
    }
  }

  // Refresh Token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        return {'success': false, 'message': 'No refresh token available'};
      }

      final response = await _apiService.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response['success'] == true) {
        await _storageService.saveToken(response['token']);
        if (response['refresh_token'] != null) {
          await _storageService.saveRefreshToken(response['refresh_token']);
        }
      }

      return response;
    } catch (e) {
      print('Token refresh error: $e');
      return {'success': false, 'message': 'Token refresh failed'};
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      // Notify server about logout
      await _apiService.post('/auth/logout');
    } catch (e) {
      print('Server logout error: $e');
      // Continue with local logout even if server call fails
    }

    try {
      // Clear local data
      await _storageService.clearTokens();
      await _storageService.clearStudentData();

      // Cancel all notifications
      await _notificationService.cancelAllNotifications();

      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e) {
      print('Local logout error: $e');
      return {'success': false, 'message': 'Logout failed'};
    }
  }

  // Check Authentication Status
  Future<bool> isAuthenticated() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      // Optionally verify token with server
      final response = await _apiService.get('/auth/verify');
      return response['success'] == true;
    } catch (e) {
      print('Auth check error: $e');
      return false;
    }
  }

  // Get Current User Data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response['success'] == true) {
        // Update stored student data
        await _storageService.saveStudentData(response['student']);
        return response['student'];
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      // Fallback to stored data
      return await _storageService.getStudentData();
    }
  }

  // Update Device Token (for push notifications)
  Future<Map<String, dynamic>> updateDeviceToken(String deviceToken) async {
    try {
      final response = await _apiService.post(
        '/auth/device-token',
        data: {
          'device_token': deviceToken,
          'platform': GetPlatform.isAndroid ? 'android' : 'ios',
        },
      );

      return response;
    } catch (e) {
      print('Update device token error: $e');
      return {'success': false, 'message': 'Device token update failed'};
    }
  }

  // Enable Two-Factor Authentication
  Future<Map<String, dynamic>> enableTwoFactor() async {
    try {
      final response = await _apiService.post('/auth/2fa/enable');
      return response;
    } catch (e) {
      print('Enable 2FA error: $e');
      return {
        'success': false,
        'message': 'Two-factor authentication setup failed',
      };
    }
  }

  // Disable Two-Factor Authentication
  Future<Map<String, dynamic>> disableTwoFactor(String code) async {
    try {
      final response = await _apiService.post(
        '/auth/2fa/disable',
        data: {'code': code},
      );

      return response;
    } catch (e) {
      print('Disable 2FA error: $e');
      return {
        'success': false,
        'message': 'Two-factor authentication disable failed',
      };
    }
  }

  // Verify Two-Factor Code
  Future<Map<String, dynamic>> verifyTwoFactor(String code) async {
    try {
      final response = await _apiService.post(
        '/auth/2fa/verify',
        data: {'code': code},
      );

      if (response['success'] == true) {
        // Store tokens if provided
        if (response['token'] != null) {
          await _storageService.saveToken(response['token']);
        }
        if (response['refresh_token'] != null) {
          await _storageService.saveRefreshToken(response['refresh_token']);
        }
      }

      return response;
    } catch (e) {
      print('Verify 2FA error: $e');
      return {'success': false, 'message': 'Two-factor verification failed'};
    }
  }

  // Setup Notifications
  Future<void> _setupNotifications() async {
    try {
      // Clear existing notifications
      await _notificationService.cancelAllNotifications();

      // Schedule welcome notification
      await _notificationService.showNotification(
        id: 1,
        title: 'Welcome to P Connect!',
        body: 'Complete your profile to get personalized job recommendations.',
      );
    } catch (e) {
      print('Setup notifications error: $e');
    }
  }

  // Delete Account
  Future<Map<String, dynamic>> deleteAccount(String password) async {
    try {
      final response = await _apiService.delete(
        '/auth/account',
        data: {'password': password},
      );

      if (response['success'] == true) {
        // Clear all local data
        await _storageService.clearAll();
        await _notificationService.cancelAllNotifications();
      }

      return response;
    } catch (e) {
      print('Delete account error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Account deletion failed. Please try again.',
      };
    }
  }

  // Update Password
  Future<Map<String, dynamic>> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.put(
        '/auth/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      return response;
    } catch (e) {
      print('Update password error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Password update failed. Please try again.',
      };
    }
  }

  // Check if first time login
  Future<bool> isFirstTimeLogin() async {
    try {
      final studentData = await _storageService.getStudentData();
      return studentData?['is_first_time_login'] == true;
    } catch (e) {
      print('Check first time login error: $e');
      return false;
    }
  }

  // Mark first time login as complete
  Future<void> markFirstTimeLoginComplete() async {
    try {
      final studentData = await _storageService.getStudentData();
      if (studentData != null) {
        studentData['is_first_time_login'] = false;
        await _storageService.saveStudentData(studentData);
      }

      // Also update on server
      await _apiService.post('/auth/first-login-complete');
    } catch (e) {
      print('Mark first time login complete error: $e');
    }
  }
}
