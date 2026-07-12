class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.code,
    required this.unit,
    required this.minStock,
    required this.emoji,
    this.brand = '',
    this.barcode = '',
    this.nameBn = '',
  });

  final String id;
  final String name;
  final String nameBn;
  final String brand;
  final String category;
  final int buyPrice;
  final int sellPrice;
  final int stock;
  final String code;
  final String unit;
  final int minStock;
  final String barcode;
  final String emoji;

  bool get isLowStock => stock <= minStock;
}
