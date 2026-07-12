import '../../../../core/network/json_value.dart';
import '../../domain/entities/sale_submission.dart';
import '../../domain/repositories/sales_gateway.dart';
import '../datasources/sales_remote_data_source.dart';

class SalesRemoteGateway implements SalesGateway {
  const SalesRemoteGateway(this._remote);

  final SalesRemoteDataSource _remote;

  @override
  Future<String> createSale(SaleSubmission sale) async {
    final payload = await _remote.create(
      {
        'client_id': sale.clientId,
        'invoiceNo': sale.clientId,
        'invoice_no': sale.clientId,
        'customer': {
          'name': sale.customerName,
          'phone': sale.customerPhone,
        },
        'salesman_phone': sale.salesmanPhone,
        'items': sale.lines
            .map(
              (line) => {
                'product_id': line.productId,
                'productId': line.productId,
                'quantity': line.quantity,
                'sale_price': line.unitPrice,
                'salePrice': line.unitPrice,
                'batch_no': line.batchNo,
                'batchNo': line.batchNo,
              },
            )
            .toList(growable: false),
        'discount': sale.discount,
        'discountAmount': sale.discount,
        'tax_amount': sale.taxAmount,
        'taxAmount': sale.taxAmount,
        'charge_amount': sale.chargeAmount,
        'chargeAmount': sale.chargeAmount,
        'total_amount': sale.totalAmount,
        'totalAmount': sale.totalAmount,
        'paid_amount': sale.paidAmount,
        'paidAmount': sale.paidAmount,
        'due_amount': sale.dueAmount,
        'dueAmount': sale.dueAmount,
        'payment_method': sale.paymentMethod,
        'paymentMethod': sale.paymentMethod,
        'payment_reference': sale.paymentReference,
      },
      idempotencyKey: sale.clientId,
    );
    final createdSale = payload['sale'];
    if (createdSale is Map) {
      return JsonValue.string(
        createdSale.map((key, value) => MapEntry('$key', value)),
        const ['id', 'uuid', 'sale_id'],
        fallback: sale.clientId,
      );
    }
    return JsonValue.string(
      payload,
      const ['id', 'uuid', 'sale_id'],
      fallback: sale.clientId,
    );
  }

  @override
  Future<void> cancelSale({
    required String saleId,
    required String reason,
    required String refundMethod,
  }) {
    return _remote.cancel(
      saleId,
      reason: reason,
      refundMethod: refundMethod,
    );
  }
}
