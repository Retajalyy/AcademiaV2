import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../services/add_user_service.dart';

enum UserType { student, professor, admin }

class AddUserController extends GetxController {
  final AddUserService _service = AddUserService();

  // ── Type selection ────────────────────────────────────────────────────────
  final Rx<UserType> selectedType = UserType.student.obs;

  // ── Shared ────────────────────────────────────────────────────────────────
  final isLoading = false.obs;

  // ── Professor / Admin form controllers ────────────────────────────────────
  final fname    = TextEditingController();
  final lname    = TextEditingController();
  final uniId    = TextEditingController();
  final email    = TextEditingController();
  final phone    = TextEditingController();
  final password = TextEditingController();
  final jobTitle = TextEditingController(); // admin only
  final RxBool   obscurePassword = true.obs;

  // ── Professor academic info ───────────────────────────────────────────────
  final RxList<Map<String, String>> faculties    = <Map<String, String>>[].obs;
  final RxString selectedFaculty = ''.obs;
  final RxBool   isTA            = false.obs; // false = Professor, true = T.A.

  // ── CSV (student) ─────────────────────────────────────────────────────────
  final RxString csvFileName    = ''.obs;
  final RxString csvContent     = ''.obs;
  final RxString csvResultMsg   = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFaculties();
  }

  @override
  void onClose() {
    fname.dispose();
    lname.dispose();
    uniId.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    jobTitle.dispose();
    super.onClose();
  }

  void selectType(UserType t) {
    selectedType.value = t;
    csvResultMsg.value = '';
  }

  void togglePasswordVisibility() => obscurePassword.toggle();

  Future<void> _loadFaculties() async {
    final list = await _service.fetchFaculties();
    faculties.assignAll(list);
    if (list.isNotEmpty) selectedFaculty.value = list.first['code']!;
  }

  // ── Pick CSV / XLSX file ──────────────────────────────────────────────────
  Future<void> pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;

      csvFileName.value = file.name;
      csvResultMsg.value = '';

      final ext = (file.extension ?? '').toLowerCase();
      if (ext == 'xlsx' || ext == 'xls') {
        csvContent.value = _xlsxToCsv(bytes);
      } else {
        // Strip UTF-8 BOM (﻿) that Excel adds when saving as CSV
        var text = String.fromCharCodes(bytes);
        if (text.startsWith('﻿')) text = text.substring(1);
        csvContent.value = text;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not open file: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Converts the first sheet of an xlsx file into a CSV string.
  String _xlsxToCsv(List<int> bytes) {
    final excel = Excel.decodeBytes(bytes);
    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName]!;

    final buffer = StringBuffer();
    for (final row in sheet.rows) {
      final cells = row.map((cell) {
        final val = cell?.value?.toString() ?? '';
        // Wrap in quotes if the value contains a comma or quote
        if (val.contains(',') || val.contains('"')) {
          return '"${val.replaceAll('"', '""')}"';
        }
        return val;
      }).join(',');
      buffer.writeln(cells);
    }
    return buffer.toString();
  }

  // ── Submit student CSV ────────────────────────────────────────────────────
  Future<void> submitStudentCsv() async {
    if (csvContent.value.isEmpty) {
      Get.snackbar('No file', 'Please choose a CSV file first.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    csvResultMsg.value = '';
    try {
      final res = await _service.createStudentsFromCsv(csvContent.value);
      csvResultMsg.value =
          '✅ ${res['success']} students added${res['failed']! > 0 ? ', ❌ ${res['failed']} failed' : ''}';
    } catch (e) {
      csvResultMsg.value = '❌ Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Submit professor ──────────────────────────────────────────────────────
  Future<void> submitProfessor() async {
    if (!_validateCommon()) return;
    isLoading.value = true;
    try {
      await _service.createProfessor(
        fname:      fname.text.trim(),
        lname:      lname.text.trim(),
        uniId:      uniId.text.trim(),
        email:      email.text.trim(),
        password:   password.text.trim(),
        phone:      phone.text.trim(),
        department: selectedFaculty.value,
        isTA:       isTA.value,
      );
      _clearForm();
      Get.snackbar('Success',
          '${isTA.value ? 'Teaching Assistant' : 'Professor'} added successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900);
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Submit admin ──────────────────────────────────────────────────────────
  Future<void> submitAdmin() async {
    if (!_validateCommon()) return;
    isLoading.value = true;
    try {
      await _service.createAdmin(
        fname:    fname.text.trim(),
        lname:    lname.text.trim(),
        uniId:    uniId.text.trim(),
        email:    email.text.trim(),
        password: password.text.trim(),
        phone:    phone.text.trim(),
        jobTitle: jobTitle.text.trim(),
      );
      _clearForm();
      Get.snackbar('Success', 'Admin added successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900);
    } catch (e) {
      Get.snackbar('Error', 'Failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateCommon() {
    if (fname.text.trim().isEmpty || lname.text.trim().isEmpty ||
        uniId.text.trim().isEmpty || email.text.trim().isEmpty) {
      Get.snackbar('Missing fields', 'Please fill in all required fields.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (password.text.trim().length < 6) {
      Get.snackbar('Weak password', 'Password must be at least 6 characters.',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  void _clearForm() {
    fname.clear(); lname.clear(); uniId.clear();
    email.clear(); phone.clear(); password.clear(); jobTitle.clear();
  }
}
