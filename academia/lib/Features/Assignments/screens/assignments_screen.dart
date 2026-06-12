import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:academia/Core/utilities/colors.dart';
import '../models/assignment_model.dart';
import '../services/assignments_service.dart';

// ── Controller ────────────────────────────────────────────────────────────────

class AssignmentsController extends GetxController {
  final _service = AssignmentsService();

  final assignments   = <AssignmentModel>[].obs;
  final isLoading     = true.obs;
  final errorMessage  = RxnString();
  final filter        = 'all'.obs;
  final isSubmitting  = false.obs;

  // selected file per assignment id
  final selectedPaths = <int, String>{}.obs;
  final selectedNames = <int, String>{}.obs;

  late final int sectionId;
  late final int courseId;
  late int _studentId;

  List<AssignmentModel> get filtered {
    if (filter.value == 'all') return assignments.toList();
    return assignments.where((a) => a.status == filter.value).toList();
  }

  int get totalCount   => assignments.length;
  int get pendingCount => assignments.where((a) => a.isPending).length;
  int get handedCount  => assignments.where((a) => a.isHanded).length;
  int get missedCount  => assignments.where((a) => a.isMissed).length;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    sectionId  = args?['sectionId'] as int? ?? 0;
    courseId   = args?['courseId']  as int? ?? 0;
    _init();
  }

  Future<void> _init() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final uid  = Supabase.instance.client.auth.currentUser!.id;
      _studentId = await _service.getStudentId(uid);
      assignments.value =
          await _service.getAssignments(sectionId, _studentId, courseId: courseId);
    } catch (_) {
      assignments.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFile(int assignmentId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'zip'],
    );
    if (result != null && result.files.single.path != null) {
      selectedPaths[assignmentId] = result.files.single.path!;
      selectedNames[assignmentId] = result.files.single.name;
    }
  }

  Future<void> submit(int assignmentId) async {
    final path = selectedPaths[assignmentId];
    final name = selectedNames[assignmentId];
    if (path == null) {
      Get.snackbar('No file selected', 'Please attach a file first',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
      return;
    }
    isSubmitting.value = true;
    try {
      final item = assignments.firstWhere((a) => a.id == assignmentId);
      await _service.submitAssignment(
        assignmentId: assignmentId,
        studentId:    _studentId,
        filePath:     path,
        fileName:     name!,
        isMaterial:   item.isMaterial,
      );
      selectedPaths.remove(assignmentId);
      selectedNames.remove(assignmentId);
      await _init();
      Get.snackbar('Submitted!', 'Assignment submitted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade500,
          colorText: Colors.white);
    } catch (_) {
      Get.snackbar('Error', 'Failed to submit. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AssignmentsController());
    final args       = Get.arguments as Map<String, dynamic>?;
    final courseName = args?['courseName'] as String? ?? '';
    final doctorName = args?['doctorName'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          _Header(courseName: courseName, doctorName: doctorName),
          _StatCards(c: c),
          _FilterBar(c: c),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.secondaryYellow),
                );
              }
              final items = c.filtered;
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 14),
                      Text(
                        'No assignments yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Assignments for this course\nwill appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: c._init,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: items.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Obx(() => Text(
                              '${c.assignments.length} SESSIONS',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            )),
                      );
                    }
                    return _AssignmentCard(item: items[i - 1], c: c);
                  },
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
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back row
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
                'Assignments',
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

// ── Stat cards ────────────────────────────────────────────────────────────────

class _StatCards extends StatelessWidget {
  final AssignmentsController c;
  const _StatCards({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              _Card(label: 'Total',   value: c.totalCount,   color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              _Card(label: 'Pending', value: c.pendingCount, color: const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _Card(label: 'Handed',  value: c.handedCount,  color: const Color(0xFF16A34A)),
              const SizedBox(width: 8),
              _Card(label: 'Missed',  value: c.missedCount,  color: const Color(0xFFDC2626)),
            ],
          ),
        ));
  }
}

