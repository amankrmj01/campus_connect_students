// lib/data/mock_data/group_mock_data.dart
class GroupMockData {
  static final List<Map<String, dynamic>> groups = [
    {
      'id': 'group_001',
      'name': 'Google SDE 2024 Batch',
      'description':
          'Discussion group for Google Software Development Engineer applications',
      'jobId': 'job_001',
      'jobTitle': 'Software Development Engineer',
      'companyName': 'Google',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Google',
      'createdDate': '2024-09-01T10:00:00Z',
      'memberCount': 245,
      'maxMembers': 500,
      'isActive': true,
      'privacy': 'PUBLIC',
      'tags': ['SDE', 'Google', 'Full-time'],
      'moderators': [
        {
          'id': 'user_mod_001',
          'name': 'Sarah Wilson',
          'role': 'HR_RECRUITER',
          'companyName': 'Google',
        },
      ],
      'latestMessage': {
        'id': 'msg_001',
        'senderId': 'user_002',
        'senderName': 'Jane Smith',
        'message': 'Has anyone received the online assessment link yet?',
        'timestamp': '2024-09-25T08:30:00Z',
        'type': 'TEXT',
      },
      'unreadCount': 3,
      'isMember': true,
      'notifications': true,
    },
    {
      'id': 'group_002',
      'name': 'Meta Frontend Intern Group',
      'description': 'Connect with other Meta frontend intern applicants',
      'jobId': 'job_002',
      'jobTitle': 'Frontend Developer Intern',
      'companyName': 'Meta',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Meta',
      'createdDate': '2024-09-10T14:30:00Z',
      'memberCount': 156,
      'maxMembers': 300,
      'isActive': true,
      'privacy': 'PUBLIC',
      'tags': ['Internship', 'Frontend', 'Meta'],
      'moderators': [
        {
          'id': 'user_mod_002',
          'name': 'Alex Thompson',
          'role': 'HR_RECRUITER',
          'companyName': 'Meta',
        },
      ],
      'latestMessage': {
        'id': 'msg_002',
        'senderId': 'user_003',
        'senderName': 'Mike Johnson',
        'message': 'Interview scheduled for next week! Any tips?',
        'timestamp': '2024-09-24T16:45:00Z',
        'type': 'TEXT',
      },
      'unreadCount': 1,
      'isMember': true,
      'notifications': true,
    },
    {
      'id': 'group_003',
      'name': 'Microsoft Data Science 2024',
      'description':
          'Discussion forum for Microsoft Data Scientist position applicants',
      'jobId': 'job_003',
      'jobTitle': 'Data Scientist',
      'companyName': 'Microsoft',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Microsoft',
      'createdDate': '2024-09-15T09:00:00Z',
      'memberCount': 89,
      'maxMembers': 200,
      'isActive': true,
      'privacy': 'PUBLIC',
      'tags': ['Data Science', 'Microsoft', 'ML'],
      'moderators': [
        {
          'id': 'user_mod_003',
          'name': 'David Chen',
          'role': 'TECHNICAL_RECRUITER',
          'companyName': 'Microsoft',
        },
      ],
      'latestMessage': {
        'id': 'msg_003',
        'senderId': 'user_mod_003',
        'senderName': 'David Chen',
        'message':
            'Phone screening will focus on ML fundamentals and statistics',
        'timestamp': '2024-09-25T10:15:00Z',
        'type': 'ANNOUNCEMENT',
      },
      'unreadCount': 0,
      'isMember': true,
      'notifications': true,
    },
    {
      'id': 'group_004',
      'name': 'Uber Mobile Dev Team',
      'description': 'Mobile development opportunities at Uber',
      'jobId': 'job_004',
      'jobTitle': 'Mobile App Developer',
      'companyName': 'Uber',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Uber',
      'createdDate': '2024-09-05T11:15:00Z',
      'memberCount': 134,
      'maxMembers': 250,
      'isActive': true,
      'privacy': 'PUBLIC',
      'tags': ['Mobile', 'Flutter', 'Uber'],
      'moderators': [
        {
          'id': 'user_mod_004',
          'name': 'Emma Rodriguez',
          'role': 'HIRING_MANAGER',
          'companyName': 'Uber',
        },
      ],
      'latestMessage': {
        'id': 'msg_004',
        'senderId': 'user_004',
        'senderName': 'Lisa Park',
        'message': 'Application deadline is approaching fast!',
        'timestamp': '2024-09-23T14:20:00Z',
        'type': 'TEXT',
      },
      'unreadCount': 5,
      'isMember': false,
      'notifications': false,
    },
  ];

