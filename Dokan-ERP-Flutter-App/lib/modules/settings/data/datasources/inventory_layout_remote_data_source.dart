import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class InventoryLayoutRemoteDataSource {
  const InventoryLayoutRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getInventoryMode() async {
    return ApiPayload.object(
        await _client.get('${ApiEndpoints.inventory}/mode'));
  }

  Future<Map<String, dynamic>> updateInventoryMode(
      Map<String, dynamic> body) async {
    return ApiPayload.object(
      await _client.post(
        '${ApiEndpoints.inventory}/mode',
        body: body,
        headers: const {
          'Idempotency-Key': 'update-inventory-mode',
          'X-Queue-If-Offline': 'true',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getLayoutTree() async {
    final response = await _client.get('${ApiEndpoints.inventory}/layout-tree');
    final data = Map<String, dynamic>.from(ApiPayload.object(response));
    if (response.headers['x-dokan-offline-cache'] == 'true') {
      data['_isOfflineCache'] = true;
    }
    return data;
  }

  Future<Map<String, dynamic>> createZone(Map<String, dynamic> body) async {
    return ApiPayload.object(
      await _client.post(
        '${ApiEndpoints.inventory}/zones',
        body: body,
      ),
    );
  }

  Future<Map<String, dynamic>> updateZone(
      String id, Map<String, dynamic> body) async {
    return ApiPayload.object(
      await _client.patch(
        ApiEndpoints.inventoryZone(id),
        body: body,
      ),
    );
  }

  Future<void> deleteZone(String id) async {
    await _client.delete(ApiEndpoints.inventoryZone(id));
  }

  Future<Map<String, dynamic>> createRack(Map<String, dynamic> body) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.inventoryRacks,
        body: body,
      ),
    );
  }

  Future<Map<String, dynamic>> updateRack(
      String id, Map<String, dynamic> body) async {
    return ApiPayload.object(
      await _client.patch(
        ApiEndpoints.inventoryRack(id),
        body: body,
      ),
    );
  }

  Future<void> deleteRack(String id) async {
    await _client.delete(ApiEndpoints.inventoryRack(id));
  }

  Future<Map<String, dynamic>> createShelf(Map<String, dynamic> body) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.inventoryShelves,
        body: body,
      ),
    );
  }

  Future<Map<String, dynamic>> updateShelf(
      String id, Map<String, dynamic> body) async {
    return ApiPayload.object(
      await _client.patch(
        ApiEndpoints.inventoryShelf(id),
        body: body,
      ),
    );
  }

  Future<void> deleteShelf(String id) async {
    await _client.delete(ApiEndpoints.inventoryShelf(id));
  }

  Future<Map<String, dynamic>> createBin(Map<String, dynamic> body) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.inventoryBins,
        body: body,
      ),
    );
  }

  Future<Map<String, dynamic>> updateBin(
      String id, Map<String, dynamic> body) async {
    return ApiPayload.object(
      await _client.patch(
        ApiEndpoints.inventoryBin(id),
        body: body,
      ),
    );
  }

  Future<void> deleteBin(String id) async {
    await _client.delete(ApiEndpoints.inventoryBin(id));
  }
}
