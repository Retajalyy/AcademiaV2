import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../model/exam_result_model.dart';
import '../service/exam_results_service.dart';

class ResultDetailSheet extends StatefulWidget {
  final ExamResultModel result;
  const ResultDetailSheet({super.key, required this.result});

  static void show(ExamResultModel result) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResultDetailSheet(result: result),
    );
  }

  @override
  State<ResultDetailSheet> createState() => _ResultDetailSheetState();
}

class _ResultDetailSheetState extends State<ResultDetailSheet> {
  final _service = ExamResultsService();
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.fetchUploadDetail(widget.result.semesterId);
      if (mounted) setState(() { _rows = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize:     0.50,
      maxChildSize:     0.95,
      expand: false,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Handle ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.semester.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _HeaderChip('${r.studentsCount} students'),
                      const SizedBox(width: 8),
                      _HeaderChip('${r.passRate.toInt()}% pass'),
                      const SizedBox(width: 8),
                      _HeaderChip('GPA ${r.avgGpa.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red)))
                      : _rows.isEmpty
                          ? Center(
                              child: Text('No student records found',
                                  style: TextStyle(color: Colors.grey.shade500)))
                          : ListView.builder(
                              controller: scroll,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                              itemCount: _rows.length,
                              itemBuilder: (_, i) =>
                                  _StudentCard(row: _rows[i]),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header chip ───────────────────────────────────────────────────────────────

class _HeaderChip extends StatelessWidget {
  final String label;
  const _HeaderChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

// ── Student card ──────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const _StudentCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final student  = row['students']  as Map<String, dynamic>? ?? {};
    final profile  = student['profiles'] as Map<String, dynamic>? ?? {};
    final uniId    = profile['uni_id'] as String? ?? '—';
    final name     = '${profile['fname'] ?? ''} ${profile['lname'] ?? ''}'.trim();
    final gpa      = (row['gpa'] as num?)?.toDouble() ?? 0.0;
    final courses  = (row['course_results'] as List?) ?? [];
    final gpaColor = gpa >= 2.0 ? const Color(0xFF1B8A4B) : Colors.red.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue)),
                      const SizedBox(height: 2),
                      Text(uniId,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gpaColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'GPA ${gpa.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: gpaColor),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.shade100),

          // Course rows
          ...courses.map((c) => _CourseRow(course: c as Map<String, dynamic>)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Course row ────────────────────────────────────────────────────────────────

class _CourseRow extends StatelessWidget {
  final Map<String, dynamic> course;
  const _CourseRow({required this.course});

  @override
  Widget build(BuildContext context) {
    final name   = course['course_name'] as String? ?? '';
    final grade  = course['grade']       as int?    ?? 0;
    final letter = course['letter']      as String? ?? 'F';
    final isPassing = grade >= 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: const TextStyle(fontSize: 12, color: Color(0xFF333333))),
          ),
          Text('$grade',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPassing ? Colors.grey.shade700 : Colors.red.shade600)),
          const SizedBox(width: 10),
          Container(
            width: 32,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: isPassing
                  ? AppColors.primaryBlue.withOpacity(0.08)
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(letter,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isPassing
                        ? AppColors.primaryBlue
                        : Colors.red.shade600)),
          ),
        ],
      ),
    );
  }
}
