class OrderSummaryModel {
  final String fee;
  final String semester;
  final double totalAmount;

  const OrderSummaryModel({
    this.fee = 'Graduation Project Fee',
    this.semester = 'Semester 8',
    this.totalAmount = 5000,
  });
}