import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_data_source.dart';
import '../mappers/supplier_api_mapper.dart';

class SupplierRemoteRepository implements SupplierRepository {
  const SupplierRemoteRepository(this._remote);

  final SupplierRemoteDataSource _remote;

  @override
  Future<List<Supplier>> list({String? shopId, String? search}) async {
    final values = await _remote.list(shopId: shopId, search: search);
    return values.map(SupplierApiMapper.fromJson).toList(growable: false);
  }

  @override
  Future<List<SupplierLedgerEntry>> ledger(
    String supplierId, {
    String? shopId,
  }) async {
    final values = await _remote.ledger(supplierId, shopId: shopId);
    return values
        .map(
          (item) => SupplierApiMapper.ledgerFromJson(
            item,
            supplierId: supplierId,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Supplier> create(
    CreateSupplierInput input, {
    String? shopId,
  }) async {
    final payload = await _remote.create(
      SupplierApiMapper.createInput(input, shopId: shopId),
      idempotencyKey: input.clientId,
    );
    if (payload.isEmpty) {
      final now = DateTime.now();
      return Supplier(
        id: input.clientId,
        name: input.name,
        phone: input.phone,
        address: input.address,
        productType: input.productType,
        creditLimit: input.creditLimit,
        createdAt: now,
        updatedAt: now,
      );
    }
    final value = payload['supplier'];
    return SupplierApiMapper.fromJson(
      value is Map ? Map<String, dynamic>.from(value) : payload,
    );
  }

  @override
  Future<void> delete(String supplierId) => _remote.delete(supplierId);

  @override
  Future<void> recordPayment(
    String supplierId,
    RecordSupplierPaymentInput input, {
    String? shopId,
  }) {
    return _remote.recordPayment(
      supplierId,
      SupplierApiMapper.paymentInput(input, shopId: shopId),
      input.clientId,
    );
  }
}
