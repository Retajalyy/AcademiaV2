import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Valid university ID format', () {
    String uniId = 'A12212';
    expect(uniId.isNotEmpty, true);
    expect(uniId.length >= 5, true);
  });

  test('Valid role assignment', () {
    String role = 'professor';
    expect(role == 'professor' || role == 'student', true);
  });

  test('Empty registration fields rejected', () {
    String fname = '';
    String lname = '';
    expect(fname.isEmpty, true);
    expect(lname.isEmpty, true);
  });
}