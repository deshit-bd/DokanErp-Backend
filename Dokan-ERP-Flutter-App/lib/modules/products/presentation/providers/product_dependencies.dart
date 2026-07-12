import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/inventory_catalog_snapshot_repository.dart';
import '../../domain/repositories/product_settings_repository.dart';
import '../../application/services/popular_product_catalog_service.dart';
import '../../application/services/scanner_permission_gateway.dart';

final inventoryCatalogSnapshotRepositoryProvider =
    Provider<InventoryCatalogSnapshotRepository>(
  (_) => throw UnimplementedError(
    'Override inventoryCatalogSnapshotRepositoryProvider',
  ),
);

final dokanScannerPermissionServiceProvider =
    Provider<ScannerPermissionGateway>(
  (_) => throw UnimplementedError(
    'Override dokanScannerPermissionServiceProvider',
  ),
);

final productSettingsRepositoryProvider = Provider<ProductSettingsRepository>(
  (_) => throw UnimplementedError('Override productSettingsRepositoryProvider'),
);

final popularProductCatalogServiceProvider =
    Provider<PopularProductCatalogService>(
  (_) => const PopularProductCatalogService(),
);

final productSyncErrorProvider = StateProvider<String?>((_) => null);

enum DokanStockMovementType { sale, purchase, loss, returnItem, manual }

class DokanProductHistoryEntry {
  const DokanProductHistoryEntry({
    required this.label,
    required this.amount,
    required this.timeLabel,
    required this.color,
    this.timestamp,
    this.kind,
  });

  final String label;
  final String amount;
  final String timeLabel;
  final Color color;
  final DateTime? timestamp;
  final DokanStockMovementType? kind;
}

final productStockHistoryProvider =
    FutureProvider.autoDispose.family<List<DokanProductHistoryEntry>, String>(
  (_, __) => throw UnimplementedError('Override productStockHistoryProvider'),
);

abstract interface class ProductInventoryGateway {
  Future<void> adjustStock({
    required String barcode,
    required int amount,
    required String referenceText,
    required String note,
    required int purchasePrice,
  });

  Future<void> updatePrice({
    required String barcode,
    required int purchasePrice,
    required int salePrice,
  });
}

final productInventoryGatewayProvider = Provider<ProductInventoryGateway>(
  (_) => throw UnimplementedError('Override productInventoryGatewayProvider'),
);
