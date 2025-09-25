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
    },
    {
      'id': 'job_003',
      'title': 'Data Scientist',
      'companyName': 'Microsoft',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Microsoft',
      'location': 'Seattle, WA',
      'type': 'FULL_TIME',
      'mode': 'REMOTE',
      'description':
          'Join Microsoft\'s Data Science team to work on machine learning models and data analytics solutions that power Microsoft\'s cloud services and products.',
      'requirements': {
        'minCgpa': 8.5,
        'graduationYear': [2024, 2025],
        'departments': ['Computer Science', 'Mathematics', 'Statistics'],
        'skills': ['Python', 'Machine Learning', 'SQL', 'R', 'Statistics'],
        'experience': 'Fresh Graduate',
      },
      'salary': {
        'min': 110000,
        'max': 160000,
        'currency': 'USD',
        'period': 'YEARLY',
      },
      'benefits': [
        'Health Insurance',
        'Stock Purchase Plan',
        'Flexible Work Hours',
        'Professional Development',
      ],
      'applicationDeadline': '2024-11-01T23:59:59Z',
      'jobPostedDate': '2024-09-15T09:00:00Z',
      'applicationCount': 567,
      'maxApplications': 1500,
      'status': 'ACTIVE',
      'recruiter': {
        'name': 'David Chen',
        'email': 'david.chen@microsoft.com',
        'phone': '+1-555-0789',
      },
      'interviewProcess': [
        'Application Review',
        'Phone Screening',
        'Technical Assessment',
        'On-site Interview',
        'Final Decision',
      ],
      'tags': ['Data Science', 'Machine Learning', 'Remote'],
    },
    {
      'id': 'job_004',
      'title': 'Mobile App Developer',
      'companyName': 'Uber',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Uber',
      'location': 'San Francisco, CA',
      'type': 'FULL_TIME',
      'mode': 'HYBRID',
      'description':
          'Build and maintain Uber\'s mobile applications used by millions of riders and drivers worldwide. Work with cutting-edge mobile technologies and contribute to the future of transportation.',
      'requirements': {
        'minCgpa': 7.0,
        'graduationYear': [2024, 2025],
        'departments': ['Computer Science', 'Information Technology'],
        'skills': ['Flutter', 'React Native', 'iOS', 'Android', 'Dart'],
        'experience': 'Fresh Graduate',
      },
      'salary': {
        'min': 100000,
        'max': 150000,
        'currency': 'USD',
        'period': 'YEARLY',
      },
      'benefits': [
        'Health Insurance',
        'Uber Credits',
        'Stock Options',
        'Gym Membership',
      ],
      'applicationDeadline': '2024-10-20T23:59:59Z',
      'jobPostedDate': '2024-09-05T11:15:00Z',
      'applicationCount': 734,
      'maxApplications': 3000,
      'status': 'ACTIVE',
      'recruiter': {
        'name': 'Emma Rodriguez',
        'email': 'emma.rodriguez@uber.com',
        'phone': '+1-555-0321',
      },
      'interviewProcess': [
        'Resume Review',
        'Phone Interview',
        'Technical Coding',
        'System Design',
        'Cultural Fit',
      ],
      'tags': ['Mobile Development', 'Transportation', 'Startup Culture'],
    },
    {
      'id': 'job_005',
      'title': 'DevOps Engineer',
      'companyName': 'Amazon',
      'companyLogo': 'https://via.placeholder.com/100x100?text=Amazon',
      'location': 'Austin, TX',
      'type': 'FULL_TIME',
      'mode': 'ON_SITE',
      'description':
          'Join Amazon Web Services team as a DevOps Engineer and help build and maintain the infrastructure that powers the world\'s leading cloud platform.',
      'requirements': {
        'minCgpa': 7.5,
        'graduationYear': [2024, 2025],
        'departments': [
          'Computer Science',
          'Information Technology',
          'Electronics',
        ],
        'skills': ['AWS', 'Docker', 'Kubernetes', 'Linux', 'Python'],
        'experience': 'Fresh Graduate',
      },
      'salary': {
        'min': 115000,
        'max': 170000,
        'currency': 'USD',
        'period': 'YEARLY',
      },
      'benefits': [
        'Health Insurance',
        'Stock Purchase Plan',
        'Career Development',
        'Employee Discounts',
      ],
      'applicationDeadline': '2024-11-15T23:59:59Z',
      'jobPostedDate': '2024-09-20T16:45:00Z',
      'applicationCount': 423,
      'maxApplications': 2500,
      'status': 'ACTIVE',
      'recruiter': {
        'name': 'Michael Brown',
        'email': 'michael.brown@amazon.com',
        'phone': '+1-555-0654',
      },
      'interviewProcess': [
        'Application Screening',
        'Technical Phone Screen',
        'On-site Technical Interview',
        'Behavioral Interview',
        'Final Review',
      ],
      'tags': ['Cloud', 'DevOps', 'Infrastructure'],
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
}
