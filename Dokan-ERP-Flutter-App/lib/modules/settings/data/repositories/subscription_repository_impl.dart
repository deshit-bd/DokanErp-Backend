import '../../domain/entities/subscription_info.dart';
import '../../domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl();

  @override
  Future<SubscriptionInfo> loadSubscriptionInfo() async {
    return SubscriptionInfo(
      allowed: true,
      status: 'TRIAL',
      tier: 'TRIAL',
      trialEndsAt:
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      billableAccounts: 1,
      ratePerAccount: 0.0,
      totalAmount: 0.0,
      paidAmount: 0.0,
      amountDue: 0.0,
      message: 'Active Trial Mode',
      recentInvoices: const [
        SubscriptionInvoice(
          id: 'trial-inv-1',
          billingDate: '2026-06-12T00:00:00Z',
          billableAccounts: 1,
          ratePerAccount: 0.0,
          totalAmount: 0.0,
          paidAmount: 0.0,
          amountDue: 0.0,
          status: 'PAID',
        ),
      ],
      recentPayments: const [
        SubscriptionPayment(
          id: 'trial-pay-1',
          invoiceId: 'trial-inv-1',
          amount: 0.0,
          method: 'system',
          status: 'SUCCESS',
          paidAt: '2026-06-12T00:00:00Z',
          billingDate: '2026-06-12T00:00:00Z',
        ),
      ],
    );
  }

  @override
  Future<void> paySubscription({
    required double amount,
    required String method,
    required String trxId,
  }) async {
    // Local mock payment completes immediately
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
