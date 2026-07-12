import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/business_settings.dart';
import '../../domain/repositories/business_settings_repository.dart';

class BusinessSettingsRepositoryImpl implements BusinessSettingsRepository {
  const BusinessSettingsRepositoryImpl();

  static const _inventoryKey = 'dokan_inventory_settings_v1';
  static const _storeKey = 'dokan_store_details_v1';

  Future<Map<String, dynamic>> _read(String key) async {
    final raw = (await SharedPreferences.getInstance()).getString(key);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  Future<void> _write(String key, Map<String, dynamic> value) async {
    await (await SharedPreferences.getInstance())
        .setString(key, jsonEncode(value));
  }

  @override
  Future<InventorySettings> loadInventorySettings() async {
    return InventorySettings.fromJson(await _read(_inventoryKey));
  }

  @override
  Future<void> saveInventorySettings(InventorySettings settings) {
    return _write(_inventoryKey, settings.toJson());
  }

  @override
  Future<StoreDetails> loadStoreDetails() async {
    return StoreDetails.fromJson(await _read(_storeKey));
  }

  @override
  Future<void> saveStoreDetails(StoreDetails details) {
    return _write(_storeKey, details.toJson());
  }

  @override
  Future<String> uploadShopLogo({
    required String fileName,
    required String contentType,
    required String base64Data,
  }) async {
    final current = await loadStoreDetails();
    final updated = current.copyWith(
      logoFileName: fileName,
      logoBase64: base64Data,
    );
    await saveStoreDetails(updated);
    return updated.logoUrl;
  }

  @override
  Future<StoreDetails> uploadStoreDocument({
    required StoreDocumentType type,
    required StoreDocumentUpload document,
  }) async {
    final current = await loadStoreDetails();
    final updated = switch (type) {
      StoreDocumentType.trade =>
        current.copyWith(tradeLicenseNo: document.fileName),
      StoreDocumentType.tin => current.copyWith(tinNo: document.fileName),
      StoreDocumentType.bin => current.copyWith(binNo: document.fileName),
    };
    await saveStoreDetails(updated);
    return updated;
  }
}
