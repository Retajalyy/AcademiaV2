import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_admin_model.dart';
import '../services/students_admin_service.dart';

class StudentsAdminController extends GetxController {
  final StudentsAdminService _service = StudentsAdminService();
  final _db = Supabase.instance.client;

  final RxList<StudentAdminModel>    allStudents      = <StudentAdminModel>[].obs;
  final RxList<StudentAdminModel>    filtered         = <StudentAdminModel>[].obs;
  final RxList<Map<String, String>>  faculties        = <Map<String, String>>[].obs;

  final RxString selectedFaculty = ''.obs;
  final RxString searchQuery     = ''.obs;
  final RxString sortBy          = ''.obs; // '', 'level', 'name', 'faculty', 'major'
  final RxBool   isLoading       = true.obs;
  final RxString semesterLabel   = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    ever(selectedFaculty, (_) => _applyFilter());
    ever(searchQuery,     (_) => _applyFilter());
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final students     = await _service.fetchStudents();
      final facultyList  = await _service.fetchFacultyFilters();
      final window       = await _db
          .from('registration_windows')
          .select('next_semester_label, next_year_label')
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

      allStudents.assignAll(students);
      faculties.assignAll(facultyList);
      final semParts = [
        window?['next_semester_label'] as String? ?? '',
        window?['next_year_label']     as String? ?? '',
      ].where((s) => s.isNotEmpty).toList();
      semesterLabel.value = semParts.join(' · ');

      _applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    var list = allStudents.toList();

    // Faculty filter
    if (selectedFaculty.value.isNotEmpty) {
      list = list.where((s) => s.faculty == selectedFaculty.value).toList();
    }

    // Search filter
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((s) =>
        s.name.toLowerCase().contains(q) ||
        s.uniId.toLowerCase().contains(q) ||
        s.major.toLowerCase().contains(q)
      ).toList();
    }

    // Sort
    switch (sortBy.value) {
      case 'level':   list.sort((a, b) => a.level.compareTo(b.level)); break;
      case 'name':    list.sort((a, b) => a.name.compareTo(b.name)); break;
      case 'faculty': list.sort((a, b) => a.faculty.compareTo(b.faculty)); break;
      case 'major':   list.sort((a, b) => a.major.compareTo(b.major)); break;
    }

    filtered.assignAll(list);
  }

  void selectFaculty(String code) {
    selectedFaculty.value = selectedFaculty.value == code ? '' : code;
  }

  void onSearch(String q) => searchQuery.value = q;

  void setSortBy(String value) {
    sortBy.value = sortBy.value == value ? '' : value;
    _applyFilter();
  }

  @override
  Future<void> refresh() => _load();
}
