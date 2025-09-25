// lib/data/mock_data/application_mock_data.dart
class ApplicationMockData {
  static final List<Map<String, dynamic>> applications = [
    {
      'id': 'app_001',
      'studentId': 'user_001',
      'jobId': 'job_001',
      'jobTitle': 'Software Development Engineer',
      'companyName': 'Google',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Google',
      'appliedDate': '2024-09-20T10:30:00Z',
      'status': 'UNDER_REVIEW',
      'statusHistory': [
        {
          'status': 'APPLIED',
          'date': '2024-09-20T10:30:00Z',
          'note': 'Application submitted successfully',
        },
        {
          'status': 'UNDER_REVIEW',
          'date': '2024-09-22T14:15:00Z',
          'note': 'Application is being reviewed by HR team',
        },
      ],
      'documents': [
        {
          'type': 'RESUME',
          'fileName': 'John_Doe_Resume.pdf',
          'uploadDate': '2024-09-20T10:25:00Z',
          'fileUrl': 'https://example.com/documents/resume.pdf',
        },
        {
          'type': 'COVER_LETTER',
          'fileName': 'Cover_Letter_Google.pdf',
          'uploadDate': '2024-09-20T10:28:00Z',
          'fileUrl': 'https://example.com/documents/cover_letter.pdf',
        },
      ],
      'interviews': [],
      'feedback': null,
      'nextSteps': 'Wait for initial screening results',
      'expectedResponseDate': '2024-10-05T23:59:59Z',
      'priority': 'HIGH',
      'notes': 'Dream company - put extra effort in preparation',
    },
    {
      'id': 'app_002',
      'studentId': 'user_001',
      'jobId': 'job_002',
      'jobTitle': 'Frontend Developer Intern',
      'companyName': 'Meta',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Meta',
      'appliedDate': '2024-09-18T16:45:00Z',
      'status': 'SHORTLISTED',
      'statusHistory': [
        {
          'status': 'APPLIED',
          'date': '2024-09-18T16:45:00Z',
          'note': 'Application submitted',
        },
        {
          'status': 'UNDER_REVIEW',
          'date': '2024-09-19T09:00:00Z',
          'note': 'Resume screening in progress',
        },
        {
          'status': 'SHORTLISTED',
          'date': '2024-09-23T11:30:00Z',
          'note':
              'Congratulations! You have been shortlisted for the next round',
        },
      ],
      'documents': [
        {
          'type': 'RESUME',
          'fileName': 'John_Doe_Resume.pdf',
          'uploadDate': '2024-09-18T16:40:00Z',
          'fileUrl': 'https://example.com/documents/resume.pdf',
        },
        {
          'type': 'PORTFOLIO',
          'fileName': 'Portfolio_Link.txt',
          'uploadDate': '2024-09-18T16:42:00Z',
          'fileUrl': 'https://johndoe.dev',
        },
      ],
      'interviews': [
        {
          'id': 'int_001',
          'type': 'TECHNICAL',
          'scheduledDate': '2024-09-28T14:00:00Z',
          'duration': 60,
          'mode': 'VIDEO_CALL',
          'interviewer': {
            'name': 'Sarah Johnson',
            'title': 'Senior Frontend Developer',
            'email': 'sarah.johnson@meta.com',
          },
          'meetingLink': 'https://meet.google.com/abc-defg-hij',
          'status': 'SCHEDULED',
          'instructions':
              'Prepare for coding questions on React and JavaScript',
        },
      ],
      'feedback': null,
      'nextSteps': 'Prepare for technical interview on Sep 28',
      'expectedResponseDate': '2024-10-02T23:59:59Z',
      'priority': 'HIGH',
      'notes': 'Great internship opportunity - focus on React preparation',
    },
    {
      'id': 'app_003',
      'studentId': 'user_001',
      'jobId': 'job_004',
      'jobTitle': 'Mobile App Developer',
      'companyName': 'Uber',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Uber',
      'appliedDate': '2024-09-15T12:20:00Z',
      'status': 'REJECTED',
      'statusHistory': [
        {
          'status': 'APPLIED',
          'date': '2024-09-15T12:20:00Z',
          'note': 'Application submitted',
        },
        {
          'status': 'UNDER_REVIEW',
          'date': '2024-09-16T10:00:00Z',
          'note': 'Application under review',
        },
        {
          'status': 'REJECTED',
          'date': '2024-09-24T15:30:00Z',
          'note':
              'Thank you for your interest. We have decided to move forward with other candidates.',
        },
      ],
      'documents': [
        {
          'type': 'RESUME',
          'fileName': 'John_Doe_Resume.pdf',
          'uploadDate': '2024-09-15T12:15:00Z',
          'fileUrl': 'https://example.com/documents/resume.pdf',
        },
      ],
      'interviews': [],
      'feedback': {
        'overall':
            'Good technical skills but looking for more mobile development experience',
        'strengths': [
          'Strong Flutter knowledge',
          'Good problem-solving skills',
        ],
        'improvements': [
          'Gain more real-world mobile app experience',
          'Learn native development',
        ],
        'rating': 3.5,
      },
      'nextSteps': null,
      'expectedResponseDate': null,
      'priority': 'MEDIUM',
      'notes': 'Need to gain more mobile development experience',
    },
    {
      'id': 'app_004',
      'studentId': 'user_001',
      'jobId': 'job_003',
      'jobTitle': 'Data Scientist',
      'companyName': 'Microsoft',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Microsoft',
      'appliedDate': '2024-09-22T09:15:00Z',
      'status': 'INTERVIEW_SCHEDULED',
      'statusHistory': [
        {
          'status': 'APPLIED',
          'date': '2024-09-22T09:15:00Z',
          'note': 'Application submitted',
        },
        {
          'status': 'UNDER_REVIEW',
          'date': '2024-09-23T08:00:00Z',
          'note': 'Initial screening in progress',
        },
        {
          'status': 'INTERVIEW_SCHEDULED',
          'date': '2024-09-25T10:00:00Z',
          'note': 'Phone screening scheduled',
        },
      ],
      'documents': [
        {
          'type': 'RESUME',
          'fileName': 'John_Doe_Resume.pdf',
          'uploadDate': '2024-09-22T09:10:00Z',
          'fileUrl': 'https://example.com/documents/resume.pdf',
        },
        {
          'type': 'TRANSCRIPT',
          'fileName': 'Academic_Transcript.pdf',
          'uploadDate': '2024-09-22T09:12:00Z',
          'fileUrl': 'https://example.com/documents/transcript.pdf',
        },
      ],
      'interviews': [
        {
          'id': 'int_002',
          'type': 'PHONE_SCREENING',
          'scheduledDate': '2024-09-30T15:30:00Z',
          'duration': 45,
          'mode': 'PHONE_CALL',
          'interviewer': {
            'name': 'Dr. Emily Watson',
            'title': 'Senior Data Scientist',
            'phone': '+1-555-0987',
          },
          'status': 'SCHEDULED',
          'instructions':
              'Review statistics, machine learning concepts, and be ready to discuss projects',
        },
      ],
      'feedback': null,
      'nextSteps': 'Prepare for phone screening on Sep 30',
      'expectedResponseDate': '2024-10-07T23:59:59Z',
      'priority': 'HIGH',
      'notes':
          'Great match for my skills - prepare thoroughly for ML questions',
    },
    {
      'id': 'app_005',
      'studentId': 'user_001',
      'jobId': 'job_005',
      'jobTitle': 'DevOps Engineer',
      'companyName': 'Amazon',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Amazon',
      'appliedDate': '2024-09-21T14:30:00Z',
      'status': 'APPLIED',
      'statusHistory': [
        {
          'status': 'APPLIED',
          'date': '2024-09-21T14:30:00Z',
          'note': 'Application submitted successfully',
        },
      ],
      'documents': [
        {
          'type': 'RESUME',
          'fileName': 'John_Doe_Resume.pdf',
          'uploadDate': '2024-09-21T14:25:00Z',
          'fileUrl': 'https://example.com/documents/resume.pdf',
        },
        {
          'type': 'COVER_LETTER',
          'fileName': 'Cover_Letter_Amazon.pdf',
          'uploadDate': '2024-09-21T14:28:00Z',
          'fileUrl': 'https://example.com/documents/cover_letter_amazon.pdf',
        },
      ],
      'interviews': [],
      'feedback': null,
      'nextSteps': 'Wait for initial response from recruiter',
      'expectedResponseDate': '2024-10-10T23:59:59Z',
      'priority': 'MEDIUM',
      'notes': 'Good opportunity to learn cloud technologies',
    },
  ];

