import '../../../products/domain/entities/dokan_catalog_product.dart';

abstract interface class PurchaseProductCatalogRepository {
  Future<List<DokanCatalogProduct>> loadProducts();
}
