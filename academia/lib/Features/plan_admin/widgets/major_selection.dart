import 'package:academia/Core/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/plan_admin_controller.dart';

class MajorSelectorWidget extends StatelessWidget {
  final Function(String majorCode) onMajorSelected;
  const MajorSelectorWidget({super.key, required this.onMajorSelected});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PlanAdminController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SELECT MAJOR',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.smalltext,
                fontSize: 16)),
        const SizedBox(height: 10),
        Obx(() {
          if (c.majorsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.majors.isEmpty) {
            return Text(
              c.errorMessage.isNotEmpty
                  ? c.errorMessage.value
                  : 'No majors found for this faculty.',
              style: const TextStyle(color: AppColors.smalltext),
            );
          }
          return Column(
            children: c.majors.map((m) {
              final code       = m['code']!;
              final name       = m['name']!;
              final isSelected = c.selectedMajor.value == code;

              return InkWell(
                onTap: () async {
                  await c.selectMajor(code);
                  onMajorSelected(code);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(name,
                            style: const TextStyle(
                                color: AppColors.accentProgramming1,
                                fontSize: 17)),
                      ),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.accentProgramming1
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentProgramming1
                                : Colors.grey,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 21, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
