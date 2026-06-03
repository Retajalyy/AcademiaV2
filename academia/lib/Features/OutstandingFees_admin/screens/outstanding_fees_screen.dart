import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controllers/outstanding_fees_controller.dart';
import '../models/outstanding_fee_model.dart';

class OutstandingFeesScreen extends StatefulWidget {
  const OutstandingFeesScreen({super.key});

  @override
  State<OutstandingFeesScreen> createState() => _OutstandingFeesScreenState();
}

class _OutstandingFeesScreenState extends State<OutstandingFeesScreen> {
  late final OutstandingFeesController c;

  @override
  void initState() {
    super.initState();
    Get.delete<OutstandingFeesController>(force: true);
    c = Get.put(OutstandingFeesController());
  }

  @override
  void dispose() {
    Get.delete<OutstandingFeesController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(16, 54, 16, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: Colors.white70, size: 30),
                Text('Dashboard',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 19,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('Outstanding Fees',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Students with unpaid tuition balances',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: TextField(
            onChanged: (v) => c.searchQuery.value = v,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Search Students...',
              hintStyle:
                  const TextStyle(color: Color(0xFF9CA3AF), fontSize: 18),
              prefixIcon: const Icon(Icons.search,
                  color: Color(0xFF9CA3AF), size: 22),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Faculty filter chips
        Obx(() => SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FacultyChip(
                    label: 'All',
                    selected: c.selectedFaculty.value == 'All',
                    onTap: () => c.selectedFaculty.value = 'All',
                  ),
                  ...c.faculties.map((f) => _FacultyChip(
                        label: f['name']!,
                        selected: c.selectedFaculty.value == f['code'],
                        onTap: () => c.selectedFaculty.value = f['code']!,
                      )),
                ],
              ),
            )),

        const SizedBox(height: 2),

        // Count + sort row
        Obx(() {
          final list = c.filtered;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Text(
                  '${list.length} STUDENT${list.length == 1 ? '' : 'S'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => c.sortByLevel.toggle(),
                  child: Row(
                    children: [
                      Icon(Icons.sort_rounded,
                          size: 20,
                          color: c.sortByLevel.value
                              ? AppColors.primaryBlue
                              : const Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(
                        'Sort by Level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.sortByLevel.value
                              ? AppColors.primaryBlue
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        // List
        Expanded(
          child: Obx(() {
            if (c.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryBlue));
            }
            final list = c.filtered;
            if (list.isEmpty) {
              return Center(
                child: Text('No outstanding fees found',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 16)),
              );
            }
            return RefreshIndicator(
              onRefresh: c.loadData,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _StudentFeeCard(student: list[i]),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Faculty chip ──────────────────────────────────────────────────────────────

class _FacultyChip extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;
  const _FacultyChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryBlue
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      );
}

// ── Student fee card ──────────────────────────────────────────────────────────

class _StudentFeeCard extends StatelessWidget {
  final OutstandingFeeStudent student;
  const _StudentFeeCard({required this.student});

  @override
  Widget build(BuildContext context) {
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
        children: [
          // ── Top: avatar + info + badges ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: student.avatarColor,
                  backgroundImage: student.avatarUrl != null
                      ? NetworkImage(student.avatarUrl!)
                      : null,
                  child: student.avatarUrl == null
                      ? Text(student.initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18))
                      : null,
                ),

                const SizedBox(width: 12),

                // Name / ID / major line
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2B4A))),
                      const SizedBox(height: 3),
                      Text('ID: ${student.uniId}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF848282))),
                      const SizedBox(height: 2),
                      Text(
                        '${student.major} . Level ${student.level}'
                        '${student.groupLabel.isNotEmpty ? ' . Group ${student.groupLabel}' : ''}',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF848282)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Faculty + major badges stacked
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Badge(
                      label: student.facultyBadge,
                      bgColor: student.facultyBadgeColor
                          .withValues(alpha: 0.12),
                      textColor: student.facultyBadgeColor,
                    ),
                    const SizedBox(height: 6),
                    _Badge(
                      label: student.majorBadge,
                      bgColor: const Color(0xFFFFF3DF),
                      textColor: const Color(0xFFB18334),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Bottom: amount + due date ───────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: Color(0xFFF3F3F3)),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.credit_card_outlined,
                    color: AppColors.fail, size: 18),
                const SizedBox(width: 6),
                // Expanded pushes due-date to the right while giving
                // the amount text all remaining space — no wrapping
                Expanded(
                  child: Text(
                    student.amountLabel +
                        (student.feeCount > 1
                            ? '  ·  ${student.feeCount} fees'
                            : ''),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.fail),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.access_time_outlined,
                    size: 16, color: Color(0xFF848282)),
                const SizedBox(width: 4),
                Text(
                  student.dueDateStatus,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF848282)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge chip ────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color  bgColor;
  final Color  textColor;
  const _Badge(
      {required this.label,
       required this.bgColor,
       required this.textColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor)),
      );
}
