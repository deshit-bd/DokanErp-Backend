import '../../domain/entities/dokan_catalog_product.dart';

class PopularProductDraft {
  const PopularProductDraft({
    required this.name,
    required this.quantity,
    required this.emoji,
    required this.category,
    required this.stock,
    required this.salePrice,
  });

  final String name;
  final String quantity;
  final String emoji;
  final String category;
  final int stock;
  final int salePrice;
}

class PopularProductCatalogService {
  const PopularProductCatalogService();

  List<DokanCatalogProduct> createProducts(
    Iterable<PopularProductDraft> drafts,
  ) {
    return drafts.map(_createProduct).toList(growable: false);
  }

  DokanCatalogProduct _createProduct(PopularProductDraft draft) {
    return DokanCatalogProduct(
      name: '${draft.name} (${draft.quantity})',
      barcode: _barcode('${draft.name}|${draft.quantity}'),
      category: draft.category == 'সব' ? 'মুদি' : draft.category,
      emoji: draft.emoji,
      salePrice: draft.salePrice,
      purchasePrice: (draft.salePrice * 85 / 100).round(),
      stock: draft.stock,
      lowStockThreshold: 5,
      salesCount: 0,
      packInfo: draft.quantity,
    );
  }

  String _barcode(String value) {
    var checksum = 0;
    for (final unit in value.codeUnits) {
      checksum = (checksum * 31 + unit) & 0x7fffffff;
    }
    return '88${checksum.toString().padLeft(10, '0').substring(0, 10)}';
  }
}
