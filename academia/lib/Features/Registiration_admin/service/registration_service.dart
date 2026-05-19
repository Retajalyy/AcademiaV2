// lib/Features/Registiration_admin/services/registration_service.dart

import '../model/registiration_model.dart';

class RegistrationService {
  // ─── Simulated API calls (replace with real http/dio calls) ───────────────

  /// Fetch whether any registration plan currently exists
  Future<bool> fetchHasActivePlans() async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network
    return true; // false → shows NoRegistrationScreen
  }

  /// Fetch current registration open/close status
  Future<RegistrationStatusModel> fetchRegistrationStatus() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const RegistrationStatusModel(
      isOpen: true,
      message: "Registration is currently open",
      closingDate: "May 10, 2026",
      daysRemaining: "8 days remaining",
    );
  }

  /// Fetch all active plans
  Future<List<RegistrationPlanModel>> fetchActivePlans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const RegistrationPlanModel(
        id: "plan_001",
        title: "Semester 8 · Spring 2026",
        faculty: "FCI · Year 4 · Software Engineering",
        progress: 0.70,
        progressText: "70/90 students",
        courses: "6",
        enrolled: "80%",
        groups: "3",
        openDate: "April 20, 2026",
        closeDate: "May 1, 2026",
      ),
      const RegistrationPlanModel(
        id: "plan_002",
        title: "Semester 8 · Spring 2026",
        faculty: "FCI · Year 4 · Cyber Security",
        progress: 0.48,
        progressText: "50/110 students",
        courses: "6",
        enrolled: "48%",
        groups: "2",
        openDate: "April 20, 2026",
        closeDate: "May 1, 2026",
      ),
    ];
  }

  /// Create a new registration plan
  Future<RegistrationPlanModel> createPlan(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 700));
    // In real app: POST to API and return created plan
    return RegistrationPlanModel.fromJson({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      ...data,
      'isActive': true,
    });
  }

  /// Delete / close a plan by id
  Future<bool> deletePlan(String planId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}