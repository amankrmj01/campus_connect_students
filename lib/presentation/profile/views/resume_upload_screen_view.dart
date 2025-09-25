// lib/presentation/profile/views/resume_upload_screen_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile.controller.dart';

class ResumeUploadScreenView extends GetView<ProfileController> {
  const ResumeUploadScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Resume'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Resume Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.description,
                      size: 64,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Resume',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.resumeFileName.value.isEmpty
                            ? 'No resume uploaded yet'
                            : controller.resumeFileName.value,
                        style: TextStyle(
                          fontSize: 16,
                          color: controller.resumeFileName.value.isEmpty
                              ? Colors.grey.shade600
                              : Colors.blue.shade700,
                          fontWeight: controller.resumeFileName.value.isEmpty
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upload Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.pickResumeFile,
                          icon: controller.isSaving.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  controller.resumeFileName.value.isEmpty
                                      ? Icons.upload_file
                                      : Icons.refresh,
                                ),
                          label: Text(
                            controller.resumeFileName.value.isEmpty
                                ? 'Upload Resume'
                                : 'Update Resume',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // View Resume Button (if exists)
                    if (controller.currentStudent.value?.resumeUrl != null &&
                        controller
                            .currentStudent
                            .value!
                            .resumeUrl!
                            .isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Open resume viewer
                            Get.snackbar('Info', 'Opening resume viewer...');
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Current Resume'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.blue.shade700),
                            foregroundColor: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // File Requirements Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.rule, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'File Requirements',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRequirement(
                      'Supported formats: PDF, DOC, DOCX',
                      Icons.check_circle_outline,
                    ),
                    _buildRequirement(
                      'Maximum file size: 5 MB',
                      Icons.check_circle_outline,
                    ),
                    _buildRequirement(
                      'File name should be professional',
                      Icons.check_circle_outline,
                    ),
                    _buildRequirement(
                      'Keep your resume updated regularly',
                      Icons.check_circle_outline,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tips Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Resume Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Keep your resume to 1-2 pages maximum'),
                    _buildTip('Use a professional email address'),
                    _buildTip('Include relevant work experience and projects'),
                    _buildTip('Add your technical skills and certifications'),
                    _buildTip('Proofread for grammar and spelling errors'),
                    _buildTip('Use action verbs to describe your achievements'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Resume Importance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Why Resume Matters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your resume is often the first impression you make on potential employers. '
                    'A well-crafted resume can significantly increase your chances of getting shortlisted '
                    'for interviews. Make sure it accurately reflects your skills, experience, and achievements.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
