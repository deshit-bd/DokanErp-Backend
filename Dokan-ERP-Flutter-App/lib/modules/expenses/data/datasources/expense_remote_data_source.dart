import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class ExpenseRemoteDataSource {
  const ExpenseRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list({
    int page = 1,
    int perPage = 50,
    String period = 'ALL',
    DateTime? from,
    DateTime? to,
  }) async {
    return ApiPayload.list(await _client.get(
      ApiEndpoints.expenses,
      query: {
        'page': page,
        'per_page': perPage,
        'period': period,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      },
    ));
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> input) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.expenses,
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
        ApiEndpoints.expense(id),
        body: input,
        headers: const {'X-Queue-If-Offline': 'true'},
      ),
    );
  }

  Future<void> delete(String id) async {
    await _client.delete(
      ApiEndpoints.expense(id),
      headers: {
        'Idempotency-Key': 'delete-expense-$id',
        'X-Queue-If-Offline': 'true',
      },
    );
  }
}
