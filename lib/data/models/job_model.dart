// lib/data/models/job_model.dart
import 'enum.dart';

class Job {
  final String jobId;
  final String recruiterId;
  final String companyName;
  final String title;
  final String description;
  final Requirements requirements;
  final JobType type;
  final SalaryRange? salary;
  final String location;
  final DateTime applicationDeadline;
  final DateTime postedAt;
  final ApplicationForm customForm;
  final GroupInfo groupInfo;
  final bool isActive;
  final List<String> appliedCandidates;

  Job({
    required this.jobId,
    required this.recruiterId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.requirements,
    required this.type,
    this.salary,
    required this.location,
    required this.applicationDeadline,
    required this.postedAt,
    required this.customForm,
    required this.groupInfo,
    required this.isActive,
    required this.appliedCandidates,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobId: json['jobId'] ?? '',
      recruiterId: json['recruiterId'] ?? '',
      companyName: json['companyName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requirements: Requirements.fromJson(json['requirements'] ?? {}),
      type: JobTypeExtension.fromString(json['type'] ?? 'INTERNSHIP'),
      salary: json['salary'] != null
          ? SalaryRange.fromJson(json['salary'])
          : null,
      location: json['location'] ?? '',
      applicationDeadline: DateTime.parse(
        json['applicationDeadline'] ?? DateTime.now().toIso8601String(),
      ),
      postedAt: DateTime.parse(
        json['postedAt'] ?? DateTime.now().toIso8601String(),
      ),
      customForm: ApplicationForm.fromJson(json['customForm'] ?? {}),
      groupInfo: GroupInfo.fromJson(json['groupInfo'] ?? {}),
      isActive: json['isActive'] ?? true,
      appliedCandidates: List<String>.from(json['appliedCandidates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'recruiterId': recruiterId,
      'companyName': companyName,
      'title': title,
      'description': description,
      'requirements': requirements.toJson(),
      'type': type.value,
      'salary': salary?.toJson(),
      'location': location,
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'postedAt': postedAt.toIso8601String(),
      'customForm': customForm.toJson(),
      'groupInfo': groupInfo.toJson(),
      'isActive': isActive,
      'appliedCandidates': appliedCandidates,
    };
  }
}

class Requirements {
  final double minCgpa;
  final List<String> allowedBranches;
  final List<String> allowedDegreeTypes;
  final int graduationYear;
  final List<String> requiredSkills;
  final int maxBacklogs;

  Requirements({
    required this.minCgpa,
    required this.allowedBranches,
    required this.allowedDegreeTypes,
    required this.graduationYear,
    required this.requiredSkills,
    required this.maxBacklogs,
  });

  factory Requirements.fromJson(Map<String, dynamic> json) {
    return Requirements(
      minCgpa: (json['minCgpa'] ?? 0.0).toDouble(),
      allowedBranches: List<String>.from(json['allowedBranches'] ?? []),
      allowedDegreeTypes: List<String>.from(json['allowedDegreeTypes'] ?? []),
      graduationYear: json['graduationYear'] ?? DateTime.now().year,
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      maxBacklogs: json['maxBacklogs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minCgpa': minCgpa,
      'allowedBranches': allowedBranches,
      'allowedDegreeTypes': allowedDegreeTypes,
      'graduationYear': graduationYear,
      'requiredSkills': requiredSkills,
      'maxBacklogs': maxBacklogs,
    };
  }
}

class SalaryRange {
  final double min;
  final double max;
  final String currency;

  SalaryRange({required this.min, required this.max, required this.currency});

  factory SalaryRange.fromJson(Map<String, dynamic> json) {
    return SalaryRange(
      min: (json['min'] ?? 0.0).toDouble(),
      max: (json['max'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {'min': min, 'max': max, 'currency': currency};
  }
}

class ApplicationForm {
  final String formId;
  final List<FormQuestion> questions;
  final List<FormLink> additionalLinks;

  ApplicationForm({
    required this.formId,
    required this.questions,
    required this.additionalLinks,
  });

  factory ApplicationForm.fromJson(Map<String, dynamic> json) {
    return ApplicationForm(
      formId: json['formId'] ?? '',
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((item) => FormQuestion.fromJson(item))
              .toList() ??
          [],
      additionalLinks:
          (json['additionalLinks'] as List<dynamic>?)
              ?.map((item) => FormLink.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formId': formId,
      'questions': questions.map((item) => item.toJson()).toList(),
      'additionalLinks': additionalLinks.map((item) => item.toJson()).toList(),
    };
  }
}

class FormQuestion {
  final String questionId;
  final String questionText;
  final QuestionType questionType;
  final List<String> options;
  final bool isRequired;

  FormQuestion({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.isRequired,
  });

  factory FormQuestion.fromJson(Map<String, dynamic> json) {
    return FormQuestion(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      questionType: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['questionType'] ?? 'TEXT'),
        orElse: () => QuestionType.TEXT,
      ),
      options: List<String>.from(json['options'] ?? []),
      isRequired: json['isRequired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionType': questionType.toString().split('.').last,
      'options': options,
      'isRequired': isRequired,
    };
  }
}

class FormLink {
  final String linkText;
  final String url;
  final String description;

  FormLink({
    required this.linkText,
    required this.url,
    required this.description,
  });

  factory FormLink.fromJson(Map<String, dynamic> json) {
    return FormLink(
      linkText: json['linkText'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'linkText': linkText, 'url': url, 'description': description};
  }
}

class GroupInfo {
  final String groupId;
  final String groupName;
  final int participantCount;
  final bool isActive;
  final DateTime createdAt;

  GroupInfo({
    required this.groupId,
    required this.groupName,
    required this.participantCount,
    required this.isActive,
    required this.createdAt,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      groupId: json['groupId'] ?? '',
      groupName: json['groupName'] ?? '',
      participantCount: json['participantCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'participantCount': participantCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
