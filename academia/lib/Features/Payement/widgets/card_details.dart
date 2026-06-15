import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:academia/Core/utilities/colors.dart';

class CardDetailsForm extends StatefulWidget {
  final ValueChanged<String> onNameChanged;
  final GlobalKey<CardDetailsFormState> formKey;

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
    required this.formKey,
    required this.onNameChanged,
    this.containerColor = const Color(0xFFF4F3F3),
    this.containerBorderColor = const Color(0x12000000),
    this.sectionTitle = 'CARD DETAILS',
    this.sectionTitleColor = AppColors.textgrey,
    this.labelColor = AppColors.textgrey,
    this.labelFontSize = 14,
    this.labelFontWeight = FontWeight.w500,
    this.fieldFillColor = Colors.white,
    this.fieldBorderColor = const Color(0x12000000),
    this.fieldFocusedBorderColor = const Color(0x40000000),
    this.hintColor = const Color(0xFF848282),
    this.hintFontSize = 14,
  }) : super(key: formKey);

  @override
  State<CardDetailsForm> createState() => CardDetailsFormState();
}

class CardDetailsFormState extends State<CardDetailsForm> {
  final _nameCtrl = TextEditingController();

  bool _cardComplete = false;
  String? _cardError;
  String? _nameError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  /// Called by the parent before submitting. Returns true if all valid.
  bool validate() {
    setState(() {
      _cardError = _cardComplete ? null : 'Enter complete card details';
      _nameError = _nameCtrl.text.trim().isEmpty ? 'Required' : null;
    });
    return _cardError == null && _nameError == null;
  }

  // ── field builder (used for Name on Card) ────────────────────────────────

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: widget.labelColor,
            fontSize: widget.labelFontSize,
            fontWeight: widget.labelFontWeight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (v) {
            setState(() => _nameError = null);
            onChanged(v);
          },
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: widget.hintColor, fontSize: widget.hintFontSize),
            errorText: errorText,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
            filled: true,
            fillColor: widget.fieldFillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.fieldBorderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : widget.fieldBorderColor,
                width: errorText != null ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? Colors.red
                    : widget.fieldFocusedBorderColor,
                width: 1.5,
              ),
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
          widget.sectionTitle,
          style: TextStyle(
            color: widget.sectionTitleColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.containerColor,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: widget.containerBorderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card Number / Expiry / CVC — collected directly by the
              // Stripe SDK, never seen by app code ────────────────────────
              Text(
                'Card Information',
                style: TextStyle(
                  color: widget.labelColor,
                  fontSize: widget.labelFontSize,
                  fontWeight: widget.labelFontWeight,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: widget.fieldFillColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _cardError != null ? Colors.red : widget.fieldBorderColor,
                    width: _cardError != null ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CardField(
                  onCardChanged: (details) {
                    setState(() {
                      _cardComplete = details?.complete ?? false;
                      if (_cardComplete) _cardError = null;
                    });
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Card number   MM/YY   CVC',
                    hintStyle: TextStyle(
                        color: widget.hintColor, fontSize: widget.hintFontSize),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_cardError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _cardError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 10),

              // ── Name on Card ───────────────────────────────────────────────
              _field(
                label: 'Name on Card',
                hint: 'John Doe',
                controller: _nameCtrl,
                errorText: _nameError,
                onChanged: (v) => widget.onNameChanged(v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
