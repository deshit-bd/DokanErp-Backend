import '../../domain/repositories/product_settings_repository.dart';

class ProductSettingsOfflineFirstRepository
    implements ProductSettingsRepository {
  const ProductSettingsOfflineFirstRepository(this._remote, this._local);

  final ProductSettingsRepository _remote;
  final ProductSettingsRepository _local;

  @override
  Future<List<String>?> loadCategories() async {
    try {
      final values = await _remote.loadCategories();
      if (values != null) await _local.saveCategories(values);
      return values ?? await _local.loadCategories();
    } catch (_) {
      return _local.loadCategories();
    }
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    await _local.saveCategories(categories);
    await _remote.saveCategories(categories);
  }

  @override
  Future<int?> loadStockThreshold() async {
    try {
      final value = await _remote.loadStockThreshold();
      if (value != null) await _local.saveStockThreshold(value);
      return value ?? await _local.loadStockThreshold();
    } catch (_) {
      return _local.loadStockThreshold();
    }
  }

  @override
  Future<void> saveStockThreshold(int threshold) async {
    await _local.saveStockThreshold(threshold);
    await _remote.saveStockThreshold(threshold);
  }
}
