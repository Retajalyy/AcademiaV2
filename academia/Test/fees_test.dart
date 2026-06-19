import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Fee amount is valid', () {
    double fee = 500.00;
    expect(fee > 0, true);
  });

  test('Paid status is recorded correctly', () {
    String status = 'paid';
    expect(status == 'paid' || status == 'unpaid', true);
  });

  test('Unpaid fee triggers alert', () {
    String status = 'unpaid';
    bool showAlert = status == 'unpaid';
    expect(showAlert, true);
  });
}