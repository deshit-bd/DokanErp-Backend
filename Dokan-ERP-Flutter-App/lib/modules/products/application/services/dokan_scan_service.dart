import '../../domain/entities/dokan_catalog_product.dart';
import 'product_service.dart';

class DokanScanResult {
  const DokanScanResult({
    required this.rawCode,
    required this.normalizedCode,
    required this.product,
  });

  final String rawCode;
  final String normalizedCode;
  final DokanCatalogProduct? product;

  bool get isResolved => product != null;
}

class DokanScanService {
  const DokanScanService(this._productService);

  final ProductService _productService;

  DokanScanResult resolve(String rawCode) {
    final normalizedCode = _productService.normalizeProductId(rawCode);
    final product = _productService.getProduct(normalizedCode);

    return DokanScanResult(
      rawCode: rawCode,
      normalizedCode: normalizedCode,
      product: product,
    );
  }

  /// Best-effort product lookup by (spoken) name for voice-driven selling.
  DokanCatalogProduct? findByName(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return null;
    final products = _productService.allProducts;
    for (final product in products) {
      if (product.name.toLowerCase() == needle) return product;
    }
    for (final product in products) {
      final name = product.name.toLowerCase();
      if (name.contains(needle) || needle.contains(name)) return product;
    }
    return null;
  }
}
