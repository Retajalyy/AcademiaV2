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
      backgroundColor: AppColors.babyblue,
      drawer: const SideMenu(activeItem: "Courses"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          c.resetForm();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: const Color(0xC22468A0),
            builder: (_) => const AddCourseSheet(),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Builder(builder: (ctx) {
              final top = MediaQuery.of(ctx).padding.top;
              return Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, top + 16, 20, 26),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: const Icon(Icons.menu,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Courses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage and Add Courses',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              );
            }),

            // ── Search ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: c.onSearch,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 15),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.grey.shade400, size: 22),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // ── Faculty Tabs ─────────────────────────────────────────────
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
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? AppColors.primaryBlue
                                    : Colors.black
                                        .withValues(alpha: 0.07),
                              ),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: 13,
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

            // ── Course List ──────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryBlue));
                }
                if (c.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.errorMessage.value,
                            style: const TextStyle(
                                color: AppColors.fail)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: c.loadData,
                            child: const Text('Retry')),
                      ],
                    ),
                  );
                }
                if (c.filteredCourses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.book_outlined,
                            size: 52, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No courses found',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                // Section label
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  itemCount: c.filteredCourses.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Obx(() => Text(
                              'ALL COURSES – ${c.filteredCourses.length} TOTAL',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.8,
                              ),
                            )),
                      );
                    }
                    final course = c.filteredCourses[i - 1];
                    return Dismissible(
                      key: ValueKey(course.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.fail,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: ctx,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16)),
                            title: const Text('Delete Course'),
                            content: Text(
                                'Delete "${course.name}"? This cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                child: const Text('Delete',
                                    style: TextStyle(
                                        color: AppColors.fail)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) {
                        c.deletingCourse.value = course;
                        c.confirmDelete();
                      },
                      child: CourseCard(course: course),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
