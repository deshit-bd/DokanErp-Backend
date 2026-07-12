import '../../../../core/network/json_value.dart';
import '../../domain/entities/purchase_order.dart';

abstract final class PurchaseOrderApiMapper {
  static PurchaseOrder fromJson(Map<String, dynamic> json) {
    final createdAt = JsonValue.dateTime(
      json,
      const ['created_at', 'createdAt'],
      fallback: DateTime.now(),
    );
    return PurchaseOrder(
      id: JsonValue.string(json, const ['id', 'uuid', 'reference']),
      supplierKey: JsonValue.string(
        json,
        const ['supplier_id', 'supplierKey', 'supplier_key'],
      ),
      supplierName: JsonValue.string(
        json,
        const ['supplier_name', 'supplierName'],
      ),
      lines: JsonValue.objectList(json, const ['lines', 'items'])
          .map(_lineFromJson)
          .toList(growable: false),
      status: _status(
        JsonValue.string(json, const ['status'], fallback: 'draft'),
      ),
      createdAt: createdAt,
      updatedAt: JsonValue.dateTime(
        json,
        const ['updated_at', 'updatedAt'],
        fallback: createdAt,
      ),
      reference: JsonValue.string(
        json,
        const ['reference', 'invoice_number', 'purchase_number'],
      ),
      note: JsonValue.string(json, const ['note', 'notes']),
      paidAmount: JsonValue.integer(json, const ['paid_amount', 'paidAmount']),
      paymentMethod: JsonValue.string(
          json, const ['payment_method', 'paymentMethod'],
          fallback: 'CASH'),
      paymentDetails: json['payment_details'] as Map<String, dynamic>? ??
          json['paymentDetails'] as Map<String, dynamic>? ??
          json['paymentMeta'] as Map<String, dynamic>?,
    );
  }

  static Map<String, dynamic> toJson(PurchaseOrder order) {
    return {
      'client_id': order.id,
      'supplier_id': order.supplierKey,
      'supplier_name': order.supplierName,
      'reference': order.reference,
      'note': order.note,
      'status': order.status.name,
      'paid_amount': order.paidAmount,
      'payment_method': order.paymentMethod,
      'payment_details': order.paymentDetails,
      'lines': order.lines
          .map(
            (line) => {
              'product_id': line.productId,
              'product_name': line.productName,
              'ordered_quantity': line.orderedQuantity,
              'unit_cost': line.unitCost,
              'received_quantity': line.receivedQuantity,
              'returned_quantity': line.returnedQuantity,
            },
          )
          .toList(growable: false),
    };
  }

  static PurchaseOrderLine _lineFromJson(Map<String, dynamic> json) {
    return PurchaseOrderLine(
      productId:
          JsonValue.string(json, const ['product_id', 'productId', 'id']),
      productName:
          JsonValue.string(json, const ['product_name', 'productName', 'name']),
      orderedQuantity: JsonValue.integer(
        json,
        const ['ordered_quantity', 'orderedQuantity', 'quantity'],
      ),
      unitCost:
          JsonValue.integer(json, const ['unit_cost', 'unitCost', 'cost']),
      receivedQuantity: JsonValue.integer(
        json,
        const ['received_quantity', 'receivedQuantity'],
      ),
      returnedQuantity: JsonValue.integer(
        json,
        const ['returned_quantity', 'returnedQuantity'],
      ),
      purchaseItemId: JsonValue.string(
        json,
        const ['purchaseItemId', 'purchase_item_id'],
      ),
    );
  }

  static PurchaseOrderStatus _status(String value) {
    final normalized =
        value.replaceAll('-', '').replaceAll('_', '').toLowerCase();
    return switch (normalized) {
      'submitted' => PurchaseOrderStatus.submitted,
      'partiallyreceived' => PurchaseOrderStatus.partiallyReceived,
      'received' => PurchaseOrderStatus.received,
      'cancelled' || 'canceled' => PurchaseOrderStatus.cancelled,
      _ => PurchaseOrderStatus.draft,
    };
  }
}
