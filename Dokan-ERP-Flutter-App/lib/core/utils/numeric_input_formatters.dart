import 'package:flutter/services.dart';

class TrimLeadingZeroInputFormatter extends TextInputFormatter {
  const TrimLeadingZeroInputFormatter({this.allowDecimal = false});

  final bool allowDecimal;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length < 2 || !text.startsWith('0')) {
      return newValue;
    }
    if (allowDecimal && text.startsWith('0.')) {
      return newValue;
    }

    final trimmed = text.replaceFirst(RegExp(r'^0+'), '');
    final normalized = trimmed.isEmpty ? '0' : trimmed;
    final offsetDelta = text.length - normalized.length;
    final selection = newValue.selection;

    return newValue.copyWith(
      text: normalized,
      selection: selection.copyWith(
        baseOffset:
            (selection.baseOffset - offsetDelta).clamp(0, normalized.length),
        extentOffset:
            (selection.extentOffset - offsetDelta).clamp(0, normalized.length),
      ),
      composing: TextRange.empty,
    );
  }
}

class DecimalNumberInputFormatter extends TextInputFormatter {
  const DecimalNumberInputFormatter();

  static final RegExp _decimalPattern = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!_decimalPattern.hasMatch(newValue.text)) {
      return oldValue;
    }
    return const TrimLeadingZeroInputFormatter(allowDecimal: true)
        .formatEditUpdate(oldValue, newValue);
  }
}

abstract final class NumericInputFormatters {
  static final List<TextInputFormatter> wholeNumber = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    const TrimLeadingZeroInputFormatter(),
  ];

  static final List<TextInputFormatter> decimal = <TextInputFormatter>[
    const DecimalNumberInputFormatter(),
  ];
}
