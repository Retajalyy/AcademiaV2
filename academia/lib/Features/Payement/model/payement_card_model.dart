class PaymentCardModel {
  final String nameOnCard;

  PaymentCardModel({
    this.nameOnCard = '',
  });

  PaymentCardModel copyWith({
    String? nameOnCard,
  }) =>
      PaymentCardModel(
        nameOnCard: nameOnCard ?? this.nameOnCard,
      );
}
