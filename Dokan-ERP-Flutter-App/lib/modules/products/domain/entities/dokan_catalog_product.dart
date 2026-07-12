enum DokanStockStatus { outOfStock, lowStock, available }

class DokanProductBatch {
  const DokanProductBatch({
    this.id = '',
    this.purchaseItemId = '',
    this.batchNo = '',
    this.expiryDate,
    required this.quantity,
    required this.purchasePrice,
    required this.salePrice,
    this.createdAt,
  });

  final String id;
  final String purchaseItemId;
  final String batchNo;
  final DateTime? expiryDate;
  final int quantity;
  final int purchasePrice;
  final int salePrice;
  final DateTime? createdAt;
}

class DokanCatalogProduct {
  const DokanCatalogProduct({
    this.masterProductId = '',
    required this.name,
    required this.barcode,
    required this.category,
    required this.emoji,
    this.brand = '',
    this.unit = '',
    this.imageLabel = '',
    required this.salePrice,
    required this.purchasePrice,
    required this.stock,
    required this.lowStockThreshold,
    required this.salesCount,
    required this.packInfo,
    this.batches = const <DokanProductBatch>[],
  });

  final String masterProductId;
  final String name;
  final String barcode;
  final String category;
  final String emoji;
  final String brand;
  final String unit;
  final String imageLabel;
  final int salePrice;
  final int purchasePrice;
  final int stock;
  final int lowStockThreshold;
  final int salesCount;
  final String packInfo;
  final List<DokanProductBatch> batches;

  String get productId => barcode;

  DokanCatalogProduct copyWith({
    String? masterProductId,
    String? name,
    String? barcode,
    String? category,
    String? emoji,
    String? brand,
    String? unit,
    String? imageLabel,
    int? salePrice,
    int? purchasePrice,
    int? stock,
    int? lowStockThreshold,
    int? salesCount,
    String? packInfo,
    List<DokanProductBatch>? batches,
  }) {
    return DokanCatalogProduct(
      masterProductId: masterProductId ?? this.masterProductId,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      brand: brand ?? this.brand,
      unit: unit ?? this.unit,
      imageLabel: imageLabel ?? this.imageLabel,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      salesCount: salesCount ?? this.salesCount,
      packInfo: packInfo ?? this.packInfo,
      batches: batches ?? this.batches,
    );
  }

  DokanStockStatus get stockStatus {
    if (stock <= 0) {
      return DokanStockStatus.outOfStock;
    }
    if (stock <= lowStockThreshold) {
      return DokanStockStatus.lowStock;
    }
    return DokanStockStatus.available;
  }
}
