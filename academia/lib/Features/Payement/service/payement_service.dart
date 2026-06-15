import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academia/Features/Payement/model/payement_card_model.dart';
import 'package:academia/Features/Payement/model/order_summary_model.dart';
import 'package:academia/Features/Payement/model/payement_status_model.dart';

class PaymentService {
  final _db = Supabase.instance.client;

  Future<int> _getStudentId() async {
    final userId = _db.auth.currentUser!.id;
    final row = await _db
        .from('students')
        .select('id')
        .eq('profile_id', userId)
        .single();
    return row['id'] as int;
  }

  Future<OrderSummaryModel> getOrderSummary() async {
    final studentId = await _getStudentId();

    final feesData = await _db
        .from('student_fees')
        .select('label, amount')
        .eq('student_id', studentId)
        .eq('is_paid', false)
        .order('due_date');

    final fees = feesData as List;
    final total = fees.fold<double>(
        0, (sum, f) => sum + (f['amount'] as num).toDouble());

    final label = fees.isEmpty
        ? 'No outstanding fees'
        : fees.length == 1
            ? (fees.first['label'] as String? ?? 'Tuition Fee')
            : '${fees.length} outstanding fees';

    final window = await _db
        .from('registration_windows')
        .select('next_semester_label, next_year_label')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();
    final semesterParts = [
      window?['next_semester_label'] as String?,
      window?['next_year_label'] as String?,
    ].whereType<String>().where((s) => s.isNotEmpty).toList();
    final semester = semesterParts.join(' – ');

    return OrderSummaryModel(
      fee: label,
      semester: semester,
      totalAmount: total,
    );
  }

  /// Charges the student's outstanding fees via Stripe (test mode) and, on
  /// success, marks them as paid.
  ///
  /// The amount is computed server-side by the `stripe-payment` edge
  /// function (mode "create") from the student's unpaid `student_fees`
  /// rows — the client never tells the server how much to charge. After
  /// Stripe confirms the PaymentIntent, the edge function (mode "confirm")
  /// re-checks its status with Stripe and updates `student_fees` using the
  /// service role, so no client-side write to `student_fees` is needed.
  Future<PaymentStatusModel> submitPayment(PaymentCardModel card) async {
    if (card.nameOnCard.trim().isEmpty) {
      return const PaymentStatusModel(
        isSuccess: false,
        message: 'Please enter the name on your card.',
      );
    }

    try {
      final createResp = await _db.functions.invoke(
        'stripe-payment',
        body: {'mode': 'create'},
      );
      final createData = createResp.data as Map<String, dynamic>;
      if (createData['error'] != null) {
        return PaymentStatusModel(
          isSuccess: false,
          message: createData['error'].toString(),
        );
      }
      final clientSecret = createData['clientSecret'] as String;

      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(name: card.nameOnCard),
          ),
        ),
      );

      if (paymentIntent.status != PaymentIntentsStatus.Succeeded) {
        return PaymentStatusModel(
          isSuccess: false,
          message:
              'Payment was not completed (status: ${paymentIntent.status.name}).',
        );
      }

      final confirmResp = await _db.functions.invoke(
        'stripe-payment',
        body: {'mode': 'confirm', 'paymentIntentId': paymentIntent.id},
      );
      final confirmData = confirmResp.data as Map<String, dynamic>;
      if (confirmData['success'] != true) {
        return PaymentStatusModel(
          isSuccess: false,
          message: confirmData['message']?.toString() ??
              confirmData['error']?.toString() ??
              'Payment could not be confirmed.',
        );
      }

      return PaymentStatusModel(
        isSuccess: true,
        message: 'Payment successful!',
        transactionId: confirmData['transactionId'] as String?,
      );
    } on StripeException catch (e) {
      return PaymentStatusModel(
        isSuccess: false,
        message: e.error.localizedMessage ?? 'Payment failed.',
      );
    } catch (e) {
      return PaymentStatusModel(
        isSuccess: false,
        message: 'Payment failed: $e',
      );
    }
  }
}
