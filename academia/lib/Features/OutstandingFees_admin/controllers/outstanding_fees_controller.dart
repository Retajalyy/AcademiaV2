import 'package:get/get.dart';
import '../models/outstanding_fee_model.dart';
import '../services/outstanding_fees_service.dart';

class OutstandingFeesController extends GetxController {
  final _service = OutstandingFeesService();

  final students        = <OutstandingFeeStudent>[].obs;
  final faculties       = <Map<String, String>>[].obs;
  final isLoading       = true.obs;
  final searchQuery     = ''.obs;
  final selectedFaculty = 'All'.obs;
  final sortByLevel     = false.obs;

  List<OutstandingFeeStudent> get filtered {
    var list = students.toList();

    if (selectedFaculty.value != 'All') {
      list = list.where((s) => s.faculty == selectedFaculty.value).toList();
    }

    final q = searchQuery.value.toLowerCase().trim();
    if (q.isNotEmpty) {
      list = list.where((s) =>
          s.name.toLowerCase().contains(q) ||
          s.uniId.toLowerCase().contains(q) ||
          s.major.toLowerCase().contains(q) ||
          s.groupLabel.toLowerCase().contains(q)).toList();
    }

    if (sortByLevel.value) {
      list.sort((a, b) => a.level.compareTo(b.level));
    }

    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _service.fetchOutstandingFees(),
        _service.fetchFacultyFilters(),
      ]);
      students.value  = results[0] as List<OutstandingFeeStudent>;
      faculties.value = results[1] as List<Map<String, String>>;

      // Auto-send reminders for fees due in ≤10 days that haven't been sent yet
      final toRemind = students
          .where((s) => s.needsReminder)
          .toList();
      if (toRemind.isNotEmpty) {
        _service.sendReminders(toRemind);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
