import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class CustomerRemoteDataSource {
  const CustomerRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list({
    String? shopId,
    String? search,
  }) async {
    return ApiPayload.list(
      await _client.get(
        ApiEndpoints.customers,
        query: {
          if (shopId != null && shopId.isNotEmpty) 'shopId': shopId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      ),
    );
  }

  Future<Map<String, dynamic>> create(
    Map<String, dynamic> input, {
    required String idempotencyKey,
  }) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.customers,
        body: input,
        headers: {
          'Idempotency-Key': idempotencyKey,
          'X-Queue-If-Offline': 'true',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> get(String id, {String? shopId}) async {
    return ApiPayload.object(
      await _client.get(
        ApiEndpoints.customer(id),
        query: {
          if (shopId != null && shopId.isNotEmpty) 'shopId': shopId,
        },
      ),
    );
  }

  Future<Map<String, dynamic>> collectDuePayment({
    required String customerId,
    required int amount,
    required String shopId,
    DateTime? paidAt,
    String? notes,
    String paymentMethod = 'CASH',
    Map<String, dynamic>? paymentDetails,
  }) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.customerPayments(customerId),
        body: <String, dynamic>{
          'amount': amount,
          'paymentMethod': paymentMethod,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (paidAt != null) 'paidAt': paidAt.toIso8601String(),
          'shopId': shopId,
          if (paymentDetails != null) 'paymentDetails': paymentDetails,
        },
        headers: {
          'X-Queue-If-Offline': 'true',
        },
      ),
    );
  }
}
