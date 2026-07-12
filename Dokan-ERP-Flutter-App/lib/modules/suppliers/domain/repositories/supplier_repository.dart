import '../entities/supplier.dart';

abstract interface class SupplierRepository {
  Future<List<Supplier>> list({String? shopId, String? search});

  Future<List<SupplierLedgerEntry>> ledger(
    String supplierId, {
    String? shopId,
  });

  Future<Supplier> create(
    CreateSupplierInput input, {
    String? shopId,
  });

  Future<void> delete(String supplierId);

  Future<void> recordPayment(
    String supplierId,
    RecordSupplierPaymentInput input, {
    String? shopId,
  });
}
