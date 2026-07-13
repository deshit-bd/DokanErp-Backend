import 'package:dokan_erp/modules/products/products.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  group('DokanScanService findByName bilingual checks', () {
    const p1 = DokanCatalogProduct(
      name: 'লাক্স সাবান ১০০গ্রা',
      barcode: 'LUX-101',
      category: 'Test',
      emoji: '',
      salePrice: 50,
      purchasePrice: 40,
      stock: 10,
      lowStockThreshold: 2,
      salesCount: 0,
      packInfo: '',
    );
    const p2 = DokanCatalogProduct(
      name: 'Sugar 1kg',
      barcode: 'SUGAR-102',
      category: 'Test',
      emoji: '',
      salePrice: 120,
      purchasePrice: 100,
      stock: 10,
      lowStockThreshold: 2,
      salesCount: 0,
      packInfo: '',
    );
    
    const p3 = DokanCatalogProduct(
      name: 'Sakib',
      barcode: 'SAKIB-103',
      category: 'Test',
      emoji: '',
      salePrice: 10,
      purchasePrice: 5,
      stock: 10,
      lowStockThreshold: 2,
      salesCount: 0,
      packInfo: '',
    );
    const p4 = DokanCatalogProduct(
      name: 'সাগর তেল',
      barcode: 'SAGOR-104',
      category: 'Test',
      emoji: '',
      salePrice: 100,
      purchasePrice: 80,
      stock: 10,
      lowStockThreshold: 2,
      salesCount: 0,
      packInfo: '',
    );
    
    late DokanScanService scanService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      final fakeRepo = _FakeProductCatalogRepository([p1, p2, p3, p4]);
      final prodService = ProductService(fakeRepo);
      scanService = DokanScanService(prodService);
    });

    test('matches English spoken inputs to Bangla catalog items', () {
      final match = scanService.findByName('lux soap');
      expect(match, same(p1));
    });

    test('matches Bangla spoken inputs to English catalog items', () {
      final match = scanService.findByName('চিনি');
      expect(match, same(p2));
    });

    test('matches partial inputs', () {
      final match = scanService.findByName('soap');
      expect(match, same(p1));
    });

    test('matches spoken Bangla to phonetic English catalog items (e.g. সাকিব to Sakib)', () {
      final match = scanService.findByName('সাকিব');
      expect(match, same(p3));
    });

    test('matches spoken English to phonetic Bangla catalog items (e.g. sagor to সাগর)', () {
      final match = scanService.findByName('sagor');
      expect(match, same(p4));
    });

    test('supports dynamically registered custom synonyms', () {
      expect(scanService.findByName('pepsi'), isNull);

      scanService.registerSynonym('pepsi', 'লাক্স');

      final match = scanService.findByName('pepsi');
      expect(match, same(p1));
    });
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
