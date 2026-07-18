part of '../product_screens.dart';

class DokanLowStockAlertListScreen extends StatelessWidget {
  const DokanLowStockAlertListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DokanLowStockAlertScreen();
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3D4943),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedNumberString(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertFilterChip extends StatelessWidget {
  const _AlertFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0C8C67) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: selected
                    ? const Color(0xFF0C8C67)
                    : const Color(0xFFD9E6E2)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF111111),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _LowStockProductCard extends StatelessWidget {
  const _LowStockProductCard({
    required this.product,
    required this.statusColor,
    required this.progress,
    required this.threshold,
    required this.onAddStock,
    this.extraAction,
  });

  final DokanCatalogProduct product;
  final Color statusColor;
  final double progress;
  final int threshold;
  final VoidCallback? onAddStock;
  final Widget? extraAction;

  @override
  Widget build(BuildContext context) {
    final limit = threshold > 0 ? threshold : 5;
    final remainingText = product.stock <= 0
        ? 'স্টক নেই'
        : '${_bnDigits(product.stock.toString())}টি বাকি';
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E6E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    product.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: const TextStyle(
                        color: Color(0xFF3D4943),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedNumberString(
                '${_bnDigits(product.stock.toString())}টি',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$remainingText / সীমা ${_bnDigits(limit.toString())}টি',
                  style: const TextStyle(
                    color: Color(0xFF3D4943),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AnimatedNumberString(
                '$percentage%',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: statusColor,
              backgroundColor: const Color(0xFFDCE7E3),
            ),
          ),
          if (product.stock <= limit) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (extraAction != null) extraAction!,
                if (extraAction != null) const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onAddStock,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0C8C67),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_rounded),
                  label: const Text(
                    'স্টক যোগ করুন',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StockLogCard extends StatelessWidget {
  const _StockLogCard({
    required this.entry,
    required this.dateText,
    required this.timeText,
    required this.deltaText,
  });

  final DokanStockLedgerEntry entry;
  final String dateText;
  final String timeText;
  final String deltaText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E6E2)),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: entry.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(entry.icon, color: entry.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: entry.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        entry.typeLabel,
                        style: TextStyle(
                          color: entry.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      entry.productName,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${entry.category} • $dateText • $timeText',
                  style: const TextStyle(
                    color: Color(0xFF3D4943),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  entry.note,
                  style: const TextStyle(
                    color: Color(0xFF5F6A66),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                deltaText,
                style: TextStyle(
                  color: entry.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'স্টক: ${_bnDigits(entry.stockSnapshot.toString())}টি',
                style: const TextStyle(
                  color: Color(0xFF3D4943),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
