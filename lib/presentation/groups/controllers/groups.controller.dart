// lib/presentation/groups/controllers/groups.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/enum.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/services/storage_service.dart';

class GroupsController extends GetxController {
  final ChatRepository _chatRepository = Get.find<ChatRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Reactive variables
  final RxList<RecruitmentGroup> userGroups = <RecruitmentGroup>[].obs;
  final Rx<RecruitmentGroup?> selectedGroup = Rx<RecruitmentGroup?>(null);
  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSendingMessage = false.obs;
  final Rx<Student?> currentStudent = Rx<Student?>(null);

  // Chat input
  final TextEditingController messageController = TextEditingController();
  final ScrollController messagesScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    initializeGroups();
  }

  @override
  void onClose() {
    messageController.dispose();
    messagesScrollController.dispose();
    super.onClose();
  }

  // Initialize groups data
  void initializeGroups() async {
    try {
      isLoading.value = true;
      await loadCurrentStudent();
      await loadUserGroups();
    } catch (e) {
      print('Initialize groups error: $e');
      Get.snackbar(
        'Error',
        'Failed to load groups',
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

  // Load user groups
  Future<void> loadUserGroups() async {
    try {
      if (currentStudent.value == null) return;

      final response = await _chatRepository.getUserGroups(
        studentId: currentStudent.value!.userId,
      );

      if (response['success'] == true && response['data'] != null) {
        final groupsData = response['data']['groups'] as List? ?? [];
        final groups = groupsData
            .map((group) => RecruitmentGroup.fromJson(group))
            .toList();
        userGroups.assignAll(groups);
      } else {
        userGroups.clear();
      }
    } catch (e) {
      print('Load user groups error: $e');
      userGroups.clear();
    }
  }

  // Select group and load messages
  void selectGroup(RecruitmentGroup group) async {
    try {
      selectedGroup.value = group;
      isLoadingMessages.value = true;
      messages.clear();

      final response = await _chatRepository.getGroupMessages(
        groupId: group.groupId,
      );

      if (response['success'] == true) {
        final groupMessages = (response['messages'] as List)
            .map((message) => Message.fromJson(message))
            .toList();
        messages.assignAll(groupMessages);

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom();
        });
      }
    } catch (e) {
      print('Load group messages error: $e');
      Get.snackbar(
        'Error',
        'Failed to load messages',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingMessages.value = false;
    }
  }

  // Convert MessageType enum to String
  String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.FILE:
        return 'FILE';
    }
  }

  // Convert String to MessageType enum
  MessageType _stringToMessageType(String typeString) {
    switch (typeString.toUpperCase()) {
      case 'TEXT':
        return MessageType.TEXT;
      case 'IMAGE':
        return MessageType.IMAGE;
      case 'FILE':
        return MessageType.FILE;
      default:
        return MessageType.TEXT;
    }
  }

  // Send text message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || selectedGroup.value == null)
      return;

    try {
      isSendingMessage.value = true;
      final messageText = messageController.text.trim();

      // Clear input immediately for better UX
      messageController.clear();

      // Add optimistic message
      final optimisticMessage = Message(
        messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        groupId: selectedGroup.value!.groupId,
        senderId: currentStudent.value!.userId,
        senderName: currentStudent.value!.name,
        senderType: UserType.STUDENT,
        content: messageText,
        timestamp: DateTime.now(),
        messageType: MessageType.TEXT,
        isDelivered: false,
      );

      messages.add(optimisticMessage);
      scrollToBottom();

      final response = await _chatRepository.sendMessage(
        groupId: selectedGroup.value!.groupId,
        senderId: currentStudent.value!.userId,
        content: messageText,
        messageType: _messageTypeToString(
          MessageType.TEXT,
        ), // Convert enum to string
      );

      if (response['success'] == true) {
        // Replace optimistic message with real one
        final realMessage = Message.fromJson(response['message']);
        final index = messages.indexWhere(
          (msg) => msg.messageId == optimisticMessage.messageId,
        );
        if (index != -1) {
          messages[index] = realMessage;
        }
      } else {
        // Remove failed message
        messages.removeWhere(
          (msg) => msg.messageId == optimisticMessage.messageId,
        );
        Get.snackbar(
          'Error',
          'Failed to send message',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Send message error: $e');
      // Remove failed message
      messages.removeWhere((msg) => msg.messageId.startsWith('temp_'));
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Send image message
  Future<void> sendImageMessage(String imagePath) async {
    if (selectedGroup.value == null || currentStudent.value == null) return;

    try {
      isSendingMessage.value = true;

      // Add optimistic message
      final optimisticMessage = Message(
        messageId: 'temp_img_${DateTime.now().millisecondsSinceEpoch}',
        groupId: selectedGroup.value!.groupId,
        senderId: currentStudent.value!.userId,
        senderName: currentStudent.value!.name,
        senderType: UserType.STUDENT,
        content: imagePath,
        // Store local path temporarily
        timestamp: DateTime.now(),
        messageType: MessageType.IMAGE,
        isDelivered: false,
      );

      messages.add(optimisticMessage);
      scrollToBottom();

      final response = await _chatRepository.sendImageMessage(
        groupId: selectedGroup.value!.groupId,
        senderId: currentStudent.value!.userId,
        imagePath: imagePath,
      );

      if (response['success'] == true) {
        // Replace optimistic message with real one
        final realMessage = Message.fromJson(response['message']);
        final index = messages.indexWhere(
          (msg) => msg.messageId == optimisticMessage.messageId,
        );
        if (index != -1) {
          messages[index] = realMessage;
        }
      } else {
        // Remove failed message
        messages.removeWhere(
          (msg) => msg.messageId == optimisticMessage.messageId,
        );
        Get.snackbar(
          'Error',
          'Failed to send image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Send image error: $e');
      messages.removeWhere((msg) => msg.messageId.startsWith('temp_img_'));
      Get.snackbar(
        'Error',
        'Failed to send image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Send file message
  Future<void> sendFileMessage(String filePath) async {
    if (selectedGroup.value == null || currentStudent.value == null) return;

    try {
      isSendingMessage.value = true;

      // Add optimistic message
      final optimisticMessage = Message(
        messageId: 'temp_file_${DateTime.now().millisecondsSinceEpoch}',
        groupId: selectedGroup.value!.groupId,
        senderId: currentStudent.value!.userId,
        senderName: currentStudent.value!.name,
        senderType: UserType.STUDENT,
        content: filePath.split('/').last,
        // Show filename
        timestamp: DateTime.now(),
        messageType: MessageType.FILE,
        isDelivered: false,
      );

      messages.add(optimisticMessage);
      scrollToBottom();

      final response = await _chatRepository.sendFileMessage(
        groupId: selectedGroup.value!.groupId,
        senderId: currentStudent.value!.userId,
        filePath: filePath,
      );

      if (response['success'] == true) {
        // Replace optimistic message with real one
        final realMessage = Message.fromJson(response['message']);
        final index = messages.indexWhere(
          (msg) => msg.messageId == optimisticMessage.messageId,
        );
        if (index != -1) {
          messages[index] = realMessage;
        }
      } else {
        // Remove failed message
        messages.removeWhere(
          (msg) => msg.messageId == optimisticMessage.messageId,
        );
        Get.snackbar(
          'Error',
          'Failed to send file',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Send file error: $e');
      messages.removeWhere((msg) => msg.messageId.startsWith('temp_file_'));
      Get.snackbar(
        'Error',
        'Failed to send file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  // Show attachment options
  void showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send Attachment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Photo Gallery'),
              onTap: () {
                Get.back();
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attachment, color: Colors.orange),
              title: const Text('Document'),
              onTap: () {
                Get.back();
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from gallery
  void _pickImageFromGallery() async {
    try {
      // TODO: Implement image picker from gallery
      // final picker = ImagePicker();
      // final image = await picker.pickImage(source: ImageSource.gallery);
      // if (image != null) {
      //   await sendImageMessage(image.path);
      // }

      // For now, show a placeholder
      Get.snackbar(
        'Feature Coming Soon',
        'Image picker will be implemented with image_picker package',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Pick image from gallery error: $e');
    }
  }

  // Pick image from camera
  void _pickImageFromCamera() async {
    try {
      // TODO: Implement image picker from camera
      // final picker = ImagePicker();
      // final image = await picker.pickImage(source: ImageSource.camera);
      // if (image != null) {
      //   await sendImageMessage(image.path);
      // }

      // For now, show a placeholder
      Get.snackbar(
        'Feature Coming Soon',
        'Camera capture will be implemented with image_picker package',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Pick image from camera error: $e');
    }
  }

  // Pick file
  void _pickFile() async {
    try {
      // TODO: Implement file picker
      // final result = await FilePicker.platform.pickFiles();
      // if (result != null && result.files.isNotEmpty) {
      //   await sendFileMessage(result.files.first.path!);
      // }

      // For now, show a placeholder
      Get.snackbar(
        'Feature Coming Soon',
        'File picker will be implemented with file_picker package',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Pick file error: $e');
    }
  }

  // Scroll to bottom of messages
  void scrollToBottom() {
    if (messagesScrollController.hasClients) {
      messagesScrollController.animateTo(
        messagesScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Back to groups list
  void backToGroupsList() {
    selectedGroup.value = null;
    messages.clear();
  }

  // Refresh groups
  Future<void> refreshGroups() async {
    await loadUserGroups();
  }

  // Refresh messages
  Future<void> refreshMessages() async {
    if (selectedGroup.value != null) {
      selectGroup(selectedGroup.value!);
    }
  }

  // Get message time format
  String getMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  // Check if message is from current user
  bool isMyMessage(Message message) {
    return message.senderId == currentStudent.value?.userId;
  }

  // Get group participant count
  String getParticipantCountText(int count) {
    if (count == 1) {
      return '1 participant';
    }
    return '$count participants';
  }

  // Format last message preview
  String formatLastMessagePreview(String content, MessageType type) {
    switch (type) {
      case MessageType.TEXT:
        return content.length > 50 ? '${content.substring(0, 50)}...' : content;
      case MessageType.IMAGE:
        return '📷 Image';
      case MessageType.FILE:
        return '📎 File';
      default:
        return content;
    }
  }

  // Get sender type icon
  IconData getSenderTypeIcon(UserType senderType) {
    switch (senderType) {
      case UserType.STUDENT:
        return Icons.person;
      case UserType.RECRUITER:
        return Icons.business;
      case UserType.COLLEGE_ADMIN:
        return Icons.school;
    }
  }

  // Get sender type color
  Color getSenderTypeColor(UserType senderType) {
    switch (senderType) {
      case UserType.STUDENT:
        return Colors.blue;
      case UserType.RECRUITER:
        return Colors.green;
      case UserType.COLLEGE_ADMIN:
        return Colors.orange;
    }
  }

  // Get message status icon
  Widget getMessageStatusIcon(Message message) {
    if (message.messageId.startsWith('temp_')) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      );
    } else if (message.isDelivered) {
      return const Icon(Icons.done_all, size: 12, color: Colors.green);
    } else {
      return const Icon(Icons.done, size: 12, color: Colors.grey);
    }
  }

  // Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Get file extension icon
  IconData getFileExtensionIcon(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }
}
