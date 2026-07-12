import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class SalesmanRemoteDataSource {
  const SalesmanRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list({String? search}) {
    return _client.get(
      ApiEndpoints.staff,
      query: {
        'role': 'salesman',
        if (search != null && search.isNotEmpty) 'search': search,
      },
    ).then(ApiPayload.list);
  }

  Future<Map<String, dynamic>> create(
    Map<String, dynamic> input, {
    required String idempotencyKey,
  }) {
    return _client.post(
      ApiEndpoints.staff,
      body: input,
      headers: {
        'Idempotency-Key': idempotencyKey,
        'X-Queue-If-Offline': 'true',
      },
    ).then(ApiPayload.object);
  }
}
