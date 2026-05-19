import '../model/course_admin_model.dart';

class CourseAdminService {
  Future<CourseStatsModel> fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const CourseStatsModel(
      totalCourses: 48,
      professors: 12,
      faculties: 3,
    );
  }

  Future<List<CourseAdminModel>> fetchCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      CourseAdminModel(
        id: 'c001',
        name: 'Analysis of Algorithm',
        faculty: 'Computers & Information',
        level: 'Year 4',
        major: 'Software Engineering',
        credits: 3,
        type: 'Core',
        prerequisite: 'Data Structures',
      ),
      CourseAdminModel(
        id: 'c002',
        name: 'Finance Institutions & markets',
        faculty: 'Business Administration',
        level: 'Year 4',
        major: 'Finance & Investment',
        credits: 3,
        type: 'Core',
        prerequisite: '—',
      ),
      CourseAdminModel(
        id: 'c003',
        name: 'Digital Marketing',
        faculty: 'Computers & Information',
        level: 'Year 2',
        major: 'General',
        credits: 2,
        type: 'Elective',
        prerequisite: '—',
      ),
    ];
  }

  Future<CourseAdminModel> addCourse(CourseFormModel form) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return CourseAdminModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: form.name,
      faculty: form.faculty,
      level: form.level,
      major: form.major,
      credits: int.tryParse(form.credits) ?? 3,
      type: form.type,
      prerequisite: form.prerequisite.isEmpty ? '—' : form.prerequisite,
    );
  }

  Future<CourseAdminModel> editCourse(String id, CourseFormModel form) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return CourseAdminModel(
      id: id,
      name: form.name,
      faculty: form.faculty,
      level: form.level,
      major: form.major,
      credits: int.tryParse(form.credits) ?? 3,
      type: form.type,
      prerequisite: form.prerequisite.isEmpty ? '—' : form.prerequisite,
    );
  }

  Future<bool> deleteCourse(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}