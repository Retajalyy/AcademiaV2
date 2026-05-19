import 'package:academia/Core/utilities/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_item_model.dart';

class ServicesService {
  final _db = Supabase.instance.client;

  Future<ServiceStatus> _fetchRegistrationStatus() async {
    final row = await _db
        .from('registration_windows')
        .select('status')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
    switch (row?['status'] as String?) {
      case 'open':           return ServiceStatus.opened;
      case 'closed':         return ServiceStatus.closed;
      case 'not_opened_yet': return ServiceStatus.pending;
      default:               return ServiceStatus.none;
    }
  }

  Future<List<ServiceSectionModel>> fetchSections() async {
    final registrationStatus = await _fetchRegistrationStatus();

    return [
      ServiceSectionModel(
        title: 'ACADEMIC',
        items: const [
          ServiceItemModel(
            id: 'courses',
            title: 'Courses',
            subtitle: 'Materials & lectures',
            iconAsset: 'lib/assets/Icons/courses.svg',
            accentColor: AppColors.primaryBlue,
            accentBackground: AppColors.lightblue,
            route: '/course',
          ),
          ServiceItemModel(
            id: 'assessments',
            title: 'Assessments',
            subtitle: 'Grades and Participation',
            iconAsset: 'lib/assets/Icons/Assesments.svg',
            accentColor: AppColors.primaryBlue,
            accentBackground: AppColors.lightblue,
            route: '/assesments',
          ),
          ServiceItemModel(
            id: 'results',
            title: 'Results',
            subtitle: 'Results & GPA',
            iconAsset: 'lib/assets/Icons/Results.svg',
            accentColor: AppColors.secondaryYellow,
            accentBackground: AppColors.LightYellow,
            route: '/academicresults',
          ),
          ServiceItemModel(
            id: 'exam_schedule',
            title: 'Exam Schedule',
            subtitle: 'Dates & Locations',
            iconAsset: 'lib/assets/Icons/examschedule.svg',
            accentColor: AppColors.secondaryYellow,
            accentBackground: AppColors.LightYellow,
            route: '/exam',
          ),
        ],
      ),
      ServiceSectionModel(
        title: 'ADMINISTRATION',
        items: [
          ServiceItemModel(
            id: 'registration',
            title: 'Registration',
            subtitle: 'Enroll for next semester',
            iconAsset: 'lib/assets/Icons/Registration.svg',
            accentColor: AppColors.primaryBlue,
            accentBackground: AppColors.lightblue,
            status: registrationStatus,   // ← live from DB
            route: '/Registration',
          ),
          const ServiceItemModel(
            id: 'fees',
            title: 'Fees & Payments',
            subtitle: 'Pay tuition fees',
            iconAsset: 'lib/assets/Icons/Fees.svg',
            accentColor: AppColors.secondaryYellow,
            accentBackground: AppColors.LightYellow,
            route: '/Fees',
          ),
        ],
      ),
    ];
  }
}
