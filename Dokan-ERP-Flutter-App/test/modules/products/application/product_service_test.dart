import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const product = DokanCatalogProduct(
    name: 'Test Product',
    barcode: 'SKU-101',
    category: 'Test',
    emoji: '',
    salePrice: 25,
    purchasePrice: 20,
    stock: 10,
    lowStockThreshold: 2,
    salesCount: 0,
    packInfo: '',
  );

  late ProductService service;

  setUp(() {
    service = ProductService(_FakeProductCatalogRepository([product]));
  });

  test('normalizes and resolves product identifiers', () {
    expect(service.getProduct(' barcode: sku-101 '), same(product));
  });

  test('calculates subtotal from repository products', () {
    expect(service.subtotalForCart({'SKU-101': 3}), 75);
  });
}

class _FakeProductCatalogRepository implements ProductCatalogRepository {
  _FakeProductCatalogRepository(this.products);

  @override
  final List<DokanCatalogProduct> products;

  @override
  void addProduct(DokanCatalogProduct product) {}

  @override
  void addStock(
    DokanCatalogProduct product, {
    required int amount,
    required int purchasePrice,
    required String referenceText,
  }) {}

  @override
  void reduceStock(
    DokanCatalogProduct product, {
    required int amount,
    required String reason,
  }) {}

  @override
  void updatePrice(
    DokanCatalogProduct product, {
    required int purchasePrice,
    required int salePrice,
  }) {}
}
