enum StockUrgency {
  low,
  medium,
  high,
}

extension StockUrgencyLabelX on StockUrgency {
  String get label => switch (this) {
        StockUrgency.low => 'low',
        StockUrgency.medium => 'medium',
        StockUrgency.high => 'high',
      };
}

class StockItem {
  const StockItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.lowStockLimit,
  });

  final String productId;
  final String productName;
  final int quantity;
  final int lowStockLimit;

  bool get isLowStock => quantity <= lowStockLimit;
  int get lowStockGap =>
      quantity >= lowStockLimit ? 0 : lowStockLimit - quantity;

  StockUrgency get urgency {
    if (!isLowStock) {
      return StockUrgency.low;
    }
    if (quantity <= 0) {
      return StockUrgency.high;
    }
    if (lowStockGap >= 5) {
      return StockUrgency.high;
    }
    if (lowStockGap >= 2) {
      return StockUrgency.medium;
    }
    return StockUrgency.low;
  }

  StockItem restock(int amount) {
    final nextAmount = amount < 0 ? 0 : amount;
    return StockItem(
      productId: productId,
      productName: productName,
      quantity: quantity + nextAmount,
      lowStockLimit: lowStockLimit,
    );
  }

  StockItem consume(int amount) {
    final nextAmount = amount < 0 ? 0 : amount;
    return StockItem(
      productId: productId,
      productName: productName,
      quantity: (quantity - nextAmount).clamp(0, quantity),
      lowStockLimit: lowStockLimit,
    );
  }
}
