import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academia/Core/utilities/colors.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class _SessionRecord {
  final int      sessionNum;
  final DateTime date;
  final bool     isPresent;
  final String   sectionType; // 'Lecture' | 'Section'

  const _SessionRecord({
    required this.sessionNum,
    required this.date,
    required this.isPresent,
    required this.sectionType,
  });

  String get dateLabel {
    const days   = ['Monday','Tuesday','Wednesday','Thursday',
                     'Friday','Saturday','Sunday'];
    const months = ['','January','February','March','April','May','June',
                       'July','August','September','October','November','December'];
    return '${days[date.weekday - 1]}, ${months[date.month]} ${date.day}, ${date.year}';
  }
}

class _AttendanceData {
  final List<_SessionRecord> sessions;
  final String semesterLabel;

  const _AttendanceData({required this.sessions, required this.semesterLabel});

  int    get total      => sessions.length;
  int    get present    => sessions.where((s) => s.isPresent).length;
  int    get absent     => total - present;
  double get rate       => total > 0 ? present / total : 0;
  int    get absencesLeft => (4 - absent).clamp(0, 4);
  bool   get isBlocked  => absent > 4;
}

// ── Controller ────────────────────────────────────────────────────────────────

class _AttendanceController extends GetxController {
  final _db = Supabase.instance.client;

  final isLoading = true.obs;
  final data      = Rxn<_AttendanceData>();

  late final int    sectionId;
  late final int    _studentId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    sectionId  = args?['sectionId'] as int? ?? 0;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      final uid = _db.auth.currentUser!.id;
      final sRow = await _db
          .from('students')
          .select('id')
          .eq('profile_id', uid)
          .single();
      _studentId = sRow['id'] as int;

      // Get course_id and type from this section
      final secRow = await _db
          .from('sections')
          .select('type, course_id')
          .eq('id', sectionId)
          .maybeSingle();
      final secType  = (secRow?['type']      as String? ?? 'Lecture');
      final courseId = secRow?['course_id']  as int?;

      // Collect ALL section_ids for this course so we match the professor's
      // section regardless of which section the student enrolled through
      List<int> allSectionIds = [sectionId];
      if (courseId != null) {
        final allSecs = await _db
            .from('sections')
            .select('id')
            .eq('course_id', courseId);
        final ids = (allSecs as List).map((s) => s['id'] as int).toList();
        if (ids.isNotEmpty) allSectionIds = ids;
      }

      // All sessions for ANY section of this course
      final sessionsRaw = await _db
          .from('attendance_sessions')
          .select('id, session_num, session_date, section_id')
          .inFilter('section_id', allSectionIds)
          .order('session_date', ascending: false);

      final sessionsList = sessionsRaw as List;
      if (sessionsList.isEmpty) {
        data.value = const _AttendanceData(sessions: [], semesterLabel: '');
        return;
      }

      final sessionIds = sessionsList.map((s) => s['id'] as int).toList();

      // Student's records for these sessions
      final recordsRaw = await _db
          .from('attendance_records')
          .select('session_id, is_present')
          .eq('student_id', _studentId)
          .inFilter('session_id', sessionIds);

      final recordMap = <int, bool>{
        for (final r in recordsRaw as List)
          r['session_id'] as int: r['is_present'] as bool? ?? false
      };

      // Semester label (best-effort)
      String semLabel = '';
      try {
        final winRow = await _db
            .from('registration_group_sections')
            .select('registration_groups(window_id)')
            .eq('section_id', sectionId)
            .limit(1)
            .maybeSingle();
        final windowId = (winRow?['registration_groups']
            as Map?)?['window_id'] as int?;
        if (windowId != null) {
          final win = await _db
              .from('registration_windows')
              .select('next_semester_label, next_year_label')
              .eq('id', windowId)
              .maybeSingle();
          if (win != null) {
            final sem  = win['next_semester_label'] as String? ?? '';
            final year = win['next_year_label']     as String? ?? '';
            semLabel = [sem, year].where((s) => s.isNotEmpty).join(' · ');
          }
        }
      } catch (_) {}

      // Fetch type for all sections so each session shows the right label
      final typeBySection = <int, String>{sectionId: secType};
      if (courseId != null) {
        try {
          final secTypes = await _db
              .from('sections')
              .select('id, type')
              .inFilter('id', allSectionIds);
          for (final s in secTypes as List) {
            typeBySection[s['id'] as int] = s['type'] as String? ?? 'Lecture';
          }
        } catch (_) {}
      }

