import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../Core/utilities/colors.dart';
import 'package:academia/Core/utilities/text_style.dart';
import '../models/fee_model.dart';

class PaidFeeCard extends StatelessWidget {
  final List<FeeModel> fees;
  const PaidFeeCard({super.key, required this.fees});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "PAID FEES",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.mainGreen,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...fees.map((fee) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PaidFeeItem(fee: fee),
            )),
      ],
    );
  }
}

Future<void> _downloadInvoice(BuildContext context, FeeModel fee, Rect shareRect) async {
  try {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ]),
            pw.SizedBox(height: 8),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text(fee.label),
              pw.Text(fee.formattedAmount),
            ]),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('PAID', style: pw.TextStyle(color: PdfColors.green700, fontWeight: pw.FontWeight.bold)),
            ]),
            if (fee.formattedPaidOn != null) ...[
              pw.SizedBox(height: 4),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Payment Date'),
                pw.Text(fee.formattedPaidOn!),
              ]),
            ],
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_${fee.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Invoice - ${fee.label}',
      sharePositionOrigin: shareRect,
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _PaidFeeItem extends StatelessWidget {
  final FeeModel fee;
  const _PaidFeeItem({required this.fee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5EF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book,
                    color: AppColors.darkGreen, size: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        fontFamily: 'Instrument Sans',
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "Amount paid",
                      style: TextStyles.percenatge
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fee.formattedAmount,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Paid",
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E7EB), height: 20, thickness: 1),
          Row(
            children: [
              const Icon(Icons.check_circle,
                  size: 18, color: Color(0xFFB3B3B3)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  fee.formattedPaidOn != null
                      ? "Paid on ${fee.formattedPaidOn}"
                      : "Payment confirmed",
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF848282)),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final box = context.findRenderObject() as RenderBox?;
                  final rect = box == null
                      ? Rect.fromCenter(
                          center: MediaQuery.of(context).size.center(Offset.zero),
                          width: 1, height: 1)
                      : box.localToGlobal(Offset.zero) & box.size;
                  _downloadInvoice(context, fee, rect);
                },
                child: const Row(
                  children: [
                    Icon(Icons.download, size: 15, color: AppColors.primaryBlue),
                    SizedBox(width: 4),
                    Text(
                      "Download invoice",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
