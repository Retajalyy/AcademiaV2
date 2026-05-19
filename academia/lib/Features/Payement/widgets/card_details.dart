import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:academia/Core/utilities/colors.dart';

class CardDetailsForm extends StatefulWidget {
  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<String> onExpiryChanged;
  final ValueChanged<String> onCvvChanged;
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
    required this.onCardNumberChanged,
    required this.onExpiryChanged,
    required this.onCvvChanged,
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
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl     = TextEditingController();
  final _cvvCtrl        = TextEditingController();
  final _nameCtrl       = TextEditingController();

  String? _cardNumberError;
  String? _expiryError;
  String? _cvvError;
  String? _nameError;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  /// Called by the parent before submitting. Returns true if all valid.
  bool validate() {
    final cardRaw = _cardNumberCtrl.text.replaceAll(' ', '');
    setState(() {
      _cardNumberError = _cardNumberCtrl.text.trim().isEmpty
          ? 'Required'
          : cardRaw.length != 16
              ? 'Enter a valid 16-digit card number'
              : null;

      _expiryError = _expiryCtrl.text.trim().isEmpty
          ? 'Required'
          : !_isValidExpiry(_expiryCtrl.text.trim())
              ? 'Enter a valid expiry (MM/YY)'
              : null;

      _cvvError = _cvvCtrl.text.trim().isEmpty
          ? 'Required'
          : _cvvCtrl.text.trim().length < 3
              ? 'Enter a valid CVV'
              : null;

      _nameError = _nameCtrl.text.trim().isEmpty ? 'Required' : null;
    });

    return _cardNumberError == null &&
        _expiryError == null &&
        _cvvError == null &&
        _nameError == null;
  }

  bool _isValidExpiry(String value) {
    final parts = value.split('/');
    if (parts.length != 2) return false;
    final month = int.tryParse(parts[0]);
    final year  = int.tryParse(parts[1]);
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    final now          = DateTime.now();
    final fullYear     = 2000 + year;
    final expiryDate   = DateTime(fullYear, month + 1);
    return expiryDate.isAfter(now);
  }

  // ── formatters ──────────────────────────────────────────────────────────────

  /// Groups card digits as "1234 1234 1234 1234"
  String _formatCardNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Auto-inserts "/" after two digits for MM/YY
  String _formatExpiry(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 2) return digits;
    return '${digits.substring(0, 2)}/${digits.substring(2, digits.length.clamp(0, 4))}';
  }

  // ── field builder ────────────────────────────────────────────────────────────

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool obscureText = false,
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
            // clear error on typing
            setState(() {
              if (label == 'Card Number') _cardNumberError = null;
              if (label == 'Expiry Date') _expiryError = null;
              if (label == 'CVV') _cvvError = null;
              if (label == 'Name on Card') _nameError = null;
            });
            onChanged(v);
          },
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
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
              // ── Card Number ────────────────────────────────────────────────
              _field(
                label: 'Card Number',
                hint: '1234 1234 1234 1234',
                controller: _cardNumberCtrl,
                errorText: _cardNumberError,
                keyboardType: TextInputType.number,
                maxLength: 19, // 16 digits + 3 spaces
                onChanged: (v) {
                  final formatted = _formatCardNumber(v);
                  if (formatted != v) {
                    _cardNumberCtrl.value = TextEditingValue(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                  widget.onCardNumberChanged(formatted);
                },
              ),
              const SizedBox(height: 10),

              // ── Expiry + CVV ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _field(
                      label: 'Expiry Date',
                      hint: 'MM/YY',
                      controller: _expiryCtrl,
                      errorText: _expiryError,
                      keyboardType: TextInputType.number,
                      maxLength: 5, // MM/YY
                      onChanged: (v) {
                        final formatted = _formatExpiry(v);
                        if (formatted != v) {
                          _expiryCtrl.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length),
                          );
                        }
                        widget.onExpiryChanged(formatted);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      label: 'CVV',
                      hint: '123',
                      controller: _cvvCtrl,
                      errorText: _cvvError,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      onChanged: (v) => widget.onCvvChanged(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Name on Card ───────────────────────────────────────────────
              _field(
                label: 'Name on Card',
                hint: 'John Doe',
                controller: _nameCtrl,
                errorText: _nameError,
                keyboardType: TextInputType.name,
                onChanged: (v) => widget.onNameChanged(v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}