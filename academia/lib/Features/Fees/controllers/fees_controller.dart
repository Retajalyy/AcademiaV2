import 'package:get/get.dart';
import '../models/fee_model.dart';
import '../services/fees_service.dart';

class FeesController extends GetxController {
  final FeesService _service = FeesService();

  var fees      = <FeeModel>[].obs;
  var isLoading = true.obs;

  List<FeeModel> get dueFees  => fees.where((f) => !f.isPaid).toList();
  List<FeeModel> get paidFees => fees.where((f) =>  f.isPaid).toList();

  double get totalAmount       => fees.fold(0.0, (s, f) => s + f.amount);
  double get paidAmount        => paidFees.fold(0.0, (s, f) => s + f.amount);
  double get outstandingAmount => dueFees.fold(0.0, (s, f) => s + f.amount);
  double get progress          => totalAmount > 0 ? paidAmount / totalAmount : 0;

  String get formattedOutstanding => _fmt(outstandingAmount, fees.isNotEmpty ? fees.first.currency : 'EGP');
  String get formattedPaid        => _fmt(paidAmount,        fees.isNotEmpty ? fees.first.currency : 'EGP');
  String get formattedTotal       => _fmt(totalAmount,       fees.isNotEmpty ? fees.first.currency : 'EGP');

  String get nearestDueDate {
    final unpaid = dueFees..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return unpaid.isNotEmpty ? unpaid.first.formattedDueDate : '';
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      fees.value = await _service.fetchFees();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load fees: $e');
    } finally {
      isLoading.value = false;
    }
  }

  static String _fmt(double amount, String currency) {
    final n = amount.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < n.length; i++) {
      if (i > 0 && (n.length - i) % 3 == 0) buf.write(',');
      buf.write(n[i]);
    }
    return '${buf.toString()} $currency';
  }
}
