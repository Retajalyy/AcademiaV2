// lib/Features/fees_admin/widgets/add_fee_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/fee_admin_controller.dart';
import '../model/fee_admin_model.dart';

class AddFeeSheet extends StatelessWidget {
  const AddFeeSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddFeeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FeesAdminController>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── DRAG HANDLE ───────────────────────────────────────────────
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── SCROLLABLE CONTENT ────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
                  children: [

                    // ── 1. FEE TYPE ──────────────────────────────────────────
                    _SectionLabel(number: "1", label: "FEE TYPE"),
                    const SizedBox(height: 10),

                    Obx(() => Column(
                          children: FeeType.values.map((type) {
                            final isSelected = c.selectedFeeType.value == type;

                            return GestureDetector(
                              onTap: () => c.selectFeeType(type),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 13),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.grey.shade300,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primaryBlue
                                              : Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      type.label,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.accentProgramming1,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )),

                    const SizedBox(height: 16),

                    // ── 2. AMOUNT ────────────────────────────────────────────
                    _SectionLabel(number: "2", label: "AMOUNT"),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: c.setAmount,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 15),
                            decoration: BoxDecoration(
                              color: AppColors.bluegroundicon,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "EGP",
                              style: TextStyle(
                                color: AppColors.accentProgramming1,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 3. FACULTY ───────────────────────────────────────────
                    _SectionLabel(number: "3", label: "FACULTY"),
                    const SizedBox(height: 10),

                    Obx(() => GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 3.2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: c.faculties.map((faculty) {
                            final isSelected =
                                c.selectedFaculty.value == faculty;

                            return GestureDetector(
                              onTap: () => c.selectFaculty(faculty),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        faculty,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.accentProgramming1,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )),

                    const SizedBox(height: 16),

                    // ── 4. LEVEL ─────────────────────────────────────────────
                    _SectionLabel(number: "4", label: "LEVEL"),
                    const SizedBox(height: 10),

                    Obx(() => Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: c.levels.asMap().entries.map((entry) {
                              final index = entry.key;
                              final level = entry.value;
                              final isSelected =
                                  c.selectedLevel.value == level;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => c.selectLevel(level),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 11),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryBlue
                                          : Colors.white,
                                      border: index < c.levels.length - 1
                                          ? Border(
                                              right: BorderSide(
                                                  color: Colors.grey.shade300),
                                            )
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        level,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.accentProgramming1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )),

                    const SizedBox(height: 16),

                    // ── 5. DUE DATE ──────────────────────────────────────────
                    _SectionLabel(number: "5", label: "DUE DATE"),
                    const SizedBox(height: 10),

                    Obx(() => GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) c.setDueDate(picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  c.formattedDueDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.accentProgramming1,
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                  color: AppColors.smalltext,
                                ),
                              ],
                            ),
                          ),
                        )),

                    const SizedBox(height: 28),

                    // ── ADD FEE BUTTON — fits text width ─────────────────────
                    Obx(() => Center(
                          child: ElevatedButton(
                            onPressed:
                                c.isSubmitting.value ? null : c.submitFee,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: c.isSubmitting.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Add Fee",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String number;
  final String label;

  const _SectionLabel({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.smalltext,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}