// lib/features/exam/data/services/exam_service.dart

import '../model/exam_model.dart';

class ExamService {
  /// Replace the body of this method with your real API call.
  Future<List<ExamModel>> fetchExams() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // ── Mock data ────────────────────────────────────────────
    return [
      const ExamModel(
        id:     '1',
        title:  'Cloud Computing',
        date:   '24',
        month:  'APR',
        time:   '10:00 AM - 11:00 AM',
        room:   'Room 3B',
        status: ExamStatus.next,
      ),
      const ExamModel(
        id:     '2',
        title:  'Internet of Things',
        date:   '25',
        month:  'APR',
        time:   '10:00 AM - 11:00 AM',
        room:   'Room 5B',
        status: ExamStatus.upcoming,
      ),
      const ExamModel(
        id:     '3',
        title:  'Introduction to AI',
        date:   '23',
        month:  'APR',
        time:   '10:00 AM - 11:00 AM',
        room:   'Room 5B',
        status: ExamStatus.completed,
      ),
    ];
    // ────────────────────────────────────────────────────────
  }

  /// Returns null when no active exam period exists.
  Future<ExamPeriodModel?> fetchExamPeriod() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Return null to trigger NoExamScheduleScreen
    return const ExamPeriodModel(
      title:    'Midterms exams period',
      subtitle: 'April 23 - May 1, 2026',
    );
  }
}