class _Card extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Card({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final AssignmentsController c;
  const _FilterBar({required this.c});

  static const _filters = ['all', 'handed', 'missed', 'pending'];
  static const _labels  = ['All', 'Handed', 'Missed', 'Pending'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() => Row(
            children: List.generate(_filters.length, (i) {
              final selected = c.filter.value == _filters[i];
              return Padding(
                padding: EdgeInsets.only(right: i < _filters.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => c.filter.value = _filters[i],
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBlue
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          )),
    );
  }
}

// ── Assignment card ───────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel item;
  final AssignmentsController c;
  const _AssignmentCard({required this.item, required this.c});

  static const _pendingColor = Color(0xFFF59E0B);
  static const _handedColor  = Color(0xFF16A34A);
  static const _missedColor  = Color(0xFFDC2626);

  Color get _borderColor => item.isPending
      ? _pendingColor
      : item.isHanded
          ? _handedColor
          : _missedColor;

  Color get _iconBg => item.isPending
      ? const Color(0xFFFEF3C7)
      : item.isHanded
          ? const Color(0xFFDCFCE7)
          : const Color(0xFFFEE2E2);

  Color get _badgeBg => item.isPending
      ? const Color(0xFFFEF3C7)
      : item.isHanded
          ? const Color(0xFFDCFCE7)
          : const Color(0xFFFEE2E2);

  String get _badgeLabel => item.isPending
      ? 'Pending'
      : item.isHanded
          ? 'Handed'
          : 'Missed';

  String get _dateLabel => item.isPending
      ? 'Due ${item.formattedDueDate}'
      : 'Submitted ${item.formattedSubmitDate}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: _borderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit_outlined,
                      color: _borderColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          )),
                      const SizedBox(height: 2),
                      Text(_dateLabel,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_badgeLabel,
                      style: TextStyle(
                        color: _borderColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // ── Bottom section ────────────────────────────────────────────
          if (item.isPending)
            _PendingBottom(item: item, c: c)
          else
            _GradeBottom(item: item, color: _borderColor),
        ],
      ),
    );
  }
}

// ── Pending bottom ────────────────────────────────────────────────────────────

class _PendingBottom extends StatelessWidget {
  final AssignmentModel item;
  final AssignmentsController c;
  const _PendingBottom({required this.item, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Not submitted yet',
                  style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontStyle: FontStyle.italic)),
              Text(
                '${item.daysLeft > 0 ? item.daysLeft : 0} days left',
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // View assignment file (professor-uploaded)
          if (item.materialFileUrl != null && item.materialFileUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () async {
                  final uri = Uri.tryParse(item.materialFileUrl!);
                  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.description_outlined,
                          size: 20, color: AppColors.primaryBlue),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('View Assignment',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            )),
                      ),
                      Icon(Icons.open_in_new_rounded,
                          size: 16, color: AppColors.primaryBlue),
                    ],
                  ),
                ),
              ),
            ),

          // File attach area
          Obx(() {
            final path = c.selectedPaths[item.id];
            final name = c.selectedNames[item.id];
            return GestureDetector(
              onTap: () => c.pickFile(item.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.grey.shade300, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file_rounded,
                        size: 20, color: Colors.grey.shade400),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            path != null ? name! : 'Attach your file',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: path != null
                                  ? AppColors.primaryBlue
                                  : Colors.grey.shade600,
                            ),
                          ),
                          if (path == null)
                            Text('PDF, DOCX, ZIP supported',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primaryBlue, width: 1.2),
                      ),
                      child: Text('Browse',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),

          // Submit button
          Obx(() => SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: c.isSubmitting.value
                      ? null
                      : () => c.submit(item.id),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppColors.primaryBlue, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: c.isSubmitting.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBlue))
                      : const Text('Submit Assignment',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          )),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Grade bottom ──────────────────────────────────────────────────────────────

class _GradeBottom extends StatelessWidget {
  final AssignmentModel item;
  final Color color;
  const _GradeBottom({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    final grade   = item.grade ?? 0;
    final max     = item.maxGrade;
    final percent = item.gradePercent;
    final pctLabel = '${(percent * 100).toStringAsFixed(0)}%';

    // No grade assigned yet — just confirm submission
    if (max == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              item.isHanded
                  ? 'Submitted ${item.formattedSubmitDate}'
                  : 'Not submitted — grade pending',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Row(
        children: [
          Text('Grade ',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13)),
          Text(
            grade.toStringAsFixed(grade.truncateToDouble() == grade ? 0 : 1),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(' / ${max.toStringAsFixed(max.truncateToDouble() == max ? 0 : 1)}',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(pctLabel,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
