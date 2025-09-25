// lib/presentation/profile/controllers/profile.controller.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/enum.dart';
import '../../../data/models/student_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../infrastructure/navigation/routes.dart';

class ProfileController extends GetxController
    with GetTickerProviderStateMixin {
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Reactive variables
  final Rx<Student?> currentStudent = Rx<Student?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxInt profileCompletionPercentage = 0.obs;
  final RxBool isEditingPersonalDetails = false.obs;
  final RxBool isEditingAcademicDetails = false.obs;

  // Tab controller
  late TabController tabController;

  // Form controllers - Personal Details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Form controllers - Academic Details
  final TextEditingController cgpaController = TextEditingController();
  final TextEditingController tenthMarksController = TextEditingController();
  final TextEditingController twelfthMarksController = TextEditingController();
  final TextEditingController backlogsController = TextEditingController();
  final TextEditingController graduationYearController =
      TextEditingController();

  // Form controllers - Address
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  // Work Experience and Certifications
  final RxList<WorkExperience> workExperiences = <WorkExperience>[].obs;
  final RxList<Certification> certifications = <Certification>[].obs;

  // Form keys
  final GlobalKey<FormState> personalDetailsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> academicDetailsFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  // File handling
  final Rx<File?> selectedProfileImage = Rx<File?>(null);
  final Rx<File?> selectedResumeFile = Rx<File?>(null);
  final RxString resumeFileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    initializeProfile();
  }

  @override
  void onClose() {
    disposeControllers();
    tabController.dispose();
    super.onClose();
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cgpaController.dispose();
    tenthMarksController.dispose();
    twelfthMarksController.dispose();
    backlogsController.dispose();
    graduationYearController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
  }

  // Initialize profile data
  void initializeProfile() async {
    try {
      isLoading.value = true;
      await loadStudentData();
      populateControllers();
      calculateProfileCompletion();
    } catch (e) {
      print('Initialize profile error: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load student data
  Future<void> loadStudentData() async {
    try {
      final response = await _profileRepository.getStudentProfile();
      if (response['success'] == true) {
        currentStudent.value = Student.fromJson(response['student']);
        // Also update local storage
        await _storageService.saveStudentData(response['student']);
      }
    } catch (e) {
      // Try to load from local storage if API fails
      final studentData = await _storageService.getStudentData();
      if (studentData != null) {
        currentStudent.value = Student.fromJson(studentData);
      }
      print('Load student data error: $e');
    }
  }

  // Populate form controllers with student data
  void populateControllers() {
    if (currentStudent.value == null) return;

    final student = currentStudent.value!;

    // Personal Details
    nameController.text = student.name;
    emailController.text = student.email;

    // Academic Details
    if (student.academicDetails != null) {
      cgpaController.text = student.academicDetails!.cgpa?.toString() ?? '';
      tenthMarksController.text =
          student.academicDetails!.tenthMarks?.toString() ?? '';
      twelfthMarksController.text =
          student.academicDetails!.twelfthMarks?.toString() ?? '';
      backlogsController.text =
          student.academicDetails!.backlogs?.toString() ?? '';
      graduationYearController.text =
          student.academicDetails!.graduationYear?.toString() ?? '';
    }

    // Address
    if (student.address != null) {
      streetController.text = student.address!.street;
      cityController.text = student.address!.city;
      stateController.text = student.address!.state;
      pincodeController.text = student.address!.pincode;
      countryController.text = student.address!.country;
    } else {
      countryController.text = 'India'; // Default country
    }

    // Work Experience and Certifications
    workExperiences.assignAll(student.workExperience);
    certifications.assignAll(student.certifications);

    // Resume file name
    if (student.resumeUrl != null && student.resumeUrl!.isNotEmpty) {
      resumeFileName.value = student.resumeUrl!.split('/').last;
    }
  }

  // Calculate profile completion percentage
  void calculateProfileCompletion() {
    if (currentStudent.value == null) return;

    int completedFields = 0;
    int totalFields = 12; // Total required fields

    final student = currentStudent.value!;

    // Basic info (always completed from college)
    if (student.name.isNotEmpty) completedFields++;
    if (student.email.isNotEmpty) completedFields++;
    if (student.regNumber.isNotEmpty) completedFields++;

    // Academic details
    if (student.academicDetails?.cgpa != null) completedFields++;
    if (student.academicDetails?.tenthMarks != null) completedFields++;
    if (student.academicDetails?.twelfthMarks != null) completedFields++;
    if (student.academicDetails?.graduationYear != null) completedFields++;

    // Address
    if (student.address?.street.isNotEmpty == true) completedFields++;
    if (student.address?.city.isNotEmpty == true) completedFields++;
    if (student.address?.state.isNotEmpty == true) completedFields++;
    if (student.address?.pincode.isNotEmpty == true) completedFields++;

    // Resume
    if (student.resumeUrl != null && student.resumeUrl!.isNotEmpty)
      completedFields++;

    profileCompletionPercentage.value = ((completedFields / totalFields) * 100)
        .round();
  }

  // Save personal details
  Future<void> savePersonalDetails() async {
    if (!personalDetailsFormKey.currentState!.validate()) return;

    try {
      isSaving.value = true;

      final updatedData = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      final response = await _profileRepository.updatePersonalDetails(
        updatedData,
      );

      if (response['success'] == true) {
        await loadStudentData();
        isEditingPersonalDetails.value = false;
        Get.snackbar(
          'Success',
          'Personal details updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to update personal details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Save personal details error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // Save academic details
  Future<void> saveAcademicDetails() async {
    if (!academicDetailsFormKey.currentState!.validate()) return;

    try {
      isSaving.value = true;

      final academicData = {
        'cgpa': double.tryParse(cgpaController.text),
        'tenthMarks': double.tryParse(tenthMarksController.text),
        'twelfthMarks': double.tryParse(twelfthMarksController.text),
        'backlogs': int.tryParse(backlogsController.text),
        'graduationYear': int.tryParse(graduationYearController.text),
      };

      final response = await _profileRepository.updateAcademicDetails(
        academicData,
      );

      if (response['success'] == true) {
        await loadStudentData();
        calculateProfileCompletion();
        isEditingAcademicDetails.value = false;
        Get.snackbar(
          'Success',
          'Academic details updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to update academic details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Save academic details error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // Save address
  Future<void> saveAddress() async {
    if (!addressFormKey.currentState!.validate()) return;

    try {
      isSaving.value = true;

      final addressData = {
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'country': countryController.text.trim(),
      };

      final response = await _profileRepository.updateAddress(addressData);

      if (response['success'] == true) {
        await loadStudentData();
        calculateProfileCompletion();
        Get.snackbar(
          'Success',
          'Address updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to update address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Save address error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // Pick profile image
  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        selectedProfileImage.value = File(image.path);
        await uploadProfileImage();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Pick profile image error: $e');
    }
  }

  // Upload profile image
  Future<void> uploadProfileImage() async {
    if (selectedProfileImage.value == null) return;

    try {
      isSaving.value = true;

      final response = await _profileRepository.uploadProfileImage(
        selectedProfileImage.value!,
      );

      if (response['success'] == true) {
        await loadStudentData();
        Get.snackbar(
          'Success',
          'Profile picture updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to upload profile picture',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Upload profile image error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // Pick resume file
  Future<void> pickResumeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedResumeFile.value = File(result.files.first.path!);
        resumeFileName.value = result.files.first.name;
        await uploadResume();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick resume file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Pick resume file error: $e');
    }
  }

  // Upload resume
  Future<void> uploadResume() async {
    if (selectedResumeFile.value == null) return;

    try {
      isSaving.value = true;

      final response = await _profileRepository.uploadResume(
        selectedResumeFile.value!,
      );

      if (response['success'] == true) {
        await loadStudentData();
        calculateProfileCompletion();
        Get.snackbar(
          'Success',
          'Resume uploaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to upload resume',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Upload resume error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // Add work experience
  void addWorkExperience() {
    Get.toNamed(Routes.PROFILE + '/work-experience');
  }

  // Edit work experience
  void editWorkExperience(int index) {
    Get.toNamed(
      Routes.PROFILE + '/work-experience',
      arguments: {'workExperience': workExperiences[index], 'index': index},
    );
  }

  // Delete work experience
  void deleteWorkExperience(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Work Experience'),
        content: const Text(
          'Are you sure you want to delete this work experience?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              workExperiences.removeAt(index);
              Get.back();
              _saveWorkExperiences();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Save work experiences
  Future<void> _saveWorkExperiences() async {
    try {
      final response = await _profileRepository.updateWorkExperiences(
        workExperiences.map((exp) => exp.toJson()).toList(),
      );

      if (response['success'] == true) {
        await loadStudentData();
        Get.snackbar(
          'Success',
          'Work experiences updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Save work experiences error: $e');
    }
  }

  // Add certification
  void addCertification() {
    Get.toNamed(Routes.PROFILE + '/certification');
  }

  // Edit certification
  void editCertification(int index) {
    Get.toNamed(
      Routes.PROFILE + '/certification',
      arguments: {'certification': certifications[index], 'index': index},
    );
  }

  // Delete certification
  void deleteCertification(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Certification'),
        content: const Text(
          'Are you sure you want to delete this certification?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              certifications.removeAt(index);
              Get.back();
              _saveCertifications();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Save certifications
  Future<void> _saveCertifications() async {
    try {
      final response = await _profileRepository.updateCertifications(
        certifications.map((cert) => cert.toJson()).toList(),
      );

      if (response['success'] == true) {
        await loadStudentData();
        Get.snackbar(
          'Success',
          'Certifications updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Save certifications error: $e');
    }
  }

  // Toggle edit modes
  void togglePersonalDetailsEdit() {
    isEditingPersonalDetails.value = !isEditingPersonalDetails.value;
    if (!isEditingPersonalDetails.value) {
      populateControllers(); // Reset form if cancelled
    }
  }

  void toggleAcademicDetailsEdit() {
    isEditingAcademicDetails.value = !isEditingAcademicDetails.value;
    if (!isEditingAcademicDetails.value) {
      populateControllers(); // Reset form if cancelled
    }
  }

  // Form validators
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateCGPA(String? value) {
    if (value == null || value.isEmpty) {
      return 'CGPA is required';
    }
    final cgpa = double.tryParse(value);
    if (cgpa == null || cgpa < 0 || cgpa > 10) {
      return 'CGPA must be between 0 and 10';
    }
    return null;
  }

  String? validateMarks(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final marks = double.tryParse(value);
    if (marks == null || marks < 0 || marks > 100) {
      return '$fieldName must be between 0 and 100';
    }
    return null;
  }

  String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Graduation year is required';
    }
    final year = int.tryParse(value);
    final currentYear = DateTime.now().year;
    if (year == null || year < currentYear || year > currentYear + 10) {
      return 'Please enter a valid graduation year';
    }
    return null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }
    if (value.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid 6-digit pincode';
    }
    return null;
  }
}
