part of '../reports_screens.dart';

class _StockReportRequestKey {
  const _StockReportRequestKey({
    required this.selectedDate,
    required this.selectedRange,
  });

  final DateTime selectedDate;
  final int selectedRange;

  @override
  bool operator ==(Object other) {
    return other is _StockReportRequestKey &&
        other.selectedRange == selectedRange &&
        DateUtils.isSameDay(other.selectedDate, selectedDate);
  }

  @override
  int get hashCode => Object.hash(
      selectedRange, selectedDate.year, selectedDate.month, selectedDate.day);
}

class _StockMovementEntry {
  const _StockMovementEntry({
    required this.name,
    required this.category,
    required this.quantity,
    required this.type,
    required this.dateLabel,
  });

  final String name;
  final String category;
  final int quantity;
  final String type;
  final String dateLabel;
}

class _StockAlertEntry {
  const _StockAlertEntry({
    required this.name,
    required this.category,
    required this.quantity,
    required this.status,
  });

  final String name;
  final String category;
  final int quantity;
  final String status;
}

class _RemoteStockReportData {
  const _RemoteStockReportData({
    required this.openingStock,
    required this.stockIn,
    required this.stockOut,
    required this.availableProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.movements,
    required this.alerts,
  });

  final int openingStock;
  final int stockIn;
  final int stockOut;
  final int availableProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final List<_StockMovementEntry> movements;
  final List<_StockAlertEntry> alerts;
}

Map<String, dynamic> _stockReportFiltersFor(_StockReportRequestKey key) {
  DateTime from;
  DateTime to;
  final selectedDay = DateTime(
    key.selectedDate.year,
    key.selectedDate.month,
    key.selectedDate.day,
  );
  switch (key.selectedRange) {
    case 0:
      from = _startOfWeek(key.selectedDate);
      to = from
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      break;
    case 1:
      from = DateTime(key.selectedDate.year, key.selectedDate.month, 1);
      to = DateTime(
        key.selectedDate.year,
        key.selectedDate.month + 1,
        0,
        23,
        59,
        59,
        999,
      );
      break;
    case 2:
      from = DateTime(key.selectedDate.year, 1, 1);
      to = DateTime(key.selectedDate.year, 12, 31, 23, 59, 59, 999);
      break;
    default:
      from = selectedDay;
      to = DateTime(
        key.selectedDate.year,
        key.selectedDate.month,
        key.selectedDate.day,
        23,
        59,
        59,
        999,
      );
      break;
  }

  String formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  return {
    'from': formatDate(from),
    'to': formatDate(to),
  };
}

String _stockMovementDateLabel(Object? value) {
  final date = _dateValue(value);
  return _expenseDateLabel(date);
}

String _stockMovementTypeLabel(String type) {
  final normalized = type.trim().toLowerCase();
  if (normalized.contains('in') || normalized.contains('purchase')) {
    return 'স্টক ইন';
  }
  if (normalized.contains('out') || normalized.contains('sale')) {
    return 'স্টক আউট';
  }
  if (normalized.contains('adjust')) {
    return 'অ্যাডজাস্ট';
  }
  return type.trim().isEmpty ? 'মুভমেন্ট' : type;
}

Color _stockMovementTypeColor(String type) {
  final normalized = type.trim().toLowerCase();
  if (normalized.contains('in') || normalized.contains('purchase')) {
    return const Color(0xFF0C8C67);
  }
  if (normalized.contains('out') || normalized.contains('sale')) {
    return const Color(0xFFD43B3B);
  }
  return const Color(0xFF2F6BFF);
}

