import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      final data = await _service.fetchStudentProfile();
      student.value = data;
      phoneController.text = data.phone;
      avatarUrl.value = data.avatarUrl;
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
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image == null) return;
    pendingImageBytes.value = await image.readAsBytes();
    _pendingImageExt = image.path.split('.').last.toLowerCase();
  }

  // Save button — uploads image (if picked) + saves phone
  Future<void> updateProfile() async {
    if (student.value == null) return;
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
