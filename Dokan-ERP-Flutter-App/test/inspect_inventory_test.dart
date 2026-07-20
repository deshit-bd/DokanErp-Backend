import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dokan_erp/modules/products/domain/entities/dokan_catalog_product.dart';
import 'package:dokan_erp/modules/products/presentation/providers/product_dependencies.dart';
import 'package:dokan_erp/modules/products/presentation/screens/product_screens.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  test('direct parsing of snapshot and history matching', () {
    // 1. Read snapshot JSON file
    final file = File('test/snapshot.json');
    final jsonStr = file.readAsStringSync();
    final data = jsonDecode(jsonStr);

    final rawProducts = data['products'] as List;
    final rawMovements = data['movements'] as List;

    // Parse products and associate histories
    final products = rawProducts.map((p) {
      final map = p as Map<String, dynamic>;
      return DokanCatalogProduct(
        masterProductId: map['masterProductId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        barcode: map['barcode'] as String? ?? '',
        category: map['category'] as String? ?? '',
        emoji: map['emoji'] as String? ?? '',
        salePrice: (map['salePrice'] as num).toInt(),
        purchasePrice: (map['purchasePrice'] as num).toInt(),
        stock: (map['stock'] as num).toInt(),
        lowStockThreshold: (map['lowStockThreshold'] as num).toInt(),
        salesCount: (map['salesCount'] as num).toInt(),
        packInfo: map['packInfo'] as String? ?? '',
      );
    }).toList();

    final remoteHistoryByBarcode = <String, List<DokanProductHistoryEntry>>{};
    for (final movMap in rawMovements) {
      final mov = movMap as Map<String, dynamic>;
      final barcode = (mov['barcode'] as String? ?? '').trim();
      final masterId = (mov['masterProductId'] as String? ?? '').trim();
      final shopProductId = (mov['shopProductId'] as String? ?? '').trim();

      final entry = dokanRemoteHistoryEntryFromJson({
        'movementType': mov['movementType'],
        'createdAt': mov['createdAt'],
        'quantityDelta': mov['quantityDelta'],
        'note': mov['note'],
      });

      for (final p in products) {
        if ((barcode.isNotEmpty && p.barcode == barcode) ||
            (masterId.isNotEmpty && p.masterProductId == masterId) ||
            (shopProductId.isNotEmpty && p.barcode == shopProductId)) {
          remoteHistoryByBarcode.putIfAbsent(p.barcode, () => []).add(entry);
        }
      }
    }

    // Generate snapshot JSON
    final serializedSnapshot = jsonEncode({
      'version': 1,
      'remote': true,
      'products': products.map((product) {
        final remoteHistory = remoteHistoryByBarcode[product.barcode];
        final history = remoteHistory ?? const <DokanProductHistoryEntry>[];
        return {
          'product': {
            'masterProductId': product.masterProductId,
            'name': product.name,
            'barcode': product.barcode,
            'category': product.category,
            'emoji': product.emoji,
            'salePrice': product.salePrice,
            'purchasePrice': product.purchasePrice,
            'stock': product.stock,
            'lowStockThreshold': product.lowStockThreshold,
            'salesCount': product.salesCount,
            'packInfo': product.packInfo,
            'batches': [],
          },
          'inventory': {
            'stock': product.stock,
            'purchasePrice': product.purchasePrice,
            'salePrice': product.salePrice,
            'historyEntries': history.map(dokanHistoryEntryToJson).toList(),
          },
        };
      }).toList(),
    });

    // 2. Call parseCatalogSync directly
    final parsedResult = parseCatalogSync(serializedSnapshot);
    print('Parsed catalog length: ${parsedResult.products.length}');
    print('Parsed inventory store size: ${parsedResult.inventoryStore.length}');

    int productsWithLossHistory = 0;
    int todayLossQtySum = 0;
    
    final today = DateTime.now();

    parsedResult.inventoryStore.forEach((barcode, state) {
      final history = state.historyEntries;
      final lossEntries = history.where((entry) => entry.kind == DokanStockMovementType.loss).toList();
      if (lossEntries.isNotEmpty) {
        productsWithLossHistory++;
        final product = parsedResult.products.firstWhere((p) => p.barcode == barcode);
        print('Product: ${product.name}, History entries: ${lossEntries.length}');
        for (final entry in lossEntries) {
          final entryDate = entry.timestamp ?? today;
          final isToday = entryDate.year == today.year &&
              entryDate.month == today.month &&
              entryDate.day == today.day;
          
          final cleanAmount = entry.amount.replaceAll(RegExp(r'[^0-9০-৯]'), '');
          int val = 0;
          for (var i = 0; i < cleanAmount.length; i++) {
            final char = cleanAmount[i];
            const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
            final index = digits.indexOf(char);
            if (index != -1) {
              val = val * 10 + index;
            } else {
              val = val * 10 + (int.tryParse(char) ?? 0);
            }
          }
          
          print('  Entry: kind=${entry.kind}, amount=${entry.amount} (val=$val), timestamp=${entry.timestamp}, isToday=$isToday');
          if (isToday) {
            todayLossQtySum += val;
          }
        }
      }
    });

    print('Total products with loss history: $productsWithLossHistory');
    print('Sum of today loss quantity: $todayLossQtySum');
  });
}

