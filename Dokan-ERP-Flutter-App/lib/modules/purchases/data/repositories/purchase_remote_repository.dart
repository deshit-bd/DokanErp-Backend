import '../../domain/entities/purchase_order.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_remote_data_source.dart';
import '../mappers/purchase_order_api_mapper.dart';

class PurchaseRemoteRepository implements PurchaseRepository {
  const PurchaseRemoteRepository(this._remote);

  final PurchaseRemoteDataSource _remote;

  @override
  Future<List<PurchaseOrder>> loadOrders() async {
    final payload = await _remote.list(perPage: 100);
    return payload.map(PurchaseOrderApiMapper.fromJson).toList(growable: false);
  }

  @override
  Future<PurchaseOrder> createOrder(PurchaseOrder order) async {
    final payload = await _remote.create(
      PurchaseOrderApiMapper.toJson(order),
      idempotencyKey: order.id,
    );
    return payload.isEmpty ? order : PurchaseOrderApiMapper.fromJson(payload);
  }

  @override
  Future<PurchaseOrder> updateOrder(PurchaseOrder order) async {
    final payload = await _remote.update(
      order.id,
      PurchaseOrderApiMapper.toJson(order),
    );
    return payload.isEmpty ? order : PurchaseOrderApiMapper.fromJson(payload);
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
    final payload = await _remote.receive(
      order.id,
      {
        'lines': receivedLines
            .map(
              (line) => {
                'product_id': line.productId,
                'quantity': line.physicalCount,
                'purchase_price': line.buyingPrice,
                'sale_price': line.sellingPrice,
                if (line.batchNo != null) 'batchNo': line.batchNo,
              },
            )
            .toList(growable: false),
        if (placements != null && placements.isNotEmpty)
          'placements': placements
              .map(
                (placement) => {
                  'product_id': placement.productId,
                  'physical_count': placement.physicalCount,
                  'sale_price': placement.sellingPrice,
                  if (placement.zoneId != null) 'zoneId': placement.zoneId,
                  if (placement.rackId != null) 'rackId': placement.rackId,
                  if (placement.shelfId != null) 'shelfId': placement.shelfId,
                  if (placement.binId != null) 'binId': placement.binId,
                  if (placement.batchNo != null) 'batchNo': placement.batchNo,
                  if (placement.productName != null)
                    'productName': placement.productName,
                },
              )
              .toList(growable: false),
        if (paidAmount != null) 'paid_amount': paidAmount,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (paymentDetails != null) 'payment_details': paymentDetails,
      },
      idempotencyKey:
          '${order.id}-receive-${order.updatedAt.microsecondsSinceEpoch}',
    );
    return payload.isEmpty ? order : PurchaseOrderApiMapper.fromJson(payload);
  }

  @override
  Future<PurchaseOrder> cancelOrder(PurchaseOrder order,
      {String? reason}) async {
    final payload = await _remote.cancel(order.id, reason: reason);
    return payload.isEmpty ? order : PurchaseOrderApiMapper.fromJson(payload);
  }

  @override
  Future<PurchaseOrder> returnOrder(
    PurchaseOrder order,
    List<Map<String, dynamic>> returnItems, {
    String? refundMethod,
    String? notes,
  }) async {
    final payload = await _remote.returnOrder(
      order.id,
      returnItems,
      refundMethod: refundMethod,
      notes: notes,
    );
    return payload.isEmpty ? order : PurchaseOrderApiMapper.fromJson(payload);
  }
}
