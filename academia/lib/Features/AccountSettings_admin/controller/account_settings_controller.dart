import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/account_settings_model.dart';
import '../service/account_settings_service.dart';

class AccountSettingsController extends GetxController {
  final AccountSettingsService _service = AccountSettingsService();

  final Rx<AccountSettingsModel?> account = Rx(null);
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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

    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (phone.isEmpty || email.isEmpty) {
      Get.snackbar(
        'Validation',
        'Phone and email cannot be empty.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    isSaving.value = true;
    try {
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
        'Could not save changes. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void onChangePhoto() {
    // TODO: integrate image_picker
    Get.snackbar('Coming soon', 'Photo upload will be added here.');
  }
}