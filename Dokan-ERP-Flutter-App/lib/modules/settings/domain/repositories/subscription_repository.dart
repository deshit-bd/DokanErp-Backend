import '../entities/subscription_info.dart';

abstract interface class SubscriptionRepository {
  Future<SubscriptionInfo> loadSubscriptionInfo();
  Future<void> paySubscription({
    required double amount,
    required String method,
    required String trxId,
  });
}