  static final Map<String, String> statusMessages = {
    'APPLIED': 'Your application has been submitted successfully',
    'UNDER_REVIEW': 'Your application is being reviewed',
    'SHORTLISTED': 'Congratulations! You have been shortlisted',
    'INTERVIEW_SCHEDULED': 'Interview has been scheduled',
    'SELECTED': 'Congratulations! You have been selected',
    'REJECTED': 'Unfortunately, your application was not successful',
    'WITHDRAWN': 'Application withdrawn by candidate',
    'ON_HOLD': 'Application is currently on hold',
  };

  static final Map<String, String> statusColors = {
    'APPLIED': 'blue',
    'UNDER_REVIEW': 'orange',
    'SHORTLISTED': 'green',
    'INTERVIEW_SCHEDULED': 'purple',
    'SELECTED': 'green',
    'REJECTED': 'red',
    'WITHDRAWN': 'grey',
    'ON_HOLD': 'yellow',
  };

  static List<Map<String, dynamic>> getApplicationsByStudentId(
    String studentId,
  ) {
    return applications.where((app) => app['studentId'] == studentId).toList();
  }

  static Map<String, dynamic> getApplicationById(String applicationId) {
    return applications.firstWhere(
      (app) => app['id'] == applicationId,
      orElse: () => {},
    );
  }

  static List<Map<String, dynamic>> getApplicationsByStatus(String status) {
    return applications.where((app) => app['status'] == status).toList();
  }

  static Map<String, int> getApplicationStats(String studentId) {
    final userApps = getApplicationsByStudentId(studentId);
    final stats = <String, int>{};

    for (final status in statusMessages.keys) {
      stats[status] = userApps.where((app) => app['status'] == status).length;
    }

    stats['TOTAL'] = userApps.length;
    return stats;
  }

  static List<Map<String, dynamic>> getUpcomingInterviews(String studentId) {
    final userApps = getApplicationsByStudentId(studentId);
    final upcomingInterviews = <Map<String, dynamic>>[];

    for (final app in userApps) {
      final interviews = app['interviews'] as List<dynamic>;
      for (final interview in interviews) {
        final scheduledDate = DateTime.parse(interview['scheduledDate']);
        if (scheduledDate.isAfter(DateTime.now())) {
          upcomingInterviews.add({
            ...interview,
            'applicationId': app['id'],
            'jobTitle': app['jobTitle'],
            'companyName': app['companyName'],
            'companyLogo': app['companyLogo'],
          });
        }
      }
    }

    upcomingInterviews.sort(
      (a, b) => DateTime.parse(
        a['scheduledDate'],
      ).compareTo(DateTime.parse(b['scheduledDate'])),
    );

    return upcomingInterviews;
  }
}
