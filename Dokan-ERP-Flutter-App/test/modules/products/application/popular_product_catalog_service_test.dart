import 'package:dokan_erp/modules/products/products.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates deterministic catalog products from onboarding drafts', () {
    const service = PopularProductCatalogService();
    const draft = PopularProductDraft(
      name: 'Rice',
      quantity: '1 kg',
      emoji: '🌾',
      category: 'Grocery',
      stock: 20,
      salePrice: 100,
    );

    final first = service.createProducts(const [draft]).single;
    final second = service.createProducts(const [draft]).single;

    expect(first.barcode, second.barcode);
    expect(first.barcode, hasLength(12));
    expect(first.purchasePrice, 85);
    expect(first.stock, 20);
  });
}
