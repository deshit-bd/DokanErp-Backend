import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../data/data.dart';
import '../../modules/modules.dart';

List<Override> get appDependencyOverrides {
  configureNotificationSnapshotRepository(
    const NotificationSnapshotRepositoryImpl(NotificationLocalDataSource()),
  );
  return [
    authSessionRepositoryProvider.overrideWith(
      (_) => const AuthSessionRepositoryImpl(AuthLocalDataSource()),
    ),
    authGatewayProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? AuthRemoteGateway(ref.watch(authRemoteDataSourceProvider))
          : null,
    ),
    expenseRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? ExpenseOfflineFirstRepository(
              ExpenseRemoteRepository(
                ref.watch(expenseRemoteDataSourceProvider),
              ),
              const ExpenseLocalDataSource(),
            )
          : const ExpenseRepositoryImpl(ExpenseLocalDataSource()),
    ),
    inventoryCatalogSnapshotRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? InventoryCatalogOfflineFirstRepository(
              InventoryCatalogRemoteRepository(
                ref.watch(productRemoteDataSourceProvider),
              ),
              const InventoryCatalogSnapshotRepositoryImpl(
                InventoryCatalogLocalDataSource(),
              ),
            )
          : MockInventoryCatalogSnapshotRepository(
              const InventoryCatalogLocalDataSource(),
            ),
    ),
    productSettingsRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? ProductSettingsOfflineFirstRepository(
              ProductSettingsRemoteRepository(
                ref.watch(productRemoteDataSourceProvider),
              ),
              const ProductSettingsRepositoryImpl(),
            )
          : const ProductSettingsRepositoryImpl(),
    ),
    dokanScannerPermissionServiceProvider.overrideWith(
      (_) => const DokanScannerPermissionService(),
    ),
    purchaseRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? PurchaseOfflineFirstRepository(
              PurchaseRemoteRepository(
                ref.watch(purchaseRemoteDataSourceProvider),
              ),
              const PurchaseLocalDataSource(),
            )
          : const PurchaseRepositoryImpl(PurchaseLocalDataSource()),
    ),
    salesGatewayProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? SalesRemoteGateway(ref.watch(salesRemoteDataSourceProvider))
          : null,
    ),
    salesHistoryRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? SalesHistoryRemoteRepository(
              ref.watch(salesRemoteDataSourceProvider),
              const DokanPosHistoryLocalDataSource(),
            )
          : const SalesHistoryRepositoryImpl(
              DokanPosHistoryLocalDataSource(),
            ),
    ),
    businessSettingsRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? BusinessSettingsOfflineFirstRepository(
              BusinessSettingsRemoteRepository(
                ref.watch(businessSettingsRemoteDataSourceProvider),
              ),
              const BusinessSettingsRepositoryImpl(),
            )
          : const BusinessSettingsRepositoryImpl(),
    ),
    customerRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? CustomerRemoteRepository(
              ref.watch(customerRemoteDataSourceProvider),
            )
          : MockCustomerRepository(),
    ),
    supplierRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? SupplierRemoteRepository(
              ref.watch(supplierRemoteDataSourceProvider),
            )
          : MockSupplierRepository(),
    ),
    subscriptionRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? SubscriptionRemoteRepository(
              ref.watch(subscriptionRemoteDataSourceProvider))
          : const SubscriptionRepositoryImpl(),
    ),
    inventoryLayoutRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? InventoryLayoutRepositoryImpl(
              ref.watch(inventoryLayoutRemoteDataSourceProvider),
            )
          : MockInventoryLayoutRepository(),
    ),
    salesmanRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? SalesmanRemoteRepository(
              ref.watch(salesmanRemoteDataSourceProvider))
          : InMemorySalesmanRepository(),
    ),
    productRepositoryProvider.overrideWith(
      (ref) => InMemoryProductRepository(),
    ),
    dashboardRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? DashboardRemoteRepository(ref.watch(erpRemoteDataSourceProvider))
          : MockDashboardRepository(),
    ),
    notificationRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? NotificationRemoteRepository(
              ref.watch(notificationRemoteDataSourceProvider))
          : const _DummyNotificationRepository(),
    ),
    reportRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? ReportRemoteRepository(ref.watch(erpRemoteDataSourceProvider))
          : const MockReportRepository(),
    ),
    inventoryRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? InventoryRemoteRepository(
              ref.watch(productRemoteDataSourceProvider))
          : InMemoryInventoryRepository(),
    ),
    purchaseProductCatalogProvider.overrideWith((ref) async {
      if (ref.watch(apiConfiguredProvider)) {
        final remote = ref.watch(productRemoteDataSourceProvider);
        final payload = await remote.shopCatalog();
        return payload
            .map(ProductApiMapper.fromJson)
            .where((product) => product.name.trim().isNotEmpty)
            .toList(growable: false);
      } else {
        return ref.watch(dokanInventoryCatalogProvider);
      }
    }),
    salesHistoryOrdersProvider.overrideWith((ref) async {
      ref.keepAlive();
      void logMsg(String msg) {
        try {
          File('/Users/macbookair/Desktop/dokan_erp/flutter_debug.log')
              .writeAsStringSync(
                  '${DateTime.now().toIso8601String()} - [HISTORY_PROVIDER] $msg\n',
                  mode: FileMode.append);
        } catch (_) {}
        debugPrint('[HISTORY_PROVIDER] $msg');
      }

      final localOrders = ref.read(dokanPosProvider).orders;
      logMsg('localOrders length: ${localOrders.length}');
      if (!ref.watch(apiConfiguredProvider)) {
        logMsg('API not configured');
        return localOrders;
      }

      try {
        logMsg('Calling fetchSales...');
        final sales =
            await ref.watch(salesHistoryRepositoryProvider).fetchSales();
        logMsg('fetched raw sales: ${sales.length}');
        final remoteOrders = sales
            .map(dokanPosOrderRecordFromRemoteSale)
            .toList(growable: false);
        logMsg('mapped remoteOrders: ${remoteOrders.length}');
        for (var i = 0; i < remoteOrders.length; i++) {
          final o = remoteOrders[i];
          logMsg(
              '  - RemoteOrder[$i] ID: ${o.id}, ref: ${o.paymentReference}, customer: ${o.customerName}, total: ${o.totalAmount}, status: ${o.status.name}, date: ${o.createdAt}');
        }
        return remoteOrders;
      } catch (e, stack) {
        logMsg('ERROR: $e\n$stack');
        return localOrders;
      }
    }),
    productInventoryGatewayProvider.overrideWith(
      (ref) => ProductInventoryGatewayImpl(ref),
    ),
    productStockHistoryProvider.overrideWith((ref, productId) async {
      final gateway = ref.watch(productInventoryGatewayProvider);
      if (gateway is ProductInventoryGatewayImpl) {
        return gateway.fetchStockHistory(productId);
      }
      return const <DokanProductHistoryEntry>[];
    }),
  ];
}

