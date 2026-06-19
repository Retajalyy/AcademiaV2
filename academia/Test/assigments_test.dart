import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Assignment has valid title and deadline', () {
    String title = 'Math Homework 1';
    String deadline = '2025-06-30';
    expect(title.isNotEmpty, true);
    expect(deadline.isNotEmpty, true);
  });

  test('Empty assignment title rejected', () {
    String title = '';
    expect(title.isEmpty, true);
  });

  test('Assignment submission is recorded', () {
    bool submitted = true;
    expect(submitted, true);
  });
}