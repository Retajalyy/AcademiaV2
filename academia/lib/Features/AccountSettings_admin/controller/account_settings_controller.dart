import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../model/account_settings_model.dart';
import '../service/account_settings_service.dart';

class AccountSettingsController extends GetxController {
  final AccountSettingsService _service = AccountSettingsService();
  final _picker = ImagePicker();

  final Rx<AccountSettingsModel?> account = Rx(null);
  final RxBool isLoading = true.obs;
  final RxBool isSaving  = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Locally-staged avatar (before save)
  final pendingImageBytes = Rxn<Uint8List>();
  String _pendingImageExt = 'jpg';

  @override
  void onInit() {
    super.onInit();
    loadAccount();
  }

  @override
  void onClose() {
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> loadAccount() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _service.fetchAccountSettings();
      account.value = data;
      phoneController.text = data.phone;
      emailController.text = data.personalEmail;
    } catch (e) {
      errorMessage.value = 'Failed to load account settings.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveChanges() async {
    if (isSaving.value) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (phone.isEmpty) {
      Get.snackbar(
        'Validation',
        'Phone cannot be empty.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    isSaving.value = true;
    try {
      // Upload avatar first if one was picked
      if (pendingImageBytes.value != null) {
        final newUrl = await _service.uploadAvatar(
            pendingImageBytes.value!, _pendingImageExt);
        PaintingBinding.instance.imageCache.clear();
        account.value = account.value?.copyWith(photoPath: newUrl);
        pendingImageBytes.value = null;
      }

      final success = await _service.saveAccountSettings(
        phone: phone,
        personalEmail: email,
      );

      if (success) {
        account.value = account.value?.copyWith(
          phone: phone,
          personalEmail: email,
        );
        Get.snackbar(
          'Saved',
          'Account settings updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 8),
      );
    } finally {
      isSaving.value = false;
    }
  }

  void onChangePhoto(BuildContext context) {
    final hasPhoto =
        pendingImageBytes.value != null || account.value?.photoPath != null;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _pickAndCrop();
            },
            child: Text(hasPhoto ? 'Change Photo' : 'Choose from Library'),
          ),
          if (hasPhoto)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(ctx);
                _removePhoto();
              },
              child: const Text('Remove Photo'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _pickAndCrop() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 90);
    if (image == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        IOSUiSettings(
          title: 'Crop Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped == null) return;

    pendingImageBytes.value = await cropped.readAsBytes();
    _pendingImageExt = cropped.path.split('.').last.toLowerCase();
  }

  void _removePhoto() {
    pendingImageBytes.value = null;
    account.value = account.value?.copyWith(photoPath: '');
  }
}
