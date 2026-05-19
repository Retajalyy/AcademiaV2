class FeeModel {
  final int id;
  final String label;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidOn;

  FeeModel({
    required this.id,
    required this.label,
    required this.amount,
    required this.currency,
    required this.dueDate,
    required this.isPaid,
    this.paidOn,
  });

  String get formattedAmount {
    final n = amount.toInt();
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()} $currency';
  }

  String get formattedDueDate => _fmt(dueDate);
  String? get formattedPaidOn => paidOn != null ? _fmt(paidOn!) : null;

  static String _fmt(DateTime d) {
    const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }

  factory FeeModel.fromMap(Map<String, dynamic> row) {
    return FeeModel(
      id:       row['id']       as int,
      label:    row['label']    as String? ?? 'Fee',
      amount:   (row['amount']  as num).toDouble(),
      currency: row['currency'] as String? ?? 'EGP',
      dueDate:  DateTime.parse(row['due_date'] as String),
      isPaid:   row['is_paid']  as bool? ?? false,
      paidOn:   row['paid_on'] != null
          ? DateTime.parse(row['paid_on'] as String)
          : null,
    );
  }
}
