import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class QuickSetupCatalogRemoteDataSource {
  const QuickSetupCatalogRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> loadCatalog() async {
    return ApiPayload.object(await _client.get(ApiEndpoints.quickSetupCatalog));
  }

  Future<Map<String, dynamic>> selectProducts(List<String> productIds) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.quickSetupCatalogSelect,
        body: {'productIds': productIds},
      ),
    );
  }

  Future<Map<String, dynamic>> savePricing(
    List<Map<String, dynamic>> items,
  ) async {
    return ApiPayload.object(
      await _client.patch(
        ApiEndpoints.quickSetupCatalogPricing,
        body: {'items': items},
      ),
    );
  }
}