      final sessions = sessionsList.map((s) {
        final sid    = s['id']         as int;
        final secId  = s['section_id'] as int? ?? sectionId;
        final type   = typeBySection[secId] ?? 'Lecture';
        return _SessionRecord(
          sessionNum:  s['session_num']  as int?    ?? 0,
          date:        DateTime.parse(s['session_date'] as String),
          isPresent:   recordMap[sid]   ?? false,
          sectionType: type,
        );
      }).toList();

      data.value = _AttendanceData(
        sessions:      sessions,
        semesterLabel: semLabel,
      );
    } catch (_) {
      data.value = const _AttendanceData(sessions: [], semesterLabel: '');
    } finally {
      isLoading.value = false;
    }
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c          = Get.put(_AttendanceController());
    final args       = Get.arguments as Map<String, dynamic>?;
    final courseName = args?['courseName'] as String? ?? '';
    final doctorName = args?['doctorName'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          _Header(courseName: courseName, doctorName: doctorName),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.secondaryYellow),
                );
              }
              final d = c.data.value;
              if (d == null || d.total == 0) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy_outlined,
                          size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No attendance records yet',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 15)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: c._load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OverviewCard(d: d),
                      const SizedBox(height: 12),
                      if (d.absent > 0) _WarningBox(d: d),
                      if (d.absent > 0) const SizedBox(height: 16),
                      Text(
                        '${d.total} SESSIONS',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...d.sessions.map((s) => _SessionCard(s: s)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String courseName;
  final String doctorName;
  const _Header({required this.courseName, required this.doctorName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: Get.back,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chevron_left,
                        color: Colors.white, size: 20),
                    Text('Course Details',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Attendance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (courseName.isNotEmpty || doctorName.isNotEmpty)
                Text(
                  [courseName, doctorName]
                      .where((s) => s.isNotEmpty)
                      .join(' . '),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Overview card ─────────────────────────────────────────────────────────────

class _OverviewCard extends StatelessWidget {
  final _AttendanceData d;
  const _OverviewCard({required this.d});

  @override
  Widget build(BuildContext context) {
    final rateStr = '${(d.rate * 100).toStringAsFixed(0)}%';
    final subtitle = [
      d.semesterLabel,
      '${d.total} sessions held',
    ].where((s) => s.isNotEmpty).join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryYellow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Attendance Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B4A),
                  ),
                ),
              ],
            ),
          ),
          if (subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                _Stat(
                    value: '${d.present}',
                    label: 'Present',
                    color: const Color(0xFF16A34A)),
                _VerticalDivider(),
                _Stat(
                    value: '${d.absent}',
                    label: 'Absent',
                    color: const Color(0xFFDC2626)),
                _VerticalDivider(),
                _Stat(
                    value: rateStr,
                    label: 'Rate',
                    color: const Color(0xFFD97706)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color  color;
  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              )),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: Colors.grey.shade200);
}

// ── Warning box ───────────────────────────────────────────────────────────────

class _WarningBox extends StatelessWidget {
  final _AttendanceData d;
  const _WarningBox({required this.d});

  @override
  Widget build(BuildContext context) {
    final text = d.isBlocked
        ? 'You have exceeded the maximum absences and may be blocked from the final exam.'
        : 'You have ${d.absent} absence${d.absent == 1 ? '' : 's'}. You can miss '
          '${d.absencesLeft} more before being blocked from the final exam.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFD97706), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              _buildRichText(text, d),
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF92400E), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildRichText(String text, _AttendanceData d) {
    final boldStyle = const TextStyle(fontWeight: FontWeight.bold);
    return TextSpan(
      children: [
        TextSpan(text: 'You have '),
        TextSpan(
            text: '${d.absent} absence${d.absent == 1 ? '' : 's'}',
            style: boldStyle),
        TextSpan(text: '. You can miss '),
        TextSpan(
            text: '${d.absencesLeft} more',
            style: boldStyle),
        const TextSpan(
            text: ' before being blocked from the final exam.'),
      ],
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final _SessionRecord s;
  const _SessionCard({required this.s});

  @override
  Widget build(BuildContext context) {
    final color = s.isPresent
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
    final badgeBg = s.isPresent
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.sectionType} ${s.sessionNum}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2B4A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.dateLabel,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s.isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
