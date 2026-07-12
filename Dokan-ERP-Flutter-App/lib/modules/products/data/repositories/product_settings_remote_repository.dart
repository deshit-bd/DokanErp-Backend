import '../../../../core/network/json_value.dart';
import '../../domain/repositories/product_settings_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductSettingsRemoteRepository implements ProductSettingsRepository {
  const ProductSettingsRemoteRepository(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<List<String>?> loadCategories() async {
    final values = await _remote.categories();
    return values
        .map(
          (item) => JsonValue.string(
            item,
            const ['name', 'label', 'category_name'],
          ),
        )
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    final current = await _remote.categories();
    final currentByName = {
      for (final item in current)
        JsonValue.string(item, const ['name', 'label', 'category_name']): item,
    };

    for (final name in categories) {
      if (!currentByName.containsKey(name)) {
        await _remote.createCategory(name);
      }
    }

    for (final entry in currentByName.entries) {
      if (entry.key.isEmpty || categories.contains(entry.key)) continue;
      final id = JsonValue.string(entry.value, const ['id', 'uuid']);
      if (id.isNotEmpty) await _remote.deleteCategory(id);
    }
  }

  @override
  Future<int?> loadStockThreshold() async {
    final payload = await _remote.inventorySettings();
    return JsonValue.integer(
      payload,
      const ['low_stock_limit', 'lowStockLimit'],
      fallback: 10,
    );
  }

  @override
  Future<void> saveStockThreshold(int threshold) async {
    await _remote.saveInventoryThreshold(threshold);
  }
}
