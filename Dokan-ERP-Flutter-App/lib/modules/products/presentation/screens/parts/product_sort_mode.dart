part of '../product_screens.dart';

String _bnDigits(String input) {
  if (AppStrings.activeLanguage == AppLanguage.english) {
    return _latinDigits(input);
  }
  const map = <String, String>{
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };
  return input.split('').map((char) => map[char] ?? char).join();
}

String _latinDigits(String input) {
  const map = <String, String>{
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };
  return input.split('').map((char) => map[char] ?? char).join();
}

String _currency(int value) => '৳${_bnDigits(value.toString())}';

Color _stockStatusColor(int stock, int threshold) {
  if (stock <= 0) {
    return const Color(0xFFD43B3B);
  }
  if (stock < threshold) {
    return const Color(0xFFF49B1A);
  }
  return const Color(0xFF0C8C67);
}

Color _stockStatusBackground(int stock, int threshold) {
  if (stock <= 0) {
    return const Color(0xFFFDEEEF);
  }
  if (stock < threshold) {
    return const Color(0xFFFFF4E0);
  }
  return const Color(0xFFE5F7ED);
}

String _stockStatusLabel(int stock, int threshold) {
  if (stock <= 0) return 'স্টক নেই';
  if (stock < threshold) return 'কম স্টক';
  return 'পর্যাপ্ত স্টক';
}

String _emojiForCategory(String category) {
  switch (category) {
    case 'চাল-ডাল':
      return 'ðŸŒ¾';
    case 'তেল-মসলা':
      return 'ðŸ›¢ï¸';
    case 'সাবান':
      return 'ðŸ§¼';
    case 'পানীয়':
      return 'ðŸ¥¤';
    case 'বিস্কুট':
      return 'ðŸª';
    default:
      return 'ðŸ“¦';
  }
}

List<String> _productCategoryOptions(Iterable<String> categories) {
  final options = categories
      .where((category) =>
          category != DokanCategoryNotifier.uncategorized && category != 'সব')
      .toList(growable: false);
  if (options.isEmpty) {
    return <String>[DokanCategoryNotifier.uncategorized];
  }
  return options;
}

enum _ProductSortMode { newest, name, lowStock, highestSales }

enum _LowStockAlertFilter { all, lowStock, outOfStock }

class _ProductInventoryState {
  const _ProductInventoryState({
    required this.stock,
    required this.purchasePrice,
    required this.salePrice,
    required this.historyEntries,
  });

  final int stock;
  final int purchasePrice;
  final int salePrice;
  final List<_ProductHistoryEntry> historyEntries;

  _ProductInventoryState copyWith({
    int? stock,
    int? purchasePrice,
    int? salePrice,
    List<_ProductHistoryEntry>? historyEntries,
  }) {
    return _ProductInventoryState(
      stock: stock ?? this.stock,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      historyEntries: historyEntries ?? this.historyEntries,
    );
  }
}

final Map<String, _ProductInventoryState> _productInventoryStore =
    <String, _ProductInventoryState>{};

final dokanInventoryCatalogReadyProvider = StateProvider<bool>((ref) => false);

String _inventoryKey(DokanCatalogProduct product) => product.barcode;

Map<String, dynamic> _historyEntryToJson(_ProductHistoryEntry entry) {
  return <String, dynamic>{
    'label': entry.label,
    'amount': entry.amount,
    'timeLabel': entry.timeLabel,
    'color': entry.color.toARGB32(),
    'timestamp': entry.timestamp?.millisecondsSinceEpoch,
    'kind': entry.kind?.name,
  };
}

_ProductHistoryEntry _historyEntryFromJson(Map<String, dynamic> json) {
  final timestampValue = json['timestamp'];
  return _ProductHistoryEntry(
    label: json['label'] as String? ?? '',
    amount: json['amount'] as String? ?? '',
    timeLabel: json['timeLabel'] as String? ?? '',
    color: Color((json['color'] as num?)?.toInt() ?? 0xFF0C8C67),
    timestamp: timestampValue is num
        ? DateTime.fromMillisecondsSinceEpoch(timestampValue.toInt())
        : null,
    kind: _historyKindFromString(json['kind'] as String?),
  );
}

DokanStockMovementType? _historyKindFromString(String? value) {
  return switch (value) {
    'sale' => DokanStockMovementType.sale,
    'purchase' => DokanStockMovementType.purchase,
    'loss' => DokanStockMovementType.loss,
    'returnItem' => DokanStockMovementType.returnItem,
    'manual' => DokanStockMovementType.manual,
    _ => null,
  };
}

