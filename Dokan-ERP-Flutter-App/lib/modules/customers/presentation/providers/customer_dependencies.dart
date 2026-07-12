import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/app_flow_provider.dart';
import '../../domain/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository?>(
  (_) => null,
);

final customerListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  if (repository == null) return const <Map<String, dynamic>>[];
  final shopId = ref.watch(dokanAppFlowProvider.select((s) => s.shopId)).trim();
  if (shopId.isEmpty) return const <Map<String, dynamic>>[];
  final customers = await repository.list(shopId: shopId);
  return customers
      .map((customer) => <String, dynamic>{
            'id': customer.id,
            'name': customer.name,
            'phone': customer.phone,
            'totalSales': customer.totalSales,
            'currentDue': customer.currentDue,
          })
      .toList(growable: false);
});

/// A single payment entry returned by [customerPaymentsProvider].
class CustomerPaymentEntry {
  const CustomerPaymentEntry({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.paidAt,
    required this.notes,
  });

  final String id;
  final int amount;
  final String paymentMethod;
  final DateTime paidAt;
  final String notes;
}

/// Provides the payment history for a given customer ID.
/// Placed here (not inside business_screens) so the POS notifier can
/// invalidate it after recording a due payment.
final customerPaymentsProvider =
    FutureProvider.family<List<CustomerPaymentEntry>, String>(
        (ref, customerId) async {
  final repository = ref.watch(customerRepositoryProvider);
  if (repository == null) return const [];
  final shopId = ref.watch(dokanAppFlowProvider.select((s) => s.shopId)).trim();
  if (shopId.isEmpty) return const [];
  try {
    final response = await repository.get(customerId, shopId: shopId);
    final customerData = response['customer'] as Map<String, dynamic>?;
    if (customerData == null) return const [];
    final payments = customerData['recentPayments'] as List?;
    if (payments == null) return const [];
    return payments.map((p) {
      final m = Map<String, dynamic>.from(p as Map);
      return CustomerPaymentEntry(
        id: m['id'] as String? ?? '',
        amount: (m['amount'] as num?)?.round() ?? 0,
        paymentMethod: m['paymentMethod'] as String? ?? '',
        paidAt:
            DateTime.tryParse(m['paidAt'] as String? ?? '') ?? DateTime.now(),
        notes: m['notes'] as String? ?? '',
      );
    }).toList();
  } catch (e) {
    debugPrint('[customerPaymentsProvider] error: $e');
    return const [];
  }
});
