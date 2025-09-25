// lib/data/models/group_model.dart
import 'enum.dart';

class RecruitmentGroup {
  final String groupId;
  final String jobId;
  final String groupName;
  final String companyName;
  final String jobTitle;
  final List<String> participants;
  final bool isActive;
  final String currentRound;
  final DateTime createdAt;
  final Message? lastMessage;
  final int unreadCount;

  RecruitmentGroup({
    required this.groupId,
    required this.jobId,
    required this.groupName,
    required this.companyName,
    required this.jobTitle,
    required this.participants,
    required this.isActive,
    required this.currentRound,
    required this.createdAt,
    this.lastMessage,
    required this.unreadCount,
  });

  factory RecruitmentGroup.fromJson(Map<String, dynamic> json) {
    return RecruitmentGroup(
      groupId: json['groupId'] ?? '',
      jobId: json['jobId'] ?? '',
      groupName: json['groupName'] ?? '',
      companyName: json['companyName'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      isActive: json['isActive'] ?? true,
      currentRound: json['currentRound'] ?? 'Round 1',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'jobId': jobId,
      'groupName': groupName,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'participants': participants,
      'isActive': isActive,
      'currentRound': currentRound,
      'createdAt': createdAt.toIso8601String(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
    };
  }
}

class Message {
  final String messageId;
  final String groupId;
  final String senderId;
  final String senderName;
  final UserType senderType;
  final String content;
  final DateTime timestamp;
  final MessageType messageType;
  final bool isDelivered;
  final bool isRead;

  Message({
    required this.messageId,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    required this.timestamp,
    required this.messageType,
    required this.isDelivered,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] ?? '',
      groupId: json['groupId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderType: UserTypeExtension.fromString(json['senderType'] ?? 'STUDENT'),
      content: json['content'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['messageType'] ?? 'TEXT'),
        orElse: () => MessageType.TEXT,
      ),
      isDelivered: json['isDelivered'] ?? true,
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType.value,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType.toString().split('.').last,
      'isDelivered': isDelivered,
      'isRead': isRead,
    };
  }
}
