import 'package:get/get.dart';
import 'package:academia/Features/Payement/model/payement_card_model.dart';
import 'package:academia/Features/Payement/model/order_summary_model.dart';
import 'package:academia/Features/Payement/model/payement_status_model.dart';
import 'package:academia/Features/Payement/service/payement_service.dart';
import 'package:academia/Features/Payement/screens/PayementStatusScreen.dart';

class PaymentController extends GetxController {
  final PaymentService _service = PaymentService();

  final cardModel    = PaymentCardModel().obs;
  final orderSummary = const OrderSummaryModel().obs;
  final isLoading    = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrderSummary();
  }

  Future<void> _loadOrderSummary() async {
    final summary = await _service.getOrderSummary();
    orderSummary.value = summary;
  }

  void updateCardNumber(String v) =>
      cardModel.value = cardModel.value.copyWith(cardNumber: v);
  void updateExpiry(String v) =>
      cardModel.value = cardModel.value.copyWith(expiry: v);
  void updateCvv(String v) =>
      cardModel.value = cardModel.value.copyWith(cvv: v);
  void updateName(String v) =>
      cardModel.value = cardModel.value.copyWith(nameOnCard: v);

  Future<void> pay() async {
    isLoading.value = true;
    final PaymentStatusModel status =
        await _service.submitPayment(cardModel.value);
    isLoading.value = false;
    Get.off(() => PaymentSuccessScreen(status: status));
  }
}