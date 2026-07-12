part of '../sales_screens.dart';

class _FilterActionButton extends StatelessWidget {
  const _FilterActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? const Color(0xFF00694C) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: filled ? const Color(0xFF00694C) : const Color(0xFFD9E6E2),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : const Color(0xFF00694C),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryIconButton extends StatelessWidget {
  const _HistoryIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: const Color(0xFF3D4943), size: 28),
        ),
      ),
    );
  }
}

class _SalesFilter {
  const _SalesFilter({required this.label});

  final String label;
}

class _SalesGroup {
  const _SalesGroup({required this.title, required this.items});

  final String title;
  final List<_SalesItem> items;
}

enum _SalesStatus { paid, due, partial }

class _SalesItem {
  const _SalesItem({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.profit,
    required this.statusLabel,
    required this.status,
    required this.timeText,
    required this.referenceId,
    this.createdAt,
  });

  final String id;
  final String customerName;
  final int amount;
  final int profit;
  final String statusLabel;
  final _SalesStatus status;
  final String timeText;
  final String referenceId;
  final DateTime? createdAt;
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F6F4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Icon(icon, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE1F0EC) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD6E4E0)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.selected,
    required this.onAdd,
    required this.onRemove,
  });

  final _Product product;
  final int quantity;
  final bool selected;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selected ? onRemove : onAdd,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3FAF8) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF006B53) : const Color(0xFFD6E4E0),
            width: selected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF006B53).withOpacity(0.06)
                  : const Color(0xFF000000).withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProductPreview(),
                if (selected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F2F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'x$quantity',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _banglaText(product.name),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '৳${product.price}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  tr('স্টক আছে: ${trNum(product.stock - quantity)}',
                      'Stock: ${trNum(product.stock - quantity)}'),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      onPressed: onAdd,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF006B53)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        tr('যোগ', 'Add'),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: selected ? onRemove : null,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.remove, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPreview() {
    final imageUrl = product.imageUrl.trim();
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 36,
          height: 36,
          color: const Color(0xFFF4F8F7),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackPreview(),
          ),
        ),
      );
    }

    return _buildFallbackPreview();
  }

  Widget _buildFallbackPreview() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(product.icon, color: const Color(0xFF006B53)),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.valueColor,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = labelStyle ??
        const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        );
    final valueTextStyle = valueStyle ??
        TextStyle(
          color: valueColor ?? Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: valueTextStyle),
      ],
    );
  }
}
