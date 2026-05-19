// lib/Features/plan_admin/widgets/group_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/utilities/text_style.dart';
import '../controller/plan_admin_controller.dart';

class GroupFormWidget extends StatelessWidget {
  final VoidCallback? onAddAnotherGroup;

  const GroupFormWidget({
    super.key,
    this.onAddAnotherGroup,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PlanAdminController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── GROUP HEADER ──────────────────────────────────────────────────
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
          child: const Text(
            "Group 1 – SE1",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ── OUTER BODY ────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x14000000)),
            ),
            child: Obx(() {
              final isLecture = c.isLecture.value;
              final capacity = c.groupCapacity.value;

              return Column(
                children: [
                  // COURSE HEADER
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bluegroundicon,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.storage_rounded,
                          size: 22,
                          color: AppColors.accentProgramming1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Cloud Computing",
                          style: TextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _badge("Core"),
                          const SizedBox(height: 4),
                          _badge("3 Credits"),
                        ],
                      ),
                    ],
                  ),

                  const Divider(color: Color(0xffE6E6E6)),
                  const SizedBox(height: 14),

                  // LECTURE / SECTION TOGGLE
                  Row(
                    children: [
                      Expanded(
                        child: _typeButton(
                          title: "LECTURE",
                          selected: isLecture,
                          onTap: () => c.setScheduleType(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _typeButton(
                          title: "SECTION",
                          selected: !isLecture,
                          onTap: () => c.setScheduleType(false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isLecture ? "PROFESSOR" : "TEACHING ASSISTANT",
                      style: TextStyles.caption.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.smalltext,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  _buildDropdown(),

                  const SizedBox(height: 16),

                  // DAY / HALL
                  Row(
                    children: [
                      Expanded(child: _buildColumnTitle("DAY")),
                      const SizedBox(width: 10),
                      Expanded(child: _buildColumnTitle("HALL")),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown()),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDropdown()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // FROM / TO
                  Row(
                    children: [
                      Expanded(child: _buildColumnTitle("FROM")),
                      const SizedBox(width: 10),
                      Expanded(child: _buildColumnTitle("TO")),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown()),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDropdown()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // CAPACITY
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "GROUP CAPACITY",
                      style: TextStyles.caption.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.smalltext,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: c.decrementCapacity,
                        child: _capacityButton(Icons.remove),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4FC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x12000000)),
                          ),
                          child: Center(
                            child: Text(
                              "$capacity",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: c.incrementCapacity,
                        child: _capacityButton(Icons.add),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ADD ANOTHER GROUP BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onAddAnotherGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text(
                        "Add Another Group",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bluegroundicon,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyles.caption.copyWith(
          color: AppColors.primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _typeButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: null,
          isExpanded: true,
          hint: Text(
            "Select...",
            style: TextStyles.caption.copyWith(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          items: const [],
          onChanged: (value) {},
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.smalltext),
        ),
      ),
    );
  }

  Widget _buildColumnTitle(String title) {
    return Text(
      title,
      style: TextStyles.caption.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.smalltext,
      ),
    );
  }

  Widget _capacityButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Icon(icon, size: 18, color: Colors.black),
    );
  }
}