class ProductInventoryGatewayImpl implements ProductInventoryGateway {
  const ProductInventoryGatewayImpl(this.ref);

  final Ref ref;

  String _resolveRemoteProductId(String productId) {
    final normalized = productId.trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    for (final item in ref.read(dokanInventoryCatalogProvider)) {
      if (item.barcode == normalized || item.masterProductId == normalized) {
        final masterProductId = item.masterProductId.trim();
        return masterProductId.isNotEmpty ? masterProductId : normalized;
      }
    }

    return normalized;
  }

  @override
  Future<void> adjustStock({
    required String barcode,
    required int amount,
    required String referenceText,
    required String note,
    required int purchasePrice,
  }) async {
    if (ref.read(apiConfiguredProvider)) {
      await ref.read(productRemoteDataSourceProvider).adjustStock(
            productId: barcode,
            quantity: amount,
            type: 'ADD',
            reference: referenceText,
            note: note.isEmpty ? null : note,
            purchasePrice: purchasePrice,
          );
      await ref
          .read(dokanInventoryCatalogProvider.notifier)
          .refreshFromRepository();
    } else {
      DokanCatalogProduct? product;
      for (final item in ref.read(dokanInventoryCatalogProvider)) {
        if (item.barcode == barcode) {
          product = item;
          break;
        }
      }
      if (product != null) {
        ref.read(dokanInventoryCatalogProvider.notifier).applyStockAdd(
              product,
              addAmount: amount,
              purchasePrice: purchasePrice,
              referenceText: referenceText,
            );
      }
    }
  }

