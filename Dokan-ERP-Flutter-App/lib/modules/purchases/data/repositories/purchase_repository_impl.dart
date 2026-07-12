import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_local_data_source.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  const PurchaseRepositoryImpl(this._local);

  final PurchaseLocalDataSource _local;

  @override
  Future<List<PurchaseOrder>> loadOrders() => _local.load();

  @override
  Future<PurchaseOrder> createOrder(PurchaseOrder order) async {
    final current = await _local.load();
    await _local.save([order, ...current]);
    return order;
  }

  @override
  Future<PurchaseOrder> updateOrder(PurchaseOrder order) async {
    final current = await _local.load();
    final index = current.indexWhere((item) => item.id == order.id);
    if (index >= 0) current[index] = order;
    await _local.save(current);
    return order;
  }

  @override
  Future<PurchaseOrder> receiveOrder(
    PurchaseOrder order,
    List<PurchaseReceiveLineInput> receivedLines, {
    List<PurchaseInventoryPlacementInput>? placements,
    int? paidAmount,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) {
    return updateOrder(order);
  }

  @override
  Future<PurchaseOrder> cancelOrder(PurchaseOrder order,
      {String? reason}) async {
    final updated = order.copyWith(status: PurchaseOrderStatus.cancelled);
    return updateOrder(updated);
  }

  @override
  Future<PurchaseOrder> returnOrder(
    PurchaseOrder order,
    List<Map<String, dynamic>> returnItems, {
    String? refundMethod,
    String? notes,
  }) {
    return updateOrder(order);
  }
}
