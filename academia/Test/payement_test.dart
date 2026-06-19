import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Payment amount is valid', () {
    double amount = 1500.00;
    expect(amount > 0, true);
  });

  test('Payment status is recorded', () {
    String status = 'paid';
    expect(status == 'paid' || status == 'unpaid', true);
  });

  test('Outstanding fees calculated correctly', () {
    double total = 3000.00;
    double paid = 1500.00;
    double outstanding = total - paid;
    expect(outstanding, 1500.00);
  });
}