  @override
  Future<void> updatePrice({
    required String barcode,
    required int purchasePrice,
    required int salePrice,
  }) async {
    if (ref.read(apiConfiguredProvider)) {
      await ref.read(productRemoteDataSourceProvider).update(
        barcode,
        {
          'purchase_price': purchasePrice,
          'sale_price': salePrice,
        },
      );
      await ref
          .read(dokanInventoryCatalogProvider.notifier)
          .refreshFromRepository();
    } else {
      DokanCatalogProduct? product;
      for (final item in ref.read(dokanInventoryCatalogProvider)) {
        if (item.barcode == barcode) {
          product = item;
          break;
        }
      }
      if (product != null) {
        ref.read(dokanInventoryCatalogProvider.notifier).applyPriceChange(
              product,
              purchasePrice: purchasePrice,
              salePrice: salePrice,
            );
      }
    }
  }

  Future<List<DokanProductHistoryEntry>> fetchStockHistory(
      String barcode) async {
    if (ref.read(apiConfiguredProvider)) {
      final remote = ref.read(productRemoteDataSourceProvider);
      final payload =
          await remote.stockHistory(_resolveRemoteProductId(barcode));
      return payload
          .map(dokanHistoryEntryFromRemoteJson)
          .toList(growable: false);
    } else {
      DokanCatalogProduct? product;
      for (final item in ref.read(dokanInventoryCatalogProvider)) {
        if (item.barcode == barcode) {
          product = item;
          break;
        }
      }
      if (product == null) {
        return const <DokanProductHistoryEntry>[];
      }
      return List<DokanProductHistoryEntry>.from(
        dokanLocalHistoryFor(product),
      );
    }
  }
}

class _DummyNotificationRepository implements NotificationRepository {
  const _DummyNotificationRepository();

  @override
  Future<List<Map<String, dynamic>>> list() async => const [];

  @override
  Future<Map<String, dynamic>> loadPreferences() async => const {};

  @override
  Future<void> updatePreferences(Map<String, dynamic> prefs) async {}

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> create({
    required String type,
    required String title,
    required String message,
  }) async {}
}



