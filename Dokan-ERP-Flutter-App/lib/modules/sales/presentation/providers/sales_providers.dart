import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../domain/entities/cart_line.dart';

final saleCatalogProvider = Provider<List<Product>>(
  (ref) => ref.watch(productsProvider),
);

final saleQuickProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(saleCatalogProvider);
  return products.take(8).toList(growable: false);
});

final salePopularProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(saleCatalogProvider);
  return products.reversed.take(6).toList(growable: false);
});

final salesCartProvider =
    StateNotifierProvider<SalesCartNotifier, Map<String, int>>(
  (ref) => SalesCartNotifier(),
);

final salesCartLinesProvider = Provider<List<CartLine>>((ref) {
  final cart = ref.watch(salesCartProvider);
  return cart.entries
      .map((entry) => CartLine(productId: entry.key, quantity: entry.value))
      .toList(growable: false);
});

class SalesCartNotifier extends StateNotifier<Map<String, int>> {
  SalesCartNotifier() : super(const <String, int>{});

  void addProduct(Product product) {
    state = <String, int>{
      ...state,
      product.id: (state[product.id] ?? 0) + 1,
    };
  }

  void clear() {
    state = const <String, int>{};
  }
}
