import '../entities/dokan_catalog_product.dart';

abstract interface class ProductCatalogRepository {
  List<DokanCatalogProduct> get products;

  void addProduct(DokanCatalogProduct product);

  void addStock(
    DokanCatalogProduct product, {
    required int amount,
    required int purchasePrice,
    required String referenceText,
  });

  void reduceStock(
    DokanCatalogProduct product, {
    required int amount,
    required String reason,
  });

  void updatePrice(
    DokanCatalogProduct product, {
    required int purchasePrice,
    required int salePrice,
  });
}
