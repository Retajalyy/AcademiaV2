import 'package:get/get.dart';
import '../services/professor_service.dart';

class ProfessorExamEntry {
  final int    id;
  final String courseName;
  final String examType;
  final DateTime examDate;
  final String startTime;
  final String endTime;
  final String room;
  final String? level;
  final List<String> groups;

  ProfessorExamEntry({
    required this.id,
    required this.courseName,
    required this.examType,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.level,
    required this.groups,
  });

  int get daysUntil {
    final today   = DateTime.now();
    final todayD  = DateTime(today.year, today.month, today.day);
    final examD   = DateTime(examDate.year, examDate.month, examDate.day);
    return examD.difference(todayD).inDays;
  }

  bool get isPast => daysUntil < 0;

  String get formattedDate {
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['','Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'];
    final weekday = days[examDate.weekday - 1];
    return '$weekday, ${months[examDate.month]} ${examDate.day}';
  }

  String get formattedTime {
    return '${_fmt(startTime)} – ${_fmt(endTime)}';
  }

  static String _fmt(String raw) {
    try {
      final parts = raw.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1].padLeft(2, '0');
      return '${h.toString().padLeft(2,'0')}:$m';
    } catch (_) {
      return raw;
    }
  }

  factory ProfessorExamEntry.fromMap(Map<String, dynamic> row) {
    return ProfessorExamEntry(
      id:         row['id'] as int,
      courseName: row['course_name'] as String? ?? '',
      examType:   row['exam_type']   as String? ?? 'Exam',
      examDate:   DateTime.parse(row['exam_date'] as String),
      startTime:  row['start_time']  as String? ?? '',
      endTime:    row['end_time']    as String? ?? '',
      room:       row['room']        as String? ?? '',
      level:      row['level']       as String?,
      groups:     (row['groups'] as List?)?.cast<String>() ?? [],
    );
  }
}

class ProfessorExamScheduleController extends GetxController {
  final _service = ProfessorService();

  late final int  professorId;
  late final bool isTA;

  final exams     = <ProfessorExamEntry>[].obs;
  final isLoading = true.obs;
  final error     = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    professorId = args['professorId'] as int? ?? 0;
    isTA        = args['isTA']        as bool? ?? false;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final rows = await _service.fetchProfessorExamSchedule(
          professorId, isTA: isTA);
      exams.value = rows.map(ProfessorExamEntry.fromMap).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _load();

  List<ProfessorExamEntry> get upcoming =>
      exams.where((e) => !e.isPast).toList();
  List<ProfessorExamEntry> get past =>
      exams.where((e) => e.isPast).toList();
}
