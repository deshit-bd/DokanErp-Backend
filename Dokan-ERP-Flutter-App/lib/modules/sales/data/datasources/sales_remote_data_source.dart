import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class SalesRemoteDataSource {
  const SalesRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list({
    int page = 1,
    int perPage = 50,
    DateTime? from,
    DateTime? to,
  }) async {
    return ApiPayload.list(await _client.get(
      ApiEndpoints.sales,
      query: {
        'page': page,
        'per_page': perPage,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      },
    ));
  }

  Future<Map<String, dynamic>> create(
    Map<String, dynamic> input, {
    required String idempotencyKey,
  }) async {
    return ApiPayload.object(await _client.post(
      ApiEndpoints.sales,
      body: input,
      headers: {
        'Idempotency-Key': idempotencyKey,
        'X-Queue-If-Offline': 'true',
      },
    ));
  }

  Future<Map<String, dynamic>> addPayment(
    String id,
    Map<String, dynamic> input, {
    required String idempotencyKey,
  }) async {
    return ApiPayload.object(await _client.post(
      '${ApiEndpoints.sale(id)}/payments',
      body: input,
      headers: {
        'Idempotency-Key': idempotencyKey,
        'X-Queue-If-Offline': 'true',
      },
    ));
  }

  Future<void> cancel(
    String id, {
    required String reason,
    String? refundMethod,
  }) async {
    await _client.post(
      '${ApiEndpoints.sale(id)}/cancel',
      body: {
        'reason': reason,
        if (refundMethod != null) 'refund_method': refundMethod,
      },
      headers: {
        'Idempotency-Key': 'cancel-sale-$id',
        'X-Queue-If-Offline': 'true',
      },
    );
  }
}
