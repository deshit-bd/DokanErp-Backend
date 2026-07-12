import 'package:dokan_erp/modules/purchases/purchases.dart';
import 'package:dokan_erp/modules/purchases/purchases.dart';
import 'package:dokan_erp/modules/purchases/purchases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('purchase order calculates amount and survives serialization', () {
    final now = DateTime(2026, 6, 20);
    final order = PurchaseOrder(
      id: 'PO-1',
      supplierKey: 'S1',
      supplierName: 'Supplier',
      lines: const [
        PurchaseOrderLine(
          productId: 'P1',
          productName: 'Product',
          orderedQuantity: 5,
          unitCost: 40,
        ),
      ],
      status: PurchaseOrderStatus.submitted,
      createdAt: now,
      updatedAt: now,
    );

    final restored = PurchaseOrder.fromJson(order.toJson());

    expect(restored.totalAmount, 200);
    expect(restored.lines.single.orderedQuantity, 5);
    expect(restored.status, PurchaseOrderStatus.submitted);
  });

  test('partial receipt does not receive omitted product lines', () async {
    final now = DateTime(2026, 6, 22);
    final order = PurchaseOrder(
      id: 'PO-2',
      supplierKey: 'S1',
      supplierName: 'Supplier',
      lines: const [
        PurchaseOrderLine(
          productId: 'P1',
          productName: 'One',
          orderedQuantity: 5,
          unitCost: 40,
        ),
        PurchaseOrderLine(
          productId: 'P2',
          productName: 'Two',
          orderedQuantity: 7,
          unitCost: 30,
        ),
      ],
      status: PurchaseOrderStatus.submitted,
      createdAt: now,
      updatedAt: now,
    );
    final repository = _MemoryPurchaseRepository([order]);
    final container = ProviderContainer(
      overrides: [
        purchaseRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(purchaseOrderProvider.future);

    final saved =
        await container.read(purchaseOrderProvider.notifier).recordReceipt(
      order.id,
      const [
        PurchaseReceiveLineInput(
          productId: 'P1',
          physicalCount: 2,
          buyingPrice: 40,
          sellingPrice: 50,
        ),
      ],
    );

    expect(saved?.status, PurchaseOrderStatus.partiallyReceived);
    expect(saved?.lines[0].receivedQuantity, 2);
    expect(saved?.lines[1].receivedQuantity, 0);
  });
}

class _MemoryPurchaseRepository implements PurchaseRepository {
  _MemoryPurchaseRepository(this.orders);

  final List<PurchaseOrder> orders;

  @override
  Future<List<PurchaseOrder>> loadOrders() async => orders;

  @override
  Future<PurchaseOrder> createOrder(PurchaseOrder order) async => order;

  @override
  Future<PurchaseOrder> updateOrder(PurchaseOrder order) async => order;

  @override
  Future<PurchaseOrder> receiveOrder(
    PurchaseOrder order,
    List<PurchaseReceiveLineInput> receivedLines, {
    List<PurchaseInventoryPlacementInput>? placements,
    int? paidAmount,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async =>
      order;

  @override
  Future<PurchaseOrder> cancelOrder(
    PurchaseOrder order, {
    String? reason,
  }) async =>
      order.copyWith(status: PurchaseOrderStatus.cancelled);

  @override
  Future<PurchaseOrder> returnOrder(
    PurchaseOrder order,
    List<Map<String, dynamic>> returnItems, {
    String? refundMethod,
    String? notes,
  }) async =>
      order;
}
