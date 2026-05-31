import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/faculty_admin_model.dart';
import '../services/faculties_admin_service.dart';

class FacultiesAdminController extends GetxController {
  final FacultiesAdminService _service = FacultiesAdminService();
  final _db = Supabase.instance.client;

  final RxList<FacultyAdminModel> allFaculties = <FacultyAdminModel>[].obs;
  final RxList<FacultyAdminModel> filtered     = <FacultyAdminModel>[].obs;
  final RxBool   isLoading   = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString yearLabel   = ''.obs;

  int get totalMajors => allFaculties.fold(0, (sum, f) => sum + f.majorNames.length);

  @override
  void onInit() {
    super.onInit();
    _load();
    ever(searchQuery, (_) => _applyFilter());
  }

  Future<void> _load() async {
    if (isClosed) return;
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.fetchFaculties(),
        _db
            .from('registration_windows')
            .select('next_semester_label')
            .order('id', ascending: false)
            .limit(1)
            .maybeSingle()
            .catchError((_) => null),
      ]);

      if (isClosed) return;

      allFaculties.assignAll(results[0] as List<FacultyAdminModel>);
      final window = results[1] as Map<String, dynamic>?;
      yearLabel.value = window?['next_semester_label'] as String? ?? '';
      _applyFilter();
    } catch (e) {
      if (isClosed) return;
      Get.snackbar('Error', 'Failed to load faculties: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void _applyFilter() {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) {
      filtered.assignAll(allFaculties);
      return;
    }
    filtered.assignAll(allFaculties.where((f) =>
      f.name.toLowerCase().contains(q) ||
      f.majorNames.any((m) => m.toLowerCase().contains(q)),
    ));
  }

  void onSearch(String q) => searchQuery.value = q;

  @override
  Future<void> refresh() => _load();
}
