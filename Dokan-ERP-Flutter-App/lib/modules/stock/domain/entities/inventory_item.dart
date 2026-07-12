class InventoryItem {
  const InventoryItem({
    required this.emoji,
    required this.nameBn,
    required this.nameEn,
    required this.category,
    required this.buyPrice,
    required this.salePrice,
    required this.stock,
    required this.code,
    required this.location,
    required this.barcode,
    required this.monthlySales,
    required this.unit,
    required this.supplierLabels,
  });

  final String emoji;
  final String nameBn;
  final String nameEn;
  final String category;
  final int buyPrice;
  final int salePrice;
  final int stock;
  final String code;
  final String location;
  final String barcode;
  final int monthlySales;
  final String unit;
  final List<String> supplierLabels;

  int get profit => salePrice - buyPrice;
  int get totalPotentialProfit => profit * stock;
  int get stockValue => salePrice * stock;
  int get profitRate => buyPrice <= 0 ? 0 : ((profit / buyPrice) * 100).round();
  bool get isLowStock => stock <= 8;

  InventoryItem copyWith({int? stock}) {
    return InventoryItem(
      emoji: emoji,
      nameBn: nameBn,
      nameEn: nameEn,
      category: category,
      buyPrice: buyPrice,
      salePrice: salePrice,
      stock: stock ?? this.stock,
      code: code,
      location: location,
      barcode: barcode,
      monthlySales: monthlySales,
      unit: unit,
      supplierLabels: supplierLabels,
    );
  }
}
