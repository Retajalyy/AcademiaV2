class SessionStudentRecord {
  final int    studentId;
  final String name;
  final String groupLabel;
  final bool   isPresent;

  const SessionStudentRecord({
    required this.studentId,
    required this.name,
    required this.groupLabel,
    required this.isPresent,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class AttendanceGroupInfo {
  final int          groupId;
  final int          sectionId;
  final String       label;
  final String       timeRange;
  final String       room;
  final List<String> scheduleDays; // e.g. ['Sunday', 'Tuesday']
  final List<AttendanceStudentInfo> students;

  const AttendanceGroupInfo({
    required this.groupId,
    required this.sectionId,
    required this.label,
    required this.timeRange,
    required this.room,
    required this.scheduleDays,
    required this.students,
  });

  /// Returns the most recent past occurrence of any scheduled day.
  DateTime get mostRecentScheduleDate {
    const dayMap = {
      'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4,
      'Friday': 5, 'Saturday': 6, 'Sunday': 7,
    };
    final today = DateTime.now();
    DateTime? best;
    for (final day in scheduleDays) {
      final target = dayMap[day];
      if (target == null) continue;
      var diff = today.weekday - target;
      if (diff < 0) diff += 7;
      final candidate = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: diff));
      if (best == null || candidate.isAfter(best)) best = candidate;
    }
    return best ?? today;
  }
}

class AtRiskStudent {
  final int    studentId;
  final String name;
  final int    attended;
  final int    totalSessions;

  const AtRiskStudent({
    required this.studentId,
    required this.name,
    required this.attended,
    required this.totalSessions,
  });

  int get absent        => totalSessions - attended;
  int get absencesLeft  => (4 - absent).clamp(0, 4);
  bool get isBlocked    => absent > 4;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class AtRiskCourse {
  final String           courseName;
  final List<AtRiskStudent> students;
  const AtRiskCourse({required this.courseName, required this.students});
}

class AttendanceSessionSummary {
  final int          sessionId;
  final int          sessionNum;
  final DateTime     date;
  final String       sectionType; // 'LEC' or 'SEC'
  final List<String> groups;
  final int          presentCount;
  final int          totalCount;

  const AttendanceSessionSummary({
    required this.sessionId,
    required this.sessionNum,
    required this.date,
    required this.sectionType,
    required this.groups,
    required this.presentCount,
    required this.totalCount,
  });

  double get percentage =>
      totalCount > 0 ? (presentCount / totalCount * 100) : 0;

  String get dateLabel {
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['','Jan','Feb','Mar','Apr','May','Jun',
                       'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month]} ${date.day}';
  }
}

class AttendanceStudentInfo {
  final int    studentId;
  final String name;
  final String uniId;
  bool isPresent;

  AttendanceStudentInfo({
    required this.studentId,
    required this.name,
    required this.uniId,
    this.isPresent = false,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
