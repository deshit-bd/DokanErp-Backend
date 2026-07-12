abstract interface class ProductSettingsRepository {
  Future<List<String>?> loadCategories();
  Future<void> saveCategories(List<String> categories);
  Future<int?> loadStockThreshold();
  Future<void> saveStockThreshold(int threshold);
}
