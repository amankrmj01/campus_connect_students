// lib/data/mock_data/user_mock_data.dart
class UserMockData {
  static final Map<String, dynamic> currentUser = {
    'id': 'user_001',
    'name': 'John Doe',
    'email': 'john.doe@student.college.edu',
    'phone': '+1234567890',
    'profileImage': 'https://via.placeholder.com/150',
    'studentId': 'ST2021001',
    'department': 'Computer Science',
    'year': 3,
    'semester': 6,
    'cgpa': 8.5,
    'batch': '2021-2025',
    'dateOfBirth': '2002-05-15',
    'address': {
      'street': '123 Main St',
      'city': 'New York',
      'state': 'NY',
      'zipCode': '10001',
      'country': 'USA',
    },
    'skills': [
      'Flutter',
      'Dart',
      'React',
      'Node.js',
      'Python',
      'Java',
      'SQL',
      'Git',
    ],
    'resume': 'https://example.com/resume.pdf',
    'linkedinUrl': 'https://linkedin.com/in/johndoe',
    'githubUrl': 'https://github.com/johndoe',
    'portfolioUrl': 'https://johndoe.dev',
    'isProfileComplete': true,
    'accountStatus': 'active',
    'registrationDate': '2024-01-15T10:30:00Z',
    'lastLoginDate': '2024-09-25T08:15:00Z',
    'preferences': {
      'jobTypes': ['FULL_TIME', 'INTERNSHIP'],
      'locations': ['New York', 'San Francisco', 'Remote'],
      'salaryRange': {'min': 60000, 'max': 120000},
      'industries': ['Technology', 'Finance', 'Healthcare'],
    },
    'achievements': [
      {
        'title': 'Dean\'s List',
        'description': 'Achieved Dean\'s List for 4 consecutive semesters',
        'date': '2023-12-01',
      },
      {
        'title': 'Hackathon Winner',
        'description': 'First place in College Hackathon 2023',
        'date': '2023-10-15',
      },
    ],
    'projects': [
      {
        'id': 'proj_001',
        'title': 'E-commerce Mobile App',
        'description':
            'Flutter-based e-commerce application with payment integration',
        'technologies': ['Flutter', 'Firebase', 'Node.js'],
        'githubUrl': 'https://github.com/johndoe/ecommerce-app',
        'liveUrl':
            'https://play.google.com/store/apps/details?id=com.johndoe.ecommerce',
        'startDate': '2023-06-01',
        'endDate': '2023-08-31',
      },
      {
        'id': 'proj_002',
        'title': 'Task Management System',
        'description': 'Web-based task management system for teams',
        'technologies': ['React', 'Node.js', 'MongoDB'],
        'githubUrl': 'https://github.com/johndoe/task-manager',
        'liveUrl': 'https://taskmanager.johndoe.dev',
        'startDate': '2023-01-15',
        'endDate': '2023-04-30',
      },
    ],
    'certifications': [
      {
        'title': 'Google Flutter Certified Developer',
        'issuer': 'Google',
        'issueDate': '2023-09-01',
        'expiryDate': '2025-09-01',
        'credentialId': 'GFC123456',
        'credentialUrl': 'https://developers.google.com/certification/flutter',
      },
      {
        'title': 'AWS Cloud Practitioner',
        'issuer': 'Amazon Web Services',
        'issueDate': '2023-07-15',
        'expiryDate': '2026-07-15',
        'credentialId': 'AWS123456',
        'credentialUrl': 'https://aws.amazon.com/certification/',
      },
    ],
  };

  static final List<Map<String, dynamic>> mockStudents = [
    currentUser,
    {
      'id': 'user_002',
      'name': 'Jane Smith',
      'email': 'jane.smith@student.college.edu',
      'phone': '+1234567891',
      'profileImage': 'https://via.placeholder.com/150',
      'studentId': 'ST2021002',
      'department': 'Information Technology',
      'year': 4,
      'semester': 8,
      'cgpa': 9.2,
      'batch': '2021-2025',
      'dateOfBirth': '2001-12-20',
      'skills': ['Python', 'Machine Learning', 'Django', 'TensorFlow'],
      'isProfileComplete': true,
      'accountStatus': 'active',
    },
    {
      'id': 'user_003',
      'name': 'Mike Johnson',
      'email': 'mike.johnson@student.college.edu',
      'phone': '+1234567892',
      'profileImage': 'https://via.placeholder.com/150',
      'studentId': 'ST2021003',
      'department': 'Electronics',
      'year': 2,
      'semester': 4,
      'cgpa': 7.8,
      'batch': '2022-2026',
      'dateOfBirth': '2003-03-10',
      'skills': ['C++', 'Embedded Systems', 'Arduino', 'IoT'],
      'isProfileComplete': false,
      'accountStatus': 'active',
    },
  ];

  // Auth mock data
  static final Map<String, dynamic> loginCredentials = {
    'email': 'john.doe@student.college.edu',
    'password': 'password123',
  };

  static final Map<String, dynamic> authTokens = {
    'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    'refresh_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    'token_type': 'Bearer',
    'expires_in': 3600,
  };
}
