part of '../business_screens.dart';

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.record});

  final DokanPosOrderRecord record;

  @override
  Widget build(BuildContext context) {
    final statusColor = record.status == DokanPosOrderStatus.paid
        ? const Color(0xFF0C8C67)
        : record.status == DokanPosOrderStatus.partiallyPaid
            ? const Color(0xFFD87A10)
            : const Color(0xFFB3261E);
    final statusLabel = record.status == DokanPosOrderStatus.paid
        ? 'পরিশোধিত'
        : record.status == DokanPosOrderStatus.partiallyPaid
            ? 'আংশিক পরিশোধিত'
            : record.status == DokanPosOrderStatus.due
                ? 'বাকি'
                : 'বাতিল';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              record.status == DokanPosOrderStatus.paid
                  ? Icons.check_circle_rounded
                  : record.status == DokanPosOrderStatus.partiallyPaid
                      ? Icons.timelapse_rounded
                      : record.status == DokanPosOrderStatus.due
                          ? Icons.error_outline_rounded
                          : Icons.cancel_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.summary,
                  style: const TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatDate(record.createdAt)} • ${dokanPosPaymentMethodLabel(record.paymentMethod)}',
                  style: const TextStyle(
                    color: Color(0xFF6B7B79),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(record.totalAmount),
                style: const TextStyle(
                  color: Color(0xFF163732),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              _Pill(
                label: statusLabel,
                background: statusColor.withOpacity(0.12),
                textColor: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.record});

  final DokanPosOrderRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F5EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_rounded,
                color: Color(0xFF0C8C67), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.customerName,
                  style: const TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatDate(record.createdAt)} • ${dokanPosPaymentMethodLabel(record.paymentMethod)}',
                  style: const TextStyle(
                    color: Color(0xFF6B7B79),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(record.paidAmount),
                style: const TextStyle(
                  color: Color(0xFF0C8C67),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                record.dueAmount > 0
                    ? 'বাকি ${_formatCurrency(record.dueAmount)}'
                    : 'সম্পূর্ণ',
                style: const TextStyle(
                  color: Color(0xFF7A8A88),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.record});

  final DokanPosOrderRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2ECE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Color(0xFF1B62D3), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.summary,
                  style: const TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${record.customerName}${record.customerNumber.isEmpty ? '' : ' • ${record.customerNumber}'}',
                  style: const TextStyle(
                    color: Color(0xFF6B7B79),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatShortTime(record.createdAt),
            style: const TextStyle(
              color: Color(0xFF7A8A88),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: const Color(0xFF163732),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.textColor,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7B79),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedNumberString(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF163732),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
