import '../../../products/domain/entities/dokan_catalog_product.dart';
import '../../domain/repositories/cart_repository.dart';

class CartService {
  const CartService(this._repository);

  final CartRepository _repository;

  void addProduct(DokanCatalogProduct product) {
    _repository.addItem(product.barcode, stockLimit: product.stock);
  }

  void removeProduct(String productId) {
    _repository.removeItem(productId);
  }

  void setQuantity(DokanCatalogProduct product, int quantity) {
    _repository.setItemQuantity(
      product.barcode,
      quantity,
      stockLimit: product.stock,
    );
  }
}
