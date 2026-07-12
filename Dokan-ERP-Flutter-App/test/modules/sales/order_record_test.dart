import 'package:dokan_erp/modules/sales/sales.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sales order preserves line items, payment and cancellation audit', () {
    final now = DateTime(2026, 6, 20, 12);
    final order = DokanPosOrderRecord(
      id: 'order-1',
      customerName: 'Customer',
      customerNumber: '01700000000',
      totalAmount: 220,
      paidAmount: 220,
      dueAmount: 0,
      paymentMethod: DokanPosPaymentMethod.cash,
      status: DokanPosOrderStatus.cancelled,
      summary: 'Test',
      createdAt: now,
      lines: const [
        DokanPosOrderLine(
          productId: 'P1',
          productName: 'Product',
          quantity: 2,
          unitPrice: 110,
          unitCost: 80,
        ),
      ],
      paymentHistory: [
        DokanOrderPayment(
          id: 'pay-1',
          amount: 220,
          method: DokanPosPaymentMethod.cash,
          createdAt: now,
        ),
      ],
      cancelledAt: now,
      cancellationReason: 'Return',
      refundMethod: 'Cash',
    );

    final restored = DokanPosOrderRecord.fromJson(order.toJson());

    expect(restored.lines.single.quantity, 2);
    expect(restored.costAmount, 160);
    expect(restored.grossProfit, 60);
    expect(restored.paymentHistory.single.amount, 220);
    expect(restored.cancellationReason, 'Return');
  });
}
