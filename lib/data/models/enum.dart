// lib/data/models/enums.dart
// ignore_for_file: constant_identifier_names

enum ApplicationStatus {
  APPLIED,
  UNDER_REVIEW,
  SHORTLISTED,
  REJECTED,
  WITHDRAWN,
}

enum JobType { INTERNSHIP, FULL_TIME, BOTH }

enum UserType { STUDENT, COLLEGE_ADMIN, RECRUITER }

enum RoundStatus { SELECTED, ELIMINATED, PENDING }

enum QuestionType {
  TEXT,
  MULTIPLE_CHOICE,
  CHECKBOX,
  DROPDOWN,
  FILE_UPLOAD,
  DATE,
  NUMBER,
}

enum MessageType { TEXT, IMAGE, FILE }

enum NotificationType {
  APPLICATION_UPDATE,
  JOB_RECOMMENDATION,
  GROUP_MESSAGE,
  SYSTEM_ANNOUNCEMENT,
}

// Extension methods for better string representation
extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.APPLIED:
        return 'Applied';
      case ApplicationStatus.UNDER_REVIEW:
        return 'Under Review';
      case ApplicationStatus.SHORTLISTED:
        return 'Shortlisted';
      case ApplicationStatus.REJECTED:
        return 'Rejected';
      case ApplicationStatus.WITHDRAWN:
        return 'Withdrawn';
    }
  }

  String get value {
    switch (this) {
      case ApplicationStatus.APPLIED:
        return 'APPLIED';
      case ApplicationStatus.UNDER_REVIEW:
        return 'UNDER_REVIEW';
      case ApplicationStatus.SHORTLISTED:
        return 'SHORTLISTED';
      case ApplicationStatus.REJECTED:
        return 'REJECTED';
      case ApplicationStatus.WITHDRAWN:
        return 'WITHDRAWN';
    }
  }

  static ApplicationStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'APPLIED':
        return ApplicationStatus.APPLIED;
      case 'UNDER_REVIEW':
        return ApplicationStatus.UNDER_REVIEW;
      case 'SHORTLISTED':
        return ApplicationStatus.SHORTLISTED;
      case 'REJECTED':
        return ApplicationStatus.REJECTED;
      case 'WITHDRAWN':
        return ApplicationStatus.WITHDRAWN;
      default:
        return ApplicationStatus.APPLIED;
    }
  }
}

extension JobTypeExtension on JobType {
  String get value {
    switch (this) {
      case JobType.INTERNSHIP:
        return 'INTERNSHIP';
      case JobType.FULL_TIME:
        return 'FULL_TIME';
      case JobType.BOTH:
        return 'BOTH';
    }
  }

  static JobType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INTERNSHIP':
        return JobType.INTERNSHIP;
      case 'FULL_TIME':
        return JobType.FULL_TIME;
      case 'BOTH':
        return JobType.BOTH;
      default:
        return JobType.INTERNSHIP;
    }
  }
}

extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case UserType.STUDENT:
        return 'STUDENT';
      case UserType.COLLEGE_ADMIN:
        return 'COLLEGE_ADMIN';
      case UserType.RECRUITER:
        return 'RECRUITER';
    }
  }

  static UserType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'STUDENT':
        return UserType.STUDENT;
      case 'COLLEGE_ADMIN':
        return UserType.COLLEGE_ADMIN;
      case 'RECRUITER':
        return UserType.RECRUITER;
      default:
        return UserType.STUDENT;
    }
  }
}
