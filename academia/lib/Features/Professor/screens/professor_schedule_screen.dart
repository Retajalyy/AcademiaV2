import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/professor_schedule_controller.dart';
import '../models/professor_schedule_item.dart';

class ProfessorScheduleScreen extends StatelessWidget {
  const ProfessorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfessorScheduleController());

    return Scaffold(
      backgroundColor: AppColors.babyblue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(),
          _DaySelector(c: c),
          Expanded(child: _ClassList(c: c)),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) => Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 26),
      color: AppColors.primaryBlue,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'View and manage all your scheduled classes',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ));
  }
}

// ── Day Selector ──────────────────────────────────────────────────────────────

class _DaySelector extends StatelessWidget {
  final ProfessorScheduleController c;
  const _DaySelector({required this.c});

  static const _labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Obx(() {
        final selected = c.selectedDayIndex.value;
        return Row(
          children: List.generate(_labels.length, (i) {
            final isSelected = i == selected;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => c.selectDay(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? AppColors.secondaryYellow
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    _labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF1A2A4A)
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

// ── Class List ────────────────────────────────────────────────────────────────

class _ClassList extends StatelessWidget {
  final ProfessorScheduleController c;
  const _ClassList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (c.classes.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_available_outlined,
                  size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No classes scheduled',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: c.classes.length,
        itemBuilder: (_, i) => _ClassCard(item: c.classes[i]),
      );
    });
  }
}

// ── Class Card ────────────────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  final ProfessorScheduleItem item;
  const _ClassCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final borderColor = _typeColor(item.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            SizedBox(
              width: 44,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.startTime,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2A4A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.endTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: const Color(0xFFEEEEEE),
            ),

            // Course info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2A4A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TypeBadge(type: item.type),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.room_outlined,
                    label: item.location.isNotEmpty ? item.location : '—',
                  ),
                  if (item.groups.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    _InfoRow(
                      icon: Icons.group_outlined,
                      label: item.groups.join(' · '),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'lecture':
        return AppColors.primaryBlue;
      case 'section':
        return AppColors.secondaryYellow;
      case 'lab':
        return const Color(0xFFE67E22);
      default:
        return AppColors.primaryBlue;
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isLecture = type.toLowerCase() == 'lecture';
    final isSection = type.toLowerCase() == 'section';

    final Color bg;
    final Color text;

    if (isLecture) {
      bg = const Color(0xFFE8F0FE);
      text = const Color(0xFF1A73E8);
    } else if (isSection) {
      bg = const Color(0xFFFFF3E0);
      text = const Color(0xFFF57C00);
    } else {
      bg = const Color(0xFFFBE9E7);
      text = const Color(0xFFBF360C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
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
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
