// lib/presentation/jobs/controllers/job_application_form.controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/job_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';

class JobApplicationFormController extends GetxController {
  final JobRepository _jobRepository = Get.find<JobRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  // Form state
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Rx<Job?> job = Rx<Job?>(null);
  final Rx<Student?> currentStudent = Rx<Student?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Answers storage - using dynamic to handle different answer types
  final RxMap<int, dynamic> answers = <int, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeForm();
  }

  void _initializeForm() async {
    try {
      isLoading.value = true;

      // Get job from arguments
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments != null && arguments['job'] != null) {
        job.value = arguments['job'] as Job;
      }

      // Load student data
      await _loadStudentData();

      // Initialize answers map
      if (job.value != null) {
        for (int i = 0; i < job.value!.customForm.questions.length; i++) {
          final question = job.value!.customForm.questions[i];
          if (question.questionType.toString().contains('CHECKBOX')) {
            answers[i] = <String>[];
          } else {
            answers[i] = '';
          }
        }
      }
    } catch (e) {
      print('Initialize form error: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize application form',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadStudentData() async {
    try {
      final studentData = await _storageService.getStudentData();
      if (studentData != null) {
        currentStudent.value = Student.fromJson(studentData);
      }
    } catch (e) {
      print('Load student data error: $e');
    }
  }

  void updateAnswer(int questionIndex, dynamic answer) {
    answers[questionIndex] = answer;
  }

  int getDaysLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  Future<void> openLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open link',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Open link error: $e');
      Get.snackbar(
        'Error',
        'Could not open link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitApplication() async {
    try {
      if (job.value == null || currentStudent.value == null) {
        Get.snackbar(
          'Error',
          'Missing application data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validate form
      if (!formKey.currentState!.validate()) {
        Get.snackbar(
          'Validation Error',
          'Please fill in all required fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Check required questions
      for (int i = 0; i < job.value!.customForm.questions.length; i++) {
        final question = job.value!.customForm.questions[i];
        if (question.isRequired) {
          final answer = answers[i];
          if (answer == null ||
              (answer is String && answer.isEmpty) ||
              (answer is List && answer.isEmpty)) {
            Get.snackbar(
              'Validation Error',
              'Please answer all required questions',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }
        }
      }

      isSubmitting.value = true;

      // Prepare application data with answers
      final applicationData = {
        'jobId': job.value!.jobId,
        'candidateId':
            currentStudent.value!.studentId ?? currentStudent.value!.userId,
        'answers': _formatAnswersForSubmission(),
        'appliedAt': DateTime.now().toIso8601String(),
      };

      // Submit application using the job repository
      final response = await _jobRepository.submitJobApplication(
        applicationData,
      );

      if (response['success'] == true) {
        // Show success dialog
        await Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Application Submitted'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your application has been submitted successfully!'),
                SizedBox(height: 8),
                Text(
                  'Application ID: ${response['data']['applicationId']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Status: ${response['data']['status']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You will be notified about updates via email and in the applications section.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to jobs screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to submit application',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Submit application error: $e');
      Get.snackbar(
        'Error',
        'Failed to submit application. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  List<Map<String, dynamic>> _formatAnswersForSubmission() {
    final formattedAnswers = <Map<String, dynamic>>[];

    for (int i = 0; i < job.value!.customForm.questions.length; i++) {
      final question = job.value!.customForm.questions[i];
      final answer = answers[i];

      formattedAnswers.add({
        'questionId': question.questionId,
        'questionText': question.questionText,
        'questionType': question.questionType.toString().split('.').last,
        'answer': answer,
        'isRequired': question.isRequired,
      });
    }

    return formattedAnswers;
  }
}
