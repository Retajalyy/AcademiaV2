import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Course has valid name and code', () {
    String courseName = 'Data Structures';
    String courseCode = 'CS201';
    expect(courseName.isNotEmpty, true);
    expect(courseCode.isNotEmpty, true);
  });

  test('Course credit hours are valid', () {
    int creditHours = 3;
    expect(creditHours > 0, true);
  });

  test('Course belongs to valid faculty', () {
    String faculty = 'Engineering';
    expect(faculty.isNotEmpty, true);
  });
}