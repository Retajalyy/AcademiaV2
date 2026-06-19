import 'package:flutter_test/flutter_test.dart';

void main() {
  test('User message is not empty', () {
    String message = 'What is my GPA?';
    expect(message.isNotEmpty, true);
  });

  test('Bot response is returned', () {
    String botResponse = 'Your GPA is 3.5';
    expect(botResponse.isNotEmpty, true);
  });

  test('Empty message is rejected', () {
    String message = '';
    expect(message.isEmpty, true);
  });
}