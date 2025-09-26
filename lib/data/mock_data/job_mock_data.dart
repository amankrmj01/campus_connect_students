// lib/data/mock_data/job_mock_data.dart
class JobMockData {
  static final List<Map<String, dynamic>> jobs = [
    {
      'id': 'job_001',
      'title': 'Software Development Engineer',
      'companyName': 'Google',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Google',
      'location': 'Mountain View, CA',
      'type': 'FULL_TIME',
      'mode': 'HYBRID',
      'description':
          'Join Google as a Software Development Engineer and work on cutting-edge technologies that impact billions of users worldwide. You will be responsible for designing, developing, and maintaining large-scale distributed systems.',
      'requirements': {
        'minCgpa': 7.5,
        'graduationYear': [2024, 2025],
        'departments': [
          'Computer Science',
          'Information Technology',
          'Electronics',
        ],
        'skills': ['Java', 'Python', 'System Design', 'Data Structures'],
        'experience': 'Fresh Graduate',
      },
      'salary': {
        'min': 120000,
        'max': 180000,
        'currency': 'USD',
        'period': 'YEARLY',
      },
      'benefits': [
        'Health Insurance',
        'Stock Options',
        'Free Meals',
        'Gym Membership',
        'Learning Budget',
      ],
      'applicationDeadline': '2024-10-15T23:59:59Z',
      'jobPostedDate': '2024-09-01T10:00:00Z',
      'applicationCount': 1245,
      'maxApplications': 5000,
      'status': 'ACTIVE',
      'recruiter': {
        'name': 'Sarah Wilson',
        'email': 'sarah.wilson@google.com',
        'phone': '+1-555-0123',
      },
      'interviewProcess': [
        'Online Assessment',
        'Technical Interview Round 1',
        'Technical Interview Round 2',
        'Behavioral Interview',
        'Final HR Round',
      ],
      'tags': ['Tech Giant', 'High Package', 'Stock Options'],
      'applicationQuestions': [
        {
          'id': 'q1',
          'type': 'text',
          'question': 'Why do you want to work at Google?',
          'required': true,
          'maxLength': 500,
        },
        {
          'id': 'q2',
          'type': 'multiple_choice',
          'question': 'What is your preferred programming language?',
          'required': true,
          'options': ['Java', 'Python', 'C++', 'JavaScript', 'Go'],
        },
        {
          'id': 'q3',
          'type': 'file_upload',
          'question': 'Upload your portfolio or GitHub profile link',
          'required': false,
          'allowedFileTypes': ['pdf', 'txt'],
        },
      ],
    },
    {
      'id': 'job_002',
      'title': 'Frontend Developer Intern',
      'companyName': 'Meta',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Meta',
      'location': 'Menlo Park, CA',
      'type': 'INTERNSHIP',
      'mode': 'ON_SITE',
      'description':
          'Join Meta\'s frontend team as an intern and contribute to building the next generation of social technology. Work with React, GraphQL, and other modern web technologies.',
      'requirements': {
        'minCgpa': 8.0,
        'graduationYear': [2025, 2026],
        'departments': ['Computer Science', 'Information Technology'],
        'skills': ['React', 'JavaScript', 'CSS', 'HTML'],
        'experience': 'Student',
      },
      'salary': {
        'min': 8000,
        'max': 10000,
        'currency': 'USD',
        'period': 'MONTHLY',
      },
      'benefits': [
        'Mentorship Program',
        'Free Meals',
        'Transportation',
        'Housing Assistance',
      ],
      'applicationDeadline': '2024-10-30T23:59:59Z',
      'jobPostedDate': '2024-09-10T14:30:00Z',
      'applicationCount': 892,
      'maxApplications': 2000,
      'status': 'ACTIVE',
      'recruiter': {
        'name': 'Alex Thompson',
        'email': 'alex.thompson@meta.com',
        'phone': '+1-555-0456',
      },
      'interviewProcess': [
        'Resume Screening',
        'Coding Challenge',
        'Technical Interview',
        'Final Interview',
      ],
      'tags': ['Internship', 'Frontend', 'Social Media'],
      'applicationQuestions': [], // No additional questions required
    },
    // New jobs with no questions for easy application
    {
      'id': 'job_003',
      'title': 'Junior Software Developer',
      'companyName': 'Microsoft',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Microsoft',
      'location': 'Redmond, WA',
      'type': 'FULL_TIME',
      'mode': 'HYBRID',
      'description':
          'Join Microsoft as a Junior Software Developer. Work on Azure services, Office 365, and other Microsoft products. Perfect opportunity for fresh graduates to start their career.',
      'requirements': {
        'minCgpa': 7.0,
        'graduationYear': [2024, 2025],
        'departments': [
          'Computer Science',
          'Information Technology',
          'Software Engineering',
        ],
        'skills': ['C#', 'JavaScript', 'Azure', 'SQL'],
        'experience': 'Fresh Graduate',
      },
      'salary': {
        'min': 95000,
        'max': 125000,
        'currency': 'USD',
        'period': 'YEARLY',
      },
      'benefits': [
        'Health Insurance',
        'Stock Options',
        'Flexible Working Hours',
        'Learning Resources',
      ],
      'applicationDeadline': '2025-11-15T23:59:59Z',
      'jobPostedDate': '2024-09-20T09:00:00Z',
      'applicationCount': 456,
      'maxApplications': 3000,
      'status': 'ACTIVE',
      'recruiter': {
        'name': 'Jennifer Clark',
        'email': 'jennifer.clark@microsoft.com',
        'phone': '+1-555-0789',
      },
      'interviewProcess': [
        'Resume Review',
        'Technical Assessment',
        'Final Interview',
      ],
      'tags': ['Microsoft', 'Cloud', 'Fresh Graduate'],
      'applicationQuestions': [], // No additional questions - direct apply
    },
    {
      'id': 'job_004',
      'title': 'Mobile App Developer Intern',
      'companyName': 'Apple',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Apple',
      'location': 'Cupertino, CA',
      'type': 'INTERNSHIP',
      'mode': 'ON_SITE',
      'description':
          'Intern with Apple\'s iOS development team. Work on native iOS applications using Swift and contribute to apps used by millions worldwide.',
      'requirements': {
        'minCgpa': 7.5,
        'graduationYear': [2025, 2026],
        'departments': ['Computer Science', 'Information Technology'],
        'skills': ['Swift', 'iOS', 'Xcode', 'UIKit'],
        'experience': 'Student',
      },
      'salary': {
        'min': 7500,
        'max': 9500,
        'currency': 'USD',
        'period': 'MONTHLY',
      },
      'benefits': [
        'Apple Products Discount',
        'Mentorship',
        'Free Lunch',
        'Fitness Center Access',
      ],
      'applicationDeadline': '2025-12-01T23:59:59Z',
      'jobPostedDate': '2024-09-25T11:00:00Z',
      'applicationCount': 234,
      'maxApplications': 1500,
      'status': 'ACTIVE',
      'recruiter': {
        'name': 'David Kim',
        'email': 'david.kim@apple.com',
        'phone': '+1-555-0234',
      },
      'interviewProcess': [
        'Portfolio Review',
        'Technical Interview',
        'Culture Fit Interview',
      ],
      'tags': ['Apple', 'iOS', 'Mobile Development'],
      'applicationQuestions': [], // No additional questions - direct apply
    },
    {
      'id': 'job_005',
      'title': 'Data Analyst',
      'companyName': 'Netflix',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Netflix',
      'location': 'Los Gatos, CA',
      'type': 'FULL_TIME',
      'mode': 'REMOTE',
      'description':
          'Join Netflix as a Data Analyst and help analyze viewer data to improve content recommendations and user experience across the platform.',
      'requirements': {
        'minCgpa': 7.5,
        'graduationYear': [2024, 2025],
        'departments': [
          'Computer Science',
          'Statistics',
          'Mathematics',
          'Data Science',
        ],
        'skills': ['Python', 'SQL', 'Tableau', 'Statistics'],
        'experience': 'Fresh Graduate',
      },
      'salary': {
        'min': 85000,
        'max': 110000,
        'currency': 'USD',
        'period': 'YEARLY',
      },
      'benefits': [
        'Netflix Subscription',
        'Health Insurance',
        'Remote Work',
        'Flexible Hours',
      ],
      'applicationDeadline': '2025-10-20T23:59:59Z',
      'jobPostedDate': '2024-09-22T14:00:00Z',
      'applicationCount': 678,
      'maxApplications': 2500,
      'status': 'ACTIVE',
      'recruiter': {
        'name': 'Maria Rodriguez',
        'email': 'maria.rodriguez@netflix.com',
        'phone': '+1-555-0567',
      },
      'interviewProcess': [
        'Data Challenge',
        'Technical Interview',
        'Business Case Interview',
      ],
      'tags': ['Netflix', 'Data Analysis', 'Remote'],
      'applicationQuestions': [], // No additional questions - direct apply
    },
    {
      'id': 'job_006',
      'title': 'Backend Engineer',
      'companyName': 'Spotify',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Spotify',
      'location': 'New York, NY',
      'type': 'FULL_TIME',
      'mode': 'HYBRID',
      'description':
          'Build scalable backend systems at Spotify that serve millions of music lovers worldwide. Work with microservices, APIs, and real-time data processing.',
      'requirements': {
        'minCgpa': 7.2,
        'graduationYear': [2024, 2025],
        'departments': [
          'Computer Science',
          'Information Technology',
          'Software Engineering',
        ],
        'skills': ['Java', 'Python', 'Microservices', 'Docker', 'Kubernetes'],
        'experience': 'Fresh Graduate',
      },
      'salary': {
        'min': 100000,
        'max': 135000,
        'currency': 'USD',
        'period': 'YEARLY',
      },
      'benefits': [
        'Spotify Premium',
        'Health Insurance',
        'Stock Options',
        'Music Equipment Budget',
      ],
      'applicationDeadline': '2025-11-30T23:59:59Z',
      'jobPostedDate': '2024-09-18T16:30:00Z',
      'applicationCount': 567,
      'maxApplications': 4000,
      'status': 'ACTIVE',
      'recruiter': {
        'name': 'Erik Andersson',
        'email': 'erik.andersson@spotify.com',
        'phone': '+1-555-0890',
      },
      'interviewProcess': [
        'Phone Screen',
        'Technical Challenge',
        'System Design Interview',
        'Final Interview',
      ],
      'tags': ['Spotify', 'Backend', 'Music Tech'],
      'applicationQuestions': [
        {
          'id': 'q1',
          'type': 'text',
          'question': 'Describe your experience with distributed systems',
          'required': true,
          'maxLength': 300,
        },
      ],
    },
  ];

