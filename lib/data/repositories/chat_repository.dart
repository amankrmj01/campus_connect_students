// lib/data/repositories/chat_repository.dart
import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/mock_api_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class ChatRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Cache keys
  static const String _groupsCacheKey = 'cache_user_groups';
  static const String _messagesCacheKey = 'cache_messages_';

  // Cache duration
  static const Duration _cacheDuration = Duration(minutes: 10);

  // Get User Groups
  Future<Map<String, dynamic>> getUserGroups({
    required String studentId,
  }) async {
    try {
      // Try cache first
      final cachedGroups = await _storageService
          .getCacheWithTTL<Map<String, dynamic>>(_groupsCacheKey);
      if (cachedGroups != null) {
        return cachedGroups;
      }

      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = await MockApiService.getGroups(studentId);
      } else {
        response = await _apiService.get(
          '/chat/groups',
          queryParameters: {'student_id': studentId},
        );
      }

      if (response['success'] == true) {
        // Cache the response
        await _storageService.setCacheWithTTL(
          _groupsCacheKey,
          response,
          _cacheDuration,
        );
      }

      return response;
    } catch (e) {
      print('Get user groups error: $e');

      // Try to return cached data
      final cachedGroups = await _storageService
          .getCacheWithTTL<Map<String, dynamic>>(_groupsCacheKey);
      if (cachedGroups != null) {
        return {
          'success': true,
          'groups': cachedGroups['groups'] ?? [],
          'cached': true,
        };
      }

      return {
        'success': false,
        'message': 'Failed to load groups',
        'groups': [],
      };
    }
  }

  // Get Group Messages
  Future<Map<String, dynamic>> getGroupMessages({
    required String groupId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final cacheKey = '$_messagesCacheKey$groupId';

      // Try cache first for first page
      if (page == 1) {
        final cachedMessages = await _storageService
            .getCacheWithTTL<Map<String, dynamic>>(cacheKey);
        if (cachedMessages != null) {
          return cachedMessages;
        }
      }

      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = await MockApiService.getGroupMessages(
          groupId,
          page: page,
          limit: limit,
        );
      } else {
        response = await _apiService.get(
          '/chat/groups/$groupId/messages',
          queryParameters: {'page': page, 'limit': limit},
        );
      }

      if (response['success'] == true && page == 1) {
        // Cache only the first page
        await _storageService.setCacheWithTTL(
          cacheKey,
          response,
          _cacheDuration,
        );
      }

      return response;
    } catch (e) {
      print('Get group messages error: $e');

      // Try to return cached data for first page
      if (page == 1) {
        final cacheKey = '$_messagesCacheKey$groupId';
        final cachedMessages = await _storageService
            .getCacheWithTTL<Map<String, dynamic>>(cacheKey);
        if (cachedMessages != null) {
          return {
            'success': true,
            'messages': cachedMessages['messages'] ?? [],
            'cached': true,
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to load messages',
        'messages': [],
      };
    }
  }

  // Send Message
  Future<Map<String, dynamic>> sendMessage({
    required String groupId,
    required String senderId,
    required String content,
    required String messageType, // TEXT, IMAGE, FILE
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = await MockApiService.sendMessage(groupId, senderId, content);
      } else {
        response = await _apiService.post(
          '/chat/groups/$groupId/messages',
          data: {
            'sender_id': senderId,
            'content': content,
            'message_type': messageType,
          },
        );
      }

      if (response['success'] == true) {
        // Clear messages cache for this group to refresh
        final cacheKey = '$_messagesCacheKey$groupId';
        await _storageService.removeCache(cacheKey);
      }

      return response;
    } catch (e) {
      print('Send message error: $e');
      return {
        'success': false,
        'message': e.toString().contains('ApiException')
            ? e.toString().replaceAll('ApiException: ', '')
            : 'Failed to send message',
      };
    }
  }

  // Send Image Message
  Future<Map<String, dynamic>> sendImageMessage({
    required String groupId,
    required String senderId,
    required String imagePath,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        // For mock data, simulate image upload
        await Future.delayed(Duration(milliseconds: 1000));
        response = {
          'success': true,
          'message': 'Image sent successfully',
          'data': {
            'messageId': 'msg_${DateTime.now().millisecondsSinceEpoch}',
            'imageUrl': 'https://via.placeholder.com/300x200?text=Mock+Image',
          },
        };
      } else {
        response = await _apiService.uploadFile(
          '/chat/groups/$groupId/messages/image',
          imagePath,
          fieldName: 'image',
          data: {'sender_id': senderId, 'message_type': 'IMAGE'},
        );
      }

      if (response['success'] == true) {
        // Clear messages cache for this group
        final cacheKey = '$_messagesCacheKey$groupId';
        await _storageService.removeCache(cacheKey);
      }

      return response;
    } catch (e) {
      print('Send image message error: $e');
      return {'success': false, 'message': 'Failed to send image'};
    }
  }

  // Send File Message
  Future<Map<String, dynamic>> sendFileMessage({
    required String groupId,
    required String senderId,
    required String filePath,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        // For mock data, simulate file upload
        await Future.delayed(Duration(milliseconds: 1500));
        response = {
          'success': true,
          'message': 'File sent successfully',
          'data': {
            'messageId': 'msg_${DateTime.now().millisecondsSinceEpoch}',
            'fileUrl': 'https://example.com/files/mock_file.pdf',
            'fileName': filePath.split('/').last,
          },
        };
      } else {
        response = await _apiService.uploadFile(
          '/chat/groups/$groupId/messages/file',
          filePath,
          fieldName: 'file',
          data: {'sender_id': senderId, 'message_type': 'FILE'},
        );
      }

      if (response['success'] == true) {
        // Clear messages cache for this group
        final cacheKey = '$_messagesCacheKey$groupId';
        await _storageService.removeCache(cacheKey);
      }

      return response;
    } catch (e) {
      print('Send file message error: $e');
      return {'success': false, 'message': 'Failed to send file'};
    }
  }

  // Get Group Details
  Future<Map<String, dynamic>> getGroupDetails(String groupId) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = await MockApiService.getGroupById(groupId);
      } else {
        response = await _apiService.get('/chat/groups/$groupId');
      }
      return response;
    } catch (e) {
      print('Get group details error: $e');
      return {'success': false, 'message': 'Failed to load group details'};
    }
  }

  // Get Group Participants
  Future<Map<String, dynamic>> getGroupParticipants(String groupId) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        // Mock response for group participants
        response = {
          'success': true,
          'data': {
            'participants': [
              {
                'id': '1',
                'name': 'John Doe',
                'avatar': 'https://via.placeholder.com/40',
              },
              {
                'id': '2',
                'name': 'Jane Smith',
                'avatar': 'https://via.placeholder.com/40',
              },
            ],
          },
        };
      } else {
        response = await _apiService.get('/chat/groups/$groupId/participants');
      }
      return response;
    } catch (e) {
      print('Get group participants error: $e');
      return {'success': false, 'message': 'Failed to load group participants'};
    }
  }

  // Mark Messages as Read
  Future<Map<String, dynamic>> markMessagesAsRead({
    required String groupId,
    required List<String> messageIds,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        // Mock response for marking messages as read
        response = {'success': true, 'message': 'Messages marked as read'};
      } else {
        response = await _apiService.post(
          '/chat/groups/$groupId/mark-read',
          data: {'message_ids': messageIds},
        );
      }
      return response;
    } catch (e) {
      print('Mark messages as read error: $e');
      return {'success': false, 'message': 'Failed to mark messages as read'};
    }
  }

  // Get Unread Message Count
  Future<Map<String, dynamic>> getUnreadMessageCount({
    required String studentId,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        // Mock response for unread count
        response = {
          'success': true,
          'data': {'unreadCount': 5},
        };
      } else {
        response = await _apiService.get(
          '/chat/unread-count',
          queryParameters: {'student_id': studentId},
        );
      }
      return response;
    } catch (e) {
      print('Get unread message count error: $e');
      return {'success': false, 'message': 'Failed to get unread count'};
    }
  }

  // Search Messages
  Future<Map<String, dynamic>> searchMessages({
    required String groupId,
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        // Mock search results
        response = {
          'success': true,
          'data': {'messages': [], 'totalResults': 0},
        };
      } else {
        response = await _apiService.get(
          '/chat/groups/$groupId/search',
          queryParameters: {'q': query, 'page': page, 'limit': limit},
        );
      }
      return response;
    } catch (e) {
      print('Search messages error: $e');
      return {'success': false, 'message': 'Search failed'};
    }
  }

  // Report Message
  Future<Map<String, dynamic>> reportMessage({
    required String messageId,
    required String reason,
    String? description,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = {
          'success': true,
          'message': 'Message reported successfully',
        };
      } else {
        response = await _apiService.post(
          '/chat/messages/$messageId/report',
          data: {'reason': reason, 'description': description},
        );
      }
      return response;
    } catch (e) {
      print('Report message error: $e');
      return {'success': false, 'message': 'Failed to report message'};
    }
  }

  // Delete Message
  Future<Map<String, dynamic>> deleteMessage({
    required String messageId,
    required String groupId,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = {'success': true, 'message': 'Message deleted successfully'};
      } else {
        response = await _apiService.delete('/chat/messages/$messageId');
      }

      if (response['success'] == true) {
        // Clear messages cache for this group
        final cacheKey = '$_messagesCacheKey$groupId';
        await _storageService.removeCache(cacheKey);
      }

      return response;
    } catch (e) {
      print('Delete message error: $e');
      return {'success': false, 'message': 'Failed to delete message'};
    }
  }

  // Get Group Access Status
  Future<Map<String, dynamic>> getGroupAccessStatus({
    required String jobId,
    required String studentId,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = {
          'success': true,
          'data': {'hasAccess': true, 'groupId': 'group_$jobId'},
        };
      } else {
        response = await _apiService.get(
          '/chat/group-access',
          queryParameters: {'job_id': jobId, 'student_id': studentId},
        );
      }
      return response;
    } catch (e) {
      print('Get group access status error: $e');
      return {'success': false, 'message': 'Failed to check group access'};
    }
  }

  // Join Group (When Eligible)
  Future<Map<String, dynamic>> joinGroup({
    required String groupId,
    required String studentId,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = await MockApiService.joinGroup(groupId, studentId);
      } else {
        response = await _apiService.post(
          '/chat/groups/$groupId/join',
          data: {'student_id': studentId},
        );
      }

      if (response['success'] == true) {
        // Clear groups cache to refresh
        await _storageService.removeCache(_groupsCacheKey);

        // Show welcome notification
        await _notificationService.showLocalNotification(
          title: 'Joined Group Chat',
          body: 'You can now participate in the group discussion',
        );
      }

      return response;
    } catch (e) {
      print('Join group error: $e');
      return {'success': false, 'message': 'Failed to join group'};
    }
  }

  // Leave Group
  Future<Map<String, dynamic>> leaveGroup({
    required String groupId,
    required String studentId,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = await MockApiService.leaveGroup(groupId, studentId);
      } else {
        response = await _apiService.post(
          '/chat/groups/$groupId/leave',
          data: {'student_id': studentId},
        );
      }

      if (response['success'] == true) {
        // Clear groups cache
        await _storageService.removeCache(_groupsCacheKey);
      }

      return response;
    } catch (e) {
      print('Leave group error: $e');
      return {'success': false, 'message': 'Failed to leave group'};
    }
  }

  // Update Group Settings
  Future<Map<String, dynamic>> updateGroupSettings({
    required String groupId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      Map<String, dynamic> response;
      if (_apiService.isUsingMockData) {
        response = {
          'success': true,
          'message': 'Group settings updated successfully',
        };
      } else {
        response = await _apiService.put(
          '/chat/groups/$groupId/settings',
          data: settings,
        );
      }
      return response;
    } catch (e) {
      print('Update group settings error: $e');
      return {'success': false, 'message': 'Failed to update group settings'};
    }
  }

  // Clear Chat Cache
  Future<void> clearChatCache() async {
    await _storageService.removeCache(_groupsCacheKey);

    // Clear all message caches - we'll iterate through known cache keys
    // Since we don't have getAllKeys method, we'll clear based on pattern
    for (int i = 0; i < 100; i++) {
      await _storageService.removeCache('${_messagesCacheKey}group_$i');
    }
  }

  // Get cached groups
  Future<Map<String, dynamic>?> getCachedGroups() async {
    return await _storageService.getCacheWithTTL<Map<String, dynamic>>(
      _groupsCacheKey,
    );
  }

  // Get cached messages for a group
  Future<Map<String, dynamic>?> getCachedMessages(String groupId) async {
    final cacheKey = '$_messagesCacheKey$groupId';
    return await _storageService.getCacheWithTTL<Map<String, dynamic>>(
      cacheKey,
    );
  }
}
