import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../../../Core/widgets/side_menu.dart';
import '../controller/course_admin_controller.dart';
import '../widgets/course_card.dart';
import '../widgets/add_course_admin.dart';

class CourseAdminScreen extends StatelessWidget {
  const CourseAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CourseAdminController>()) {
      Get.put(CourseAdminController(), permanent: true);
    }
    final c = Get.find<CourseAdminController>();

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      drawer: const SideMenu(activeItem: "Courses"),
      body: SafeArea(
        child: Column(
          children: [
            // ── BLUE HEADER ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              color: AppColors.primaryBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu + Title + New Course button
                  Row(
                    children: [
                      Builder(
                        builder: (ctx) => GestureDetector(
                          onTap: () => Scaffold.of(ctx).openDrawer(),
                          child: const Icon(Icons.menu,
                              color: Colors.white, size: 38),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Courses",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Manage and Add Courses",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFDEDEDE),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // + New course button
                      GestureDetector(
                        onTap: () {
                          c.resetForm();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Color(0xC22468A0),
                            
                            builder: (_) => const AddCourseSheet(),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xC22468A0).withOpacity(0.76),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.17)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.add,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                "New course",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Stats row
                  Obx(() {
                    final s = c.stats.value;
                    if (s == null) return const SizedBox.shrink();
                    return Row(
                      children: [
                        _StatBox(
                            value: s.totalCourses.toString(),
                            label: "Total courses"),
                        const SizedBox(width: 10),
                        _StatBox(
                            value: s.professors.toString(),
                            label: "Professors"),
                        const SizedBox(width: 10),
                        _StatBox(
                            value: s.faculties.toString(),
                            label: "Faculties"),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // ── WHITE BODY ───────────────────────────────────────────────
            Expanded(
              child: Container(
                color: AppColors.babyblue,
                child: Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: c.onSearch,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Search courses...",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.grey.shade400, size: 23),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                        ),
                      ),
                    ),
                     const SizedBox(width: 10),
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Obx(() => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: c.tabs.map((tab) {
                                final sel = c.selectedTab.value == tab;
                                return GestureDetector(
                                  onTap: () => c.onTabSelected(tab),
                                  child: Container(
                                    margin:
                                        const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? AppColors.primaryBlue
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                        color: sel
                                            ? AppColors.primaryBlue
                                            : Colors.black.withOpacity(0.07),
                                      ),
                                    ),
                                    child: Text(
                                      tab,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: sel
                                            ? Colors.white
                                            : AppColors.smalltext,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )),
                    ),

                    // Course list
                    Expanded(
                      child: Obx(() {
                        if (c.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (c.errorMessage.value.isNotEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(c.errorMessage.value,
                                    style:
                                        const TextStyle(color: AppColors.fail)),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                    onPressed: c.loadData,
                                    child: const Text("Retry")),
                              ],
                            ),
                          );
                        }
                        if (c.filteredCourses.isEmpty) {
                          return const Center(
                            child: Text("No courses found",
                                style: TextStyle(
                                    color: AppColors.smalltext)),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: c.filteredCourses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, i) =>
                              CourseCard(course: c.filteredCourses[i]),
                        );
                      }),
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

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFFCCDEEC)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}