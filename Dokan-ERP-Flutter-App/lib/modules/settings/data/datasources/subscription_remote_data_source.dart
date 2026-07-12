import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class SubscriptionRemoteDataSource {
  const SubscriptionRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> loadSubscriptionInfo() async {
    return ApiPayload.object(
      await _client.get(ApiEndpoints.mySubscription),
    );
  }

  Future<Map<String, dynamic>> paySubscription({
    required double amount,
    required String method,
    required String trxId,
  }) async {
    return ApiPayload.object(
      await _client.post(
        ApiEndpoints.subscriptionPayments,
        body: {
          'amount': amount,
          'method': method,
          'trxId': trxId,
        },
        headers: const {
          'X-Queue-If-Offline': 'true',
        },
      ),
    );
  }
}
