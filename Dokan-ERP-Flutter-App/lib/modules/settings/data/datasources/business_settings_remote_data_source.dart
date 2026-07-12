import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class BusinessSettingsRemoteDataSource {
  const BusinessSettingsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> inventorySettings() async {
    return ApiPayload.object(
      await _client.get('${ApiEndpoints.settings}/inventory'),
    );
  }

  Future<Map<String, dynamic>> saveInventorySettings(
    Map<String, dynamic> input,
  ) async {
    return ApiPayload.object(await _client.patch(
      '${ApiEndpoints.settings}/inventory',
      body: input,
      headers: const {
        'Idempotency-Key': 'save-inventory-settings',
        'X-Queue-If-Offline': 'true',
      },
    ));
  }

  Future<Map<String, dynamic>> storeDetails() async {
    return ApiPayload.object(
      await _client.get('${ApiEndpoints.apiVersion}/shops/me/settings'),
    );
  }

  Future<Map<String, dynamic>> saveStoreDetails(
    Map<String, dynamic> input,
  ) async {
    return ApiPayload.object(await _client.patch(
      '${ApiEndpoints.apiVersion}/shops/me/settings',
      body: input,
      headers: const {
        'Idempotency-Key': 'save-store-settings',
        'X-Queue-If-Offline': 'true',
      },
    ));
  }

  Future<Map<String, dynamic>> uploadStoreDocument(
    String type,
    Map<String, dynamic> input,
  ) async {
    return ApiPayload.object(await _client.post(
      '${ApiEndpoints.settings}/store/documents/$type',
      body: input,
      headers: const {
        'Idempotency-Key': 'upload-store-document',
      },
    ));
  }

  Future<Map<String, dynamic>> uploadShopLogo(String dataUrl) async {
    return ApiPayload.object(await _client.patch(
      ApiEndpoints.shopLogo,
      body: {
        'logoUrl': dataUrl,
      },
      headers: const {
        'Idempotency-Key': 'upload-shop-logo',
        'X-Queue-If-Offline': 'true',
      },
    ));
  }
}
