import '../../domain/entities/subscription_info.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';

class SubscriptionRemoteRepository implements SubscriptionRepository {
  const SubscriptionRemoteRepository(this._remote);

  final SubscriptionRemoteDataSource _remote;

  @override
  Future<SubscriptionInfo> loadSubscriptionInfo() async {
    final data = await _remote.loadSubscriptionInfo();
    return SubscriptionInfo.fromJson(data);
  }

  @override
  Future<void> paySubscription({
    required double amount,
    required String method,
    required String trxId,
  }) async {
    await _remote.paySubscription(
      amount: amount,
      method: method,
      trxId: trxId,
    );
  }
}
