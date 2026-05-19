// ─── Registration State Enum ───────────────────────────────────────────────
enum RegistrationState {
  open,          // Semester A/B tabs, schedule list, confirm CTA
  closed,        // Lock icon, "Registration is now closed"
  notOpenedYet,  // Clock icon, registration hasn't opened yet
}

// ─── Group Model ────────────────────────────────────────────────────────────
class CourseGroup {
  final String id;
  final String label; // e.g. "Group SE1"
  final int creditHours;
  final List<CourseLecture> lectures;

  const CourseGroup({
    required this.id,
    required this.label,
    required this.creditHours,
    required this.lectures,
  });
}

// ─── Lecture / Section Model ────────────────────────────────────────────────
class CourseLecture {
  final String courseCode;
  final String courseName;
  final int creditHours;       // e.g. 3
  final String day;
  final String timeFrom;
  final String timeTo;
  final String instructor;
  final String? room;

  // Section fields (null if this course has no section)
  final String? sectionDay;
  final String? sectionInstructor;
  final String? sectionTime;
  final String? sectionRoom;
  final String? prerequisiteWarning;
  final bool isLocked;

  const CourseLecture({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.day,
    required this.timeFrom,
    required this.timeTo,
    required this.instructor,
    this.room,
    this.sectionDay,
    this.sectionInstructor,
    this.sectionTime,
    this.sectionRoom,
    this.prerequisiteWarning,
    this.isLocked = false,
  });
}

// ─── Course with prerequisite / warning ─────────────────────────────────────
class CourseWithWarning {
  final CourseLecture lecture;
  final String? warningMessage; // e.g. prereq not met
  final bool isLocked;          // true when prereq blocks adding the course

  const CourseWithWarning({
    required this.lecture,
    this.warningMessage,
    this.isLocked = false,
  });
}

// ─── Semester Info (shown when closed) ──────────────────────────────────────
class SemesterInfo {
  final String semester;
  final String year;
  final String registrationOpen;
  final String registrationClosed;
  final String semesterStart;

  const SemesterInfo({
    required this.semester,
    required this.year,
    required this.registrationOpen,
    required this.registrationClosed,
    required this.semesterStart,
  });
}

// ─── Balance Info (shown when not opened yet) ────────────────────────────────
class BalanceInfo {
  final double outstandingAmount;
  final String currency;
  final bool isPaid;
  final String dueDate;

  const BalanceInfo({
    required this.outstandingAmount,
    required this.currency,
    required this.isPaid,
    required this.dueDate,
  });
}