import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../models/student_submission_record.dart';
import '../services/professor_service.dart';

class AssignmentOverviewScreen extends StatefulWidget {
  const AssignmentOverviewScreen({super.key});

  @override
  State<AssignmentOverviewScreen> createState() =>
      _AssignmentOverviewScreenState();
}

class _AssignmentOverviewScreenState extends State<AssignmentOverviewScreen> {
  final _service = ProfessorService();

  late final int    materialId;
  late final int    courseId;
  late final int    professorId;
  late final bool   isTA;
  late final String assignmentTitle;
  late final String courseName;
  late final String dueLabel;
  late final DateTime? dueDate;
  late final String materialType;

  List<StudentSubmissionRecord> _all    = [];
  List<String>                  _groups = [];
  String                        _selectedGroup = 'All';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final args   = Get.arguments as Map<String, dynamic>;
    materialId   = args['materialId']  as int;
    courseId     = args['courseId']    as int;
    professorId  = args['professorId'] as int;
    isTA         = args['isTA']        as bool? ?? false;
    assignmentTitle = args['title']    as String? ?? 'Assignment';
    courseName   = args['course']      as String? ?? '';
    dueLabel     = args['badge']       as String? ?? '';
    final dueRaw = args['dueDate']     as String?;
    dueDate      = dueRaw != null ? DateTime.tryParse(dueRaw) : null;
    materialType = args['materialType'] as String? ?? 'Assignment';
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _service.getStudentSubmissionsForAssignment(
        professorId:  professorId,
        courseId:     courseId,
        materialId:   materialId,
        dueDate:      dueDate,
        materialType: materialType,
        isTA:         isTA,
      );

      // Fetch group labels for each student via enrollment
      final labelList = await _service.getGroupLabelsForCourse(
        professorId: professorId,
        courseId:    courseId,
        isTA:        isTA,
      );

      setState(() {
        _all    = list;
        _groups = ['All', ...labelList];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<StudentSubmissionRecord> get _filtered {
    if (_selectedGroup == 'All') return _all;
    // Filter by group — uses studentGroupMap stored in record (future enhancement)
    return _all;
  }

  int get _submittedCount =>
      _all.where((s) => s.status != SubmissionStatus.missing).length;
  int get _missingCount =>
      _all.where((s) => s.status == SubmissionStatus.missing).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.primaryBlue,
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 12, 16, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: Get.back,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_left_rounded,
                          color: Colors.white70, size: 26),
                      Text('Homepage',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(assignmentTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  [courseName, if (dueLabel.isNotEmpty) dueLabel]
                      .join(' · '),
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding:
                          const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      children: [
                        // Stat cards
                        Row(
                          children: [
                            Expanded(
                                child: _StatCard(
                                    value: _submittedCount,
                                    label: 'Submitted',
                                    color: const Color(0xFF16A34A))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _StatCard(
                                    value: _missingCount,
                                    label: 'Missing',
                                    color: const Color(0xFFDC2626))),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Group filter chips
                        if (_groups.length > 1)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _groups.map((g) {
                                final selected = _selectedGroup == g;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedGroup = g),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.primaryBlue
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.primaryBlue
                                              : const Color(0xFFD1D5DB),
                                        ),
                                      ),
                                      child: Text(g,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: selected
                                                  ? Colors.white
                                                  : const Color(
                                                      0xFF6B7280))),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        if (_groups.length > 1) const SizedBox(height: 16),

                        // Student list
                        ..._filtered.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _StudentRow(record: s),
                            )),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final int    value;
  final String label;
  final Color  color;
  const _StatCard(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      );
}

// ── Student Row ───────────────────────────────────────────────────────────────

class _StudentRow extends StatelessWidget {
  final StudentSubmissionRecord record;
  const _StudentRow({required this.record});

  String _fmtDate(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(dt.year, dt.month, dt.day);
    final timeStr =
        '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} '
        '${dt.hour >= 12 ? 'PM' : 'AM'}';
    if (day == today) return 'Today, $timeStr';
    const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                   'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month]} ${dt.day}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final isMissing = record.status == SubmissionStatus.missing;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                record.name.isNotEmpty
                    ? record.name.split(' ').take(2)
                        .map((w) => w[0].toUpperCase())
                        .join()
                    : '?',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2B4A))),
                if (!isMissing && record.submittedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(_fmtDate(record.submittedAt!),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ],
            ),
          ),

          // Status
          Text(
            isMissing ? 'Missing' : 'Done',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isMissing
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A)),
          ),
        ],
      ),
    );
  }
}
