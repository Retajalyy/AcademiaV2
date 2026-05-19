import '../model/dashboard_model.dart';

class DashboardService {
  // Replace with your actual API base URL
  // static const String _baseUrl = 'https://your-api.com/api';

  Future<DashboardModel> fetchDashboardData() async {
    try {
      // TODO: Replace with real HTTP call, e.g.:
      // final response = await http.get(Uri.parse('$_baseUrl/dashboard'));
      // if (response.statusCode == 200) {
      //   return DashboardModel.fromJson(jsonDecode(response.body));
      // }
      // throw Exception('Failed to load dashboard');

      // ── Mock data (remove once API is ready) ──
      await Future.delayed(const Duration(milliseconds: 800));
      return DashboardModel(
        totalStudents: '2,580',
        faculties: '3',
        majors: '13',
        instructors: '270',
        totalCourses: '128',
        academicWeek: 'Week 11',
        totalWeeks: '16',
        semester: '2nd Semester',
        pendingTasks: [
          PendingTaskModel(
            type: 'notify',
            title: '34 students have\noutstanding fees',
            subtitle: 'Deadline Apr 30 · 8 days left',
            count: 34,
          ),
          PendingTaskModel(
            type: 'warn',
            title: '18 students reached\nabsence limit',
            subtitle: '4 absences · Issue formal warning',
            count: 18,
          ),
          PendingTaskModel(
            type: 'block',
            title: '7 students exceeded\nabsence limit',
            subtitle: 'Blocked from final\nexamination',
            count: 7,
          ),
        ],
      );
    } catch (e) {
      rethrow;
    }
  }
}