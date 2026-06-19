import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Attendance record is created correctly', () {
    Map<String, dynamic> record = {
      'student_id': 'A12212',
      'course': 'CS101',
      'status': 'present',
      'date': DateTime.now().toString(),
    };
    expect(record['status'], 'present');
    expect(record['student_id'], isNotEmpty);
  });

  test('Absent status is recorded correctly', () {
    String status = 'absent';
    expect(status == 'present' || status == 'absent', true);
  });

  test('Attendance date is valid', () {
    String date = DateTime.now().toString();
    expect(date.isNotEmpty, true);
  });
}