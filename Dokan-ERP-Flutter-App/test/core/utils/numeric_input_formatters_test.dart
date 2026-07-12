import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dokan_erp/core/core.dart';

void main() {
  group('TrimLeadingZeroInputFormatter', () {
    test('removes leading zero from whole number input', () {
      const formatter = TrimLeadingZeroInputFormatter();

      final value = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '0',
          selection: TextSelection.collapsed(offset: 1),
        ),
        const TextEditingValue(
          text: '06',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );

      expect(value.text, '6');
      expect(value.selection.baseOffset, 1);
    });

    test('keeps a single zero when input is only zeros', () {
      const formatter = TrimLeadingZeroInputFormatter();

      final value = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '000',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );

      expect(value.text, '0');
    });

    test('allows decimal values that start with zero', () {
      const formatter = TrimLeadingZeroInputFormatter(allowDecimal: true);

      final value = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '0',
          selection: TextSelection.collapsed(offset: 1),
        ),
        const TextEditingValue(
          text: '0.5',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );

      expect(value.text, '0.5');
    });
  });

  group('DecimalNumberInputFormatter', () {
    test('rejects a second decimal point', () {
      const formatter = DecimalNumberInputFormatter();

      final oldValue = const TextEditingValue(
        text: '10.5',
        selection: TextSelection.collapsed(offset: 4),
      );
      final value = formatter.formatEditUpdate(
        oldValue,
        const TextEditingValue(
          text: '10.5.',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );

      expect(value.text, oldValue.text);
    });
  });
}
