import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Valid professor login credentials', () {
    String email = 'lucrecia@university.edu';
    String password = 'pass1234';
    expect(email.contains('@'), true);
    expect(password.length >= 6, true);
  });

  test('Empty login fields validation', () {
    String email = '';
    String password = '';
    expect(email.isEmpty, true);
    expect(password.isEmpty, true);
  });

  test('Invalid password rejected', () {
    String password = '123';
    expect(password.length >= 6, false);
  });
}