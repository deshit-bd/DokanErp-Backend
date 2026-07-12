import '../entities/product.dart';

abstract class ProductRepository {
  List<Product> getAll();

  Product add({
    required String name,
    required String brand,
    required String category,
    required String unit,
    required int buyPrice,
    required int sellPrice,
    required int minStock,
    required String barcode,
  });
}
