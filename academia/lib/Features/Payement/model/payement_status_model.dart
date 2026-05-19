class PaymentStatusModel {
  final bool isSuccess;
  final String message;
  final String? transactionId;

  const PaymentStatusModel({
    required this.isSuccess,
    required this.message,
    this.transactionId,
  });
}