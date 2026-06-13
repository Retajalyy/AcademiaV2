import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import '../controller/plan_admin_controller.dart';

// ── Static option lists ───────────────────────────────────────────────────────

const _days = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
];

const _halls = [
  'Hall A1', 'Hall A2', 'Hall B1', 'Hall B2',
  'Hall C1', 'Hall C2', 'Lab 01', 'Lab 02',
  'Lab 03', 'Room B3', 'Room C4',
];

List<String> _buildTimes() {
  final list = <String>[];
  for (int h = 8; h <= 20; h++) {
    list.add('${h.toString().padLeft(2, '0')}:00');
    if (h < 20) list.add('${h.toString().padLeft(2, '0')}:30');
  }
  return list;
}

final _times = _buildTimes();

// ── Outer wrapper ─────────────────────────────────────────────────────────────

class GroupFormWidget extends StatelessWidget {
  final VoidCallback? onAddAnotherGroup;
  const GroupFormWidget({super.key, this.onAddAnotherGroup});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PlanAdminController>();

    return Obx(() {
      final courses = c.selectedCourseNames.toList();

      if (courses.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'No courses selected.\nGo back and select at least one course.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.smalltext),
            ),
          ),
        );
      }

      final activeIdx   = c.activeGroupIndex.value;
      final groupCount  = c.groupAssignments.length;

      return Column(
        children: [
          // ── Group tabs ───────────────────────────────────────────────
          if (groupCount > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < groupCount; i++)
                    GestureDetector(
                      onTap: () => c.switchGroup(i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8, bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: i == activeIdx
                              ? AppColors.primaryBlue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: i == activeIdx
                                ? AppColors.primaryBlue
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          c.groupLabel(i),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: i == activeIdx
                                ? Colors.white
                                : AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ── Group header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Text(
              'Group – ${c.groupLabel(activeIdx)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),

          // ── Course cards ─────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                // One card per selected course
                for (int i = 0; i < courses.length; i++) ...[
                  _CourseCard(courseName: courses[i]),
                  if (i < courses.length - 1)
                    Divider(color: Colors.grey.shade200, height: 1),
                ],

                // ── Capacity ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('GROUP CAPACITY'),
                      const SizedBox(height: 10),
                      Obx(() => Row(
                            children: [
                              _capBtn(Icons.remove, c.decrementCapacity),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.babyblue,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0x12000000)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${c.groupCapacity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _capBtn(Icons.add, c.incrementCapacity),
                            ],
                          )),
                    ],
                  ),
                ),

                // ── Add another group button ──────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onAddAnotherGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                      ),
                      child: const Text(
                        'Add Another Group',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _capBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: const Color(0x12000000)),
          ),
          child: Icon(icon, size: 18, color: Colors.black),
        ),
      );
}

// ── Per-course card (StatefulWidget to avoid Obx/dropdown conflicts) ──────────

class _CourseCard extends StatefulWidget {
  final String courseName;
  const _CourseCard({required this.courseName});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  late final PlanAdminController _c;

  bool    _hasSection        = false;

  int?    _lectureProfId;
  String? _lectureDay;
  String? _lectureHall;
  String? _lectureFrom;
  String? _lectureTo;

  int?    _sectionProfId;
  String? _sectionDay;
  String? _sectionHall;
  String? _sectionFrom;
  String? _sectionTo;

  @override
  void initState() {
    super.initState();
    _c = Get.find<PlanAdminController>();
    // Restore from the current group's saved state
    final a = _c.assignments[widget.courseName];
    if (a != null) {
      _hasSection      = a.hasSection;
      _lectureProfId   = a.lectureProfessorId;
      _lectureDay      = a.lectureDay;
      _lectureHall     = a.lectureHall;
      _lectureFrom     = a.lectureFrom;
      _lectureTo       = a.lectureTo;
      _sectionProfId   = a.sectionProfessorId;
      _sectionDay      = a.sectionDay;
      _sectionHall     = a.sectionHall;
      _sectionFrom     = a.sectionFrom;
      _sectionTo       = a.sectionTo;
    }
  }

  void _update(VoidCallback update) {
    setState(update);
    _c.setLectureProfessor(widget.courseName, _lectureProfId);
    _c.setLectureDay(widget.courseName, _lectureDay);
    _c.setLectureHall(widget.courseName, _lectureHall);
    _c.setLectureFrom(widget.courseName, _lectureFrom);
    _c.setLectureTo(widget.courseName, _lectureTo);
    // Section is active if a section professor is assigned
    _c.toggleSection(widget.courseName, _sectionProfId != null);
    _c.setSectionProfessor(widget.courseName, _sectionProfId);
    _c.setSectionDay(widget.courseName, _sectionDay);
    _c.setSectionHall(widget.courseName, _sectionHall);
    _c.setSectionFrom(widget.courseName, _sectionFrom);
    _c.setSectionTo(widget.courseName, _sectionTo);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course title row
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bluegroundicon,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book_outlined,
                    size: 18, color: AppColors.accentProgramming1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.courseName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),

