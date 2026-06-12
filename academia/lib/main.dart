import 'package:academia/Features/Academic_results/screens/AcademicResultCourseScreen.dart';
import 'package:academia/Core/widgets/bottom_bar.dart';
import 'package:academia/Features/Academic_results/screens/Academic_results_screen.dart';
import 'package:academia/Features/Assessments/screens/AssessmentScreen.dart';
import 'package:academia/Features/Course/screens/CourseScreendetails.dart';
import 'package:academia/Features/Course/screens/CourseScreen.dart';
import 'package:academia/Features/Fees/screens/FeesScreen.dart';
import 'package:academia/Features/Payement/screens/PayementScreen.dart';
import 'package:academia/Features/Registiration_admin/screens/NoRegistirationScreen.dart';
import 'package:academia/Features/Registration/screens/registration_screen.dart';
import 'package:academia/Features/Splash/screens/splash_screen.dart';
import 'package:academia/Features/Exam_schedule/screens/exam_Schedule_screen.dart';
import 'package:academia/Features/Exam_schedule/screens/no_exam_screen.dart';
import 'package:academia/Features/profile/screens/profile_page.dart';
import 'package:academia/Features/schedule/screens/schedule_screen.dart';
import 'Features/Dashboard_admin/screens/Dashboard_screen.dart';
import 'Features/AccountSettings_admin/screens/AccountSettingScreen.dart';
import 'Features/plan_admin/screens/PlanAdminScreen.dart';
import 'Features/plan_admin/screens/PlanAdmin2Screen .dart';
import 'Features/plan_admin/screens/PlanAdmin3Screen .dart';
import 'Features/Fees_admin/screens/FeesAdminScreen.dart';
import 'package:academia/Features/course_admin/screens/course_admin_screen.dart';
import 'Features/exam_results_admin/screens/exam_results_screen.dart';
import 'Features/exam_results_admin/bindings/exam_results_binding.dart';
import 'Core/widgets/professor_bottom_bar.dart';
import 'Features/Professor/screens/professor_course_detail_screen.dart';
import 'Features/Navigation/screens/navigation_screen.dart';
import 'Features/Auth/screens/forgot_password_screen.dart';
import 'Features/Dashboard_admin/screens/password_reset_screen.dart';
import 'Features/OutstandingFees_admin/screens/outstanding_fees_screen.dart';
import 'Features/Professor/screens/upload_material_screen.dart';
import 'Features/Professor/screens/assign_grades_screen.dart';
import 'Features/Professor/screens/professor_submissions_screen.dart';
import 'Features/Professor/screens/student_submissions_detail_screen.dart';
import 'Features/Professor/screens/take_attendance_screen.dart';
import 'Features/Professor/screens/attendance_records_screen.dart';
import 'Features/Professor/screens/attendance_session_detail_screen.dart';
import 'Features/Professor/screens/students_at_risk_screen.dart';
import 'Features/Professor/screens/academic_overview_screen.dart';
import 'Features/Professor/screens/assignment_overview_screen.dart';
import 'Features/Registiration_admin/screens/all_registration_plans_screen.dart';
import 'Features/Announcements/screens/announcements_screen.dart';
import 'Features/Assignments/screens/assignments_screen.dart';
import 'Features/Attendance/screens/student_attendance_screen.dart';
import 'Features/Announcements/screens/admin_announcements_screen.dart';
import 'Features/Announcements/screens/create_announcement_screen.dart';

