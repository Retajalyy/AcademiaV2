import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:academia/Core/utilities/colors.dart';
import '../controller/plan_admin_controller.dart';

class FacultySelectionWidget extends StatelessWidget {
  final VoidCallback onFacultySelected;
  const FacultySelectionWidget({super.key, required this.onFacultySelected});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PlanAdminController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('SELECT FACULTY',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.smalltext)),
        ),
        Obx(() {
          if (c.facultiesLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.faculties.isEmpty) {
            return Column(
              children: [
                Text(
                  c.errorMessage.isNotEmpty
                      ? c.errorMessage.value
                      : 'No faculties found in database.',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: c.loadFaculties,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            );
          }
          return Column(
            children: c.faculties.map((f) {
              final code       = f['code']!;
              final name       = f['name']!;
              final isSelected = c.selectedFaculty.value == code;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () async {
                    await c.selectFaculty(code);
                    onFacultySelected();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 39, height: 39,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDEDFA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.account_balance_outlined,
                              color: AppColors.accentProgramming1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.accentProgramming1)),
                        ),
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : Colors.grey.shade300,
                              width: isSelected ? 4 : 1,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10, height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accentProgramming1,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
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
