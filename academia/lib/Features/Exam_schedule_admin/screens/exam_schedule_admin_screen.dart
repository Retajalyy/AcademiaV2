import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';
import '../controller/exam_schedule_admin_controller.dart';
import '../model/exam_schedule_admin_model.dart';

class ExamScheduleAdminScreen extends StatelessWidget {
  const ExamScheduleAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ExamScheduleAdminController>()) {
      Get.put(ExamScheduleAdminController(), permanent: true);
    }
    final c = Get.find<ExamScheduleAdminController>();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      drawer: const SideMenu(activeItem: 'Exam Schedule'),
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: Obx(() {
                  if (c.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (c.errorMsg.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(c.errorMsg.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: c.loadData,
                              child: const Text('Retry')),
                        ],
                      ),
                    );
                  }
                  if (c.published.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_note_outlined,
                              size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('No exam schedules published yet',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 15)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: c.published.length,
                    itemBuilder: (_, i) =>
                        _ExamEntryCard(entry: c.published[i]),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _AddExamSheet.show(context),
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        color: AppColors.primaryBlue,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
            const SizedBox(width: 4),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exam Schedule',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('Publish exams for enrolled students',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exam Entry Card ───────────────────────────────────────────────────────────

class _ExamEntryCard extends StatelessWidget {
  final ExamScheduleEntry entry;
  const _ExamEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateStr = _fmtDate(entry.examDate);
    final isOverdue = _isPast(entry.examDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: entry.examType == 'Final'
                ? const Color(0xFFE67E22)
                : AppColors.primaryBlue,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(entry.courseName,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2A4A))),
                ),
                _Badge(label: entry.examType),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.calendar_today_outlined, label: dateStr),
            const SizedBox(height: 4),
            _InfoRow(
                icon: Icons.access_time_outlined,
                label: '${entry.startTime} - ${entry.endTime}'),
            const SizedBox(height: 4),
            _InfoRow(
                icon: Icons.room_outlined,
                label: entry.room.isNotEmpty ? entry.room : '—'),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.group_outlined,
              label: '${entry.studentCount} student${entry.studentCount == 1 ? '' : 's'}',
            ),
            if (isOverdue) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 13, color: Colors.red.shade400),
                  const SizedBox(width: 4),
                  Text('Exam date passed',
                      style: TextStyle(
                          fontSize: 11, color: Colors.red.shade400)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _fmtDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      const m = ['','Jan','Feb','Mar','Apr','May','Jun',
                     'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month]} ${d.day}, ${d.year}';
    } catch (_) {
      return raw;
    }
  }

  static bool _isPast(String raw) {
    try {
      final d = DateTime.parse(raw);
      return d.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final isFinal = label == 'Final';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: isFinal
            ? const Color(0xFFFBE9E7)
            : const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isFinal
              ? const Color(0xFFBF360C)
              : AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}

// ── Add Exam Sheet ────────────────────────────────────────────────────────────

class _AddExamSheet extends StatelessWidget {
  const _AddExamSheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddExamSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExamScheduleAdminController>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final roomCtrl = TextEditingController(text: c.room.value);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Publish Exam Schedule',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset),
                children: [
                  // Section
                  _Label('SECTION / COURSE'),
                  const SizedBox(height: 8),
                  Obx(() => Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SectionOption>(
                            value: c.selectedSection.value,
                            isExpanded: true,
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text('Select section',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ),
                            items: c.sections
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        child: Text(s.displayLabel,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) => c.selectedSection.value = v,
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Exam type
                  _Label('EXAM TYPE'),
                  const SizedBox(height: 8),
                  Obx(() => Row(
                        children: c.examTypes.map((t) {
                          final sel = c.examType.value == t;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => c.examType.value = t,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppColors.primaryBlue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: sel
                                        ? AppColors.primaryBlue
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Center(
                                  child: Text(t,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: sel
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      )),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )),
                  const SizedBox(height: 16),

                  // Date
                  _Label('EXAM DATE'),
                  const SizedBox(height: 8),
                  Obx(() => GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) c.examDate.value = picked;
                        },
                        child: _FieldBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c.formattedExamDate,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: c.examDate.value == null
                                          ? Colors.grey
                                          : Colors.black)),
                              const Icon(Icons.calendar_today_outlined,
                                  size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),

                  // Time row
                  _Label('TIME'),
                  const SizedBox(height: 8),
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final t = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(
                                        hour: 9, minute: 0));
                                if (t != null) c.startTime.value = t;
                              },
                              child: _FieldBox(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(c.formattedStartTime,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: c.startTime.value == null
                                                ? Colors.grey
                                                : Colors.black)),
                                    const Icon(Icons.access_time,
                                        size: 18, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final t = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(
                                        hour: 11, minute: 0));
                                if (t != null) c.endTime.value = t;
                              },
                              child: _FieldBox(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(c.formattedEndTime,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: c.endTime.value == null
                                                ? Colors.grey
                                                : Colors.black)),
                                    const Icon(Icons.access_time,
                                        size: 18, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 16),

                  // Room
                  _Label('ROOM / HALL'),
                  const SizedBox(height: 8),
                  _FieldBox(
                    child: TextField(
                      controller: roomCtrl,
                      onChanged: (v) => c.room.value = v,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Hall A-201',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit
                  Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              c.isSubmitting.value ? null : c.submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: c.isSubmitting.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Publish',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.6,
        ));
  }
}

class _FieldBox extends StatelessWidget {
  final Widget child;
  const _FieldBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