_ProductInventoryState _inventoryStateFromJson(
  Map<String, dynamic> json, {
  required DokanCatalogProduct fallbackProduct,
}) {
  final historyJson = json['historyEntries'];
  final historyEntries = historyJson is List
      ? historyJson
          .whereType<Map>()
          .map(
            (entry) => _historyEntryFromJson(
              entry.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false)
      : _historyFor(fallbackProduct);

  return _ProductInventoryState(
    stock: (json['stock'] as num?)?.toInt() ?? fallbackProduct.stock,
    purchasePrice: (json['purchasePrice'] as num?)?.toInt() ??
        fallbackProduct.purchasePrice,
    salePrice:
        (json['salePrice'] as num?)?.toInt() ?? fallbackProduct.salePrice,
    historyEntries: historyEntries,
  );
}

Map<String, dynamic> _inventoryStateToJson(_ProductInventoryState state) {
  return <String, dynamic>{
    'stock': state.stock,
    'purchasePrice': state.purchasePrice,
    'salePrice': state.salePrice,
    'historyEntries':
        state.historyEntries.map(_historyEntryToJson).toList(growable: false),
  };
}

DokanCatalogProduct _productFromJson(Map<String, dynamic> json) {
  final rawBatches = json['batches'];
  final batches = rawBatches is List
      ? rawBatches.whereType<Map>().map(
          (item) {
            final batch = item.map((key, value) => MapEntry('$key', value));
            return DokanProductBatch(
              id: batch['id'] as String? ?? '',
              purchaseItemId: batch['purchaseItemId'] as String? ?? '',
              batchNo: batch['batchNo'] as String? ?? '',
              expiryDate:
                  DateTime.tryParse(batch['expiryDate'] as String? ?? ''),
              quantity: (batch['quantity'] as num?)?.toInt() ?? 0,
              purchasePrice: (batch['purchasePrice'] as num?)?.toInt() ?? 0,
              salePrice: (batch['salePrice'] as num?)?.toInt() ?? 0,
              createdAt: DateTime.tryParse(batch['createdAt'] as String? ?? ''),
            );
          },
        ).toList(growable: false)
      : const <DokanProductBatch>[];

  return DokanCatalogProduct(
    masterProductId: json['masterProductId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    barcode: json['barcode'] as String? ?? '',
    category: json['category'] as String? ?? '',
    emoji: json['emoji'] as String? ?? '',
    brand: json['brand'] as String? ?? '',
    unit: json['unit'] as String? ?? '',
    imageLabel: json['imageLabel'] as String? ?? '',
    salePrice: (json['salePrice'] as num?)?.toInt() ?? 0,
    purchasePrice: (json['purchasePrice'] as num?)?.toInt() ?? 0,
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 0,
    salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
    packInfo: json['packInfo'] as String? ?? '',
    batches: batches,
  );
}

Map<String, dynamic> _productSnapshotToJson(
  DokanCatalogProduct product,
  _ProductInventoryState state,
) {
  return <String, dynamic>{
    'product': <String, dynamic>{
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
            (batch) => <String, dynamic>{
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
    'inventory': _inventoryStateToJson(state),
  };
}

String _catalogSnapshotJson(List<DokanCatalogProduct> products) {
  return jsonEncode(
    <String, dynamic>{
      'version': 1,
      'products': [
        for (final product in products)
          _productSnapshotToJson(product, _inventoryFor(product)),
      ],
    },
  );
}

List<DokanCatalogProduct> _catalogFromSnapshot(String snapshotJson) {
  final decoded = jsonDecode(snapshotJson);
  if (decoded is! Map<String, dynamic>) {
    return const <DokanCatalogProduct>[];
  }
  final productsJson = decoded['products'];
  if (productsJson is! List) {
    return const <DokanCatalogProduct>[];
  }

  final restored = <DokanCatalogProduct>[];
  for (final item in productsJson) {
    if (item is! Map) continue;
    final itemMap = item.map((key, value) => MapEntry(key.toString(), value));
    final productJson = itemMap['product'];
    final inventoryJson = itemMap['inventory'];
    if (productJson is! Map || inventoryJson is! Map) continue;

    final product = _productFromJson(
      productJson.map((key, value) => MapEntry(key.toString(), value)),
    );
    final inventory = _inventoryStateFromJson(
      inventoryJson.map((key, value) => MapEntry(key.toString(), value)),
      fallbackProduct: product,
    );

    restored.add(
      product.copyWith(
        stock: inventory.stock,
        purchasePrice: inventory.purchasePrice,
        salePrice: inventory.salePrice,
      ),
    );
  }
  return restored;
}

class DokanInventoryCatalogNotifier
    extends Notifier<List<DokanCatalogProduct>> {
  @override
  List<DokanCatalogProduct> build() {
    DokanDebug.log('build() called on DokanInventoryCatalogNotifier');
    unawaited(_hydrateInventory());
    return const <DokanCatalogProduct>[];
  }

  Future<void> _hydrateInventory() async {
    await _loadInventory(markReady: true);
  }

  Future<void> refreshFromRepository() async {
    await _loadInventory(markReady: false);
  }

  Future<void> _loadInventory({required bool markReady}) async {
    DokanDebug.log('_loadInventory started (markReady: $markReady)');
    final storage = ref.read(inventoryCatalogSnapshotRepositoryProvider);
    String? snapshotJson;
    try {
      snapshotJson = await storage.readSnapshot();
      DokanDebug.log(
          'readSnapshot returned string of length ${snapshotJson?.length}');
      Future.microtask(() {
        if (ref.read(productSyncErrorProvider.notifier).state != null) {
          ref.read(productSyncErrorProvider.notifier).state = null;
        }
      });
    } catch (error) {
      DokanDebug.log('readSnapshot threw error: $error');
      Future.microtask(() {
        ref.read(productSyncErrorProvider.notifier).state = error.toString();
        if (markReady) {
          ref.read(dokanInventoryCatalogReadyProvider.notifier).state = true;
        }
      });
      return;
    }

    if (snapshotJson == null || snapshotJson.trim().isEmpty) {
      DokanDebug.log('snapshotJson is null or empty, clearing catalog');
      _productInventoryStore..clear();
      state = const <DokanCatalogProduct>[];
      if (markReady) {
        Future.microtask(() {
          ref.read(dokanInventoryCatalogReadyProvider.notifier).state = true;
        });
      }
      return;
    }

    try {
      final restoredProducts = _catalogFromSnapshot(snapshotJson)
          .where((product) => product.barcode.trim().isNotEmpty)
          .where((product) => product.name.trim().isNotEmpty)
          .toList(growable: false);
      DokanDebug.log(
          'restoredProducts parsed: ${restoredProducts.length} items');
      if (restoredProducts.isEmpty) {
        DokanDebug.log('restoredProducts is empty, clearing catalog');
        _productInventoryStore..clear();
        state = const <DokanCatalogProduct>[];
        return;
      }

      final nextStore = <String, _ProductInventoryState>{};
      final decoded = jsonDecode(snapshotJson);
      final productsJson =
          decoded is Map<String, dynamic> ? decoded['products'] : null;
      if (productsJson is List) {
        for (final item in productsJson) {
          if (item is! Map) continue;
          final itemMap =
              item.map((key, value) => MapEntry(key.toString(), value));
          final productJson = itemMap['product'];
          final inventoryJson = itemMap['inventory'];
          if (productJson is! Map || inventoryJson is! Map) continue;

          final product = _productFromJson(
            productJson.map((key, value) => MapEntry(key.toString(), value)),
          );
          if (product.barcode.trim().isEmpty || product.name.trim().isEmpty) {
            continue;
          }
          nextStore[_inventoryKey(product)] = _inventoryStateFromJson(
            inventoryJson.map((key, value) => MapEntry(key.toString(), value)),
            fallbackProduct: product,
          );
        }
      }

      _productInventoryStore
        ..clear()
        ..addAll(nextStore);
      state = restoredProducts;
      DokanDebug.log(
          '_loadInventory completed successfully, state set with ${restoredProducts.length} products');
    } catch (error, stackTrace) {
      DokanDebug.log('_loadInventory parsing exception: $error');
      debugPrint('[CATALOG_PARSE_ERROR] $error');
      debugPrintStack(stackTrace: stackTrace);
      Future.microtask(() {
        ref.read(productSyncErrorProvider.notifier).state = error.toString();
      });
    } finally {
      if (markReady) {
        Future.microtask(() {
          ref.read(dokanInventoryCatalogReadyProvider.notifier).state = true;
        });
      }
    }
  }

  Future<void> _persistCurrentState() async {
    try {
      await ref
          .read(inventoryCatalogSnapshotRepositoryProvider)
          .writeSnapshot(_catalogSnapshotJson(state));
    } catch (error, stackTrace) {
      ref.read(productSyncErrorProvider.notifier).state = error.toString();
      debugPrint('[PRODUCT_SYNC] $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void addProduct(DokanCatalogProduct product) {
    state = <DokanCatalogProduct>[
      product,
      ...state.where((item) => item.barcode != product.barcode)
    ];
    _saveInventory(
      product,
      _ProductInventoryState(
        stock: product.stock,
        purchasePrice: product.purchasePrice,
        salePrice: product.salePrice,
        historyEntries: _historyFor(product),
      ),
    );
    unawaited(_persistCurrentState());
  }

  void reassignCategory(String oldCategory, String newCategory) {
    if (oldCategory == newCategory) return;
    state = [
      for (final item in state)
        if (item.category == oldCategory)
          item.copyWith(category: newCategory)
        else
          item,
    ];
    unawaited(_persistCurrentState());
  }

  void applyStockAdd(
    DokanCatalogProduct product, {
    required int addAmount,
    required int purchasePrice,
    required String referenceText,
  }) {
    final current = _inventoryFor(product);
    final updatedProduct = product.copyWith(
      stock: product.stock + addAmount,
      purchasePrice: purchasePrice,
    );
    final isSaleReturn = referenceText.startsWith('return-');
    final history = <_ProductHistoryEntry>[
      _ProductHistoryEntry(
        label: isSaleReturn ? 'বিক্রয় রিটার্ন' : 'ক্রয়',
        amount: '+${_bnDigits(addAmount.toString())}টি',
        timeLabel: isSaleReturn
            ? 'আজ • বিক্রয় রিটার্ন'
            : 'আজ • ${referenceText.isEmpty ? 'চালান' : 'চালান #$referenceText'}',
        color: const Color(0xFF0C8C67),
        timestamp: DateTime.now(),
        kind: isSaleReturn
            ? DokanStockMovementType.returnItem
            : DokanStockMovementType.purchase,
      ),
      ...current.historyEntries,
    ];
    _saveInventory(
      updatedProduct,
      current.copyWith(
        stock: updatedProduct.stock,
        purchasePrice: purchasePrice,
        historyEntries: history,
      ),
    );
    state = [
      for (final item in state)
        if (item.barcode == product.barcode) updatedProduct else item,
    ];
    unawaited(_persistCurrentState());
    if (updatedProduct.stock <= updatedProduct.lowStockThreshold) {
      syncLowStockAlert(
        productName: updatedProduct.name,
        stock: updatedProduct.stock,
        lowStockLimit: updatedProduct.lowStockThreshold,
        senderId: 'system',
        senderName: 'Inventory',
      );
    } else {
      clearLowStockAlert(updatedProduct.name);
    }
  }

  void applyStockReduce(
    DokanCatalogProduct product, {
    required int amount,
    required String reason,
  }) {
    final current = _inventoryFor(product);
    final updatedProduct = product.copyWith(
        stock: (product.stock - amount).clamp(0, product.stock));
    final history = <_ProductHistoryEntry>[
      _ProductHistoryEntry(
        label: 'বিক্রয়',
        amount: '-${_bnDigits(amount.toString())}টি',
        timeLabel: 'আজ • বিক্রয় সম্পন্ন',
        color: const Color(0xFFD43B3B),
        timestamp: DateTime.now(),
        kind: DokanStockMovementType.sale,
      ),
      ...current.historyEntries,
    ];
    _saveInventory(
      updatedProduct,
      current.copyWith(
        stock: updatedProduct.stock,
        historyEntries: history,
      ),
    );
    state = [
      for (final item in state)
        if (item.barcode == product.barcode) updatedProduct else item,
    ];
    unawaited(_persistCurrentState());
  }

  void applyPriceChange(
    DokanCatalogProduct product, {
    required int purchasePrice,
    required int salePrice,
  }) {
    final current = _inventoryFor(product);
    final updatedProduct = product.copyWith(
      purchasePrice: purchasePrice,
      salePrice: salePrice,
    );
    final history = <_ProductHistoryEntry>[
      _ProductHistoryEntry(
        label: 'দাম পরিবর্তন',
        amount:
            'ক্রয় ${_currency(purchasePrice)} → বিক্রয় ${_currency(salePrice)}',
        timeLabel: 'আজ • মূল্য হালনাগাদ',
        color: const Color(0xFF0C8C67),
        timestamp: DateTime.now(),
        kind: DokanStockMovementType.manual,
      ),
      ...current.historyEntries,
    ];
    _saveInventory(
      updatedProduct,
      current.copyWith(
        purchasePrice: purchasePrice,
        salePrice: salePrice,
        historyEntries: history,
      ),
    );
    state = [
      for (final item in state)
        if (item.barcode == product.barcode) updatedProduct else item,
    ];
    unawaited(_persistCurrentState());
    if (updatedProduct.stock <= updatedProduct.lowStockThreshold) {
      syncLowStockAlert(
        productName: updatedProduct.name,
        stock: updatedProduct.stock,
        lowStockLimit: updatedProduct.lowStockThreshold,
        senderId: 'system',
        senderName: 'Inventory',
      );
    } else {
      clearLowStockAlert(updatedProduct.name);
    }
  }

  void updateProductThreshold(DokanCatalogProduct product, int threshold) {
    final updatedProduct = product.copyWith(lowStockThreshold: threshold);
    state = [
      for (final item in state)
        if (item.barcode == product.barcode) updatedProduct else item,
    ];
    unawaited(_persistCurrentState());
    if (updatedProduct.stock <= updatedProduct.lowStockThreshold) {
      syncLowStockAlert(
        productName: updatedProduct.name,
        stock: updatedProduct.stock,
        lowStockLimit: updatedProduct.lowStockThreshold,
        senderId: 'system',
        senderName: 'Inventory',
      );
    } else {
      clearLowStockAlert(updatedProduct.name);
    }
  }
}

final dokanInventoryCatalogProvider =
    NotifierProvider<DokanInventoryCatalogNotifier, List<DokanCatalogProduct>>(
        DokanInventoryCatalogNotifier.new);

final lowStockProvider = Provider<List<DokanCatalogProduct>>((ref) {
  final products = ref.watch(dokanInventoryCatalogProvider);
  final threshold = ref.watch(stockThresholdProvider);
  return products.where((product) {
    final activeThreshold =
        product.lowStockThreshold > 0 ? product.lowStockThreshold : threshold;
    return product.stock > 0 && product.stock <= activeThreshold;
  }).toList(growable: false);
});

class DokanSearchMatcher {
  static bool match(String source, String query) {
    source = source.trim().toLowerCase();
    query = query.trim().toLowerCase();
    if (query.isEmpty) return true;
    if (source.contains(query)) return true;

    final srcPhonetic = _toPhonetic(source);
    final qryPhonetic = _toPhonetic(query);
    return srcPhonetic.contains(qryPhonetic);
  }

  static String _toPhonetic(String text) {
    var out = '';
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      out += _banglaToPhoneticMap[char] ?? char;
    }
    return out
        .replaceAll('ch', 'c')
        .replaceAll('sh', 's')
        .replaceAll('kh', 'k')
        .replaceAll('oo', 'u')
        .replaceAll('ee', 'i')
        .replaceAll('y', 'i')
        .replaceAll('w', 'o')
        .replaceAll('z', 'j');
  }

  static const Map<String, String> _banglaToPhoneticMap = {
    'চ': 'c',
    'ছ': 'c',
    'শ': 's',
    'ষ': 's',
    'স': 's',
    'ক': 'k',
    'খ': 'k',
    'গ': 'g',
    'ঘ': 'g',
    'ত': 't',
    'থ': 't',
    'ট': 't',
    'ঠ': 't',
    'প': 'p',
    'ফ': 'p',
    'ভ': 'v',
    'ব': 'b',
    'ম': 'm',
    'ন': 'n',
    'ণ': 'n',
    'ল': 'l',
    'র': 'r',
    'ড়': 'r',
    'ঢ়': 'r',
    'হ': 'h',
    'য': 'j',
    'জ': 'j',
    'ঝ': 'j',
    'দ': 'd',
    'ধ': 'd',
    'ড': 'd',
    'ঢ': 'd',
    'অ': 'o',
    'আ': 'a',
    'া': 'a',
    'ই': 'i',
    'ঈ': 'i',
    'ি': 'i',
    'ী': 'i',
    'উ': 'u',
    'ঊ': 'u',
    'ু': 'u',
    'ূ': 'u',
    'এ': 'e',
    'ে': 'e',
    'ও': 'o',
    'ো': 'o',
  };
}

class DokanDebug {
  static void log(String message) {
    try {
      final file =
          File('/Users/macbookair/Desktop/dokan_erp/flutter_debug.log');
      file.writeAsStringSync('${DateTime.now().toIso8601String()} - $message\n',
          mode: FileMode.append);
      debugPrint('[DOKAN_DEBUG] $message');
    } catch (_) {
      debugPrint('[DOKAN_DEBUG_ERR] Failed to write log: $message');
    }
  }
}
