import '../../domain/entities/dokan_catalog_product.dart';
import '../../domain/repositories/product_catalog_repository.dart';

class InventoryService {
  const InventoryService(this._repository);

  final ProductCatalogRepository _repository;

  void addStock(
    DokanCatalogProduct product, {
    required int amount,
    required int purchasePrice,
    required String referenceText,
  }) {
    _repository.addStock(
      product,
      amount: amount,
      purchasePrice: purchasePrice,
      referenceText: referenceText,
    );
  }

  void reduceStock(
    DokanCatalogProduct product, {
    required int amount,
    required String reason,
  }) {
    _repository.reduceStock(product, amount: amount, reason: reason);
  }

  void updatePrice(
    DokanCatalogProduct product, {
    required int purchasePrice,
    required int salePrice,
  }) {
    _repository.updatePrice(
      product,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
    );
  }
}
