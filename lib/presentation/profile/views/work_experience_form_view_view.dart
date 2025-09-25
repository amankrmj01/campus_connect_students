// lib/presentation/profile/views/work_experience_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/student_model.dart';
import '../controllers/profile.controller.dart';

class WorkExperienceFormView extends GetView<ProfileController> {
  const WorkExperienceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final WorkExperience? existingExperience = arguments?['workExperience'];
    final int? index = arguments?['index'];
    final bool isEditing = existingExperience != null;

    // Form controllers
    final companyController = TextEditingController(
      text: existingExperience?.company ?? '',
    );
    final roleController = TextEditingController(
      text: existingExperience?.role ?? '',
    );
    final durationController = TextEditingController(
      text: existingExperience?.duration ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingExperience?.description ?? '',
    );
    final skillsController = TextEditingController(
      text: existingExperience?.skills.join(', ') ?? '',
    );

    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Work Experience' : 'Add Work Experience'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade50, Colors.green.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.work, size: 32, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing
                                  ? 'Update Experience'
                                  : 'Add New Experience',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            Text(
                              'Include internships, part-time jobs, and projects',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Form Fields Card
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
                      const Text(
                        'Experience Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Job Title/Role
                      TextFormField(
                        controller: roleController,
                        decoration: InputDecoration(
                          labelText: 'Job Title / Role *',
                          hintText: 'e.g., Software Developer Intern',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Job title is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Company Name
                      TextFormField(
                        controller: companyController,
                        decoration: InputDecoration(
                          labelText: 'Company Name *',
                          hintText: 'e.g., Google, Microsoft, ABC Corp',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Company name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Duration
                      TextFormField(
                        controller: durationController,
                        decoration: InputDecoration(
                          labelText: 'Duration *',
                          hintText: 'e.g., Jan 2024 - Mar 2024, 3 months',
                          prefixIcon: const Icon(Icons.schedule),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Duration is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Job Description
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Job Description *',
                          hintText:
                              'Describe your responsibilities and achievements...',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Job description is required';
                          }
                          if (value.length < 50) {
                            return 'Please provide a detailed description (at least 50 characters)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Skills
                      TextFormField(
                        controller: skillsController,
                        decoration: InputDecoration(
                          labelText: 'Skills Used',
                          hintText: 'e.g., Flutter, Dart, Firebase, REST APIs',
                          prefixIcon: const Icon(Icons.settings),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          helperText: 'Separate multiple skills with commas',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tips Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Writing Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Use action verbs like "developed", "implemented", "managed"\n'
                      '• Quantify your achievements with numbers when possible\n'
                      '• Focus on what you accomplished, not just what you did\n'
                      '• Keep descriptions concise but informative',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Bottom padding for buttons
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _saveWorkExperience(
                    formKey,
                    companyController,
                    roleController,
                    durationController,
                    descriptionController,
                    skillsController,
                    isEditing,
                    index,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEditing ? 'Update Experience' : 'Add Experience',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveWorkExperience(
    GlobalKey<FormState> formKey,
    TextEditingController companyController,
    TextEditingController roleController,
    TextEditingController durationController,
    TextEditingController descriptionController,
    TextEditingController skillsController,
    bool isEditing,
    int? index,
  ) {
    if (formKey.currentState?.validate() == true) {
      final skills = skillsController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList();

      final workExperience = WorkExperience(
        company: companyController.text.trim(),
        role: roleController.text.trim(),
        duration: durationController.text.trim(),
        description: descriptionController.text.trim(),
        skills: skills,
      );

      if (isEditing && index != null) {
        controller.workExperiences[index] = workExperience;
      } else {
        controller.workExperiences.add(workExperience);
      }

      Get.back();
      Get.snackbar(
        'Success',
        '${isEditing ? 'Updated' : 'Added'} work experience successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}
