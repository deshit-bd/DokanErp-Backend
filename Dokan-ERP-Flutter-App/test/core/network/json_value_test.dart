import 'package:dokan_erp/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads snake and camel case fallback values', () {
    final json = {
      'sale_price': '125',
      'is_active': 1,
      'created_at': '2030-01-01T00:00:00Z',
    };

    expect(JsonValue.integer(json, const ['salePrice', 'sale_price']), 125);
    expect(JsonValue.boolean(json, const ['is_active']), isTrue);
    expect(
      JsonValue.dateTime(json, const ['created_at']).toUtc(),
      DateTime.utc(2030),
    );
  });
}
