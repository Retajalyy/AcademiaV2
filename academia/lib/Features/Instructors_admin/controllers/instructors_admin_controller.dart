import 'package:get/get.dart';
import '../models/instructor_admin_model.dart';
import '../services/instructors_admin_service.dart';

class InstructorsAdminController extends GetxController {
  final InstructorsAdminService _service = InstructorsAdminService();

  final RxList<InstructorAdminModel>  allInstructors = <InstructorAdminModel>[].obs;
  final RxList<InstructorAdminModel>  filtered       = <InstructorAdminModel>[].obs;
  final RxList<Map<String, String>>   faculties      = <Map<String, String>>[].obs;

  final RxString selectedDept  = ''.obs;
  final RxString searchQuery   = ''.obs;
  final RxString sortBy        = ''.obs; // '', 'name', 'role', 'department'
  final RxBool   isLoading     = true.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
    ever(selectedDept, (_) => _applyFilter());
    ever(searchQuery,  (_) => _applyFilter());
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.fetchInstructors(),
        _service.fetchFacultyFilters(),
      ]);
      allInstructors.assignAll(results[0] as List<InstructorAdminModel>);
      faculties.assignAll(results[1] as List<Map<String, String>>);
      _applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load instructors: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    var list = allInstructors.toList();

    if (selectedDept.value.isNotEmpty) {
      list = list.where((i) => i.department == selectedDept.value).toList();
    }

    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((i) =>
        i.name.toLowerCase().contains(q) ||
        i.uniId.toLowerCase().contains(q) ||
        i.department.toLowerCase().contains(q),
      ).toList();
    }

    switch (sortBy.value) {
      case 'name':       list.sort((a, b) => a.name.compareTo(b.name)); break;
      case 'role':       list.sort((a, b) => a.role.compareTo(b.role)); break;
      case 'department': list.sort((a, b) => a.department.compareTo(b.department)); break;
    }

    filtered.assignAll(list);
  }

  void selectDept(String code) {
    selectedDept.value = selectedDept.value == code ? '' : code;
  }

  void onSearch(String q) => searchQuery.value = q;

  void setSortBy(String value) {
    sortBy.value = sortBy.value == value ? '' : value;
    _applyFilter();
  }

  @override
  Future<void> refresh() => _load();
}
