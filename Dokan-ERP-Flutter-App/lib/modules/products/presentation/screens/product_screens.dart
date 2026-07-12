import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/auth/auth.dart';
import 'package:dokan_erp/modules/dashboard/dashboard.dart';
import 'package:dokan_erp/modules/notifications/notifications.dart';
import 'package:dokan_erp/modules/purchases/purchases.dart';
import 'package:dokan_erp/modules/reports/reports.dart';
import 'package:dokan_erp/modules/sales/sales.dart';
import 'package:dokan_erp/modules/settings/settings.dart';
import 'package:dokan_erp/modules/products/domain/entities/dokan_catalog_product.dart';
import 'package:dokan_erp/modules/products/domain/repositories/product_catalog_repository.dart';
import 'package:dokan_erp/modules/products/application/services/dokan_scan_service.dart';
import 'package:dokan_erp/modules/products/application/services/inventory_service.dart';
import 'package:dokan_erp/modules/products/application/services/product_service.dart';
import 'package:dokan_erp/modules/products/application/services/qr_action_resolver.dart';
import 'package:dokan_erp/modules/products/presentation/providers/product_dependencies.dart';
import 'package:dokan_erp/modules/products/presentation/providers/popular_products_provider.dart';
import 'package:dokan_erp/modules/products/presentation/providers/product_provider.dart';
import 'package:dokan_erp/core/core.dart';

part 'parts/product_sort_mode.dart';
part 'parts/low_stock_filter_notifier.dart';
part 'parts/product_history_entry.dart';
part 'parts/dokan_product_stock_add_screen.dart';
part 'parts/dokan_product_list_screen.dart';
part 'parts/dokan_product_detail_screen.dart';
part 'parts/salesman_product_view_screen.dart';
part 'dokan_barcode_scanner_screen.dart';
part 'parts/dokan_full_stock_history_screen.dart';
part 'parts/dokan_product_price_management_screen.dart';
part 'parts/product_bottom_nav.dart';
part 'parts/dokan_add_product_master_db_screen.dart';
part 'parts/dokan_category_settings_screen.dart';
part 'parts/dokan_threshold_setting_screen.dart';
part 'parts/dokan_low_stock_alert_list_screen.dart';
part 'parts/dokan_purchase_order_preview_screen.dart';
part 'parts/inventory_page_card.dart';
part 'parts/top_header.dart';
part 'parts/bottom_action_bar.dart';
part 'parts/product_list_history.dart';
part 'parts/product_list_actions.dart';

class _RiverpodProductCatalogRepository implements ProductCatalogRepository {
  const _RiverpodProductCatalogRepository(this.ref);

  final Ref ref;

  @override
  List<DokanCatalogProduct> get products =>
      ref.read(dokanInventoryCatalogProvider);

  @override
  void addProduct(DokanCatalogProduct product) {
    ref.read(dokanInventoryCatalogProvider.notifier).addProduct(product);
  }

  @override
  void addStock(
    DokanCatalogProduct product, {
    required int amount,
    required int purchasePrice,
    required String referenceText,
  }) {
    ref.read(dokanInventoryCatalogProvider.notifier).applyStockAdd(
          product,
          addAmount: amount,
          purchasePrice: purchasePrice,
          referenceText: referenceText,
        );
  }

  @override
  void reduceStock(
    DokanCatalogProduct product, {
    required int amount,
    required String reason,
  }) {
    ref.read(dokanInventoryCatalogProvider.notifier).applyStockReduce(
          product,
          amount: amount,
          reason: reason,
        );
  }

  @override
  void updatePrice(
    DokanCatalogProduct product, {
    required int purchasePrice,
    required int salePrice,
  }) {
    ref.read(dokanInventoryCatalogProvider.notifier).applyPriceChange(
          product,
          purchasePrice: purchasePrice,
          salePrice: salePrice,
        );
  }
}

final productCatalogRepositoryProvider = Provider<ProductCatalogRepository>(
  _RiverpodProductCatalogRepository.new,
);

final productServiceProvider = Provider<ProductService>(
  (ref) => ProductService(ref.watch(productCatalogRepositoryProvider)),
);

final inventoryServiceProvider = Provider<InventoryService>(
  (ref) => InventoryService(ref.watch(productCatalogRepositoryProvider)),
);

final dokanScanServiceProvider = Provider<DokanScanService>(
  (ref) => DokanScanService(ref.watch(productServiceProvider)),
);

final dokanQrActionResolverProvider = Provider<DokanQrActionResolver>(
  (_) => DokanQrActionResolver(),
);

final dokanLastScannedProductProvider =
    StateProvider<DokanCatalogProduct?>((ref) => null);

class PurchaseInventoryCoordinator {
  const PurchaseInventoryCoordinator(this.ref);

  final Ref ref;

  Future<String?> receiveOrder(
    String orderId,
    Map<String, int> quantities,
  ) async {
    final orders = ref.read(purchaseOrderProvider).asData?.value ??
        const <PurchaseOrder>[];
    PurchaseOrder? order;
    for (final candidate in orders) {
      if (candidate.id == orderId) {
        order = candidate;
        break;
      }
    }
    if (order == null) return 'ক্রয় আদেশ পাওয়া যায়নি';
    var receivedAmount = 0;
    for (final line in order.lines) {
      final quantity = quantities[line.productId] ?? 0;
      if (quantity <= 0) continue;
      receivedAmount += quantity * line.unitCost;
    }
    final receiveLines = order.lines
        .where((line) => (quantities[line.productId] ?? 0) > 0)
        .map(
          (line) => PurchaseReceiveLineInput(
            productId: line.productId,
            physicalCount: quantities[line.productId] ?? 0,
            buyingPrice: line.unitCost,
            sellingPrice: ref
                    .read(productServiceProvider)
                    .getProduct(line.productId)
                    ?.salePrice ??
                line.unitCost,
            batchNo: '1',
          ),
        )
        .toList(growable: false);
    await ref
        .read(purchaseOrderProvider.notifier)
        .recordReceipt(orderId, receiveLines);
    await ref
        .read(dokanInventoryCatalogProvider.notifier)
        .refreshFromRepository();
    if (receivedAmount > 0) {
      await ref.read(dokanPosProvider.notifier).addSupplierPurchase(
            supplierKey: order.supplierKey,
            supplierName: order.supplierName,
            amount: receivedAmount,
            note: 'Goods received: ${order.reference}',
          );
    }
    return null;
  }
}

final purchaseInventoryCoordinatorProvider =
    Provider<PurchaseInventoryCoordinator>(
  PurchaseInventoryCoordinator.new,
);

DokanProductHistoryEntry dokanHistoryEntryFromRemoteJson(
        Map<String, dynamic> json) =>
    _historyEntryFromRemoteJson(json);

List<DokanProductHistoryEntry> dokanLocalHistoryFor(
        DokanCatalogProduct product) =>
    _inventoryFor(product).historyEntries;
