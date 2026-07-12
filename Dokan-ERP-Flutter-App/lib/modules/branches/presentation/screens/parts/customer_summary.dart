part of '../business_screens.dart';

class _CustomerSummary {
  const _CustomerSummary({
    required this.id,
    required this.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.totalPurchase,
    required this.totalPaid,
    required this.totalDue,
    required this.openingDue,
    required this.orders,
    required this.transactionOrders,
    required this.firstTransactionAt,
    required this.lastTransactionAt,
    required this.createdAt,
  });

  final String id;
  final String key;
  final String name;
  final String phone;
  final String address;
  final int totalPurchase;
  final int totalPaid;
  final int totalDue;
  final int openingDue;
  final List<DokanPosOrderRecord> orders;
  final List<DokanPosOrderRecord> transactionOrders;
  final DateTime firstTransactionAt;
  final DateTime lastTransactionAt;
  final DateTime createdAt;
}

class _CustomerLoadingScreen extends StatelessWidget {
  const _CustomerLoadingScreen();

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
                'গ্রাহকের তথ্য লোড হচ্ছে...',
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

class _CustomerErrorScreen extends StatelessWidget {
  const _CustomerErrorScreen({this.message = 'গ্রাহকের তথ্য পাওয়া যায়নি'});

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
                    Icons.person_off_rounded,
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
                  'দয়া করে আবার চেষ্টা করুন অথবা গ্রাহক ডেটা চেক করুন।',
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return DokanSearchField(
      controller: controller,
      hintText: 'নাম বা নম্বর খুঁজুন',
      onChanged: onChanged,
      showClear: query.isNotEmpty,
      onClear: onClear,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.value,
    required this.subtitle,
    this.valueColor,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String value;
  final String subtitle;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E5E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF5C6C6A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF163732),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF7A8A88),
              fontSize: 11.5,
              height: 1.25,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

class _ReceivableHeroCard extends StatelessWidget {
  const _ReceivableHeroCard({
    required this.totalReceivable,
    required this.totalCustomers,
    required this.dueCustomers,
  });

  final int totalReceivable;
  final int totalCustomers;
  final int dueCustomers;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DokanDueManagementScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F8C67), Color(0xFF0A6A4F)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x220B5B40),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'মোট পাওনা',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(totalReceivable),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'গ্রাহক ${_banglaDigits(totalCustomers.toString())} জন • বাকি আছে ${_banglaDigits(dueCustomers.toString())} জন',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.86),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerListTile extends StatelessWidget {
  const _CustomerListTile({
    required this.customer,
    required this.onTap,
    required this.onLongPress,
  });

  final _CustomerSummary customer;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final dueColor = customer.totalDue > 0
        ? const Color(0xFFB3261E)
        : const Color(0xFF0C8C67);
    final avatarColor = customer.totalDue > 0
        ? const Color(0xFFFDECEC)
        : const Color(0xFFE7F5EF);
    final avatarTint = customer.totalDue > 0
        ? const Color(0xFFD6453A)
        : const Color(0xFF0C8C67);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD9E5E1)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  _customerInitials(customer.name),
                  style: TextStyle(
                    color: avatarTint,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: const TextStyle(
                              color: Color(0xFF163732),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (customer.totalDue > 0)
                          _Pill(
                              label: 'বাকি আছে',
                              background: const Color(0xFFFDECEC),
                              textColor: dueColor),
                        if (customer.totalDue <= 0)
                          const _Pill(
                            label: 'পরিশোধিত',
                            background: Color(0xFFE7F5EF),
                            textColor: Color(0xFF0C8C67),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone.isEmpty
                          ? 'ফোন নম্বর সংরক্ষিত নেই'
                          : customer.phone,
                      style: const TextStyle(
                        color: Color(0xFF6B7B79),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'শেষ লেনদেন: ${_relativeTime(customer.lastTransactionAt)}',
                      style: const TextStyle(
                        color: Color(0xFF81918F),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetricPill(
                          label: 'মোট ক্রয়',
                          value: _formatCurrency(customer.totalPurchase),
                        ),
                        _MetricPill(
                          label: 'বাকি',
                          value: _formatCurrency(customer.totalDue),
                          valueColor: dueColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8C9A97),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
