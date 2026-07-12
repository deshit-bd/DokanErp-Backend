part of '../sales_screens.dart';

class _DueCustomerCard extends StatelessWidget {
  const _DueCustomerCard({
    required this.customer,
    required this.selected,
    required this.onTap,
  });

  final _DueCustomerSummary customer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? const Color(0xFF0C8C67) : const Color(0xFFD6E4E0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: selected ? 1.6 : 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F0EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    const Icon(Icons.person_outline, color: Color(0xFF0C8C67)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.customerNumber.isEmpty
                          ? 'নম্বর নেই'
                          : customer.customerNumber,
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.lastPaymentAt == null
                          ? 'সর্বশেষ পেমেন্ট নেই'
                          : 'শেষ পেমেন্ট ${_dueDateLabel(customer.lastPaymentAt!)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const _DueStatusBadge(label: 'Active Due', active: true),
                  const SizedBox(height: 10),
                  Text(
                    _formatCurrency(customer.totalDue),
                    style: const TextStyle(
                      color: Color(0xFFB3261E),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueStatusBadge extends StatelessWidget {
  const _DueStatusBadge({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFE8E8) : const Color(0xFFF4F6F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFFC62828) : const Color(0xFF5F6A66),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DueEmptyState extends StatelessWidget {
  const _DueEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: const [
          Icon(Icons.check_circle_rounded, size: 72, color: Color(0xFF0C8C67)),
          SizedBox(height: 14),
          Text(
            'কোনো বাকি গ্রাহক নেই',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            'সব গ্রাহকের হিসাব আপডেট আছে',
            style:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DueHistoryTile extends StatelessWidget {
  const _DueHistoryTile({required this.record});

  final DokanPosOrderRecord record;

  @override
  Widget build(BuildContext context) {
    final accent = record.status == DokanPosOrderStatus.paid
        ? const Color(0xFF0C8C67)
        : record.status == DokanPosOrderStatus.partiallyPaid
            ? const Color(0xFFF49B1A)
            : const Color(0xFFB3261E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                record.status == DokanPosOrderStatus.paid
                    ? Icons.check_rounded
                    : record.status == DokanPosOrderStatus.partiallyPaid
                        ? Icons.timelapse_outlined
                        : Icons.error_outline,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.summary,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dueDateLabel(record.createdAt),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(record.dueAmount),
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  record.status == DokanPosOrderStatus.paid
                      ? 'পরিশোধিত'
                      : record.status == DokanPosOrderStatus.partiallyPaid
                          ? 'আংশিক'
                          : 'বাকি',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  const _Category(
      {required this.label, required this.englishLabel, required this.key});

  final String label;
  final String englishLabel;
  final String key;
}

class _Product {
  const _Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.categoryKey,
    required this.icon,
    required this.searchTerms,
  });

  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final int stock;
  final String categoryKey;
  final IconData icon;
  final List<String> searchTerms;
}