final stockReportRemoteProvider = FutureProvider.autoDispose
    .family<_RemoteStockReportData?, _StockReportRequestKey>(
  (ref, key) async {
    if (!ref.watch(reportConfiguredProvider)) {
      return null;
    }

    final payload = await ref.watch(reportRepositoryProvider).fetchReport(
          'stock',
          filters: _stockReportFiltersFor(key),
        );
    if (payload.isEmpty) {
      return null;
    }

    final summaryMap = _mapValue(
          _pickFirstValue(
              payload, const ['summary', 'overview', 'totals', 'kpi']),
        ) ??
        payload;
    final openingStock = _intValue(
      _pickFirstValue(
          summaryMap, const ['openingStock', 'opening', 'openingQty']),
    );
    final stockIn = _intValue(
      _pickFirstValue(
        summaryMap,
        const ['stockIn', 'inward', 'totalIn', 'receivedQty', 'purchaseQty'],
      ),
    );
    final stockOut = _intValue(
      _pickFirstValue(
        summaryMap,
        const ['stockOut', 'outward', 'totalOut', 'issuedQty', 'soldQty'],
      ),
    );
    final availableProducts = _intValue(
      _pickFirstValue(
        summaryMap,
        const [
          'availableProducts',
          'availableCount',
          'productCount',
          'totalProducts'
        ],
      ),
    );
    final lowStockCount = _intValue(
      _pickFirstValue(
        summaryMap,
        const ['lowStockCount', 'lowStock', 'lowStockProducts'],
      ),
    );
    final outOfStockCount = _intValue(
      _pickFirstValue(
        summaryMap,
        const ['outOfStockCount', 'outOfStock', 'zeroStockCount'],
      ),
    );

    final movementItems = _mapListValue(
      _pickFirstValue(
        payload,
        const [
          'movements',
          'movementHistory',
          'transactions',
          'recentMovements'
        ],
      ),
    );
    final movements = movementItems
        .map(
          (item) => _StockMovementEntry(
            name: _stringValue(
              _pickFirstValue(item, const ['name', 'productName', 'title']),
              fallback: 'Unnamed product',
            ),
            category: _stringValue(
              _pickFirstValue(item, const ['category', 'categoryName']),
              fallback: 'স্টক',
            ),
            quantity: _intValue(
              _pickFirstValue(
                  item, const ['quantity', 'qty', 'amount', 'units']),
            ),
            type: _stockMovementTypeLabel(
              _stringValue(
                _pickFirstValue(item, const ['type', 'movementType', 'kind']),
                fallback: 'মুভমেন্ট',
              ),
            ),
            dateLabel: _stockMovementDateLabel(
              _pickFirstValue(item, const ['date', 'createdAt', 'timestamp']),
            ),
          ),
        )
        .toList(growable: false);

    final alertItems = _mapListValue(
      _pickFirstValue(
        payload,
        const ['alerts', 'availability', 'lowStockItems', 'products'],
      ),
    );
    final alerts = alertItems
        .map(
          (item) => _StockAlertEntry(
            name: _stringValue(
              _pickFirstValue(item, const ['name', 'productName', 'title']),
              fallback: 'Unnamed product',
            ),
            category: _stringValue(
              _pickFirstValue(item, const ['category', 'categoryName']),
              fallback: 'স্টক',
            ),
            quantity: _intValue(
              _pickFirstValue(
                  item, const ['quantity', 'qty', 'stock', 'availableQty']),
            ),
            status: _stringValue(
              _pickFirstValue(
                  item, const ['status', 'availability', 'stockStatus']),
              fallback: 'Low stock',
            ),
          ),
        )
        .where((item) => item.name.trim().isNotEmpty)
        .toList(growable: false);

    return _RemoteStockReportData(
      openingStock: openingStock,
      stockIn: stockIn,
      stockOut: stockOut,
      availableProducts: availableProducts,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      movements: movements,
      alerts: alerts,
    );
  },
);

class _StockMovementTile extends StatelessWidget {
  const _StockMovementTile({required this.entry});

  final _StockMovementEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = _stockMovementTypeColor(entry.type);
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.sync_alt_rounded, color: color),
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
                  '${entry.category} • ${entry.dateLabel}',
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
                entry.type,
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '${_bnDigits(entry.quantity.toString())} ইউনিট',
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

class _StockAlertTile extends StatelessWidget {
  const _StockAlertTile({required this.entry});

  final _StockAlertEntry entry;