  static final List<Map<String, dynamic>> messages = [
    // Google SDE Group Messages
    {
      'id': 'msg_001',
      'groupId': 'group_001',
      'senderId': 'user_002',
      'senderName': 'Jane Smith',
      'senderAvatar': 'https://via.placeholder.com/40',
      'message': 'Has anyone received the online assessment link yet?',
      'timestamp': '2024-09-25T08:30:00Z',
      'type': 'TEXT',
      'edited': false,
      'reactions': [
        {'emoji': '👍', 'count': 3, 'userReacted': false},
        {'emoji': '❓', 'count': 2, 'userReacted': true},
      ],
      'replies': [
        {
          'id': 'reply_001',
          'senderId': 'user_001',
          'senderName': 'John Doe',
          'message':
              'Not yet, but I heard they send it 2-3 days after application review',
          'timestamp': '2024-09-25T08:35:00Z',
        },
        {
          'id': 'reply_002',
          'senderId': 'user_003',
          'senderName': 'Mike Johnson',
          'message': 'Same here, still waiting',
          'timestamp': '2024-09-25T08:40:00Z',
        },
      ],
    },
    {
      'id': 'msg_005',
      'groupId': 'group_001',
      'senderId': 'user_mod_001',
      'senderName': 'Sarah Wilson',
      'senderAvatar': 'https://via.placeholder.com/40',
      'message':
          'Online assessments will be sent out by end of this week. Please check your email regularly.',
      'timestamp': '2024-09-25T09:00:00Z',
      'type': 'ANNOUNCEMENT',
      'edited': false,
      'reactions': [
        {'emoji': '👍', 'count': 15, 'userReacted': true},
        {'emoji': '🎉', 'count': 8, 'userReacted': false},
      ],
      'replies': [],
      'pinned': true,
    },
    // Meta Frontend Group Messages
    {
      'id': 'msg_002',
      'groupId': 'group_002',
      'senderId': 'user_003',
      'senderName': 'Mike Johnson',
      'senderAvatar': 'https://via.placeholder.com/40',
      'message': 'Interview scheduled for next week! Any tips?',
      'timestamp': '2024-09-24T16:45:00Z',
      'type': 'TEXT',
      'edited': false,
      'reactions': [
        {'emoji': '💪', 'count': 5, 'userReacted': true},
        {'emoji': '🍀', 'count': 3, 'userReacted': false},
      ],
      'replies': [
        {
          'id': 'reply_003',
          'senderId': 'user_001',
          'senderName': 'John Doe',
          'message': 'Focus on React hooks and state management. Good luck!',
          'timestamp': '2024-09-24T17:00:00Z',
        },
      ],
    },
    // Microsoft Data Science Group Messages
    {
      'id': 'msg_003',
      'groupId': 'group_003',
      'senderId': 'user_mod_003',
      'senderName': 'David Chen',
      'senderAvatar': 'https://via.placeholder.com/40',
      'message': 'Phone screening will focus on ML fundamentals and statistics',
      'timestamp': '2024-09-25T10:15:00Z',
      'type': 'ANNOUNCEMENT',
      'edited': false,
      'reactions': [
        {'emoji': '📊', 'count': 12, 'userReacted': false},
        {'emoji': '👍', 'count': 18, 'userReacted': true},
      ],
      'replies': [],
      'pinned': true,
    },
    {
      'id': 'msg_006',
      'groupId': 'group_003',
      'senderId': 'user_001',
      'senderName': 'John Doe',
      'senderAvatar': 'https://via.placeholder.com/40',
      'message':
          'Thanks for the heads up! Any specific topics we should review?',
      'timestamp': '2024-09-25T10:30:00Z',
      'type': 'TEXT',
      'edited': false,
      'reactions': [],
      'replies': [],
    },
  ];

  static List<Map<String, dynamic>> getGroupsByStudentId(String studentId) {
    // In a real app, this would filter based on student membership
    return groups.where((group) => group['isMember'] == true).toList();
  }

  static Map<String, dynamic> getGroupById(String groupId) {
    return groups.firstWhere(
      (group) => group['id'] == groupId,
      orElse: () => {},
    );
  }

  static List<Map<String, dynamic>> getMessagesByGroupId(String groupId) {
    return messages.where((msg) => msg['groupId'] == groupId).toList();
  }

  static List<Map<String, dynamic>> searchGroups(String query) {
    return groups.where((group) {
      return group['name'].toString().toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          group['companyName'].toString().toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          group['jobTitle'].toString().toLowerCase().contains(
            query.toLowerCase(),
          );
    }).toList();
  }

  static int getTotalUnreadMessages(String studentId) {
    final userGroups = getGroupsByStudentId(studentId);
    return userGroups.fold(
      0,
      (sum, group) => sum + (group['unreadCount'] as int),
    );
  }
}
