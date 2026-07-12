import 'dart:io';
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
          : const InventoryCatalogSnapshotRepositoryImpl(
              InventoryCatalogLocalDataSource(),
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
          : null,
    ),
    supplierRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? SupplierRemoteRepository(
              ref.watch(supplierRemoteDataSourceProvider),
            )
          : null,
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
          : throw UnimplementedError(
              'No local implementation for InventoryLayoutRepository'),
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
      (ref) =>
          DashboardRemoteRepository(ref.watch(erpRemoteDataSourceProvider)),
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
          : const _DummyReportRepository(),
    ),
    inventoryRepositoryProvider.overrideWith(
      (ref) => ref.watch(apiConfiguredProvider)
          ? InventoryRemoteRepository(
              ref.watch(productRemoteDataSourceProvider))
          : InMemoryInventoryRepository(),
    ),
    purchaseProductCatalogProvider.overrideWith((ref) async {
      final remote = ref.watch(productRemoteDataSourceProvider);
      final payload = await remote.shopCatalog();
      return payload
          .map(ProductApiMapper.fromJson)
          .where((product) => product.name.trim().isNotEmpty)
          .toList(growable: false);
    }),
    salesHistoryOrdersProvider.overrideWith((ref) async {
      void logMsg(String msg) {
        try {
          File('/Users/macbookair/Desktop/dokan_erp/flutter_debug.log')
              .writeAsStringSync(
                  '${DateTime.now().toIso8601String()} - [HISTORY_PROVIDER] $msg\n',
                  mode: FileMode.append);
        } catch (_) {}
        debugPrint('[HISTORY_PROVIDER] $msg');
      }

      final localOrders = ref.watch(
        dokanPosProvider.select((state) => state.orders),
      );
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

class _DummyReportRepository implements ReportRepository {
  const _DummyReportRepository();

  @override
  Future<Map<String, dynamic>> fetchReport(
    String type, {
    Map<String, dynamic>? filters,
  }) async =>
      const {};
}
