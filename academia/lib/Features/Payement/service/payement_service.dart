import 'package:academia/Features/Payement/model/payement_card_model.dart';
import 'package:academia/Features/Payement/model/order_summary_model.dart';
import 'package:academia/Features/Payement/model/payement_status_model.dart';

class PaymentService {
  Future<OrderSummaryModel> getOrderSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const OrderSummaryModel();
  }

  Future<PaymentStatusModel> submitPayment(PaymentCardModel card) async {
    await Future.delayed(const Duration(seconds: 2));

    if (card.cardNumber.isEmpty || card.cvv.isEmpty || card.expiry.isEmpty) {
      return const PaymentStatusModel(
        isSuccess: false,
        message: 'Please fill in all card details.',
      );
    }

    return PaymentStatusModel(
      isSuccess: true,
      message: 'Payment successful!',
      transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}