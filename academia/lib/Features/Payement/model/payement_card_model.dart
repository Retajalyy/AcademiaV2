class PaymentCardModel {
  final String cardNumber;
  final String expiry;
  final String cvv;
  final String nameOnCard;

  PaymentCardModel({
    this.cardNumber = '',
    this.expiry = '',
    this.cvv = '',
    this.nameOnCard = '',
  });

  PaymentCardModel copyWith({
    String? cardNumber,
    String? expiry,
    String? cvv,
    String? nameOnCard,
  }) =>
      PaymentCardModel(
        cardNumber: cardNumber ?? this.cardNumber,
        expiry: expiry ?? this.expiry,
        cvv: cvv ?? this.cvv,
        nameOnCard: nameOnCard ?? this.nameOnCard,
      );
}