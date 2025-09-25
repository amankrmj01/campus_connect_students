// lib/data/models/application_model.dart
import 'enum.dart';
import 'job_model.dart';

class Application {
  final String applicationId;
  final String studentId;
  final String jobId;
  final Job jobDetails;
  final Map<String, dynamic> formAnswers;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? lastUpdatedAt;
  final int currentRound;
  final bool canWithdraw;
  final bool hasGroupAccess;
  final List<RoundHistory> roundHistory;

  Application({
    required this.applicationId,
    required this.studentId,
    required this.jobId,
    required this.jobDetails,
    required this.formAnswers,
    required this.status,
    required this.appliedAt,
    this.lastUpdatedAt,
    required this.currentRound,
    required this.canWithdraw,
    required this.hasGroupAccess,
    required this.roundHistory,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      applicationId: json['applicationId'] ?? '',
      studentId: json['studentId'] ?? '',
      jobId: json['jobId'] ?? '',
      jobDetails: Job.fromJson(json['jobDetails'] ?? {}),
      formAnswers: Map<String, dynamic>.from(json['formAnswers'] ?? {}),
      status: ApplicationStatusExtension.fromString(
        json['status'] ?? 'APPLIED',
      ),
      appliedAt: DateTime.parse(
        json['appliedAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'])
          : null,
      currentRound: json['currentRound'] ?? 1,
      canWithdraw: json['canWithdraw'] ?? false,
      hasGroupAccess: json['hasGroupAccess'] ?? false,
      roundHistory:
          (json['roundHistory'] as List<dynamic>?)
              ?.map((item) => RoundHistory.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationId': applicationId,
      'studentId': studentId,
      'jobId': jobId,
      'jobDetails': jobDetails.toJson(),
      'formAnswers': formAnswers,
      'status': status.value,
      'appliedAt': appliedAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'currentRound': currentRound,
      'canWithdraw': canWithdraw,
      'hasGroupAccess': hasGroupAccess,
      'roundHistory': roundHistory.map((item) => item.toJson()).toList(),
    };
  }

  Application copyWith({
    String? applicationId,
    String? studentId,
    String? jobId,
    Job? jobDetails,
    Map<String, dynamic>? formAnswers,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? lastUpdatedAt,
    int? currentRound,
    bool? canWithdraw,
    bool? hasGroupAccess,
    List<RoundHistory>? roundHistory,
  }) {
    return Application(
      applicationId: applicationId ?? this.applicationId,
      studentId: studentId ?? this.studentId,
      jobId: jobId ?? this.jobId,
      jobDetails: jobDetails ?? this.jobDetails,
      formAnswers: formAnswers ?? this.formAnswers,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      currentRound: currentRound ?? this.currentRound,
      canWithdraw: canWithdraw ?? this.canWithdraw,
      hasGroupAccess: hasGroupAccess ?? this.hasGroupAccess,
      roundHistory: roundHistory ?? this.roundHistory,
    );
  }
}

class RoundHistory {
  final int round;
  final RoundStatus status;
  final DateTime updatedAt;
  final String? remarks;

  RoundHistory({
    required this.round,
    required this.status,
    required this.updatedAt,
    this.remarks,
  });

  factory RoundHistory.fromJson(Map<String, dynamic> json) {
    return RoundHistory(
      round: json['round'] ?? 1,
      status: RoundStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'PENDING'),
        orElse: () => RoundStatus.PENDING,
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'status': status.toString().split('.').last,
      'updatedAt': updatedAt.toIso8601String(),
      'remarks': remarks,
    };
  }
}
