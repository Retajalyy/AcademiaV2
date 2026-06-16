import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessorProfileController extends GetxController {
  final _db     = Supabase.instance.client;
  final _picker = ImagePicker();

  // Read-only university info
  var fullName        = ''.obs;
  var instructorId    = ''.obs;
  var department      = ''.obs;
  var universityEmail = ''.obs;
  var academicRole    = ''.obs;
  final avatarUrl     = Rxn<String>();

  // Locally-staged image (before save)
  final pendingImageBytes = Rxn<Uint8List>();
  String _pendingImageExt = 'jpg';

  // Editable personal info
  final phoneCtrl         = TextEditingController();
  final personalEmailCtrl = TextEditingController();

  var isLoading = true.obs;
  var isSaving  = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    personalEmailCtrl.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final userId = _db.auth.currentUser!.id;

      final profile = await _db
          .from('profiles')
          .select('full_name, fname, lname, uni_id, email, avatar_url')
          .eq('id', userId)
          .single();

      final fname = profile['fname'] as String? ?? '';
      final lname = profile['lname'] as String? ?? '';
      fullName.value = (profile['full_name'] as String?)?.isNotEmpty == true
          ? profile['full_name'] as String
          : '$fname $lname'.trim();
      instructorId.value    = profile['uni_id'] as String? ?? '';
      universityEmail.value = profile['email']  as String?
          ?? _db.auth.currentUser!.email ?? '';
      final rawUrl = profile['avatar_url'] as String?;
      if (rawUrl != null && rawUrl.isNotEmpty) {
        avatarUrl.value = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      }

      try {
        final prof = await _db
            .from('professors')
            .select('department, is_ta, phone, personal_email')
            .eq('profile_id', userId)
            .single();

        department.value       = prof['department']     as String? ?? '';
        academicRole.value     = (prof['is_ta'] as bool? ?? false)
            ? 'Teaching Assistant' : 'Professor';
        phoneCtrl.text         = prof['phone']          as String? ?? '';
        personalEmailCtrl.text = prof['personal_email'] as String? ?? '';
      } catch (_) {
        try {
          final prof = await _db
              .from('professors')
              .select('department, is_ta')
              .eq('profile_id', userId)
              .single();
          department.value   = prof['department'] as String? ?? '';
          academicRole.value = (prof['is_ta'] as bool? ?? false)
              ? 'Teaching Assistant' : 'Professor';
        } catch (_) {}
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickProfileImage() async {
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

  void removePhoto() {
    pendingImageBytes.value = null;
    avatarUrl.value = null;
  }

  Future<void> save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    isSaving.value = true;
    try {
      final userId = _db.auth.currentUser!.id;

      if (pendingImageBytes.value != null) {
        final path = 'professors/$userId.$_pendingImageExt';
        await _db.storage.from('avatars').uploadBinary(
          path,
          pendingImageBytes.value!,
          fileOptions:
              FileOptions(contentType: 'image/$_pendingImageExt', upsert: true),
        );
        final baseUrl = _db.storage.from('avatars').getPublicUrl(path);
        await _db
            .from('profiles')
            .update({'avatar_url': baseUrl}).eq('id', userId);
        PaintingBinding.instance.imageCache.clear();
        avatarUrl.value =
            '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        pendingImageBytes.value = null;
      }

      await _db.from('professors').upsert({
        'profile_id':     userId,
        'phone':          phoneCtrl.text.trim(),
        'personal_email': personalEmailCtrl.text.trim(),
      }, onConflict: 'profile_id');

      Get.snackbar(
        'Saved',
        'Personal info updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 8),
      );
    } finally {
      isSaving.value = false;
    }
  }

  String get avatarInitials {
    final parts = fullName.value.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}
