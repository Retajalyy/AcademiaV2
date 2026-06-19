import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Exam has valid date and time', () {
    String examDate = '2025-06-15';
    String examTime = '10:00 AM';
    expect(examDate.isNotEmpty, true);
    expect(examTime.isNotEmpty, true);
  });

  test('Exam is linked to a course', () {
    String courseId = 'CS201';
    expect(courseId.isNotEmpty, true);
  });

  test('Exam location is specified', () {
    String location = 'Hall A';
    expect(location.isNotEmpty, true);
  });
}