// lib/Features/fees_admin/widgets/active_fee_card.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/utilities/colors.dart';
import '../controller/fee_admin_controller.dart';
import '../model/fee_admin_model.dart';

class ActiveFeesContainer extends StatelessWidget {
  const ActiveFeesContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FeesAdminController>();

    return Obx(() {
      final fees = c.activeFees;

      if (fees.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fees.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
          ),
          itemBuilder: (context, index) {
            return _FeeItem(fee: fees[index]);
          },
        ),
      );
    });
  }
}

class _FeeItem extends StatelessWidget {
  final ActiveFeeModel fee;

  const _FeeItem({required this.fee});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP ROW ─────────────────────────────────────────────────────
          Row(
            children: [
              // ICON
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bluegroundicon,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  fee.icon,
                  size: 23,
                  color: AppColors.accentProgramming1,
                ),
              ),

              const SizedBox(width: 10),

              // TITLE + SUBTITLE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fee.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      fee.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.smalltext,
                      ),
                    ),
                  ],
                ),
              ),

              // AMOUNT
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "${fee.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text: "EGP",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.smalltext,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // EDIT / DELETE MENU
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.smalltext,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditFeeDialog(context, fee);
                  } else if (value == 'delete') {
                    _showDeleteFeeDialog(context, fee);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.smalltext),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.fail),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.fail)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── PROGRESS LABEL ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Collection progress",
                style: TextStyle(fontSize: 13, color: AppColors.smalltext),
              ),
              Text(
                fee.progressText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── PROGRESS BAR ─────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: fee.progress,
              minHeight: 7,
              backgroundColor: AppColors.greytext,
              borderRadius: BorderRadius.circular(8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryBlue,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── DUE DATE ─────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                fee.isOverdue
                    ? Icons.error_outline
                    : Icons.access_time_outlined,
                size: 15,
                color: fee.isOverdue ? AppColors.fail : AppColors.smalltext,
              ),
              const SizedBox(width: 4),
              Text(
                fee.dueDateLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: fee.isOverdue ? AppColors.fail : AppColors.smalltext,
                  fontWeight:
                      fee.isOverdue ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showDeleteFeeDialog(BuildContext context, ActiveFeeModel fee) {
  showCupertinoDialog<void>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: const Text('Delete Fee'),
      content: Text(
        'Delete "${fee.title}" (${fee.amount.toStringAsFixed(0)} EGP) for students '
        'who haven\'t paid it yet? Students who already paid are not affected.',
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(ctx).pop();
            Get.find<FeesAdminController>().deleteFee(fee);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

void _showEditFeeDialog(BuildContext context, ActiveFeeModel fee) {
  showDialog(
    context: context,
    builder: (_) => _EditFeeDialog(fee: fee),
  );
}

class _EditFeeDialog extends StatefulWidget {
  final ActiveFeeModel fee;

  const _EditFeeDialog({required this.fee});

  @override
  State<_EditFeeDialog> createState() => _EditFeeDialogState();
}

class _EditFeeDialogState extends State<_EditFeeDialog> {
  late final TextEditingController _amountController;
  late DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.fee.amount.toStringAsFixed(0));
    _dueDate = widget.fee.rawDueDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    DateTime tempDate = _dueDate ?? DateTime.now();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                  onPressed: () {
                    setState(() => _dueDate = tempDate);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: tempDate,
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (d) => tempDate = d,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter a valid amount',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_dueDate == null) {
      Get.snackbar('Missing Due Date', 'Please select a due date',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Navigator.of(context).pop();
    Get.find<FeesAdminController>().updateFee(widget.fee, amount, _dueDate!);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Edit Fee'),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fee.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text('Amount (EGP)', style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
            const SizedBox(height: 6),
            CupertinoTextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              placeholder: 'Amount',
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            const SizedBox(height: 14),
            const Text('Due Date', style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDueDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemFill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dueDate == null
                          ? 'Select date'
                          : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Icon(CupertinoIcons.calendar, size: 16, color: CupertinoColors.secondaryLabel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}