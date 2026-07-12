import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/product_settings_repository.dart';

class ProductSettingsRepositoryImpl implements ProductSettingsRepository {
  const ProductSettingsRepositoryImpl();

  static const _categoriesKey = 'dokan_product_categories_v1';
  static const _thresholdKey = 'dokan_stock_threshold_v1';

  @override
  Future<List<String>?> loadCategories() async {
    return (await SharedPreferences.getInstance())
        .getStringList(_categoriesKey);
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    await (await SharedPreferences.getInstance())
        .setStringList(_categoriesKey, categories);
  }

  @override
  Future<int?> loadStockThreshold() async {
    return (await SharedPreferences.getInstance()).getInt(_thresholdKey);
  }

  @override
  Future<void> saveStockThreshold(int threshold) async {
    await (await SharedPreferences.getInstance()).setInt(
      _thresholdKey,
      threshold,
    );
  }
}
