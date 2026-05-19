class DashboardModel {
  final String totalStudents;
  final String faculties;
  final String majors;
  final String instructors;
  final String totalCourses;
  final String academicWeek;
  final String totalWeeks;
  final String semester;
  final List<PendingTaskModel> pendingTasks;

  DashboardModel({
    required this.totalStudents,
    required this.faculties,
    required this.majors,
    required this.instructors,
    required this.totalCourses,
    required this.academicWeek,
    required this.totalWeeks,
    required this.semester,
    required this.pendingTasks,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalStudents: json['total_students'] ?? '0',
      faculties: json['faculties'] ?? '0',
      majors: json['majors'] ?? '0',
      instructors: json['instructors'] ?? '0',
      totalCourses: json['total_courses'] ?? '0',
      academicWeek: json['academic_week'] ?? 'Week 1',
      totalWeeks: json['total_weeks'] ?? '16',
      semester: json['semester'] ?? '1st Semester',
      pendingTasks: (json['pending_tasks'] as List<dynamic>? ?? [])
          .map((e) => PendingTaskModel.fromJson(e))
          .toList(),
    );
  }
}

class PendingTaskModel {
  final String type; // 'notify' | 'warn' | 'block'
  final String title;
  final String subtitle;
  final int count;

  PendingTaskModel({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.count,
  });

  factory PendingTaskModel.fromJson(Map<String, dynamic> json) {
    return PendingTaskModel(
      type: json['type'] ?? 'notify',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}