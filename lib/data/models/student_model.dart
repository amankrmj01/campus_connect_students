// lib/data/models/student_model.dart

class Student {
  final String userId;
  final String name;
  final String email;
  final String regNumber;
  final String branch;
  final String degreeType;
  final String collegeName;
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
    required this.branch,
    required this.degreeType,
    required this.collegeName,
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
      branch: json['branch'] ?? '',
      degreeType: json['degreeType'] ?? '',
      collegeName: json['collegeName'] ?? '',
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
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'regNumber': regNumber,
      'branch': branch,
      'degreeType': degreeType,
      'collegeName': collegeName,
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
  final double? tenthMarks;
  final double? twelfthMarks;
  final double? cgpa;
  final int? backlogs;
  final int? graduationYear;

  AcademicDetails({
    this.tenthMarks,
    this.twelfthMarks,
    this.cgpa,
    this.backlogs,
    this.graduationYear,
  });

  factory AcademicDetails.fromJson(Map<String, dynamic> json) {
    return AcademicDetails(
      tenthMarks: json['tenthMarks']?.toDouble(),
      twelfthMarks: json['twelfthMarks']?.toDouble(),
      cgpa: json['cgpa']?.toDouble(),
      backlogs: json['backlogs'],
      graduationYear: json['graduationYear'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      skills: List<String>.from(json['skills'] ?? []),
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
