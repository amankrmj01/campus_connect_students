// lib/data/models/student_model.dart

class Student {
  final String userId;
  final String name;
  final String email;
  final String regNumber;
  final String? studentId;
  final String branch;
  final String degreeType;
  final String collegeName;
  final double cgpa;
  final int graduationYear;
  final int currentBacklogs;
  final String? profilePicture;
  final AcademicDetails? academicDetails;
  final List<WorkExperience> workExperience;
  final List<Certification> certifications;
  final Address? address;
  final String? resumeUrl;
  final bool isActive;
  final bool isBlacklisted;
  final bool profileCompleted;
  final DateTime createdAt;

  Student({
    required this.userId,
    required this.name,
    required this.email,
    required this.regNumber,
    this.studentId,
    required this.branch,
    required this.degreeType,
    required this.collegeName,
    required this.cgpa,
    required this.graduationYear,
    required this.currentBacklogs,
    this.profilePicture,
    this.academicDetails,
    required this.workExperience,
    required this.certifications,
    this.address,
    this.resumeUrl,
    required this.isActive,
    required this.isBlacklisted,
    required this.profileCompleted,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      regNumber: json['regNumber'] ?? '',
      studentId: json['studentId'],
      branch: json['branch'] ?? '',
      degreeType: json['degreeType'] ?? '',
      collegeName: json['collegeName'] ?? '',
      cgpa: (json['cgpa'] ?? 0.0).toDouble(),
      graduationYear: json['graduationYear'] ?? DateTime.now().year,
      currentBacklogs: json['currentBacklogs'] ?? 0,
      profilePicture: json['profilePicture'],
      academicDetails: json['academicDetails'] != null
          ? AcademicDetails.fromJson(json['academicDetails'])
          : null,
      workExperience:
          (json['workExperience'] as List<dynamic>?)
              ?.map((item) => WorkExperience.fromJson(item))
              .toList() ??
          [],
      certifications:
          (json['certifications'] as List<dynamic>?)
              ?.map((item) => Certification.fromJson(item))
              .toList() ??
          [],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      resumeUrl: json['resumeUrl'],
      isActive: json['isActive'] ?? true,
      isBlacklisted: json['isBlacklisted'] ?? false,
      profileCompleted: json['profileCompleted'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'regNumber': regNumber,
      'studentId': studentId,
      'branch': branch,
      'degreeType': degreeType,
      'collegeName': collegeName,
      'cgpa': cgpa,
      'graduationYear': graduationYear,
      'currentBacklogs': currentBacklogs,
      'profilePicture': profilePicture,
      'academicDetails': academicDetails?.toJson(),
      'workExperience': workExperience.map((item) => item.toJson()).toList(),
      'certifications': certifications.map((item) => item.toJson()).toList(),
      'address': address?.toJson(),
      'resumeUrl': resumeUrl,
      'isActive': isActive,
      'isBlacklisted': isBlacklisted,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AcademicDetails {
  final String? degree;
  final String? branch;
  final String? college;
  final String? university;
  final String? department;
  final int? year;
  final int? semester;
  final String? batch;
  final double? tenthMarks;
  final double? twelfthMarks;
  final double? cgpa;
  final int? backlogs;
  final int? graduationYear;

  AcademicDetails({
    this.degree,
    this.branch,
    this.college,
    this.university,
    this.department,
    this.year,
    this.semester,
    this.batch,
    this.tenthMarks,
    this.twelfthMarks,
    this.cgpa,
    this.backlogs,
    this.graduationYear,
  });

  factory AcademicDetails.fromJson(Map<String, dynamic> json) {
    return AcademicDetails(
      degree: json['degree'],
      branch: json['branch'],
      college: json['college'],
      university: json['university'],
      department: json['department'],
      year: json['year'],
      semester: json['semester'],
      batch: json['batch'],
      tenthMarks: json['tenthMarks']?.toDouble(),
      twelfthMarks: json['twelfthMarks']?.toDouble(),
      cgpa: json['cgpa']?.toDouble(),
      backlogs: json['backlogs'],
      graduationYear: json['graduationYear'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'branch': branch,
      'college': college,
      'university': university,
      'department': department,
      'year': year,
      'semester': semester,
      'batch': batch,
      'tenthMarks': tenthMarks,
      'twelfthMarks': twelfthMarks,
      'cgpa': cgpa,
      'backlogs': backlogs,
      'graduationYear': graduationYear,
    };
  }
}

class WorkExperience {
  final String company;
  final String role;
  final String duration;
  final String description;
  final List<String> skills;

  WorkExperience({
    required this.company,
    required this.role,
    required this.duration,
    required this.description,
    required this.skills,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      company: json['company'] ?? '',
      role: json['role'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
      skills:
          (json['skills'] as List?)?.map((item) => item.toString()).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'role': role,
      'duration': duration,
      'description': description,
      'skills': skills,
    };
  }
}

class Certification {
  final String name;
  final String issuingOrganization;
  final DateTime issueDate;
  final String? credentialUrl;

  Certification({
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.credentialUrl,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      name: json['name'] ?? '',
      issuingOrganization: json['issuingOrganization'] ?? '',
      issueDate: DateTime.parse(
        json['issueDate'] ?? DateTime.now().toIso8601String(),
      ),
      credentialUrl: json['credentialUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'issuingOrganization': issuingOrganization,
      'issueDate': issueDate.toIso8601String(),
      'credentialUrl': credentialUrl,
    };
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }
}
