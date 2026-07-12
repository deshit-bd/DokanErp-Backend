import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>(
  (ref) => throw UnimplementedError('Override inventoryRepositoryProvider'),
);

final inventoryItemsProvider =
    AsyncNotifierProvider<InventoryItemsNotifier, List<InventoryItem>>(
  InventoryItemsNotifier.new,
);

class InventoryItemsNotifier extends AsyncNotifier<List<InventoryItem>> {
  InventoryRepository get _repository => ref.read(inventoryRepositoryProvider);

  @override
  Future<List<InventoryItem>> build() => _repository.getAll();

  Future<InventoryItem> add(InventoryItem item) async {
    final current = state.asData?.value ?? const <InventoryItem>[];
    final saved = await _repository.add(item);
    state = AsyncData(<InventoryItem>[saved, ...current]);
    return saved;
  }

  Future<void> remove(InventoryItem item) async {
    await _repository.remove(item);
    final current = state.asData?.value ?? const <InventoryItem>[];
    state = AsyncData(
      current.where((element) => element != item).toList(growable: false),
    );
  }

  Future<void> restock(
    InventoryItem item,
    int quantity, {
    int? purchasePrice,
  }) async {
    final saved = await _repository.restock(
      item,
      quantity: quantity,
      purchasePrice: purchasePrice,
    );
    final current = state.asData?.value ?? const <InventoryItem>[];
    state = AsyncData(
      current
          .map((element) => element == item ? saved : element)
          .toList(growable: false),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }
}
