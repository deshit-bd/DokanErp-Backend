import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

class InMemorySupplierRepository implements SupplierRepository {
  InMemorySupplierRepository()
      : _suppliers = <Supplier>[
          Supplier(
            id: 'supplier-1',
            name: 'Rahim Traders',
            phone: '01712345678',
            address: 'Chawkbazar, Dhaka',
            totalPurchase: 125000,
            totalPaid: 112500,
            createdAt: DateTime(2026, 1, 10),
            updatedAt: DateTime(2026, 5, 18),
          ),
          Supplier(
            id: 'supplier-2',
            name: 'Karim Enterprise',
            phone: '01898765432',
            address: 'Babubazar, Chattogram',
            totalPurchase: 98000,
            totalPaid: 89250,
            createdAt: DateTime(2026, 1, 12),
            updatedAt: DateTime(2026, 5, 17),
          ),
          Supplier(
            id: 'supplier-3',
            name: 'Salam Brothers',
            phone: '01556789012',
            address: 'New Market, Dhaka',
            totalPurchase: 72000,
            totalPaid: 72000,
            createdAt: DateTime(2026, 2, 3),
            updatedAt: DateTime(2026, 5, 16),
          ),
        ];

  final List<Supplier> _suppliers;

  @override
  Future<List<Supplier>> list({String? shopId, String? search}) async {
    final query = search?.trim().toLowerCase() ?? '';
    if (query.isEmpty) {
      return List<Supplier>.unmodifiable(_suppliers);
    }
    return _suppliers
        .where(
          (supplier) =>
              supplier.name.toLowerCase().contains(query) ||
              supplier.phone.contains(query),
        )
        .toList(growable: false);
  }

  @override
  Future<List<SupplierLedgerEntry>> ledger(
    String supplierId, {
    String? shopId,
  }) async {
    return const <SupplierLedgerEntry>[];
  }

  @override
  Future<Supplier> create(
    CreateSupplierInput input, {
    String? shopId,
  }) async {
    final now = DateTime.now();
    final supplier = Supplier(
      id: input.clientId,
      name: input.name,
      phone: input.phone,
      address: input.address,
      productType: input.productType,
      creditLimit: input.creditLimit,
      createdAt: now,
      updatedAt: now,
    );
    _suppliers.insert(0, supplier);
    return supplier;
  }

  @override
  Future<void> delete(String supplierId) async {
    _suppliers.removeWhere((supplier) => supplier.id == supplierId);
  }

  @override
  Future<void> recordPayment(
    String supplierId,
    RecordSupplierPaymentInput input, {
    String? shopId,
  }) async {}
}
