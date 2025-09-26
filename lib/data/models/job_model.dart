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
      applicationDeadline:
          DateTime.tryParse(json['applicationDeadline'] ?? '') ??
          DateTime.now().add(Duration(days: 30)),
      postedAt: DateTime.tryParse(json['postedAt'] ?? '') ?? DateTime.now(),
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
  final List<int> graduationYears;
  final List<String> requiredSkills;
  final int maxBacklogs;

  Requirements({
    required this.minCgpa,
    required this.allowedBranches,
    required this.allowedDegreeTypes,
    required this.graduationYears,
    required this.requiredSkills,
    required this.maxBacklogs,
  });

  factory Requirements.fromJson(Map<String, dynamic> json) {
    return Requirements(
      minCgpa: (json['minCgpa'] ?? 0.0).toDouble(),
      allowedBranches:
          (json['allowedBranches'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      allowedDegreeTypes:
          (json['allowedDegreeTypes'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      graduationYears:
          (json['graduationYears'] as List?)
              ?.map((item) => int.tryParse(item.toString()) ?? 0)
              .toList() ??
          [],
      requiredSkills:
          (json['requiredSkills'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      maxBacklogs: json['maxBacklogs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minCgpa': minCgpa,
      'allowedBranches': allowedBranches,
      'allowedDegreeTypes': allowedDegreeTypes,
      'graduationYears': graduationYears,
      'requiredSkills': requiredSkills,
      'maxBacklogs': maxBacklogs,
    };
  }

  bool isGraduationYearAllowed(int year) {
    if (graduationYears.isEmpty) return true;
    return graduationYears.contains(year);
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
  final List<FormQuestion> questions;
  final List<FormLink> additionalLinks;

  ApplicationForm({required this.questions, required this.additionalLinks});

  factory ApplicationForm.fromJson(Map<String, dynamic> json) {
    return ApplicationForm(
      questions: (json['questions'] as List? ?? [])
          .map((q) => FormQuestion.fromJson(q))
          .toList(),
      additionalLinks: (json['additionalLinks'] as List? ?? [])
          .map((l) => FormLink.fromJson(l))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questions': questions.map((q) => q.toJson()).toList(),
      'additionalLinks': additionalLinks.map((l) => l.toJson()).toList(),
    };
  }
}

class FormQuestion {
  final String questionId;
  final String questionText;
  final QuestionType questionType;
  final bool isRequired;
  final List<String> options;
  final int? maxLength;
  final String? placeholder;

  FormQuestion({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.isRequired,
    required this.options,
    this.maxLength,
    this.placeholder,
  });

  factory FormQuestion.fromJson(Map<String, dynamic> json) {
    return FormQuestion(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      questionType: _parseQuestionType(json['questionType']),
      isRequired: json['isRequired'] ?? false,
      options: List<String>.from(json['options'] ?? []),
      maxLength: json['maxLength'],
      placeholder: json['placeholder'],
    );
  }

  static QuestionType _parseQuestionType(dynamic type) {
    if (type == null) return QuestionType.TEXT;
    final typeString = type.toString().toUpperCase();
    switch (typeString) {
      case 'TEXT':
        return QuestionType.TEXT;
      case 'MULTIPLE_CHOICE':
        return QuestionType.MULTIPLE_CHOICE;
      case 'CHECKBOX':
        return QuestionType.CHECKBOX;
      case 'DROPDOWN':
        return QuestionType.DROPDOWN;
      case 'FILE_UPLOAD':
        return QuestionType.FILE_UPLOAD;
      case 'DATE':
        return QuestionType.DATE;
      case 'NUMBER':
        return QuestionType.NUMBER;
      default:
        return QuestionType.TEXT;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionType': questionType.toString().split('.').last,
      'isRequired': isRequired,
      'options': options,
      'maxLength': maxLength,
      'placeholder': placeholder,
    };
  }
}

class FormLink {
  final String linkId;
  final String url;
  final String linkText;
  final String description;

  FormLink({
    required this.linkId,
    required this.url,
    required this.linkText,
    required this.description,
  });

  factory FormLink.fromJson(Map<String, dynamic> json) {
    return FormLink(
      linkId: json['linkId'] ?? '',
      url: json['url'] ?? '',
      linkText: json['linkText'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'linkId': linkId,
      'url': url,
      'linkText': linkText,
      'description': description,
    };
  }
}

class GroupInfo {
  final String groupId;
  final String groupName;
  final bool isGroupRequired;

  GroupInfo({
    required this.groupId,
    required this.groupName,
    required this.isGroupRequired,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      groupId: json['groupId'] ?? '',
      groupName: json['groupName'] ?? '',
      isGroupRequired: json['isGroupRequired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'isGroupRequired': isGroupRequired,
    };
  }
}
