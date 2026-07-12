import '../entities/business_settings.dart';

abstract interface class BusinessSettingsRepository {
  Future<InventorySettings> loadInventorySettings();
  Future<void> saveInventorySettings(InventorySettings settings);
  Future<StoreDetails> loadStoreDetails();
  Future<void> saveStoreDetails(StoreDetails details);
  Future<String> uploadShopLogo({
    required String fileName,
    required String contentType,
    required String base64Data,
  });
  Future<StoreDetails> uploadStoreDocument({
    required StoreDocumentType type,
    required StoreDocumentUpload document,
  });
}
