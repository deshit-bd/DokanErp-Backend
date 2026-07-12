import '../../domain/entities/business_settings.dart';
import '../../domain/repositories/business_settings_repository.dart';

class BusinessSettingsOfflineFirstRepository
    implements BusinessSettingsRepository {
  const BusinessSettingsOfflineFirstRepository(this._remote, this._local);

  final BusinessSettingsRepository _remote;
  final BusinessSettingsRepository _local;

  @override
  Future<InventorySettings> loadInventorySettings() async {
    try {
      final value = await _remote.loadInventorySettings();
      await _local.saveInventorySettings(value);
      return value;
    } catch (_) {
      return _local.loadInventorySettings();
    }
  }

  @override
  Future<void> saveInventorySettings(InventorySettings settings) async {
    await _local.saveInventorySettings(settings);
    await _remote.saveInventorySettings(settings);
  }

  @override
  Future<StoreDetails> loadStoreDetails() async {
    try {
      final value = await _remote.loadStoreDetails();
      final localValue = await _local.loadStoreDetails();
      final mergedValue = value.copyWith(
        logoFileName: value.logoFileName.trim().isNotEmpty
            ? value.logoFileName
            : localValue.logoFileName,
        logoBase64: value.logoBase64.trim().isNotEmpty
            ? value.logoBase64
            : localValue.logoBase64,
        logoUrl: value.logoUrl.trim().isNotEmpty
            ? value.logoUrl
            : localValue.logoUrl,
      );
      await _local.saveStoreDetails(mergedValue);
      return mergedValue;
    } catch (_) {
      return _local.loadStoreDetails();
    }
  }

  @override
  Future<void> saveStoreDetails(StoreDetails details) async {
    await _local.saveStoreDetails(details);
    await _remote.saveStoreDetails(details);
  }

  @override
  Future<String> uploadShopLogo({
    required String fileName,
    required String contentType,
    required String base64Data,
  }) async {
    final logoUrl = await _remote.uploadShopLogo(
      fileName: fileName,
      contentType: contentType,
      base64Data: base64Data,
    );
    final current = await _local.loadStoreDetails();
    await _local.saveStoreDetails(
      current.copyWith(
        logoFileName: fileName,
        logoBase64: base64Data,
        logoUrl: logoUrl,
      ),
    );
    return logoUrl;
  }

  @override
  Future<StoreDetails> uploadStoreDocument({
    required StoreDocumentType type,
    required StoreDocumentUpload document,
  }) async {
    final value = await _remote.uploadStoreDocument(
      type: type,
      document: document,
    );
    await _local.saveStoreDetails(value);
    return value;
  }
}
