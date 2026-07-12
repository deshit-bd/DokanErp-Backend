import '../../../inventory/domain/entities/stock_item.dart';

class StockAlertNotification {
  const StockAlertNotification({
    required this.productName,
    required this.currentStock,
    required this.lowStockLimit,
    required this.urgency,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  final String productName;
  final int currentStock;
  final int lowStockLimit;
  final StockUrgency urgency;
  final String senderId;
  final String senderName;
  final DateTime createdAt;

  factory StockAlertNotification.fromStockItem(
    StockItem item, {
    required String senderId,
    required String senderName,
    DateTime? createdAt,
  }) {
    return StockAlertNotification(
      productName: item.productName,
      currentStock: item.quantity,
      lowStockLimit: item.lowStockLimit,
      urgency: item.urgency,
      senderId: senderId,
      senderName: senderName,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}