import 'Features/Registiration_admin/screens/RegistirationScreen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/services/supabase_service.dart';
import 'Core/utilities/colors.dart'; 
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.init();
 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ GLOBAL THEME
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.lightblue,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),

      // 👇 start from splash instead of home
      initialRoute: '/splash',

      // 👇 routes
      getPages: [
        GetPage(
          name: '/splash',
          page: () => SplashScreen(),
        ),
        GetPage(
          name: '/academicresultscourses',
          page: () => AcademicResultsCourseScreen(),
        ),
        GetPage(
          name: '/academicresults',
          page: () => AcademicResultsScreen(),
        ),
        GetPage(
          name: '/noexam',
          page: () => NoExamScheduleScreen(),
        ),
        GetPage(
          name: '/exam',
          page: () => ExamScheduleScreen(),
        ),
        GetPage(
          name: '/assesments',
          page: () => Assessmentscreen(),
        ),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
        ),
        GetPage(
          name: '/HomePage',
          page: () => HomePage(),
        ),
        GetPage(
          name: '/profile',
          page: () => ProfilePage(),
        ),

         GetPage(
          name: '/schedule',
          page: () => ScheduleScreen(),
        ),
         GetPage(
          name: '/course',
          page: () => CourseScreen(),
        ),
         GetPage(
          name: '/coursedetails',
          page: () => CourseScreenDetails(),
        ),
         GetPage(
          name: '/Registration',
          page: () => RegistrationScreen(),
        ),
        GetPage(
          name: '/Fees',
          page: () => FeesScreen(),
        ),
        GetPage(
          name: '/Payement',
          page: () => PayementScreen(),
        ),
        
        GetPage(
          name: '/Dashboard',
          page: () => DashboardScreen(),
        ),
        GetPage(
          name: '/AccountSettings',
          page: () => AccountSettingsScreen(),
        ),
         GetPage(
          name: '/NoregistirationAdmin',
          page: () => NoRegistrationAdminScreen(),
        ),
          GetPage(
          name: '/registirationAdmin',
          page: () => RegistrationAdminScreen(), 
        ),
         GetPage(
          name: '/planAdmin1',
          page: () => Planadminscreen1(), 
        ),
        GetPage(
          name: '/planAdmin2',
          page: () => Planadminscreen2(), 
        ),
         GetPage(
          name: '/planAdmin3',
          page: () => Planadminscreen3(), 
        ),
        GetPage(
          name: '/FeeAdmin',
          page: () => FeesAdminScreen(), 
        ),
         GetPage(
          name: '/courseAdmin',
          page: () => CourseAdminScreen(), 
        ),
        GetPage(
  name: '/examResultsAdmin',
  page: () => const ExamResultsAdminScreen(),
  binding: ExamResultsBinding(),
),
        GetPage(
          name: '/app',
          page: () => const BottomBar(),
        ),
        GetPage(
          name: '/professorApp',
          page: () => const ProfessorBottomBar(),
        ),
        GetPage(
          name: '/professorCourseDetail',
          page: () => const ProfessorCourseDetailScreen(),
        ),
        GetPage(
          name: '/navigation',
          page: () => const NavigationScreen(),
        ),
        GetPage(
          name: '/assignments',
          page: () => const AssignmentsScreen(),
        ),
        GetPage(
          name: '/attendance',
          page: () => const StudentAttendanceScreen(),
        ),
        GetPage(
          name: '/forgotPassword',
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage(
          name: '/passwordResetRequests',
          page: () => const PasswordResetScreen(),
        ),
        GetPage(
          name: '/outstandingFees',
          page: () => const OutstandingFeesScreen(),
        ),
        GetPage(
          name: '/uploadMaterial',
          page: () => const UploadMaterialScreen(),
        ),
        GetPage(
          name: '/assignGrades',
          page: () => const AssignGradesScreen(),
        ),
        GetPage(
          name: '/submissions',
          page: () => const ProfessorSubmissionsScreen(),
        ),
        GetPage(
          name: '/studentSubmissionsDetail',
          page: () => const StudentSubmissionsDetailScreen(),
        ),
        GetPage(
          name: '/takeAttendance',
          page: () => const TakeAttendanceScreen(),
        ),
        GetPage(
          name: '/attendanceRecords',
          page: () => const AttendanceRecordsScreen(),
        ),
        GetPage(
          name: '/attendanceSessionDetail',
          page: () => const AttendanceSessionDetailScreen(),
        ),
        GetPage(
          name: '/studentsAtRisk',
          page: () => const StudentsAtRiskScreen(),
        ),
        GetPage(
          name: '/academicOverview',
          page: () => const AcademicOverviewScreen(),
        ),
        GetPage(
          name: '/assignmentOverview',
          page: () => const AssignmentOverviewScreen(),
        ),
        GetPage(
          name: '/allRegistrationPlans',
          page: () => const AllRegistrationPlansScreen(),
        ),
        GetPage(
          name: '/announcements',
          page: () => const AnnouncementsScreen(),
        ),
        GetPage(
          name: '/adminAnnouncements',
          page: () => const AdminAnnouncementsScreen(),
        ),
        GetPage(
          name: '/createAnnouncement',
          page: () => const CreateAnnouncementScreen(),
        ),
      ],
    );
  }
}