// Helper to expose the private _parseCatalogInBackground / run it synchronously
_MockParsedResult parseCatalogSync(String json) {
  final decoded = jsonDecode(json);
  if (decoded is! Map<String, dynamic>) {
    return _MockParsedResult([], {});
  }
  final productsJson = decoded['products'];
  if (productsJson is! List) {
    return _MockParsedResult([], {});
  }

  final restored = <DokanCatalogProduct>[];
  final nextStore = <String, _MockInventoryState>{};

  for (final item in productsJson) {
    if (item is! Map) continue;
    final itemMap = item.map((key, value) => MapEntry(key.toString(), value));
    final productJson = itemMap['product'];
    final inventoryJson = itemMap['inventory'];
    if (productJson is! Map || inventoryJson is! Map) continue;

    // Use json to manually parse since it's identical
    final product = DokanCatalogProduct(
      masterProductId: productJson['masterProductId'] as String? ?? '',
      name: productJson['name'] as String? ?? '',
      barcode: productJson['barcode'] as String? ?? '',
      category: productJson['category'] as String? ?? '',
      emoji: productJson['emoji'] as String? ?? '',
      salePrice: (productJson['salePrice'] as num).toInt(),
      purchasePrice: (productJson['purchasePrice'] as num).toInt(),
      stock: (productJson['stock'] as num).toInt(),
      lowStockThreshold: (productJson['lowStockThreshold'] as num).toInt(),
      salesCount: (productJson['salesCount'] as num).toInt(),
      packInfo: productJson['packInfo'] as String? ?? '',
    );
    
    // Parse inventoryState
    final historyJson = inventoryJson['historyEntries'] as List;
    final historyEntries = historyJson
        .whereType<Map>()
        .map(
          (entry) {
            final entryMap = entry.map((key, value) => MapEntry(key.toString(), value));
            final timestampValue = entryMap['timestamp'];
            final kindStr = entryMap['kind'] as String?;
            final kind = kindStr == 'loss' ? DokanStockMovementType.loss : null;
            return DokanProductHistoryEntry(
              label: entryMap['label'] as String? ?? '',
              amount: entryMap['amount'] as String? ?? '',
              timeLabel: entryMap['timeLabel'] as String? ?? '',
              color: Color((entryMap['color'] as num?)?.toInt() ?? 0xFF0C8C67),
              timestamp: timestampValue is num
                  ? DateTime.fromMillisecondsSinceEpoch(timestampValue.toInt())
                  : null,
              kind: kind,
            );
          },
        )
        .toList();

    restored.add(product);
    nextStore[product.barcode] = _MockInventoryState(historyEntries);
  }

  return _MockParsedResult(restored, nextStore);
}

class _MockInventoryState {
  final List<DokanProductHistoryEntry> historyEntries;
  _MockInventoryState(this.historyEntries);
}

class _MockParsedResult {
  final List<DokanCatalogProduct> products;
  final Map<String, _MockInventoryState> inventoryStore;
  _MockParsedResult(this.products, this.inventoryStore);
}
