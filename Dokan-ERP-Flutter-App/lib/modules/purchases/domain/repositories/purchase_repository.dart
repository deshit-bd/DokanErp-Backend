import '../entities/purchase_order.dart';

abstract interface class PurchaseRepository {
  Future<List<PurchaseOrder>> loadOrders();
  Future<PurchaseOrder> createOrder(PurchaseOrder order);
  Future<PurchaseOrder> updateOrder(PurchaseOrder order);
  Future<PurchaseOrder> receiveOrder(
    PurchaseOrder order,
    List<PurchaseReceiveLineInput> receivedLines, {
    List<PurchaseInventoryPlacementInput>? placements,
    int? paidAmount,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
  });
  Future<PurchaseOrder> cancelOrder(PurchaseOrder order, {String? reason});
  Future<PurchaseOrder> returnOrder(
    PurchaseOrder order,
    List<Map<String, dynamic>> returnItems, {
    String? refundMethod,
    String? notes,
  });
}
