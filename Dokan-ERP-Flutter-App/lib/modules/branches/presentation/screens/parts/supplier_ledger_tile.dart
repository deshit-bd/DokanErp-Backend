part of '../business_screens.dart';

class _SupplierLedgerTile extends StatelessWidget {
  const _SupplierLedgerTile({required this.record});

  final DokanSupplierLedgerRecord record;

  @override
  Widget build(BuildContext context) {
    final isPurchase = record.kind == DokanSupplierLedgerKind.purchase;
    final isSetup = record.kind == DokanSupplierLedgerKind.setup;
    final accent = isPurchase
        ? const Color(0xFF0C8C67)
        : isSetup
            ? const Color(0xFF7A5C14)
            : const Color(0xFF2564D7);
    final background = isPurchase
        ? const Color(0xFFE7F5EF)
        : isSetup
            ? const Color(0xFFFFF6DD)
            : const Color(0xFFEAF2FF);
    final title = isPurchase
        ? 'ক্রয়'
        : isSetup
            ? 'সেটআপ'
            : 'পেমেন্ট';
    final amountPrefix = isPurchase
        ? '+'
        : isSetup
            ? ''
            : '-';
    final trailingLabel = isSetup
        ? 'প্রারম্ভিক'
        : _paymentMethodLabel(
            record.paymentMethod ?? DokanPosPaymentMethod.cash,
          );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9E5E1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPurchase
                  ? Icons.shopping_bag_rounded
                  : isSetup
                      ? Icons.inventory_2_rounded
                      : Icons.payments_rounded,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.note,
                  style: const TextStyle(
                    color: Color(0xFF6B7B79),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(record.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF7C8C8A),
                    fontSize: 11.5,
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
                '$amountPrefix${_formatCurrency(record.amount)}',
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trailingLabel,
                style: const TextStyle(
                  color: Color(0xFF7C8C8A),
                  fontSize: 11.5,
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

class _SupplierLedgerHistoryList extends StatelessWidget {
  const _SupplierLedgerHistoryList({
    required this.emptyLabel,
    required this.records,
  });

  final String emptyLabel;
  final List<DokanSupplierLedgerRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _SupplierSectionEmptyState(label: emptyLabel);
    }

    return Column(
      children: [
        for (final record in records) ...[
          _SupplierLedgerTile(record: record),
          if (record != records.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SupplierPaymentMethodCard extends StatelessWidget {
  const _SupplierPaymentMethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final DokanPosPaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _paymentMethodAccent(method);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: selected ? 2 : 0,
      shadowColor: selected ? accent.withOpacity(0.15) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? accent : const Color(0xFFD9E5E1),
                width: selected ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withOpacity(0.12)
                      : const Color(0xFFF7FAF9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    Icon(_paymentMethodIcon(method), color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _paymentMethodLabel(method),
                  style: const TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? accent : Colors.transparent,
                  border: Border.all(
                      color: selected ? accent : const Color(0xFFC9D7D3)),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
