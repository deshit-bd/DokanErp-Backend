import '../../../auth/domain/entities/dokan_role.dart';
import '../../domain/entities/dokan_catalog_product.dart';

enum DokanQrActionType {
  openInventory,
  addToCart,
}

class DokanQrAction {
  const DokanQrAction({
    required this.type,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });

  final DokanQrActionType type;
  final String title;
  final String description;
  final String buttonLabel;
}

class DokanQrActionResolver {
  DokanQrAction resolve(DokanRole role, DokanCatalogProduct product) {
    switch (role) {
      case DokanRole.owner:
        return const DokanQrAction(
          type: DokanQrActionType.openInventory,
          title: 'Inventory management',
          description: 'Review stock, price, and analytics for this product.',
          buttonLabel: 'Open inventory view',
        );
      case DokanRole.salesman:
        return const DokanQrAction(
          type: DokanQrActionType.addToCart,
          title: 'Add to cart',
          description: 'Add this product to the current sales cart instantly.',
          buttonLabel: 'Add to cart',
        );
    }
  }
}
