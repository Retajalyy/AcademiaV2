import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:academia/Features/profile/models/student_model.dart';
import 'package:academia/Features/profile/services/student_service.dart';

class ProfileController extends GetxController {
  final StudentService _service = StudentService();
  final _picker = ImagePicker();

  final Rxn<StudentModel> student = Rxn<StudentModel>();
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  // Semester week progress
  final RxInt currentWeek   = 0.obs;
  final RxInt totalWeeks    = 16.obs;
  final RxString semesterLabel = ''.obs;

  // Displayed avatar URL (from DB)
  final Rxn<String> avatarUrl = Rxn<String>();

  // Pending local image — set when user picks, cleared after save
  final Rxn<Uint8List> pendingImageBytes = Rxn<Uint8List>();
  String _pendingImageExt = 'jpg';

  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    loadProfile();
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    error.value = '';
    try {
      final results = await Future.wait([
        _service.fetchStudentProfile(),
        _service.fetchSemesterProgress(),
      ]);
      if (isClosed) return;
      final data = results[0] as StudentModel;
      final sem  = results[1] as Map<String, dynamic>;
      student.value       = data;
      phoneController.text = data.phone;
      avatarUrl.value     = data.avatarUrl;
      currentWeek.value   = sem['currentWeek'] as int;
      totalWeeks.value    = sem['totalWeeks']  as int;
      semesterLabel.value = sem['semesterLabel'] as String;
    } catch (e) {
      error.value = 'Failed to load profile: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Pick image — only stores locally, does NOT upload yet
  Future<void> pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        IOSUiSettings(
          title: 'Crop Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          rotateButtonsHidden: false,
        ),
      ],
    );
    if (cropped == null) return;

    pendingImageBytes.value = await cropped.readAsBytes();
    _pendingImageExt = cropped.path.split('.').last.toLowerCase();
  }

  // Clear only the pending selection — reverts to the saved avatar
  void clearPendingImage() {
    pendingImageBytes.value = null;
  }

  // Remove the photo entirely (pending + saved URL) — saved on next updateProfile
  void removePhoto() {
    pendingImageBytes.value = null;
    avatarUrl.value = null;
  }

  // Save button — uploads image (if picked) + saves phone
  Future<void> updateProfile() async {
    if (student.value == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    isSaving.value = true;
    try {
      // Upload image if one was picked
      if (pendingImageBytes.value != null) {
        final url = await _service.uploadAvatarByStudentNumber(
          student.value!.id,
          pendingImageBytes.value!,
          _pendingImageExt,
        );
        PaintingBinding.instance.imageCache.clear();
        avatarUrl.value = url;
        pendingImageBytes.value = null;
      }

      // Save phone number
      await _service.updateStudentPhone(
          student.value!.id, phoneController.text);

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), duration: const Duration(seconds: 6));
    } finally {
      isSaving.value = false;
    }
  }
}
