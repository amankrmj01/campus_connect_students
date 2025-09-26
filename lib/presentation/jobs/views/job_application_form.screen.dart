// lib/presentation/jobs/views/job_application_form.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/enum.dart';
import '../../../data/models/job_model.dart';
import '../controllers/job_application_form.controller.dart';

class JobApplicationFormScreen extends GetView<JobApplicationFormController> {
  const JobApplicationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Job Application'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final job = controller.job.value;
        if (job == null) {
          return const Center(child: Text('Job not found'));
        }

        return Column(
          children: [
            // Job Info Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.companyName,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.getDaysLeft(job.applicationDeadline)} days left',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Application Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Application Form',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please answer the following questions to complete your application.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Questions
                      ...job.customForm.questions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final question = entry.value;
                        return _buildQuestionWidget(question, index);
                      }).toList(),

                      // Additional Links
                      if (job.customForm.additionalLinks.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Additional Resources',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...job.customForm.additionalLinks
                            .map((link) => _buildLinkCard(link))
                            .toList(),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Submit Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : controller.submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting...'),
                          ],
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildQuestionWidget(FormQuestion question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (question.isRequired)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnswerInput(question, index),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(FormQuestion question, int index) {
    switch (question.questionType) {
      case QuestionType.TEXT:
        return TextFormField(
          onChanged: (value) => controller.updateAnswer(index, value),
          validator: question.isRequired
              ? (value) =>
                    value?.isEmpty == true ? 'This field is required' : null
              : null,
          decoration: InputDecoration(
            hintText: 'Enter your answer',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          maxLines: 3,
        );

      case QuestionType.MULTIPLE_CHOICE:
        return Column(
          children: question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            return Obx(
              () => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: controller.answers[index]?.toString(),
                onChanged: (value) => controller.updateAnswer(index, value),
                contentPadding: EdgeInsets.zero,
              ),
            );
          }).toList(),
        );

      case QuestionType.CHECKBOX:
        return Column(
          children: question.options.asMap().entries.map((entry) {
            final option = entry.value;
            return Obx(() {
              final currentAnswers =
                  controller.answers[index] as List<String>? ?? [];
              return CheckboxListTile(
                title: Text(option),
                value: currentAnswers.contains(option),
                onChanged: (checked) {
                  final newAnswers = List<String>.from(currentAnswers);
                  if (checked == true) {
                    newAnswers.add(option);
                  } else {
                    newAnswers.remove(option);
                  }
                  controller.updateAnswer(index, newAnswers);
                },
                contentPadding: EdgeInsets.zero,
              );
            });
          }).toList(),
        );

      case QuestionType.DROPDOWN:
        return Obx(
          () => DropdownButtonFormField<String>(
            value: controller.answers[index]?.toString(),
            hint: const Text('Select an option'),
            items: question.options
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
            onChanged: (value) => controller.updateAnswer(index, value),
            validator: question.isRequired
                ? (value) => value == null ? 'Please select an option' : null
                : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        );

      default:
        return TextFormField(
          onChanged: (value) => controller.updateAnswer(index, value),
          validator: question.isRequired
              ? (value) =>
                    value?.isEmpty == true ? 'This field is required' : null
              : null,
          decoration: InputDecoration(
            hintText: 'Enter your answer',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        );
    }
  }

  Widget _buildLinkCard(FormLink link) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.link, color: Colors.blue.shade600),
        title: Text(
          link.linkText,
          style: TextStyle(
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: link.description.isNotEmpty ? Text(link.description) : null,
        trailing: Icon(Icons.open_in_new, color: Colors.grey.shade400),
        onTap: () => controller.openLink(link.url),
      ),
    );
  }
}
