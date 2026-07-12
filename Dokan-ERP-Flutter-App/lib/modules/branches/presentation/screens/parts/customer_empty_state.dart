part of '../business_screens.dart';

class _CustomerEmptyState extends StatelessWidget {
  const _CustomerEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E5E1)),
      ),
      child: const Column(
        children: [
          Icon(Icons.person_search_rounded, color: Color(0xFF0C8C67), size: 52),
          SizedBox(height: 12),
          Text(
            'কোনো গ্রাহক পাওয়া যায়নি',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF163732),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'গ্রাহকের তথ্য এখনো তৈরি হয়নি বা সার্চের সাথে মেলেনি।',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7B79),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

const List<DokanPosPaymentMethod> _allowedSupplierPaymentMethods =
    <DokanPosPaymentMethod>[
  DokanPosPaymentMethod.cash,
  DokanPosPaymentMethod.bkash,
  DokanPosPaymentMethod.nagad,
  DokanPosPaymentMethod.card,
];

class _SupplierSummary {
  const _SupplierSummary({
    required this.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.productType,
    required this.creditLimit,
    required this.totalPurchase,
    required this.totalPaid,
    required this.totalDue,
    required this.currentMonthPurchase,
    required this.lastTransactionAt,
    required this.ledger,
  });

  final String key;
  final String name;
  final String phone;
  final String address;
  final String productType;
  final int creditLimit;
  final int totalPurchase;
  final int totalPaid;
  final int totalDue;
  final int currentMonthPurchase;
  final DateTime lastTransactionAt;
  final List<DokanSupplierLedgerRecord> ledger;
}

List<_SupplierSummary> _buildSupplierSummaries(DokanPosState state) {
  final grouped = <String, List<DokanSupplierLedgerRecord>>{};
  for (final record in state.supplierLedger) {
    if (state.hiddenSupplierKeys.contains(record.supplierKey)) {
      continue;
    }
    grouped
        .putIfAbsent(record.supplierKey, () => <DokanSupplierLedgerRecord>[])
        .add(record);
  }

  final profilesByKey = <String, DokanSupplierProfileRecord>{
    for (final profile in state.supplierProfiles) profile.key: profile,
  };

  final allKeys = <String>{...grouped.keys, ...profilesByKey.keys}
      .where((key) => !state.hiddenSupplierKeys.contains(key))
      .toList(growable: false);

  final now = DateTime.now();
  final suppliers = allKeys.map((key) {
    final profile = profilesByKey[key];
    final ledger = List<DokanSupplierLedgerRecord>.from(
        grouped[key] ?? const <DokanSupplierLedgerRecord>[])
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final totalPurchase = ledger
        .where((record) => record.kind == DokanSupplierLedgerKind.purchase)
        .fold<int>(0, (sum, record) => sum + record.amount);
    final totalPaid = ledger
        .where((record) => record.kind == DokanSupplierLedgerKind.payment)
        .fold<int>(0, (sum, record) => sum + record.amount);
    final totalDue = totalPurchase - totalPaid;
    final currentMonthPurchase = ledger
        .where((record) =>
            record.kind == DokanSupplierLedgerKind.purchase &&
            record.createdAt.year == now.year &&
            record.createdAt.month == now.month)
        .fold<int>(0, (sum, record) => sum + record.amount);
    final lastTransactionAt = ledger.isNotEmpty
        ? ledger.first.createdAt
        : (profile?.updatedAt ?? profile?.createdAt ?? now);

    return _SupplierSummary(
      key: key,
      name: profile?.name ??
          (ledger.isNotEmpty ? ledger.first.supplierName : key),
      phone: profile?.phone ?? '',
      address: profile?.address ?? '',
      productType: profile?.productType ?? '',
      creditLimit: profile?.creditLimit ?? 0,
      totalPurchase: totalPurchase,
      totalPaid: totalPaid,
      totalDue: totalDue < 0 ? 0 : totalDue,
      currentMonthPurchase: currentMonthPurchase,
      lastTransactionAt: lastTransactionAt,
      ledger: List<DokanSupplierLedgerRecord>.unmodifiable(ledger),
    );
  }).toList(growable: false)
    ..sort((a, b) {
      final dueCompare = b.totalDue.compareTo(a.totalDue);
      if (dueCompare != 0) {
        return dueCompare;
      }
      return b.lastTransactionAt.compareTo(a.lastTransactionAt);
    });

  return suppliers;
}

String _paymentMethodLabel(DokanPosPaymentMethod method) {
  switch (method) {
    case DokanPosPaymentMethod.cash:
      return 'নগদ';
    case DokanPosPaymentMethod.due:
    case DokanPosPaymentMethod.bkash:
      return 'bKash';
    case DokanPosPaymentMethod.nagad:
      return 'Nagad';
    case DokanPosPaymentMethod.card:
      return 'Card';
    case DokanPosPaymentMethod.rocket:
      return 'Rocket';
    case DokanPosPaymentMethod.bank:
      return 'Bank';
  }
}

IconData _paymentMethodIcon(DokanPosPaymentMethod method) {
  switch (method) {
    case DokanPosPaymentMethod.cash:
      return Icons.payments_rounded;
    case DokanPosPaymentMethod.due:
    case DokanPosPaymentMethod.bkash:
      return Icons.account_balance_wallet_rounded;
    case DokanPosPaymentMethod.nagad:
      return Icons.phone_android_rounded;
    case DokanPosPaymentMethod.card:
      return Icons.credit_card_rounded;
    case DokanPosPaymentMethod.rocket:
      return Icons.flight_takeoff_rounded;
    case DokanPosPaymentMethod.bank:
      return Icons.account_balance_rounded;
  }
}

Color _paymentMethodAccent(DokanPosPaymentMethod method) {
  switch (method) {
    case DokanPosPaymentMethod.cash:
      return const Color(0xFF0C8C67);
    case DokanPosPaymentMethod.due:
    case DokanPosPaymentMethod.bkash:
      return const Color(0xFFE2136E);
    case DokanPosPaymentMethod.nagad:
      return const Color(0xFFFF8A00);
    case DokanPosPaymentMethod.card:
      return const Color(0xFF2564D7);
    case DokanPosPaymentMethod.rocket:
      return const Color(0xFF6A4CFF);
    case DokanPosPaymentMethod.bank:
      return const Color(0xFF607D8B);
  }
}

Widget _miniInfoChip({
  required IconData icon,
  required String text,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFFF7FAF9),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFD9E5E1)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0C8C67)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF163732),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget _actionChip({
  required String label,
  required VoidCallback onTap,
}) {
  return Material(
    color: const Color(0xFFF7FAF9),
    borderRadius: BorderRadius.circular(999),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD9E5E1)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF163732),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _SupplierLoadingScreen extends StatelessWidget {
  const _SupplierLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F8F6),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF0C8C67)),
              SizedBox(height: 14),
              Text(
                'সরবরাহকারীর তথ্য লোড হচ্ছে...',
                style: TextStyle(
                  color: Color(0xFF4E625F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupplierErrorScreen extends StatelessWidget {
  const _SupplierErrorScreen({this.message = 'সরবরাহকারীর তথ্য পাওয়া যায়নি'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECEC),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xFFD6453A),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'আবার চেষ্টা করুন বা তালিকা রিফ্রেশ করুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7B79),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