  @override
  Widget build(BuildContext context) {
    final isOut =
        entry.status.toLowerCase().contains('out') || entry.quantity <= 0;
    final accent = isOut ? const Color(0xFFD43B3B) : const Color(0xFFF49B1A);
    final background =
        isOut ? const Color(0xFFFFF5F4) : const Color(0xFFFFFAF1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOut ? const Color(0xFFF0CEC9) : const Color(0xFFF5DFC0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.warning_amber_rounded, color: accent),
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
                  entry.category,
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
                isOut ? 'স্টক নেই' : 'কম স্টক',
                style: TextStyle(color: accent, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                '${_bnDigits(entry.quantity.toString())} বাকি',
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

class _DokanStockReportPage extends ConsumerStatefulWidget {
  const _DokanStockReportPage();

  @override
  ConsumerState<_DokanStockReportPage> createState() =>
      _DokanStockReportPageState();
}

class _DokanStockReportPageState extends ConsumerState<_DokanStockReportPage> {
  DateTime _selectedDate = DateTime.now();
  int _selectedRange = 1;

  String get _dateLabel =>
      '${_bnDigits(_selectedDate.day.toString())} ${_monthName(_selectedDate.month)} ${_bnDigits(_selectedDate.year.toString())}';

  void _shiftDate(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
    });
  }

  @override
  Widget build(BuildContext context) {
    const localMovements = <_StockMovementEntry>[
      _StockMovementEntry(
        name: 'মিনিকেট চাল ৫ কেজি',
        category: 'চাল-ডাল',
        quantity: 48,
        type: 'স্টক ইন',
        dateLabel: '২৯ জুন ২০২৬',
      ),
      _StockMovementEntry(
        name: 'সয়াবিন তেল ১ লিটার',
        category: 'তেল-মসলা',
        quantity: 18,
        type: 'স্টক আউট',
        dateLabel: '২৮ জুন ২০২৬',
      ),
      _StockMovementEntry(
        name: 'লাক্স সাবান ১০০ গ্রাম',
        category: 'সাবান',
        quantity: 12,
        type: 'অ্যাডজাস্ট',
        dateLabel: '২৮ জুন ২০২৬',
      ),
    ];
    const localAlerts = <_StockAlertEntry>[
      _StockAlertEntry(
        name: 'চিনি ১ কেজি',
        category: 'চাল-ডাল',
        quantity: 4,
        status: 'Low stock',
      ),
      _StockAlertEntry(
        name: 'কোকা কোলা ২৫০মি',
        category: 'পানীয়',
        quantity: 0,
        status: 'Out of stock',
      ),
      _StockAlertEntry(
        name: 'ডিটারজেন্ট প্যাক',
        category: 'সাবান',
        quantity: 2,
        status: 'Low stock',
      ),
    ];

    final remoteStockAsync = ref.watch(
      stockReportRemoteProvider(
        _StockReportRequestKey(
          selectedDate: _selectedDate,
          selectedRange: _selectedRange,
        ),
      ),
    );
    final remote = remoteStockAsync.asData?.value;
    final openingStock = remote?.openingStock ?? 420;
    final stockIn = remote?.stockIn ?? 86;
    final stockOut = remote?.stockOut ?? 64;
    final availableProducts = remote?.availableProducts ?? 185;
    final lowStockCount = remote?.lowStockCount ?? 14;
    final outOfStockCount = remote?.outOfStockCount ?? 6;
    final movements = remote?.movements.isNotEmpty == true
        ? remote!.movements
        : localMovements;
    final alerts =
        remote?.alerts.isNotEmpty == true ? remote!.alerts : localAlerts;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF111111),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        centerTitle: true,
        title: const Text(
          'স্টক রিপোর্ট',
          style: TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          if (remoteStockAsync.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _RemoteReportLoadingBanner(
                  message: 'Stock report API theke data load hocche...',
                ),
              ),
            ),
          if (remoteStockAsync.hasError)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _RemoteReportErrorBanner(
                  message:
                      'Stock report API response pawa jayni, tai local fallback dekhano hocche.',
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  _RoundDateNavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _shiftDate(-1),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFD9E6E2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 18,
                            color: Color(0xFF0C8C67),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _dateLabel,
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RoundDateNavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _shiftDate(1),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ReportChip(
                      label: 'এই সপ্তাহ',
                      selected: _selectedRange == 0,
                      onTap: () => setState(() => _selectedRange = 0),
                    ),
                    const SizedBox(width: 10),
                    _ReportChip(
                      label: 'এই মাস',
                      selected: _selectedRange == 1,
                      onTap: () => setState(() => _selectedRange = 1),
                    ),
                    const SizedBox(width: 10),
                    _ReportChip(
                      label: 'এই বছর',
                      selected: _selectedRange == 2,
                      onTap: () => setState(() => _selectedRange = 2),
                    ),
                    const SizedBox(width: 10),
                    _ReportChip(
                      label: 'কাস্টম',
                      selected: _selectedRange == 3,
                      onTap: () => setState(() => _selectedRange = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0C8C67), Color(0xFF0A6A4F)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'স্টক মুভমেন্ট সারাংশ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _DailyHeroMetric(
                                label: 'ওপেনিং',
                                value: _bnDigits(openingStock.toString()),
                              ),
                            ),
                            Expanded(
                              child: _DailyHeroMetric(
                                label: 'স্টক ইন',
                                value: _bnDigits(stockIn.toString()),
                              ),
                            ),
                            Expanded(
                              child: _DailyHeroMetric(
                                label: 'স্টক আউট',
                                value: _bnDigits(stockOut.toString()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _CompactSummaryCard(
                          title: 'এভেইলেবল',
                          value: _bnDigits(availableProducts.toString()),
                          subtitle: 'চলমান পণ্য',
                          background: const Color(0xFFE6F4EE),
                          foreground: const Color(0xFF0C8C67),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CompactSummaryCard(
                          title: 'কম স্টক',
                          value: _bnDigits(lowStockCount.toString()),
                          subtitle: 'সতর্কতা দরকার',
                          background: const Color(0xFFFFF4E4),
                          foreground: const Color(0xFFF49B1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _CompactSummaryCard(
                    title: 'স্টক নেই',
                    value: _bnDigits(outOfStockCount.toString()),
                    subtitle: 'তাৎক্ষণিক রিস্টক দরকার',
                    background: const Color(0xFFFFECEA),
                    foreground: const Color(0xFFD43B3B),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Recent Stock Movements',
                    child: movements.isEmpty
                        ? const _ExpenseEmptyState(
                            title: 'Stock movement data পাওয়া যায়নি',
                            subtitle:
                                'API থেকে movement history এলে এখানে দেখা যাবে।',
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < movements.length; i++) ...[
                                _StockMovementTile(entry: movements[i]),
                                if (i != movements.length - 1)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Availability Alerts',
                    child: alerts.isEmpty
                        ? const _ExpenseEmptyState(
                            title: 'Availability alert পাওয়া যায়নি',
                            subtitle:
                                'Low stock বা out of stock item API response এলে এখানে দেখা যাবে।',
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < alerts.length; i++) ...[
                                _StockAlertTile(entry: alerts[i]),
                                if (i != alerts.length - 1)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ReportsBottomNav(selectedIndex: 3),
    );
  }
}
