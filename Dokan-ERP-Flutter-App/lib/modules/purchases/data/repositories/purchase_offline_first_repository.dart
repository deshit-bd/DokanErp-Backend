import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_local_data_source.dart';

class PurchaseOfflineFirstRepository implements PurchaseRepository {
  const PurchaseOfflineFirstRepository(this._remote, this._local);

  final PurchaseRepository _remote;
  final PurchaseLocalDataSource _local;

  @override
  Future<List<PurchaseOrder>> loadOrders() async {
    try {
      final values = await _remote.loadOrders();
      await _local.save(values);
      return values;
    } catch (_) {
      return _local.load();
    }
  }

  @override
  Future<PurchaseOrder> createOrder(PurchaseOrder order) async {
    final saved = await _remote.createOrder(order);
    final current = await _local.load();
    await _local.save([
      saved,
      ...current.where((item) => item.id != saved.id),
    ]);
    return saved;
  }

  @override
  Future<PurchaseOrder> updateOrder(PurchaseOrder order) async {
    final saved = await _remote.updateOrder(order);
    await _upsert(saved);
    return saved;
  }

  @override
  Future<PurchaseOrder> receiveOrder(
    PurchaseOrder order,
    List<PurchaseReceiveLineInput> receivedLines, {
    List<PurchaseInventoryPlacementInput>? placements,
    int? paidAmount,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    final saved = await _remote.receiveOrder(
      order,
      receivedLines,
      placements: placements,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      paymentDetails: paymentDetails,
    );
    await _upsert(saved);
    return saved;
  }

  @override
  Future<PurchaseOrder> cancelOrder(PurchaseOrder order,
      {String? reason}) async {
    final saved = await _remote.cancelOrder(order, reason: reason);
    await _upsert(saved);
    return saved;
  }

  @override
  Future<PurchaseOrder> returnOrder(
    PurchaseOrder order,
    List<Map<String, dynamic>> returnItems, {
    String? refundMethod,
    String? notes,
  }) async {
    final saved = await _remote.returnOrder(
      order,
      returnItems,
      refundMethod: refundMethod,
      notes: notes,
    );
    await _upsert(saved);
    return saved;
  }

  Future<void> _upsert(PurchaseOrder order) async {
    final current = List<PurchaseOrder>.from(await _local.load());
    final index = current.indexWhere((item) => item.id == order.id);
    if (index >= 0) {
      current[index] = order;
    } else {
      current.insert(0, order);
    }
    await _local.save(current);
  }
}
