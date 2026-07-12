import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_repository.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>(
  (_) => throw UnimplementedError('Override purchaseRepositoryProvider'),
);

class PurchaseOrderNotifier extends AsyncNotifier<List<PurchaseOrder>> {
  PurchaseRepository get _repository => ref.read(purchaseRepositoryProvider);

  @override
  Future<List<PurchaseOrder>> build() => _repository.loadOrders();

  Future<PurchaseOrder> createSubmittedOrder({
    required String supplierKey,
    required String supplierName,
    required List<PurchaseOrderLine> lines,
    String note = '',
    int paidAmount = 0,
    String paymentMethod = 'CASH',
    Map<String, dynamic>? paymentDetails,
  }) async {
    final now = DateTime.now();
    final order = PurchaseOrder(
      id: 'PO-${now.microsecondsSinceEpoch}',
      supplierKey: supplierKey,
      supplierName: supplierName,
      lines: List.unmodifiable(lines),
      status: PurchaseOrderStatus.submitted,
      createdAt: now,
      updatedAt: now,
      reference: 'PO-${now.millisecondsSinceEpoch}',
      note: note,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      paymentDetails: paymentDetails,
    );
    final saved = await _repository.createOrder(order);
    final current = state.asData?.value ?? const <PurchaseOrder>[];
    final updated = <PurchaseOrder>[saved, ...current];
    state = AsyncData(updated);
    _notifyDashboardChanged();
    return saved;
  }

  Future<void> replace(PurchaseOrder order) async {
    final current = List<PurchaseOrder>.from(
        state.asData?.value ?? const <PurchaseOrder>[]);
    final index = current.indexWhere((item) => item.id == order.id);
    if (index < 0) return;
    final saved = await _repository.updateOrder(order);
    current[index] = saved;
    state = AsyncData(current);
    _notifyDashboardChanged();
  }

  Future<PurchaseOrder?> recordReceipt(
    String orderId,
    List<PurchaseReceiveLineInput> receivedLines, {
    List<PurchaseInventoryPlacementInput>? placements,
    int? paidAmount,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    final current = List<PurchaseOrder>.from(
        state.asData?.value ?? const <PurchaseOrder>[]);
    final index = current.indexWhere((item) => item.id == orderId);
    if (index < 0) return null;
    final order = current[index];
    final receivedByProductId = {
      for (final line in receivedLines) line.productId: line,
    };
    final lines = order.lines.map((line) {
      final received = receivedByProductId[line.productId]?.physicalCount ?? 0;
      final next = (line.receivedQuantity + received)
          .clamp(0, line.orderedQuantity)
          .toInt();
      return line.copyWith(receivedQuantity: next);
    }).toList(growable: false);
    final fullyReceived =
        lines.every((line) => line.receivedQuantity >= line.orderedQuantity);
    final anyReceived = lines.any((line) => line.receivedQuantity > 0);
    final updated = order.copyWith(
      lines: lines,
      status: fullyReceived
          ? PurchaseOrderStatus.received
          : anyReceived
              ? PurchaseOrderStatus.partiallyReceived
              : order.status,
      updatedAt: DateTime.now(),
    );
    final saved = await _repository.receiveOrder(
      updated,
      receivedLines,
      placements: placements,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      paymentDetails: paymentDetails,
    );
    current[index] = saved;
    state = AsyncData(current);
    _notifyDashboardChanged();
    return saved;
  }

  Future<PurchaseOrder> cancelOrder(PurchaseOrder order,
      {String? reason}) async {
    final current = List<PurchaseOrder>.from(
        state.asData?.value ?? const <PurchaseOrder>[]);
    final index = current.indexWhere((item) => item.id == order.id);
    if (index < 0) return order;
    final saved = await _repository.cancelOrder(order, reason: reason);
    current[index] = saved;
    state = AsyncData(current);
    _notifyDashboardChanged();
    return saved;
  }

  Future<PurchaseOrder?> recordReturn(
    String orderId,
    List<Map<String, dynamic>> returnItems, {
    String? refundMethod,
    String? notes,
  }) async {
    final current = List<PurchaseOrder>.from(
        state.asData?.value ?? const <PurchaseOrder>[]);
    final index = current.indexWhere((item) => item.id == orderId);
    if (index < 0) return null;
    final order = current[index];
    final saved = await _repository.returnOrder(
      order,
      returnItems,
      refundMethod: refundMethod,
      notes: notes,
    );
    current[index] = saved;
    state = AsyncData(current);
    _notifyDashboardChanged();
    return saved;
  }

  void _notifyDashboardChanged() {
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(dashboardActivityProvider);
  }
}

final purchaseOrderProvider =
    AsyncNotifierProvider<PurchaseOrderNotifier, List<PurchaseOrder>>(
  PurchaseOrderNotifier.new,
);
