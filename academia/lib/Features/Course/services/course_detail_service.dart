// lib/Features/Course/services/course_details_service.dart

import 'package:academia/Features/Course/model/course_detail_model.dart';
class CourseDetailsService {
  Future<CourseDetailsModel> fetchCourseDetails(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: replace with real API call
    // final res = await dio.get('/courses/$courseId/details');
    // return CourseDetailsModel.fromJson(res.data);

    return CourseDetailsModel(
      id: courseId,
      courseName: 'Cloud Computing',
      doctorName: 'Dr. Youssef Senousy',
      credits: 3,
      progress: 0.65,
      classworkPercent: 0.75,
      assignmentsPercent: 0.75,
      attendancePercent: 0.15,
      materials: const [
        CourseMaterial(
          title: 'Lecture 1',
          subtitle: 'PDF · 2.4 MB',
          type: 'pdf',
          isAssignment: false,
        ),
        CourseMaterial(
          title: 'Lecture 2',
          subtitle: 'PDF · 3.1 MB',
          type: 'pdf',
          isAssignment: false,
        ),
        CourseMaterial(
          title: 'Lecture 3',
          subtitle: 'PDF · 2.8 MB',
          type: 'pdf',
          isAssignment: false,
        ),
        CourseMaterial(
          title: 'Assignment 1',
          subtitle: 'DOCX · Due May 5',
          type: 'docx',
          isAssignment: true,
        ),
      ],
    );
  }
}