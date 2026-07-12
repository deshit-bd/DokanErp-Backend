import '../../domain/entities/dokan_catalog_product.dart';
import '../../domain/repositories/product_catalog_repository.dart';

class DokanBatchSaleAllocation {
  const DokanBatchSaleAllocation({
    required this.product,
    required this.quantity,
    required this.salePrice,
    required this.purchasePrice,
    this.batchNo = '',
  });

  final DokanCatalogProduct product;
  final int quantity;
  final int salePrice;
  final int purchasePrice;
  final String batchNo;
}

class ProductService {
  const ProductService(this._repository);

  final ProductCatalogRepository _repository;

  List<DokanCatalogProduct> get allProducts => _repository.products;

  String normalizeProductId(String input) {
    var normalized = input.trim().toUpperCase();
    final prefix = RegExp(r'^(PRODUCT\s*ID|PRODUCTID|SKU|BARCODE)\s*[:#-]?\s*');
    while (prefix.hasMatch(normalized)) {
      normalized = normalized.replaceFirst(prefix, '');
    }
    return normalized.replaceAll(RegExp(r'\s+'), '');
  }

  DokanCatalogProduct? getProduct(String productId) {
    final normalized = normalizeProductId(productId);
    if (normalized.isEmpty) return null;

    for (final product in allProducts) {
      final barcode = normalizeProductId(product.barcode);
      if (barcode == normalized) {
        return product;
      }
    }
    return null;
  }

  List<DokanBatchSaleAllocation> allocateBatchesForSale(
    DokanCatalogProduct product,
    int quantity, {
    String stockMethod = 'FIFO',
  }) {
    if (quantity <= 0) {
      return const <DokanBatchSaleAllocation>[];
    }

    final batches = [...product.batches]..sort((left, right) {
        final leftValue = left.createdAt?.millisecondsSinceEpoch ?? 0;
        final rightValue = right.createdAt?.millisecondsSinceEpoch ?? 0;
        return stockMethod == 'LIFO'
            ? rightValue.compareTo(leftValue)
            : leftValue.compareTo(rightValue);
      });

    final allocations = <DokanBatchSaleAllocation>[];
    var remaining = quantity;

    for (final batch in batches) {
      if (remaining <= 0) {
        break;
      }
      if (batch.quantity <= 0) {
        continue;
      }

      final allocated = remaining < batch.quantity ? remaining : batch.quantity;
      allocations.add(
        DokanBatchSaleAllocation(
          product: product,
          quantity: allocated,
          salePrice: batch.salePrice > 0 ? batch.salePrice : product.salePrice,
          purchasePrice: batch.purchasePrice > 0
              ? batch.purchasePrice
              : product.purchasePrice,
          batchNo: batch.batchNo,
        ),
      );
      remaining -= allocated;
    }

    if (remaining > 0) {
      allocations.add(
        DokanBatchSaleAllocation(
          product: product,
          quantity: remaining,
          salePrice: product.salePrice,
          purchasePrice: product.purchasePrice,
          batchNo: '',
        ),
      );
    }

    return allocations;
  }

  int subtotalForCart(
    Map<String, int> cartQuantities, {
    String stockMethod = 'FIFO',
  }) {
    var total = 0;
    for (final entry in cartQuantities.entries) {
      final product = getProduct(entry.key);
      if (product == null) {
        continue;
      }
      final allocations = allocateBatchesForSale(
        product,
        entry.value,
        stockMethod: stockMethod,
      );
      for (final allocation in allocations) {
        total += allocation.salePrice * allocation.quantity;
      }
    }
    return total;
  }
}
