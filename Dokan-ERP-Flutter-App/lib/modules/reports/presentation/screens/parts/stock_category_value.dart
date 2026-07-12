part of '../reports_screens.dart';

class _StockCategoryValue {
  const _StockCategoryValue({
    required this.name,
    required this.percent,
    required this.totalValue,
    required this.color,
  });

  final String name;
  final int percent;
  final int totalValue;
  final Color color;
}

class _StockValueProduct {
  const _StockValueProduct({
    required this.rank,
    required this.name,
    required this.value,
    required this.quantity,
    required this.category,
    required this.icon,
    required this.color,
  });

  final int rank;
  final String name;
  final int value;
  final int quantity;
  final String category;
  final IconData icon;
  final Color color;
}

class _DeadStockEntry {
  const _DeadStockEntry({
    required this.name,
    required this.daysSinceSale,
  });

  final String name;
  final int daysSinceSale;
}

class _StockHeroMiniMetric extends StatelessWidget {
  const _StockHeroMiniMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockCategoryBarItem extends StatelessWidget {
  const _StockCategoryBarItem({required this.item});

  final _StockCategoryValue item;

  @override
  Widget build(BuildContext context) {
    final progress = (item.percent / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              '${_bnDigits(item.percent.toString())}%',
              style: TextStyle(
                color: item.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE7EEEC),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text(
              'মোট মূল্য',
              style: TextStyle(
                color: Color(0xFF5F6A66),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              _currency(item.totalValue),
              style: const TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StockValueProductTile extends StatelessWidget {
  const _StockValueProductTile({required this.product});

  final _StockValueProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: product.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(product.icon, color: product.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: const TextStyle(
                    color: Color(0xFF5F6A66),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
                _currency(product.value),
                style: const TextStyle(
                  color: Color(0xFF0C8C67),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_bnDigits(product.quantity.toString())}টি',
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

class _DeadStockTile extends StatelessWidget {
  const _DeadStockTile({required this.entry});

  final _DeadStockEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0CEC9)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFD43B3B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'সর্বশেষ বিক্রি ${_bnDigits(entry.daysSinceSale.toString())} দিন আগে',
                  style: const TextStyle(
                    color: Color(0xFF5F6A66),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE0DC),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'সতর্কতা',
              style: TextStyle(
                color: Color(0xFFD43B3B),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundDateNavButton extends StatelessWidget {
  const _RoundDateNavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD9E6E2)),
          ),
          child: Icon(icon, color: const Color(0xFF0C8C67)),
        ),
      ),
    );
  }
}