  static final Map<String, List<String>> jobFilters = {
    'types': ['FULL_TIME', 'PART_TIME', 'INTERNSHIP', 'CONTRACT'],
    'modes': ['ON_SITE', 'REMOTE', 'HYBRID'],
    'locations': [
      'Mountain View, CA',
      'Menlo Park, CA',
      'Seattle, WA',
      'San Francisco, CA',
      'Austin, TX',
      'New York, NY',
      'Boston, MA',
      'Remote',
    ],
    'companies': [
      'Google',
      'Meta',
      'Microsoft',
      'Uber',
      'Amazon',
      'Apple',
      'Netflix',
    ],
    'departments': [
      'Computer Science',
      'Information Technology',
      'Electronics',
      'Mathematics',
      'Statistics',
    ],
    'salaryRanges': ['0-50k', '50k-100k', '100k-150k', '150k+'],
  };

  static Map<String, dynamic> getJobById(String jobId) {
    return jobs.firstWhere((job) => job['id'] == jobId, orElse: () => {});
  }

  static List<Map<String, dynamic>> getJobsByCompany(String companyName) {
    return jobs.where((job) => job['companyName'] == companyName).toList();
  }

  static List<Map<String, dynamic>> getJobsByType(String type) {
    return jobs.where((job) => job['type'] == type).toList();
  }

  static List<Map<String, dynamic>> searchJobs(String query) {
    return jobs.where((job) {
      return job['title'].toString().toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          job['companyName'].toString().toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          job['description'].toString().toLowerCase().contains(
            query.toLowerCase(),
          );
    }).toList();
  }

  // Add the missing getAllJobs method
  static List<Map<String, dynamic>> getAllJobs() {
    return jobs;
  }
}
