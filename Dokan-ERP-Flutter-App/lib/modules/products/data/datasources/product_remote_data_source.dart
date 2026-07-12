import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class ProductRemoteDataSource {
  const ProductRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list({
    int page = 1,
    int perPage = 50,
    String? search,
    String? category,
  }) async {
    return ApiPayload.list(await _client.get(
      ApiEndpoints.products,
      query: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
      },
    ));
  }

  Future<List<Map<String, dynamic>>> shopCatalog() async {
    return ApiPayload.list(await _client.get(ApiEndpoints.shopProducts));
  }

  Future<Map<String, dynamic>> find(String id) async {
    return ApiPayload.object(await _client.get(ApiEndpoints.product(id)));
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> input) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.products,
        body: input,
        headers: const {'X-Queue-If-Offline': 'true'},
      ),
    );
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> input,
  ) async {
    return ApiPayload.object(
      await _client.patch(
        ApiEndpoints.product(id),
        body: input,
        headers: const {'X-Queue-If-Offline': 'true'},
      ),
    );
  }

  Future<void> delete(String id) async {
    await _client.delete(
      ApiEndpoints.product(id),
      headers: const {'X-Queue-If-Offline': 'true'},
    );
  }

  Future<Map<String, dynamic>> adjustStock({
    required String productId,
    required int quantity,
    required String type,
    String? reference,
    String? note,
    int? purchasePrice,
  }) async {
    return ApiPayload.object(await _client.post(
      ApiEndpoints.stockMovements,
      body: {
        'product_id': productId,
        'quantity': quantity,
        'type': type,
        if (reference != null) 'reference': reference,
        if (note != null) 'note': note,
        if (purchasePrice != null) 'purchase_price': purchasePrice,
      },
      headers: const {'X-Queue-If-Offline': 'true'},
    ));
  }

  Future<List<Map<String, dynamic>>> stockHistory(
    String productId, {
    int limit = 50,
  }) async {
    final response = await _client.get(
      ApiEndpoints.stockMovements,
      query: {
        'product_id': productId,
        'limit': limit,
      },
    );
    final value = response.data['history'];
    if (value is! List) {
      return const [];
    }
    return value
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> categories() async {
    return ApiPayload.list(await _client.get(ApiEndpoints.categories));
  }

  Future<Map<String, dynamic>> createCategory(String name) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.categories,
        body: {'name': name},
        headers: const {'X-Queue-If-Offline': 'true'},
      ),
    );
  }

  Future<void> deleteCategory(String id) async {
    await _client.delete(
      ApiEndpoints.category(id),
      headers: const {'X-Queue-If-Offline': 'true'},
    );
  }

  Future<Map<String, dynamic>> inventorySettings() async {
    return ApiPayload.object(
      await _client.get('${ApiEndpoints.settings}/inventory'),
    );
  }

  Future<void> saveInventoryThreshold(int threshold) async {
    await _client.patch(
      '${ApiEndpoints.settings}/inventory',
      body: {'low_stock_limit': threshold},
      headers: const {'X-Queue-If-Offline': 'true'},
    );
  }
}