class MockCustomerRepository implements CustomerRepository {
  MockCustomerRepository() {
    _customers = [
      Customer(
        id: 'cust-1',
        name: 'সাকিব আল হাসান',
        phone: '01711111111',
        address: 'ঢাকা',
        totalSales: 15000,
        totalPaid: 12000,
        currentDue: 3000,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        id: 'cust-2',
        name: 'তামিম ইকবাল',
        phone: '01822222222',
        address: 'চট্টগ্রাম',
        totalSales: 8000,
        totalPaid: 8000,
        currentDue: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        id: 'cust-3',
        name: 'মুশফিকুর রহিম',
        phone: '01933333333',
        address: 'বগুড়া',
        totalSales: 25000,
        totalPaid: 20000,
        currentDue: 5000,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  late List<Customer> _customers;

  @override
  Future<List<Customer>> list({String? shopId, String? search}) async {
    if (search == null || search.trim().isEmpty) {
      return _customers;
    }
    final query = search.trim().toLowerCase();
    return _customers
        .where((c) =>
            c.name.toLowerCase().contains(query) || c.phone.contains(query))
        .toList();
  }

  @override
  Future<Customer> create(CreateCustomerInput input, {String? shopId}) async {
    final customer = Customer(
      id: 'cust-${DateTime.now().millisecondsSinceEpoch}',
      name: input.name,
      phone: input.phone,
      address: input.address,
      totalSales: 0,
      totalPaid: 0,
      currentDue: input.openingDue,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _customers.add(customer);
    return customer;
  }

  @override
  Future<Map<String, dynamic>> get(String id, {String? shopId}) async {
    final customer =
        _customers.firstWhere((c) => c.id == id, orElse: () => _customers.first);
    return {
      'customer': {
        'id': customer.id,
        'name': customer.name,
        'phone': customer.phone,
        'totalSales': customer.totalSales,
        'currentDue': customer.currentDue,
        'recentPayments': [
          {
            'id': 'payment-1',
            'amount': 2000,
            'paymentMethod': 'CASH',
            'paidAt': DateTime.now()
                .subtract(const Duration(days: 2))
                .toIso8601String(),
            'notes': 'আংশিক পরিশোধ',
          }
        ]
      }
    };
  }

  @override
  Future<void> collectDuePayment({
    required String customerId,
    required int amount,
    required String shopId,
    DateTime? paidAt,
    String? notes,
    String paymentMethod = 'CASH',
    Map<String, dynamic>? paymentDetails,
  }) async {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final c = _customers[index];
      _customers[index] = Customer(
        id: c.id,
        name: c.name,
        phone: c.phone,
        address: c.address,
        totalSales: c.totalSales,
        totalPaid: c.totalPaid + amount,
        currentDue: c.currentDue - amount > 0 ? c.currentDue - amount : 0,
        createdAt: c.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}

class MockSupplierRepository implements SupplierRepository {
  MockSupplierRepository() {
    _suppliers = [
      Supplier(
        id: 'supp-1',
        name: 'প্রাণ আরএফএল ডিস্ট্রিবিউশন',
        phone: '01812345678',
        address: 'ঢাকা',
        productType: 'খাদ্য ও পানীয়',
        creditLimit: 50000,
        totalPurchase: 30000,
        totalPaid: 25000,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now(),
      ),
      Supplier(
        id: 'supp-2',
        name: 'ইউনিলিভার বাংলাদেশ',
        phone: '01798765432',
        address: 'চট্টগ্রাম',
        productType: 'প্রসাধন সামগ্রী',
        creditLimit: 100000,
        totalPurchase: 80000,
        totalPaid: 75000,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
    ];

    _ledgers = {
      'supp-1': [
        SupplierLedgerEntry(
          id: 'ledger-1',
          supplierId: 'supp-1',
          amount: 30000,
          type: SupplierLedgerType.purchase,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          note: 'পণ্য ক্রয়',
        ),
        SupplierLedgerEntry(
          id: 'ledger-2',
          supplierId: 'supp-1',
          amount: 25000,
          type: SupplierLedgerType.payment,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          note: 'নগদ পরিশোধ',
          paymentMethod: SupplierPaymentMethod.cash,
        ),
      ],
      'supp-2': [
        SupplierLedgerEntry(
          id: 'ledger-3',
          supplierId: 'supp-2',
          amount: 80000,
          type: SupplierLedgerType.purchase,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          note: 'বাল্ক পণ্য ক্রয়',
        ),
        SupplierLedgerEntry(
          id: 'ledger-4',
          supplierId: 'supp-2',
          amount: 75000,
          type: SupplierLedgerType.payment,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          note: 'বিকাশ পরিশোধ',
          paymentMethod: SupplierPaymentMethod.bkash,
        ),
      ],
    };
  }

  late List<Supplier> _suppliers;
  late Map<String, List<SupplierLedgerEntry>> _ledgers;

  @override
  Future<List<Supplier>> list({String? shopId, String? search}) async {
    if (search == null || search.trim().isEmpty) {
      return _suppliers;
    }
    final query = search.trim().toLowerCase();
    return _suppliers
        .where((s) =>
            s.name.toLowerCase().contains(query) || s.phone.contains(query))
        .toList();
  }

  @override
  Future<List<SupplierLedgerEntry>> ledger(String supplierId,
      {String? shopId}) async {
    return _ledgers[supplierId] ?? [];
  }

  @override
  Future<Supplier> create(CreateSupplierInput input, {String? shopId}) async {
    final supplier = Supplier(
      id: 'supp-${DateTime.now().millisecondsSinceEpoch}',
      name: input.name,
      phone: input.phone,
      address: input.address,
      productType: input.productType,
      creditLimit: input.creditLimit,
      totalPurchase: 0,
      totalPaid: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _suppliers.add(supplier);
    _ledgers[supplier.id] = [];
    return supplier;
  }

  @override
  Future<void> delete(String supplierId) async {
    _suppliers.removeWhere((s) => s.id == supplierId);
    _ledgers.remove(supplierId);
  }

  @override
  Future<void> recordPayment(
    String supplierId,
    RecordSupplierPaymentInput input, {
    String? shopId,
  }) async {
    final index = _suppliers.indexWhere((s) => s.id == supplierId);
    if (index != -1) {
      final s = _suppliers[index];
      _suppliers[index] = Supplier(
        id: s.id,
        name: s.name,
        phone: s.phone,
        address: s.address,
        productType: s.productType,
        creditLimit: s.creditLimit,
        totalPurchase: s.totalPurchase,
        totalPaid: s.totalPaid + input.amount,
        createdAt: s.createdAt,
        updatedAt: DateTime.now(),
      );

      final newEntry = SupplierLedgerEntry(
        id: 'ledger-${DateTime.now().millisecondsSinceEpoch}',
        supplierId: supplierId,
        amount: input.amount,
        type: SupplierLedgerType.payment,
        createdAt: DateTime.now(),
        note: input.note,
        paymentMethod: input.paymentMethod,
      );
      _ledgers[supplierId] = [
        ...?_ledgers[supplierId],
        newEntry,
      ];
    }
  }
}

class MockInventoryLayoutRepository implements InventoryLayoutRepository {
  MockInventoryLayoutRepository() {
    _mode = {'mode': 'SIMPLE'};
  }

  late Map<String, dynamic> _mode;

  @override
  Future<Map<String, dynamic>> getInventoryMode() async {
    return _mode;
  }

  @override
  Future<void> updateInventoryMode(Map<String, dynamic> mode) async {
    _mode = mode;
  }

  @override
  Future<Map<String, dynamic>> getLayoutTree() async {
    return {
      'zones': <dynamic>[],
    };
  }

  @override
  Future<Map<String, dynamic>> createZone(Map<String, dynamic> body) async => {};

  @override
  Future<Map<String, dynamic>> updateZone(
          String id, Map<String, dynamic> body) async =>
      {};

  @override
  Future<void> deleteZone(String id) async {}

  @override
  Future<Map<String, dynamic>> createRack(Map<String, dynamic> body) async => {};

  @override
  Future<Map<String, dynamic>> updateRack(
          String id, Map<String, dynamic> body) async =>
      {};

  @override
  Future<void> deleteRack(String id) async {}

  @override
  Future<Map<String, dynamic>> createShelf(Map<String, dynamic> body) async =>
      {};

  @override
  Future<Map<String, dynamic>> updateShelf(
          String id, Map<String, dynamic> body) async =>
      {};

  @override
  Future<void> deleteShelf(String id) async {}

  @override
  Future<Map<String, dynamic>> createBin(Map<String, dynamic> body) async => {};

  @override
  Future<Map<String, dynamic>> updateBin(
          String id, Map<String, dynamic> body) async =>
      {};

  @override
  Future<void> deleteBin(String id) async {}
}

class MockReportRepository implements ReportRepository {
  const MockReportRepository();

  @override
  Future<Map<String, dynamic>> fetchReport(
    String type, {
    Map<String, dynamic>? filters,
  }) async {
    final normalized = type.trim().toLowerCase().replaceAll('_', '-');
    switch (normalized) {
      case 'dashboard':
      case 'reports-summary':
        return {
          'summary': {
            'sales': 48200,
            'saleCount': 42,
            'profit': 12500,
            'purchases': 35000,
            'expenses': 4500,
            'purchaseCount': 12,
            'receivable': 8000,
            'payable': 5000,
            'lowStockCount': 2,
            'totalProducts': 10,
            'salesGrowthPercent': 15
          },
          'trend': [
            {'date': '8am', 'sales': 5000},
            {'date': '10am', 'sales': 8000},
            {'date': '12pm', 'sales': 12000},
            {'date': '2pm', 'sales': 6000},
            {'date': '4pm', 'sales': 9000},
            {'date': '6pm', 'sales': 5200},
            {'date': '8pm', 'sales': 3000}
          ],
          'trendSummary': {
            'currentTotal': 48200,
            'previousTotal': 42000,
            'changePct': 15,
            'direction': 'up'
          },
          'paymentMethods': [
            {'method': 'CASH', 'amount': 30000, 'percentage': 62},
            {'method': 'BKASH', 'amount': 15200, 'percentage': 31},
            {'method': 'DUE', 'amount': 3000, 'percentage': 7}
          ],
          'purchasePaymentMethods': [
            {'method': 'CASH', 'amount': 20000, 'percentage': 57},
            {'method': 'BKASH', 'amount': 10000, 'percentage': 29},
            {'method': 'DUE', 'amount': 5000, 'percentage': 14}
          ],
          'topProducts': [
            {
              'rank': 1,
              'name': 'মিনিকেট চাল ১কেজি',
              'sales': '২০টি',
              'value': 12600
            },
            {
              'rank': 2,
              'name': 'সয়াবিন তেল ১লি',
              'sales': '১৫টি',
              'value': 2475
            },
            {'rank': 3, 'name': 'চিনি ১কেজি', 'sales': '১০টি', 'value': 1200}
          ]
        };
      case 'sales-daily':
      case 'sales/daily':
        return {
          'summary': {
            'sales': 15200,
            'profit': 3500,
            'salesCount': 12,
            'avgSale': 1266
          },
          'trend': [
            {'label': '8am', 'value': 1200},
            {'label': '10am', 'value': 3000},
            {'label': '12pm', 'value': 4500},
            {'label': '2pm', 'value': 1500},
            {'label': '4pm', 'value': 2500},
            {'label': '6pm', 'value': 1800},
            {'label': '8pm', 'value': 700}
          ],
          'topProducts': [
            {
              'rank': 1,
              'name': 'মিনিকেট চাল ১কেজি',
              'salesCount': 8,
              'salesLabel': '৮টি বিক্রয়',
              'value': 5040
            },
            {
              'rank': 2,
              'name': 'সয়াবিন তেল ১লি',
              'salesCount': 5,
              'salesLabel': '৫টি বিক্রয়',
              'value': 825
            },
            {
              'rank': 3,
              'name': 'চিনি ১কেজি',
              'salesCount': 4,
              'salesLabel': '৪টি বিক্রয়',
              'value': 480
            }
          ],
          'paymentMethods': [
            {'method': 'CASH', 'label': 'নগদ', 'amount': 10000, 'percentage': 66},
            {'method': 'BKASH', 'label': 'বিকাশ', 'amount': 4200, 'percentage': 28},
            {'method': 'DUE', 'label': 'বাকি', 'amount': 1000, 'percentage': 6}
          ]
        };
      case 'purchases-summary':
      case 'purchases/summary':
        return {
          'summary': {
            'purchase': 12500,
            'expense': 2500,
            'totalProducts': 6,
            'purchaseCount': 5,
            'avgPurchase': 2500
          },
          'trend': [
            {'label': '8am', 'value': 0},
            {'label': '10am', 'value': 5000},
            {'label': '12pm', 'value': 4500},
            {'label': '2pm', 'value': 0},
            {'label': '4pm', 'value': 3000},
            {'label': '6pm', 'value': 0},
            {'label': '8pm', 'value': 0}
          ],
          'topItems': [
            {'rank': 1, 'name': 'মিনিকেট চাল ১কেজি', 'units': 15, 'value': 8730},
            {'rank': 2, 'name': 'সয়াবিন তেল ১লি', 'units': 10, 'value': 1480}
          ],
          'paymentMethods': [
            {'method': 'CASH', 'label': 'নগদ', 'amount': 8000, 'percentage': 64},
            {'method': 'BKASH', 'label': 'বিকাশ', 'amount': 3000, 'percentage': 24},
            {'method': 'DUE', 'label': 'বাকি', 'amount': 1500, 'percentage': 12}
          ]
        };
      case 'dues-summary':
      case 'dues/summary':
        return {
          'totals': {
            'totalReceivable': 8000,
            'totalPayable': 5000,
            'netDue': 3000
          },
          'aging': {
            'receivable': [
              {'label': '০-৭ দিন', 'amount': 4000, 'percentage': 50},
              {'label': '৮-১৫ দিন', 'amount': 2500, 'percentage': 31},
              {'label': '১৬-৩০ দিন', 'amount': 1500, 'percentage': 19},
              {'label': '৩০+ দিন', 'amount': 0, 'percentage': 0}
            ],
            'payable': [
              {'label': '০-৭ দিন', 'amount': 3000, 'percentage': 60},
              {'label': '৮-১৫ দিন', 'amount': 2000, 'percentage': 40},
              {'label': '১৬-৩০ দিন', 'amount': 0, 'percentage': 0},
              {'label': '৩০+ দিন', 'amount': 0, 'percentage': 0}
            ]
          }
        };
      case 'expenses-summary':
      case 'expenses/summary':
        return {
          'summary': {
            'totalExpense': 4500,
            'expenseCount': 8,
            'categoriesCount': 3
          },
          'categories': [
            {'category': 'দোকান ভাড়া', 'amount': 3000, 'percentage': 67},
            {'category': 'বিদ্যুৎ বিল', 'amount': 1000, 'percentage': 22},
            {'category': 'অন্যান্য', 'amount': 500, 'percentage': 11}
          ]
        };
      case 'profit-loss':
      case 'profit/loss':
        return {
          'summary': {
            'revenue': 48200,
            'costOfGoodsSold': 31200,
            'grossProfit': 17000,
            'expenses': 4500,
            'netProfit': 12500,
            'marginPercent': 26
          },
          'monthlyTrend': [
            {'month': 'জানু', 'revenue': 45000, 'profit': 11000},
            {'month': 'ফেব', 'revenue': 42000, 'profit': 10500},
            {'month': 'মার্চ', 'revenue': 48000, 'profit': 12000},
            {'month': 'এপ্রি', 'revenue': 40000, 'profit': 9500},
            {'month': 'মে', 'revenue': 43000, 'profit': 10800},
            {'month': 'জুন', 'revenue': 48200, 'profit': 12500}
          ]
        };
      case 'stock-value':
      case 'stock/value':
        return {
          'summary': {
            'totalItems': 10,
            'totalQuantity': 250,
            'totalValue': 35000,
            'totalPotentialSale': 42000,
            'potentialProfit': 7000
          },
          'categories': [
            {'category': 'চাল-ডাল', 'value': 15000, 'itemsCount': 3},
            {'category': 'তেল-মসলা', 'value': 12000, 'itemsCount': 3},
            {'category': 'সাবান', 'value': 3000, 'itemsCount': 2},
            {'category': 'অন্যান্য', 'value': 5000, 'itemsCount': 2}
          ]
        };
      case 'stock':
        return {
          'summary': {
            'totalProducts': 10,
            'outOfStock': 1,
            'lowStock': 2,
            'inStock': 7
          },
          'items': [
            {
              'name': 'কোকা কোলা ২৫০মি',
              'sku': '880005',
              'stock': 0,
              'status': 'OUT_OF_STOCK'
            },
            {
              'name': 'লাক্স সাবান ১০০গ্রা',
              'sku': '880004',
              'stock': 4,
              'status': 'LOW_STOCK'
            },
            {
              'name': 'সয়াবিন তেল ১লি',
              'sku': '880003',
              'stock': 24,
              'status': 'IN_STOCK'
            }
          ]
        };
      default:
        return {};
    }
  }
}

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary?> getSummary() async {
    return const DashboardSummary(
      todaySales: 15200,
      todayOrders: 12,
      todayPurchases: 8500,
      todayExpenses: 1200,
      todayProfit: 3500,
      receivable: 8000,
      payable: 5000,
      lowStockCount: 2,
      totalProducts: 10,
      salesGrowthPercent: 15,
    );
  }

  @override
  Future<DashboardSummary?> getSalesmanSummary() async {
    return const DashboardSummary(
      todaySales: 5200,
      todayOrders: 5,
      todayPurchases: 0,
      todayExpenses: 0,
      todayProfit: 1200,
      receivable: 1000,
      payable: 0,
      lowStockCount: 2,
      totalProducts: 10,
      salesGrowthPercent: 5,
    );
  }

  @override
  Future<List<DashboardActivityEntry>> getActivity() async {
    return [
      DashboardActivityEntry(
        title: 'বিক্রয় সম্পন্ন হয়েছে',
        subtitle: '৳১২০০ পরিশোধ করা হয়েছে',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        type: 'SALE',
      ),
      DashboardActivityEntry(
        title: 'খরচ রেকর্ড করা হয়েছে',
        subtitle: 'বিদ্যুৎ বিল ৳১০০০ পরিশোধ',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'EXPENSE',
      ),
      DashboardActivityEntry(
        title: 'পণ্য ক্রয় সম্পন্ন',
        subtitle: 'মিনিকেট চাল ১৫টি ক্রয়',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        type: 'PURCHASE',
      ),
    ];
  }
}

class MockInventoryCatalogSnapshotRepository implements InventoryCatalogSnapshotRepository {
  MockInventoryCatalogSnapshotRepository(this._local);

  final InventoryCatalogLocalDataSource _local;

  @override
  bool get seedWhenEmpty => true;

  @override
  Future<String?> readSnapshot() async {
    final val = await _local.readSnapshot();
    if (val == null || val.trim().isEmpty) {
      const list = dokanCatalogBootstrapProducts;
      return jsonEncode({
        'version': 1,
        'products': [
          for (final p in list)
            {
              'product': {
                'masterProductId': p.masterProductId,
                'name': p.name,
                'barcode': p.barcode,
                'category': p.category,
                'emoji': p.emoji,
                'brand': p.brand,
                'unit': p.unit,
                'imageLabel': p.imageLabel,
                'salePrice': p.salePrice,
                'purchasePrice': p.purchasePrice,
                'stock': p.stock,
                'lowStockThreshold': p.lowStockThreshold,
                'salesCount': p.salesCount,
                'packInfo': p.packInfo,
                'batches': const <dynamic>[],
              },
              'inventory': {
                'stock': p.stock,
                'purchasePrice': p.purchasePrice,
                'salePrice': p.salePrice,
                'historyEntries': const <dynamic>[],
              }
            }
        ]
      });
    }
    return val;
  }

  @override
  Future<void> writeSnapshot(String snapshotJson) => _local.writeSnapshot(snapshotJson);
}
