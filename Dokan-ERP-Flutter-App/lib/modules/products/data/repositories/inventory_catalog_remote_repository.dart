import 'dart:async';
import 'dart:convert';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/dokan_catalog_product.dart';
import '../../domain/repositories/inventory_catalog_snapshot_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../mappers/product_api_mapper.dart';

class InventoryCatalogRemoteRepository
    implements InventoryCatalogSnapshotRepository {
  InventoryCatalogRemoteRepository(this._remote);

  final ProductRemoteDataSource _remote;
  final Map<String, Map<String, dynamic>> _lastPayloadByBarcode = {};
  Future<void> _writeChain = Future.value();

  @override
  bool get seedWhenEmpty => false;

  @override
  Future<String?> readSnapshot() async {
    final payload = await _remote.list(perPage: 500);
    final products = payload.map(ProductApiMapper.fromJson).toList();
    _lastPayloadByBarcode
      ..clear()
      ..addEntries(
        products.map(
          (product) => MapEntry(
            product.barcode,
            ProductApiMapper.toJson(product),
          ),
        ),
      );
    return _snapshot(products);
  }

  @override
  Future<void> writeSnapshot(String snapshotJson) {
    _writeChain = _writeChain.then((_) => _synchronize(snapshotJson));
    return _writeChain;
  }

  Future<void> _synchronize(String snapshotJson) async {
    final products = _productsFromSnapshot(snapshotJson);
    final nextByBarcode = {
      for (final product in products)
        product.barcode: ProductApiMapper.toJson(product),
    };

    for (final product in products) {
      final nextPayload = nextByBarcode[product.barcode]!;
      final previousPayload = _lastPayloadByBarcode[product.barcode];
      if (previousPayload == null) {
        await _remote.create(nextPayload);
      } else if (jsonEncode(previousPayload) != jsonEncode(nextPayload)) {
        await _remote.update(product.barcode, nextPayload);
      }
    }

    if (AppConfig.syncRemoteDeletions) {
      for (final barcode in _lastPayloadByBarcode.keys) {
        if (!nextByBarcode.containsKey(barcode)) {
          await _remote.delete(barcode);
        }
      }
    }

    _lastPayloadByBarcode
      ..clear()
      ..addAll(nextByBarcode);
  }

  String _snapshot(List<DokanCatalogProduct> products) {
    return jsonEncode({
      'version': 1,
      'remote': true,
      'products': products
          .map(
            (product) => {
              'product': {
                'masterProductId': product.masterProductId,
                'name': product.name,
                'barcode': product.barcode,
                'category': product.category,
                'emoji': product.emoji,
                'brand': product.brand,
                'unit': product.unit,
                'imageLabel': product.imageLabel,
                'salePrice': product.salePrice,
                'purchasePrice': product.purchasePrice,
                'stock': product.stock,
                'lowStockThreshold': product.lowStockThreshold,
                'salesCount': product.salesCount,
                'packInfo': product.packInfo,
                'batches': product.batches
                    .map(
                      (batch) => {
                        'id': batch.id,
                        'purchaseItemId': batch.purchaseItemId,
                        'batchNo': batch.batchNo,
                        'expiryDate': batch.expiryDate?.toIso8601String(),
                        'quantity': batch.quantity,
                        'purchasePrice': batch.purchasePrice,
                        'salePrice': batch.salePrice,
                        'createdAt': batch.createdAt?.toIso8601String(),
                      },
                    )
                    .toList(growable: false),
              },
              'inventory': {
                'stock': product.stock,
                'purchasePrice': product.purchasePrice,
                'salePrice': product.salePrice,
                'historyEntries': const [],
              },
            },
          )
          .toList(growable: false),
    });
  }

  List<DokanCatalogProduct> _productsFromSnapshot(String snapshotJson) {
    final decoded = jsonDecode(snapshotJson);
    if (decoded is! Map) return const [];
    final values = decoded['products'];
    if (values is! List) return const [];

    return values
        .whereType<Map>()
        .map((item) {
          final product = item['product'];
          final inventory = item['inventory'];
          final productJson = product is Map
              ? product.map((key, value) => MapEntry('$key', value))
              : <String, dynamic>{};
          final inventoryJson = inventory is Map
              ? inventory.map((key, value) => MapEntry('$key', value))
              : <String, dynamic>{};
          return ProductApiMapper.fromJson({
            ...productJson,
            ...inventoryJson,
          });
        })
        .where((product) => product.barcode.isNotEmpty)
        .toList(growable: false);
  }
}
