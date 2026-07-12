import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class SupplierRemoteDataSource {
  const SupplierRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list({
    String? shopId,
    String? search,
  }) async {
    return ApiPayload.list(
      await _client.get(
        ApiEndpoints.suppliers,
        query: {
          if (shopId != null && shopId.isNotEmpty) 'shopId': shopId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> ledger(
    String supplierId, {
    String? shopId,
  }) async {
    final response = await _client.get(
      ApiEndpoints.supplierLedger(supplierId),
      query: {
        if (shopId != null && shopId.isNotEmpty) 'shopId': shopId,
      },
    );
    final payload = ApiPayload.object(response);
    final value = payload['ledger'] ?? payload['entries'] ?? payload['data'];
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> create(
    Map<String, dynamic> input, {
    required String idempotencyKey,
  }) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.suppliers,
        body: input,
        headers: {
          'Idempotency-Key': idempotencyKey,
          'X-Queue-If-Offline': 'true',
        },
      ),
    );
  }

  Future<void> delete(String supplierId) async {
    await _client.delete(
      ApiEndpoints.supplier(supplierId),
      headers: {
        'Idempotency-Key': 'delete-supplier-$supplierId',
        'X-Queue-If-Offline': 'true',
      },
    );
  }

  Future<void> recordPayment(
    String supplierId,
    Map<String, dynamic> input,
    String idempotencyKey,
  ) async {
    await _client.post(
      ApiEndpoints.supplierPayments(supplierId),
      body: input,
      headers: {
        'Idempotency-Key': idempotencyKey,
        'X-Queue-If-Offline': 'true',
      },
    );
  }
}
