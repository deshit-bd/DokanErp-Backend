import '../../domain/entities/business_settings.dart';
import '../../domain/repositories/business_settings_repository.dart';
import '../datasources/business_settings_remote_data_source.dart';
import '../mappers/business_settings_api_mapper.dart';
import '../../../../core/network/json_value.dart';

class BusinessSettingsRemoteRepository implements BusinessSettingsRepository {
  const BusinessSettingsRemoteRepository(this._remote);

  final BusinessSettingsRemoteDataSource _remote;

  @override
  Future<InventorySettings> loadInventorySettings() async {
    return BusinessSettingsApiMapper.inventoryFromJson(
      await _remote.inventorySettings(),
    );
  }

  @override
  Future<void> saveInventorySettings(InventorySettings settings) async {
    await _remote.saveInventorySettings(
      BusinessSettingsApiMapper.inventoryToJson(settings),
    );
  }

  @override
  Future<StoreDetails> loadStoreDetails() async {
    return BusinessSettingsApiMapper.storeFromJson(
      await _remote.storeDetails(),
    );
  }

  @override
  Future<void> saveStoreDetails(StoreDetails details) async {
    await _remote.saveStoreDetails(
      BusinessSettingsApiMapper.storeToJson(details),
    );
  }

  @override
  Future<String> uploadShopLogo({
    required String fileName,
    required String contentType,
    required String base64Data,
  }) async {
    final payload = await _remote.uploadShopLogo(
      'data:$contentType;base64,$base64Data',
    );
    final shopValue = payload['shop'];
    if (shopValue is Map) {
      final shop = shopValue.map((key, value) => MapEntry('$key', value));
      return JsonValue.string(shop, const ['logoUrl', 'logo_url']);
    }
    return JsonValue.string(payload, const ['logoUrl', 'logo_url']);
  }

  @override
  Future<StoreDetails> uploadStoreDocument({
    required StoreDocumentType type,
    required StoreDocumentUpload document,
  }) async {
    return BusinessSettingsApiMapper.storeFromJson(
      await _remote.uploadStoreDocument(
        type.name,
        document.toJson(),
      ),
    );
  }
}
