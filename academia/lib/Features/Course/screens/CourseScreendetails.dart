// lib/Features/Course/screens/course_screen_details.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_details_controller.dart';
import 'package:academia/Features/Course/widgets/course_headr2.dart';
import 'package:academia/Features/Course/widgets/course_stat.dart';
import 'package:academia/Features/Course/widgets/material_list.dart';
import 'package:academia/Core/utilities/colors.dart';

class CourseScreenDetails extends StatefulWidget {
  const CourseScreenDetails({super.key});

  @override
  State<CourseScreenDetails> createState() => _CourseScreenDetailsState();
}

class _CourseScreenDetailsState extends State<CourseScreenDetails> {
  late final CourseDetailsController ctrl;

  @override
  void initState() {
    super.initState();
    // Always delete any stale instance so data is fresh on every navigation
    Get.delete<CourseDetailsController>(force: true);
    ctrl = Get.put(CourseDetailsController());
  }

  @override
  void dispose() {
    Get.delete<CourseDetailsController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            const CourseHeaderDetails(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: AppColors.babyblue),
                child: Obx(() {
                  if (ctrl.errorMessage.isNotEmpty && !ctrl.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ctrl.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ctrl.fetchDetails(ctrl.courseId.value),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (ctrl.isLoading.value && ctrl.course.value == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ctrl.fetchDetails(ctrl.courseId.value),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          CourseStats(),
                          SizedBox(height: 20),
                          CourseMaterialList(),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
