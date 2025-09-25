// lib/presentation/profile/views/certification_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/student_model.dart';
import '../controllers/profile.controller.dart';

class CertificationFormView extends GetView<ProfileController> {
  const CertificationFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final Certification? existingCertification = arguments?['certification'];
    final int? index = arguments?['index'];
    final bool isEditing = existingCertification != null;

    // Form controllers
    final nameController = TextEditingController(
      text: existingCertification?.name ?? '',
    );
    final organizationController = TextEditingController(
      text: existingCertification?.issuingOrganization ?? '',
    );
    final credentialUrlController = TextEditingController(
      text: existingCertification?.credentialUrl ?? '',
    );

    final selectedDate = Rx<DateTime>(
      existingCertification?.issueDate ?? DateTime.now(),
    );
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Certification' : 'Add Certification'),
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
                      colors: [Colors.purple.shade50, Colors.purple.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 32,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing
                                  ? 'Update Certification'
                                  : 'Add New Certification',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade800,
                              ),
                            ),
                            Text(
                              'Showcase your achievements and skills',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.purple.shade600,
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
                        'Certification Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Certification Name
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Certification Name *',
                          hintText: 'e.g., AWS Certified Solutions Architect',
                          prefixIcon: const Icon(Icons.school),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Certification name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Issuing Organization
                      TextFormField(
                        controller: organizationController,
                        decoration: InputDecoration(
                          labelText: 'Issuing Organization *',
                          hintText:
                              'e.g., Amazon Web Services, Google, Microsoft',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Issuing organization is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Issue Date
                      Obx(
                        () => InkWell(
                          onTap: () => _selectDate(context, selectedDate),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Issue Date *',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _formatDate(selectedDate.value),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Credential URL (Optional)
                      TextFormField(
                        controller: credentialUrlController,
                        decoration: InputDecoration(
                          labelText: 'Credential URL (Optional)',
                          hintText: 'https://credential-url.com/verify',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          helperText:
                              'Link to verify your certification online',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!GetUtils.isURL(value)) {
                              return 'Please enter a valid URL';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Popular Certifications Card
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
                            Icons.trending_up,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Popular Certifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCertificationChip('AWS Cloud Practitioner'),
                          _buildCertificationChip('Google Cloud Associate'),
                          _buildCertificationChip(
                            'Microsoft Azure Fundamentals',
                          ),
                          _buildCertificationChip('Docker Certified Associate'),
                          _buildCertificationChip('Kubernetes Certification'),
                          _buildCertificationChip('Scrum Master'),
                        ],
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Certification Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Add the exact name as it appears on your certificate\n'
                      '• Include the credential URL if available for verification\n'
                      '• Keep your certifications current and relevant\n'
                      '• Add certificates that align with your career goals',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
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
                  onPressed: () => _saveCertification(
                    formKey,
                    nameController,
                    organizationController,
                    credentialUrlController,
                    selectedDate.value,
                    isEditing,
                    index,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEditing ? 'Update Certification' : 'Add Certification',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificationChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          color: Colors.orange.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, Rx<DateTime> selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _saveCertification(
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController organizationController,
    TextEditingController credentialUrlController,
    DateTime issueDate,
    bool isEditing,
    int? index,
  ) {
    if (formKey.currentState?.validate() == true) {
      final certification = Certification(
        name: nameController.text.trim(),
        issuingOrganization: organizationController.text.trim(),
        issueDate: issueDate,
        credentialUrl: credentialUrlController.text.trim().isEmpty
            ? null
            : credentialUrlController.text.trim(),
      );

      if (isEditing && index != null) {
        controller.certifications[index] = certification;
      } else {
        controller.certifications.add(certification);
      }

      Get.back();
      Get.snackbar(
        'Success',
        '${isEditing ? 'Updated' : 'Added'} certification successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}
