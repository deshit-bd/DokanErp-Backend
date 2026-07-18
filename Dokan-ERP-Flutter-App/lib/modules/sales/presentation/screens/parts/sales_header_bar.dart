part of '../sales_screens.dart';

class _SalesHeaderBar extends StatelessWidget {
  const _SalesHeaderBar({
    required this.onBack,
    required this.onSearch,
    required this.onFilter,
    required this.onCalendar,
  });

  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HistoryIconButton(
          icon: Icons.menu_rounded,
          onTap: onBack,
        ),
        const Expanded(
          child: Center(
            child: Text(
              'বিক্রয় ইতিহাস',
              style: TextStyle(
                color: Color(0xFF006B53),
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        _HistoryIconButton(
          icon: Icons.home_rounded,
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.dashboard,
              (route) => false,
            );
          },
        ),
        const SizedBox(width: 6),
        _HistoryIconButton(
          icon: Icons.search_rounded,
          onTap: onSearch,
        ),
        const SizedBox(width: 6),
        _HistoryIconButton(
          icon: Icons.tune_rounded,
          onTap: onFilter,
        ),
        const SizedBox(width: 6),
        _HistoryIconButton(
          icon: Icons.calendar_today_rounded,
          onTap: onCalendar,
        ),
      ],
    );
  }
}

class _SalesSummaryStrip extends StatelessWidget {
  const _SalesSummaryStrip({
    required this.totalSalesAmount,
    required this.totalOrderCount,
    required this.totalDueAmount,
  });

  final String totalSalesAmount;
  final String totalOrderCount;
  final String totalDueAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D9E75), Color(0xFF00694C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5B42).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              title: 'মোট বিক্রয়',
              value: totalSalesAmount,
            ),
          ),
          Container(
              width: 1,
              height: 48,
              color: Colors.white.withValues(alpha: 0.18)),
          Expanded(
            child: _SummaryMetric(
              title: 'মোট অর্ডার',
              value: totalOrderCount,
              alignEnd: true,
            ),
          ),
          Container(
              width: 1,
              height: 48,
              color: Colors.white.withValues(alpha: 0.18)),
          Expanded(
            child: _SummaryMetric(
              title: 'মোট বাকি',
              value: totalDueAmount,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.title,
    required this.value,
    this.alignEnd = false,
  });

  final String title;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
              fontWeight: FontWeight.w800,
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

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
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
      color: selected ? const Color(0xFF00694C) : const Color(0xFFE6EDF0),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minWidth: 74),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  selected ? const Color(0xFF00694C) : const Color(0xFFE6EDF0),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF3D4943),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SalesGroupSection extends StatelessWidget {
  const _SalesGroupSection({required this.group});

  final _SalesGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${group.title} — ${_banglaDigits(group.items.length.toString())}টি বিক্রয়',
              style: const TextStyle(
                color: Color(0xFF3D4943),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: group.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cardDelay = Duration(milliseconds: math.min(250, index * 30));
            return DokanFadeSlideIn(
              delay: cardDelay,
              duration: const Duration(milliseconds: 350),
              slideOffset: const Offset(0, 10),
              child: _SalesCard(item: group.items[index]),
            );
          },
        ),
      ],
    );
  }
}

class _SalesCard extends ConsumerWidget {
  const _SalesCard({required this.item});

  final _SalesItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = switch (item.status) {
      _SalesStatus.paid => const Color(0xFFD8F3DF),
      _SalesStatus.due => const Color(0xFFF8D9DB),
      _SalesStatus.partial => const Color(0xFFF7D9EA),
    };
    final iconColor = switch (item.status) {
      _SalesStatus.paid => const Color(0xFF0C8C67),
      _SalesStatus.due => const Color(0xFFD43B3B),
      _SalesStatus.partial => const Color(0xFFC2185B),
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          final orders = ref.read(salesHistoryOrdersProvider).value ?? const [];
          var order = orders.firstWhereOrNull((o) => o.id == item.id);
          if (order == null) {
            final posOrders = ref.read(dokanPosProvider).orders;
            order = posOrders.firstWhereOrNull((o) => o.id == item.id);
          }
          final orderToPush = order;
          if (orderToPush != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _DokanSaleDetailScreen(order: orderToPush),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD9E6E2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.status == _SalesStatus.partial
                      ? Icons.receipt_long_outlined
                      : item.status == _SalesStatus.due
                          ? Icons.book_outlined
                          : Icons.payments_outlined,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.timeText,
                      style: const TextStyle(
                        color: Color(0xFF3D4943),
                        fontSize: 13,
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
                    '৳${_banglaDigits(item.amount.toString())}',
                    style: const TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.status == _SalesStatus.due
                        ? 'বাকি'
                        : item.status == _SalesStatus.partial
                            ? 'আংশিক'
                            : 'লাভ ${_formatCurrency(item.profit)}',
                    style: TextStyle(
                      color: item.status == _SalesStatus.due
                          ? const Color(0xFFD43B3B)
                          : item.status == _SalesStatus.partial
                              ? const Color(0xFFE15298)
                              : const Color(0xFF0F7B57),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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
