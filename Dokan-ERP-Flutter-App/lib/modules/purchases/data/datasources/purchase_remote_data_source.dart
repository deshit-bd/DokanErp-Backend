import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class PurchaseRemoteDataSource {
  const PurchaseRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list({
    int page = 1,
    int perPage = 50,
    String? status,
  }) async {
    return ApiPayload.list(await _client.get(
      ApiEndpoints.purchases,
      query: {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status,
      },
    ));
  }

  Future<Map<String, dynamic>> create(
    Map<String, dynamic> input, {
    required String idempotencyKey,
  }) async {
    final lines = input['lines'];
    if (lines is List) {
      final productIds = lines
          .whereType<Map>()
          .map((item) => item['product_id'])
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList(growable: false);
      if (productIds.isNotEmpty) {
        try {
          await _client.post(
            ApiEndpoints.quickSetupCatalogSelect,
            body: {'productIds': productIds},
          );
        } catch (_) {}
      }
    }

    return ApiPayload.object(await _client.post(
      ApiEndpoints.purchases,
      body: input,
      headers: {
        'Idempotency-Key': idempotencyKey,
        'X-Queue-If-Offline': 'true',
      },
    ));
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> input,
  ) async {
    return ApiPayload.object(
      await _client.patch(
        ApiEndpoints.purchase(id),
        body: input,
        headers: const {'X-Queue-If-Offline': 'true'},
      ),
    );
  }

  Future<Map<String, dynamic>> receive(
    String id,
    Map<String, dynamic> input, {
    required String idempotencyKey,
  }) async {
    final lines = input['lines'];
    if (lines is List) {
      final productIds = lines
          .whereType<Map>()
          .map((item) => item['product_id'])
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList(growable: false);
      if (productIds.isNotEmpty) {
        try {
          await _client.post(
            ApiEndpoints.quickSetupCatalogSelect,
            body: {'productIds': productIds},
          );
        } catch (_) {}
      }
    }

    return ApiPayload.object(
      await _client.post(
        '${ApiEndpoints.purchase(id)}/receive',
        body: input,
        headers: {
          'Idempotency-Key': idempotencyKey,
          'X-Queue-If-Offline': 'true',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> cancel(String id, {String? reason}) async {
    return ApiPayload.object(
      await _client.post(
        '${ApiEndpoints.purchase(id)}/cancel',
        body: {if (reason != null) 'reason': reason},
        headers: {
          'Idempotency-Key': 'cancel-purchase-$id',
          'X-Queue-If-Offline': 'true',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> returnOrder(
    String id,
    List<Map<String, dynamic>> returnItems, {
    String? refundMethod,
    String? notes,
  }) async {
    return ApiPayload.object(
      await _client.post(
        '${ApiEndpoints.purchase(id)}/returns',
        body: {
          'items': returnItems,
          if (refundMethod != null) 'refundMethod': refundMethod,
          if (notes != null) 'notes': notes,
        },
        headers: {
          'Idempotency-Key':
              'return-purchase-$id-${DateTime.now().millisecondsSinceEpoch}',
          'X-Queue-If-Offline': 'true',
        },
      ),
    );
  }
}
