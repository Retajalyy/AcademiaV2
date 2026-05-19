import 'package:flutter/material.dart';
import 'package:academia/Core/utilities/colors.dart';

class CardDetailsForm extends StatelessWidget {
  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<String> onExpiryChanged;
  final ValueChanged<String> onCvvChanged;
  final ValueChanged<String> onNameChanged;

  // ── Container customization
  final Color containerColor;
  final Color containerBorderColor;
  // ── Section title
  final String sectionTitle;
  final Color sectionTitleColor;
  // ── Label
  final Color labelColor;
  final double labelFontSize;
  final FontWeight labelFontWeight;
  // ── Field colors
  final Color fieldFillColor;
  final Color fieldBorderColor;
  final Color fieldFocusedBorderColor;
  final Color hintColor;
  final double hintFontSize;

  const CardDetailsForm({
    super.key,
    required this.onCardNumberChanged,
    required this.onExpiryChanged,
    required this.onCvvChanged,
    required this.onNameChanged,
    this.containerColor        = const Color(0xFFF4F3F3),
    this.containerBorderColor  = const Color(0x12000000),
    this.sectionTitle          = 'CARD DETAILS',
    this.sectionTitleColor     = AppColors.textgrey,
    this.labelColor            = AppColors.textgrey,
    this.labelFontSize         = 14,
    this.labelFontWeight       = FontWeight.w500,
    this.fieldFillColor        = Colors.white,
    this.fieldBorderColor      = const Color(0x12000000),
    this.fieldFocusedBorderColor = const Color(0x40000000),
    this.hintColor             = const Color(0xFF848282),
    this.hintFontSize          = 14,
  });

  Widget _field(
    String label,
    String hint,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: labelFontSize,
            fontWeight: labelFontWeight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: hintFontSize),
            filled: true,
            fillColor: fieldFillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: fieldBorderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: fieldBorderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: fieldFocusedBorderColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: TextStyle(
            color: sectionTitleColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: containerBorderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('Card Number', '1234 1234 1234 1234', onCardNumberChanged),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _field('Expiry Date', 'MM/YY', onExpiryChanged)),
                  const SizedBox(width: 10),
                  Expanded(child: _field('CVV', '123', onCvvChanged)),
                ],
              ),
              const SizedBox(height: 10),
              _field('Name on Card', '', onNameChanged),
            ],
          ),
        ),
      ],
    );
  }
}