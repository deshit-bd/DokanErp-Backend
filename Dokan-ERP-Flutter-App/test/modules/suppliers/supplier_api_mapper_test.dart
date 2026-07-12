import 'package:dokan_erp/modules/suppliers/suppliers.dart';
import 'package:dokan_erp/modules/suppliers/suppliers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps supplier totals and stable shop-scoped create payload', () {
    final supplier = SupplierApiMapper.fromJson({
      'id': 'supplier-1',
      'name': 'ABC Traders',
      'mobile': '01700000000',
      'productType': 'Grocery',
      'creditLimit': '5000',
      'totalPurchase': '12000',
      'totalPaid': 7000,
      'createdAt': '2026-06-21T10:00:00Z',
    });

    expect(supplier.id, 'supplier-1');
    expect(supplier.creditLimit, 5000);
    expect(supplier.totalPurchase, 12000);
    expect(supplier.totalPaid, 7000);

    final payload = SupplierApiMapper.createInput(
      const CreateSupplierInput(
        clientId: 'supplier-1',
        name: 'ABC Traders',
        phone: '01700000000',
        address: 'Dhaka',
        productType: 'Grocery',
        creditLimit: 5000,
      ),
      shopId: 'shop-123',
    );

    expect(payload['shopId'], 'shop-123');
    expect(payload['creditLimit'], 5000);
    expect(payload, isNot(contains('dueAmount')));
  });

  test('payment payload contains only real user-entered card details', () {
    final payload = SupplierApiMapper.paymentInput(
      const RecordSupplierPaymentInput(
        clientId: 'payment-1',
        amount: 2500,
        paymentMethod: SupplierPaymentMethod.card,
        details: SupplierPaymentDetails(
          cardLast4: '4242',
          bankName: 'Example Bank',
        ),
      ),
      shopId: 'shop-123',
    );

    final details = payload['paymentDetails'] as Map<String, dynamic>;
    expect(details['cardLast4'], '4242');
    expect(details['bankName'], 'Example Bank');
    expect(details, isNot(contains('approvalCode')));
    expect(details, isNot(contains('transactionId')));
  });

  test('maps debit ledger entries as purchases', () {
    final entry = SupplierApiMapper.ledgerFromJson(
      {
        'id': 'entry-1',
        'debit': '900',
        'credit': 0,
        'entryDate': '2026-06-21T10:00:00Z',
        'entryType': 'PURCHASE',
      },
      supplierId: 'supplier-1',
    );

    expect(entry.amount, 900);
    expect(entry.type, SupplierLedgerType.purchase);
  });

  test('maps payment method correctly from json', () {
    final entry1 = SupplierApiMapper.ledgerFromJson(
      {
        'id': 'entry-2',
        'debit': 0,
        'credit': '1000',
        'entryDate': '2026-06-21T10:00:00Z',
        'entryType': 'PAYMENT',
        'paymentMethod': 'BKASH',
      },
      supplierId: 'supplier-1',
    );

    expect(entry1.paymentMethod, SupplierPaymentMethod.bkash);

    final entry2 = SupplierApiMapper.ledgerFromJson(
      {
        'id': 'entry-3',
        'debit': 0,
        'credit': '1000',
        'entryDate': '2026-06-21T10:00:00Z',
        'entryType': 'PAYMENT',
      },
      supplierId: 'supplier-1',
    );

    expect(entry2.paymentMethod, null);
  });
}
