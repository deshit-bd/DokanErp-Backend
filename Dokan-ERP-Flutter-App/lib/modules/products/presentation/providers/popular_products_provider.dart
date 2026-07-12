import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/network/remote_data_source_providers.dart';

class DokanPopularProductsState {
  const DokanPopularProductsState({
    this.stage = DokanPopularFlowStage.pick,
    this.selectedFilter = 'সব',
    this.revision = 0,
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
  });

  final DokanPopularFlowStage stage;
  final String selectedFilter;
  final int revision;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  DokanPopularProductsState copyWith({
    DokanPopularFlowStage? stage,
    String? selectedFilter,
    int? revision,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DokanPopularProductsState(
      stage: stage ?? this.stage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      revision: revision ?? this.revision,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum DokanPopularFlowStage { pick, stock, complete }

class DokanPopularProductItem {
  DokanPopularProductItem({
    required this.masterProductId,
    required this.sku,
    required this.name,
    required this.quantity,
    required this.emoji,
    required this.category,
    required this.selected,
    required String stock,
    required String purchasePrice,
    required String price,
    required String lowStockLimit,
  })  : stockController = TextEditingController(text: stock),
        purchasePriceController = TextEditingController(text: purchasePrice),
        priceController = TextEditingController(text: price),
        lowStockLimitController = TextEditingController(text: lowStockLimit);

  final String masterProductId;
  final String sku;
  final String name;
  final String quantity;
  final String emoji;
  final String category;
  bool selected;
  final TextEditingController stockController;
  final TextEditingController purchasePriceController;
  final TextEditingController priceController;
  final TextEditingController lowStockLimitController;

  void dispose() {
    stockController.dispose();
    purchasePriceController.dispose();
    priceController.dispose();
    lowStockLimitController.dispose();
  }
}

class DokanPopularProductsNotifier extends Notifier<DokanPopularProductsState> {
  final List<DokanPopularProductItem> _items = <DokanPopularProductItem>[];
  bool _catalogRequested = false;

  @override
  DokanPopularProductsState build() {
    if (!_catalogRequested) {
      _catalogRequested = true;
      Future.microtask(_loadCatalog);
    }
    ref.onDispose(() {
      _disposeItems();
    });
    return const DokanPopularProductsState();
  }

  List<DokanPopularProductItem> get items => _items;

  List<String> get filters {
    final values = <String>{};
    for (final item in _items) {
      final category = item.category.trim();
      if (category.isNotEmpty) {
        values.add(category);
      }
    }
    final ordered = values.toList()..sort();
    return <String>['সব', ...ordered];
  }

  void _bump() {
    state = state.copyWith(revision: state.revision + 1);
  }

  Future<void> _loadCatalog() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      revision: state.revision + 1,
    );
    try {
      final remote = ref.read(quickSetupCatalogRemoteDataSourceProvider);
      final payload = await remote.loadCatalog();
      final catalogValues = payload['catalogProducts'];
      final configuredValues = payload['configuredProducts'];
      final configuredById = <String, Map<String, dynamic>>{};

      if (configuredValues is List) {
        for (final item in configuredValues.whereType<Map>()) {
          final value = item.map((key, value) => MapEntry('$key', value));
          final masterProductId = '${value['masterProductId'] ?? ''}'.trim();
          if (masterProductId.isNotEmpty) {
            configuredById[masterProductId] = value;
          }
        }
      }

      final nextItems = <DokanPopularProductItem>[];
      if (catalogValues is List) {
        for (final item in catalogValues.whereType<Map>()) {
          final value = item.map((key, value) => MapEntry('$key', value));
          final masterProductId = '${value['id'] ?? ''}'.trim();
          if (masterProductId.isEmpty) {
            continue;
          }
          final configured = configuredById[masterProductId];
          final category = '${value['category'] ?? ''}'.trim();
          final packageSize = '${value['packageSize'] ?? ''}'.trim();
          final purchasePrice =
              configured?['purchasePrice'] ?? value['price'] ?? 0;
          final suggestedPrice = configured?['salePrice'] ??
              value['suggestedPrice'] ??
              value['price'] ??
              0;
          final openingStock = configured?['openingStock'] ?? 0;
          final lowStockLimitValue = int.tryParse(
                  '${configured?['lowStockLimit'] ?? configured?['lowStockThreshold'] ?? ''}') ??
              0;
          nextItems.add(
            DokanPopularProductItem(
              masterProductId: masterProductId,
              sku: '${value['sku'] ?? masterProductId}',
              name: '${value['name'] ?? ''}'.trim(),
              quantity: packageSize.isEmpty ? 'প্যাক সাইজ নেই' : packageSize,
              emoji: _emojiFor(category, '${value['name'] ?? ''}'),
              category: category.isEmpty ? 'অন্যান্য' : category,
              selected: value['selected'] == true,
              stock: '$openingStock',
              purchasePrice: '$purchasePrice',
              price: '$suggestedPrice',
              lowStockLimit:
                  '${lowStockLimitValue > 0 ? lowStockLimitValue : 10}',
            ),
          );
        }
      }

      _replaceItems(nextItems);
      final nextFilter =
          filters.contains(state.selectedFilter) ? state.selectedFilter : 'সব';
      state = state.copyWith(
        isLoading: false,
        selectedFilter: nextFilter,
        clearErrorMessage: true,
        revision: state.revision + 1,
      );
    } catch (error) {
      _replaceItems(const <DokanPopularProductItem>[]);
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        revision: state.revision + 1,
      );
    }
  }

  void _replaceItems(List<DokanPopularProductItem> nextItems) {
    _disposeItems();
    _items
      ..clear()
      ..addAll(nextItems);
    for (final item in _items) {
      item.stockController.addListener(_bump);
      item.purchasePriceController.addListener(_bump);
      item.priceController.addListener(_bump);
      item.lowStockLimitController.addListener(_bump);
    }
  }

  void _disposeItems() {
    for (final item in _items) {
      item.dispose();
    }
    _items.clear();
  }

  void setFilter(String filter) {
    state =
        state.copyWith(selectedFilter: filter, revision: state.revision + 1);
  }

  void toggleItem(DokanPopularProductItem item) {
    item.selected = !item.selected;
    _bump();
  }

  List<DokanPopularProductItem> get selectionItems {
    if (state.selectedFilter == 'সব') {
      return _items;
    }
    return _items
        .where((item) => item.category == state.selectedFilter)
        .toList();
  }

  List<DokanPopularProductItem> get stockItems =>
      _items.where((item) => item.selected).toList();

  int get selectedCount => _items.where((item) => item.selected).length;

  int get completedCount => _items.where((item) {
        if (!item.selected) return false;
        return item.stockController.text.trim().isNotEmpty &&
            item.purchasePriceController.text.trim().isNotEmpty &&
            item.priceController.text.trim().isNotEmpty &&
            item.stockController.text.trim() != '0' &&
            item.purchasePriceController.text.trim() != '0' &&
            item.priceController.text.trim() != '0';
      }).length;

  void goToPick() {
    state = state.copyWith(
        stage: DokanPopularFlowStage.pick, revision: state.revision + 1);
  }

  void goToStockPage() {
    state = state.copyWith(
        stage: DokanPopularFlowStage.stock, revision: state.revision + 1);
  }

  void goToStock(BuildContext context) {
    if (state.isSaving) {
      return;
    }
    if (selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('কমপক্ষে একটি পণ্য বাছাই করুন।',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    state = state.copyWith(
        stage: DokanPopularFlowStage.stock, revision: state.revision + 1);
  }

  Future<void> goToComplete(BuildContext context) async {
    if (state.isSaving) {
      return;
    }
    for (final item in _items.where((item) => item.selected)) {
      final stock = item.stockController.text.trim();
      final purchasePrice = item.purchasePriceController.text.trim();
      final price = item.priceController.text.trim();
      final lowStockLimitText = item.lowStockLimitController.text.trim();
      final stockValue = int.tryParse(stock);
      final purchasePriceValue = int.tryParse(purchasePrice);
      final priceValue = int.tryParse(price);
      final lowStockLimitValue =
          lowStockLimitText.isEmpty ? 10 : int.tryParse(lowStockLimitText);
      if (stock.isEmpty ||
          purchasePrice.isEmpty ||
          price.isEmpty ||
          stockValue == null ||
          stockValue < 0 ||
          purchasePriceValue == null ||
          purchasePriceValue < 0 ||
          priceValue == null ||
          priceValue < 0 ||
          lowStockLimitValue == null ||
          lowStockLimitValue < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'সব নির্বাচিত পণ্যের স্টক, ক্রয় মূল্য, বিক্রয় মূল্য ও স্বল্প মজুদ সীমা ঠিকভাবে দিন।',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }
      if (lowStockLimitText.isEmpty) {
        item.lowStockLimitController.text = '10';
      }
    }
    state = state.copyWith(
      isSaving: true,
      clearErrorMessage: true,
      revision: state.revision + 1,
    );
    try {
      final selectedItems = stockItems;
      final remote = ref.read(quickSetupCatalogRemoteDataSourceProvider);
      await remote.selectProducts(
        selectedItems
            .map((item) => item.masterProductId)
            .toList(growable: false),
      );
      await remote.savePricing(
        selectedItems
            .map(
              (item) => {
                'masterProductId': item.masterProductId,
                'openingStock':
                    int.tryParse(item.stockController.text.trim()) ?? 0,
                'purchasePrice':
                    int.tryParse(item.purchasePriceController.text.trim()) ?? 0,
                'salePrice':
                    int.tryParse(item.priceController.text.trim()) ?? 0,
                'lowStockLimit':
                    int.tryParse(item.lowStockLimitController.text.trim()) ??
                        10,
              },
            )
            .toList(growable: false),
      );
      if (!context.mounted) {
        return;
      }
      state = state.copyWith(
        stage: DokanPopularFlowStage.complete,
        isSaving: false,
        revision: state.revision + 1,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.toString(),
        revision: state.revision + 1,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ক্যাটালগের পণ্য সংরক্ষণ করা যায়নি: $error',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> reload() => _loadCatalog();

  static String _emojiFor(String category, String name) {
    final value = '$category $name'.toLowerCase();
    if (value.contains('চাল') ||
        value.contains('ধান') ||
        value.contains('rice')) {
      return '🌾';
    }
    if (value.contains('ডাল') || value.contains('lentil')) {
      return '🫘';
    }
    if (value.contains('তেল') || value.contains('oil')) {
      return '🛢️';
    }
    if (value.contains('সাবান') ||
        value.contains('শ্যাম্পু') ||
        value.contains('soap')) {
      return '🫧';
    }
    if (value.contains('দুধ') || value.contains('milk')) {
      return '🥛';
    }
    if (value.contains('বিস্কুট') || value.contains('cookie')) {
      return '🍪';
    }
    if (value.contains('পানীয়') ||
        value.contains('ড্রিংক') ||
        value.contains('cola')) {
      return '🥤';
    }
    return '📦';
  }
}

final dokanPopularProductsProvider =
    NotifierProvider<DokanPopularProductsNotifier, DokanPopularProductsState>(
  DokanPopularProductsNotifier.new,
);
