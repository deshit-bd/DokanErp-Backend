import 'package:dokan_erp/modules/expenses/expenses.dart';
import 'package:dokan_erp/modules/expenses/expenses.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/purchases/purchases.dart';
import 'package:dokan_erp/modules/purchases/purchases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps product API snake case fields', () {
    final product = ProductApiMapper.fromJson({
      'name': 'Rice',
      'barcode': '123',
      'sale_price': '80',
      'purchase_price': 60,
      'stock_quantity': 9,
      'low_stock_threshold': 4,
    });

    expect(product.barcode, '123');
    expect(product.salePrice, 80);
    expect(product.stock, 9);
  });

  test('maps purchase order and lines', () {
    final order = PurchaseOrderApiMapper.fromJson({
      'id': 'po-1',
      'supplier_id': 'supplier-1',
      'supplier_name': 'Supplier',
      'status': 'partially_received',
      'created_at': '2030-01-01T00:00:00Z',
      'items': [
        {
          'product_id': 'p-1',
          'product_name': 'Rice',
          'ordered_quantity': 10,
          'received_quantity': 4,
          'unit_cost': 50,
        },
      ],
    });

    expect(order.status, PurchaseOrderStatus.partiallyReceived);
    expect(order.lines.single.receivedQuantity, 4);
  });

  test('maps expense payment method and status', () {
    final expense = ExpenseApiMapper.fromJson({
      'id': 'e-1',
      'title': 'Internet',
      'amount': '1200.50',
      'date': '2030-01-01T00:00:00Z',
      'payment_method': 'bkash',
      'status': 'pending',
    });

    expect(expense.amount, 1200.5);
    expect(expense.paymentMethod, DokanExpensePaymentMethod.bkash);
    expect(expense.status, DokanExpenseStatus.pending);
  });
}
