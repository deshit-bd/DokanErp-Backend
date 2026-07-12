import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class InMemoryProductRepository implements ProductRepository {
  final List<Product> _products = <Product>[
    const Product(
      id: 'P001',
      name: 'Soybean Oil 1L',
      nameBn: 'সয়াবিন তেল',
      category: 'Oil',
      buyPrice: 120,
      sellPrice: 150,
      stock: 45,
      code: 'P001',
      unit: 'Litre',
      minStock: 10,
      barcode: '880100000001',
      emoji: '🛢️',
    ),
    const Product(
      id: 'P002',
      name: 'Rice 5kg',
      nameBn: 'চাল',
      category: 'Grain',
      buyPrice: 230,
      sellPrice: 280,
      stock: 8,
      code: 'P002',
      unit: 'Kg',
      minStock: 10,
      barcode: '880100000002',
      emoji: '🌾',
    ),
    const Product(
      id: 'P003',
      name: 'Sugar 1kg',
      nameBn: 'চিনি',
      category: 'Grocery',
      buyPrice: 68,
      sellPrice: 85,
      stock: 32,
      code: 'P003',
      unit: 'Kg',
      minStock: 8,
      barcode: '880100000003',
      emoji: '🧂',
    ),
    const Product(
      id: 'P004',
      name: 'Salt 1kg',
      nameBn: 'লবণ',
      category: 'Grocery',
      buyPrice: 25,
      sellPrice: 35,
      stock: 5,
      code: 'P004',
      unit: 'Kg',
      minStock: 8,
      barcode: '880100000004',
      emoji: '🧂',
    ),
    const Product(
      id: 'P005',
      name: 'Flour 2kg',
      nameBn: 'আটা',
      category: 'Grain',
      buyPrice: 88,
      sellPrice: 110,
      stock: 28,
      code: 'P005',
      unit: 'Kg',
      minStock: 10,
      barcode: '880100000005',
      emoji: '🌾',
    ),
    const Product(
      id: 'P006',
      name: 'Milk Powder 500g',
      nameBn: 'দুধ গুঁড়া',
      category: 'Dairy',
      buyPrice: 280,
      sellPrice: 340,
      stock: 18,
      code: 'P006',
      unit: 'Pack',
      minStock: 6,
      barcode: '880100000006',
      emoji: '🥛',
    ),
    const Product(
      id: 'P007',
      name: 'Mustard Oil 500ml',
      nameBn: 'সরিষার তেল',
      category: 'Oil',
      buyPrice: 115,
      sellPrice: 145,
      stock: 22,
      code: 'P007',
      unit: 'Litre',
      minStock: 8,
      barcode: '880100000007',
      emoji: '🛢️',
    ),
    const Product(
      id: 'P008',
      name: 'Lentil 1kg',
      nameBn: 'ডাল',
      category: 'Grain',
      buyPrice: 78,
      sellPrice: 95,
      stock: 3,
      code: 'P008',
      unit: 'Kg',
      minStock: 8,
      barcode: '880100000008',
      emoji: '🫘',
    ),
  ];

  @override
  List<Product> getAll() => List<Product>.unmodifiable(_products);

  @override
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
    final nextIndex = _products.length + 1;
    final product = Product(
      id: 'P${nextIndex.toString().padLeft(3, '0')}',
      name: name,
      nameBn: name,
      brand: brand,
      category: category,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      stock: minStock,
      code: 'P${nextIndex.toString().padLeft(3, '0')}',
      unit: unit,
      minStock: minStock,
      barcode: barcode,
      emoji: _emojiForCategory(category),
    );
    _products.insert(0, product);
    return product;
  }

  String _emojiForCategory(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('oil')) return '🛢️';
    if (normalized.contains('grain')) return '🌾';
    if (normalized.contains('dairy')) return '🥛';
    if (normalized.contains('spice')) return '🌶️';
    if (normalized.contains('beverage')) return '🥤';
    return '📦';
  }
}
