import 'package:shared_preferences/shared_preferences.dart';

class InventoryCatalogLocalDataSource {
  const InventoryCatalogLocalDataSource();

  static const String snapshotKey = 'dokan_inventory_catalog_snapshot';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  Future<String?> readSnapshot() async {
    return (await _preferences).getString(snapshotKey);
  }

  Future<void> writeSnapshot(String snapshotJson) async {
    await (await _preferences).setString(snapshotKey, snapshotJson);
  }
}
