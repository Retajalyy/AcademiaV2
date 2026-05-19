import 'package:academia/Features/Academic_course_results/screens/AcademicResultCourseScreen.dart';
import 'package:academia/Core/widgets/bottom_bar.dart';
import 'package:academia/Features/Academic_results/screens/Academic_results_screen.dart';
import 'package:academia/Features/Assessments/screens/AssessmentScreen.dart';
import 'package:academia/Features/Course%20details/screens/CourseScreendetails.dart';
import 'package:academia/Features/Course/screens/CourseScreen.dart';
import 'package:academia/Features/Fees/screens/FeesScreen.dart';
import 'package:academia/Features/Payement/screens/PayementScreen.dart';
import 'package:academia/Features/Registiration_admin/screens/NoRegistirationScreen.dart';
import 'package:academia/Features/Registiration_admin/screens/RegistirationScreen.dart';
import 'package:academia/Features/Splash/screens/splash_screen.dart';
import 'package:academia/Features/noexam_schedule/screens/exam_Schedule_screen2.dart';
import 'package:academia/Features/noexam_schedule/screens/exam_Schedule_screen.dart';
import 'package:academia/Features/profile/screens/profile_page.dart';
import 'package:academia/Features/schedule/screens/schedule_screen.dart';
import 'Features/Dashboard_admin/screens/Dashboard_screen.dart';
import 'Features/AccountSettings_admin/screens/AccountSettingScreen.dart';
import 'Features/plan_admin/screens/PlanAdminScreen.dart';
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
          page: () => ExamScheduleScreen(),
        ),
        GetPage(
          name: '/exam',
          page: () => ExamScheduleScreen2(),
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
          page: () => NoRegistrationScreen(),
        ),
          GetPage(
          name: '/registirationAdmin',
          page: () => RegistrationScreen(), 
        ),
         GetPage(
          name: '/planAdmin1',
          page: () => Planadminscreen1(), 
        ),
        
        GetPage(
  name: '/app',
  page: () => const BottomBar(),
),
      ],
    );
  }
}