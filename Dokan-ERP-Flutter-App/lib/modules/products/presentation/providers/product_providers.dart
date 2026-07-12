import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => throw UnimplementedError('Override productRepositoryProvider'),
);

final productsProvider =
    StateNotifierProvider<ProductListNotifier, List<Product>>(
  (ref) => ProductListNotifier(ref.watch(productRepositoryProvider)),
);

final lowStockProductsProvider = Provider<List<Product>>(
  (ref) => ref
      .watch(productsProvider)
      .where((product) => product.isLowStock)
      .toList(growable: false),
);

class ProductListNotifier extends StateNotifier<List<Product>> {
  ProductListNotifier(this._repository) : super(_repository.getAll());

  final ProductRepository _repository;

  Product add({
    required String name,
    required String brand,
    required String category,
    required String unit,
    required int buyPrice,
    required int sellPrice,
    required int minStock,
    required String barcode,
  }) {
    final product = _repository.add(
      name: name,
      brand: brand,
      category: category,
      unit: unit,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      minStock: minStock,
      barcode: barcode,
    );
    state = _repository.getAll();
    return product;
  }
}