          const Divider(height: 20, color: Color(0xffE6E6E6)),

          // ── LECTURE / SECTION exclusive tabs ─────────────────────────
          Row(
            children: [
              Expanded(child: _toggleBtn('LECTURE', !_hasSection, () {
                _update(() => _hasSection = false);
              })),
              const SizedBox(width: 10),
              Expanded(child: _toggleBtn('SECTION', _hasSection, () {
                _update(() => _hasSection = true);
              })),
            ],
          ),

          const SizedBox(height: 14),

          // ── Show ONLY the active tab's fields ─────────────────────────
          if (!_hasSection) ...[
            // ── LECTURE fields ──────────────────────────────────────────
            _label('PROFESSOR'),
            const SizedBox(height: 6),
            Obx(() {
              final profs = _c.professors.toList();
              return _dropdown<int>(
                value: profs.any((p) => p.id == _lectureProfId)
                    ? _lectureProfId
                    : null,
                hint: profs.isEmpty ? 'Loading professors...' : 'Select professor',
                items: profs
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: profs.isEmpty
                    ? null
                    : (v) => _update(() => _lectureProfId = v),
              );
            }),

            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _label('DAY')),
              const SizedBox(width: 10),
              Expanded(child: _label('HALL')),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _strDropdown(
                value: _lectureDay, items: _days, hint: 'Day',
                onChanged: (v) => _update(() => _lectureDay = v),
              )),
              const SizedBox(width: 10),
              Expanded(child: _strDropdown(
                value: _lectureHall, items: _halls, hint: 'Hall',
                onChanged: (v) => _update(() => _lectureHall = v),
              )),
            ]),

            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _label('FROM')),
              const SizedBox(width: 10),
              Expanded(child: _label('TO')),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _strDropdown(
                value: _lectureFrom, items: _times, hint: 'Time',
                onChanged: (v) => _update(() => _lectureFrom = v),
              )),
              const SizedBox(width: 10),
              Expanded(child: _strDropdown(
                value: _lectureTo, items: _times, hint: 'Time',
                onChanged: (v) => _update(() => _lectureTo = v),
              )),
            ]),
          ] else ...[
            // ── SECTION fields ──────────────────────────────────────────
            _label('TEACHING ASSISTANT'),
            const SizedBox(height: 6),
            Obx(() {
              final profs = _c.professors.toList();
              return _dropdown<int>(
                value: profs.any((p) => p.id == _sectionProfId)
                    ? _sectionProfId
                    : null,
                hint: profs.isEmpty ? 'Loading...' : 'Select teaching assistant',
                items: profs
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: profs.isEmpty
                    ? null
                    : (v) => _update(() => _sectionProfId = v),
              );
            }),

            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _label('DAY')),
              const SizedBox(width: 10),
              Expanded(child: _label('HALL')),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _strDropdown(
                value: _sectionDay, items: _days, hint: 'Day',
                onChanged: (v) => _update(() => _sectionDay = v),
              )),
              const SizedBox(width: 10),
              Expanded(child: _strDropdown(
                value: _sectionHall, items: _halls, hint: 'Hall',
                onChanged: (v) => _update(() => _sectionHall = v),
              )),
            ]),

            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _label('FROM')),
              const SizedBox(width: 10),
              Expanded(child: _label('TO')),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _strDropdown(
                value: _sectionFrom, items: _times, hint: 'Time',
                onChanged: (v) => _update(() => _sectionFrom = v),
              )),
              const SizedBox(width: 10),
              Expanded(child: _strDropdown(
                value: _sectionTo, items: _times, hint: 'Time',
                onChanged: (v) => _update(() => _sectionTo = v),
              )),
            ]),
          ],
        ],
      ),
    );
  }

  // ── Small helpers ─────────────────────────────────────────────────────────

  Widget _toggleBtn(String title, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color:
                    active ? AppColors.primaryBlue : Colors.grey.shade300),
          ),
          child: Center(
            child: Text(title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        active ? Colors.white : AppColors.primaryBlue)),
          ),
        ),
      );

  Widget _strDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) =>
      _dropdown<String>(
        value: items.contains(value) ? value : null,
        hint: hint,
        items: items
            .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
        onChanged: onChanged,
      );

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) =>
      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            hint: Text(hint,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF))),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.smalltext, size: 18),
            items: items,
            onChanged: onChanged,
          ),
        ),
      );
}

// ── Shared label ──────────────────────────────────────────────────────────────

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(text,
          style: TextStyles.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.smalltext)),
    );
