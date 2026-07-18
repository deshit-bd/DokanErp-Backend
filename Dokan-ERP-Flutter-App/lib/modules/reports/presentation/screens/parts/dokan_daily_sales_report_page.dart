part of '../reports_screens.dart';

class _RemoteDailySalesReportData {
  const _RemoteDailySalesReportData({
    required this.totalSales,
    required this.totalProfit,
    required this.salesCount,
    required this.avgSale,
    required this.hourlyTrend,
    required this.topProducts,
    required this.paymentSlices,
  });

  final int totalSales;
  final int totalProfit;
  final int salesCount;
  final int avgSale;
  final List<_TrendPoint> hourlyTrend;
  final List<_TopProductStat> topProducts;
  final List<_PaymentSlice> paymentSlices;
}

class DailySalesReportLocalCache {
  static const _keyPrefix = 'dokan_daily_sales_report_cache_v2_';

  static String _storageKey(DateTime date) {
    return '$_keyPrefix${date.year}_${date.month}_${date.day}';
  }

  static Future<Map<String, dynamic>?> load(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey(date));
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> save(DateTime date, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey(date), jsonEncode(data));
    } catch (_) {}
  }
}

class DailySalesReportRemoteNotifier extends AutoDisposeFamilyAsyncNotifier<_RemoteDailySalesReportData?, DateTime> {
  @override
  Future<_RemoteDailySalesReportData?> build(DateTime arg) async {
    // 1. Try to load from cache
    final cached = await DailySalesReportLocalCache.load(arg);
    if (cached != null) {
      // Trigger background network fetch
      _fetchAndSave(arg);
      return _parse(cached);
    }

    // 2. If no cache, perform remote fetch
    return _fetchAndSave(arg);
  }

  Future<_RemoteDailySalesReportData?> _fetchAndSave(DateTime arg) async {
    try {
      if (!ref.read(reportConfiguredProvider)) return null;
      final from = DateTime(
        arg.year,
        arg.month,
        arg.day,
      );
      final to = DateTime(
        arg.year,
        arg.month,
        arg.day,
        23,
        59,
        59,
        999,
      );
      final payload = await ref.read(reportRepositoryProvider).fetchReport(
            'sales-daily',
            filters: {
              'from': from.toIso8601String(),
              'to': to.toIso8601String(),
            },
          );
      if (payload.isNotEmpty) {
        await DailySalesReportLocalCache.save(arg, payload);
        final parsed = _parse(payload);
        state = AsyncData(parsed);
        return parsed;
      }
    } catch (_) {}
    return null;
  }

  _RemoteDailySalesReportData? _parse(Map<String, dynamic> payload) {
    final summary = _mapValue(
          _pickFirstValue(payload, const ['summary', 'kpi', 'totals']),
        ) ??
        payload;
    final totalSales = _intValue(
      _pickFirstValue(summary, const ['sales', 'totalSales', 'salesTotal']),
    );
    final totalProfit = _intValue(
      _pickFirstValue(summary, const ['profit', 'totalProfit', 'netProfit']),
    );
    final salesCount = _intValue(
      _pickFirstValue(summary, const ['salesCount', 'ordersCount', 'count']),
    );
    final avgSale = _intValue(
      _pickFirstValue(summary, const ['avgSale', 'averageSale', 'average']),
    );

    final trend = _mapListValue(
      _pickFirstValue(payload, const ['trend', 'hourlyTrend', 'timeline']),
    )
        .map(
          (item) => _TrendPoint(
            label: _stringValue(
              _pickFirstValue(item, const ['label', 'hour', 'name']),
              fallback: '-',
            ),
            value: _intValue(
              _pickFirstValue(item, const ['value', 'amount', 'sales']),
            ),
          ),
        )
        .where((item) => item.label != '-')
        .toList(growable: false);

    final topProducts = _mapListValue(
      _pickFirstValue(payload, const ['topProducts', 'top_products', 'products']),
    )
        .asMap()
        .entries
        .map(
          (entry) => _TopProductStat(
            rank: entry.key + 1,
            name: _stringValue(
              _pickFirstValue(
                entry.value,
                const ['name', 'title', 'productName'],
              ),
              fallback: 'পণ্য',
            ),
            salesCount: _intValue(
              _pickFirstValue(
                entry.value,
                const ['quantity', 'salesCount', 'count'],
              ),
            ),
            revenue: _intValue(
              _pickFirstValue(
                  entry.value, const ['revenue', 'amount', 'sales', 'value']),
            ),
            category: _stringValue(
              _pickFirstValue(entry.value, const ['category', 'categoryName']),
              fallback: 'বিক্রয়',
            ),
            icon: _reportIconForKind(
              _stringValue(_pickFirstValue(entry.value, const ['kind', 'type'])),
            ),
            color: _reportColorFromValue(
              _stringValue(entry.value['color']),
              const Color(0xFF0C8C67),
            ),
          ),
        )
        .toList(growable: false);

    return _RemoteDailySalesReportData(
      totalSales: totalSales,
      totalProfit: totalProfit,
      salesCount: salesCount,
      avgSale: avgSale,
      hourlyTrend: trend,
      topProducts: topProducts,
      paymentSlices: _remotePaymentsFromPayload(payload),
    );
  }
}

final dailySalesReportRemoteProvider = AsyncNotifierProvider.autoDispose
    .family<DailySalesReportRemoteNotifier, _RemoteDailySalesReportData?, DateTime>(
  DailySalesReportRemoteNotifier.new,
);

class _DokanDailySalesReportPage extends ConsumerStatefulWidget {
  const _DokanDailySalesReportPage();

  @override
  ConsumerState<_DokanDailySalesReportPage> createState() =>
      _DokanDailySalesReportPageState();
}

class _DokanDailySalesReportPageState
    extends ConsumerState<_DokanDailySalesReportPage> {
  DateTime _selectedDate = DateTime.now();

  String get _dateLabel =>
      '${_bnDigits(_selectedDate.day.toString())} ${_monthName(_selectedDate.month)} ${_bnDigits(_selectedDate.year.toString())}';

  void _shiftDate(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
    });
  }

  List<_TrendPoint> _getHourlyTrend(List<_ReportRecord> salesRecords) {
    final byHour = <int, int>{};
    for (final r in salesRecords) {
      final hour = r.timestamp.hour;
      byHour[hour] = (byHour[hour] ?? 0) + r.salesAmount;
    }
    final hours = [8, 10, 12, 14, 16, 18, 20];
    final labels = ['8am', '10am', '12pm', '2pm', '4pm', '6pm', '8pm'];
    return List.generate(hours.length, (i) {
      final hr = hours[i];
      var sum = 0;
      byHour.forEach((hour, value) {
        if (hour >= hr && hour < hr + 2) {
          sum += value;
        }
      });
      return _TrendPoint(label: labels[i], value: sum);
    });
  }

  List<_TopProductStat> _getTopProducts(List<_ReportRecord> salesRecords) {
    final grouped = <String, _TopProductStat>{};
    for (final r in salesRecords) {
      final existing = grouped[r.title];
      if (existing == null) {
        grouped[r.title] = _TopProductStat(
          rank: 0,
          name: r.title,
          salesCount: r.quantity,
          revenue: r.salesAmount,
          category: r.category,
          icon: r.icon,
          color: r.color,
        );
      } else {
        grouped[r.title] = _TopProductStat(
          rank: 0,
          name: r.title,
          salesCount: existing.salesCount + r.quantity,
          revenue: existing.revenue + r.salesAmount,
          category: r.category,
          icon: r.icon,
          color: r.color,
        );
      }
    }
    final sorted = grouped.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    return List.generate(math.min(5, sorted.length), (i) {
      return _TopProductStat(
        rank: i + 1,
        name: sorted[i].name,
        salesCount: sorted[i].salesCount,
        revenue: sorted[i].revenue,
        category: sorted[i].category,
        icon: sorted[i].icon,
        color: sorted[i].color,
      );
    });
  }

  List<_PaymentSlice> _getPaymentSlices(List<_ReportRecord> salesRecords) {
    final cash = salesRecords
        .where((r) => r.paymentMethod == 'নগদ')
        .fold<int>(0, (sum, r) => sum + r.salesAmount);
    final bkash = salesRecords
        .where((r) => r.paymentMethod == 'bKash')
        .fold<int>(0, (sum, r) => sum + r.salesAmount);
    final due = salesRecords
        .where((r) => r.paymentMethod == 'বাকি')
        .fold<int>(0, (sum, r) => sum + r.salesAmount);
    return [
      _PaymentSlice(
        label: 'নগদ',
        amount: cash,
        color: const Color(0xFF0C8C67),
        icon: Icons.payments_outlined,
      ),
      _PaymentSlice(
        label: 'bKash',
        amount: bkash,
        color: const Color(0xFFF49B1A),
        icon: Icons.phone_android_outlined,
      ),
      _PaymentSlice(
        label: 'বাকি',
        amount: due,
        color: const Color(0xFFE25A4E),
        icon: Icons.pending_actions_outlined,
      ),
    ];
  }

  double _paymentPercent(int amount, List<_PaymentSlice> slices) {
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.amount.abs());
    if (total <= 0) return 0;
    return amount.abs() / total;
  }

  @override
  Widget build(BuildContext context) {
    final remoteSalesAsync =
        ref.watch(dailySalesReportRemoteProvider(_selectedDate));
    final orders = ref.watch(dokanSalesHistorySnapshotProvider);
    final dayOrders = orders.where((order) {
      final createdAt = (order['createdAt'] as num?)?.toInt() ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
      return DateUtils.isSameDay(date, _selectedDate) &&
          order['status'] != 'cancelled';
    }).toList();
    final salesCount = dayOrders.length;

    final dayRecords = ref
        .watch(reportRecordsProvider)
        .where((r) => DateUtils.isSameDay(r.timestamp, _selectedDate))
        .toList();
    final salesRecords =
        dayRecords.where((r) => r.kind == _ReportRecordKind.sale).toList();
    final totalSales =
        salesRecords.fold<int>(0, (sum, r) => sum + r.salesAmount);
    final totalProfit =
        salesRecords.fold<int>(0, (sum, r) => sum + r.profitAmount);
    final avgSale = salesCount > 0 ? (totalSales / salesCount).round() : 0;

    final remoteSales = remoteSalesAsync.asData?.value;
    final resolvedSalesCount = remoteSales?.salesCount ?? salesCount;
    final resolvedTotalSales = remoteSales?.totalSales ?? totalSales;
    final resolvedTotalProfit =
        salesRecords.isNotEmpty ? totalProfit : remoteSales?.totalProfit ?? 0;
    final resolvedAvgSale = remoteSales?.avgSale ?? avgSale;
    final hourlyTrend = remoteSales?.hourlyTrend.isNotEmpty == true
        ? remoteSales!.hourlyTrend
        : _getHourlyTrend(salesRecords);
    final topProducts = remoteSales?.topProducts.isNotEmpty == true
        ? remoteSales!.topProducts
        : _getTopProducts(salesRecords);
    final paymentSlices = remoteSales?.paymentSlices.isNotEmpty == true
        ? remoteSales!.paymentSlices
        : _getPaymentSlices(salesRecords);

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
          'দৈনিক বিক্রয় রিপোর্ট',
          style: TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showReportSnackBar(context, 'শেয়ার প্রস্তুত'),
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            onPressed: () =>
                _showReportSnackBar(context, 'ক্যালেন্ডার খোলা হয়েছে'),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_outlined,
                                size: 18, color: Color(0xFF0C8C67)),
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 150),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (remoteSalesAsync.isLoading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFDCE9E5)),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'দৈনিক বিক্রয় রিপোর্ট লোড হচ্ছে...',
                              style: TextStyle(
                                color: Color(0xFF3D4943),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (remoteSalesAsync.hasError)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4F3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF4C8C4)),
                      ),
                      child: const Text(
                        'Daily sales report API response pawa jayni, tai local report fallback dekhano hocche.',
                        style: TextStyle(
                          color: Color(0xFF9F2D20),
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1FA47A), Color(0xFF0B7557)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x250B7557),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'মোট বিক্রয়',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currency(resolvedTotalSales),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.20),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DailyHeroMetric(
                                label: 'লাভ',
                                value: _currency(resolvedTotalProfit),
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 44,
                                color: Colors.white.withOpacity(0.18)),
                            Expanded(
                              child: _DailyHeroMetric(
                                label: 'বিক্রয় সংখ্যা',
                                value:
                                    '${_bnDigits(resolvedSalesCount.toString())}টি',
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 44,
                                color: Colors.white.withOpacity(0.18)),
                            Expanded(
                              child: _DailyHeroMetric(
                                label: 'গড় বিক্রয়',
                                value: _currency(resolvedAvgSale),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'ঘণ্টাভিত্তিক বিক্রয়',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Color(0xFF0C8C67),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'গত মাসের তুলনায় +১২% ↑',
                              style: TextStyle(
                                color: Color(0xFF0C8C67),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 182,
                          child: _TrendChart(points: hourlyTrend),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'শীর্ষ ৫টি পণ্য',
                    child: Column(
                      children: [
                        if (topProducts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'কোনো পণ্য বিক্রয় নেই',
                                style: TextStyle(
                                  color: Color(0xFF8A8A8A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        else
                          for (var i = 0; i < topProducts.length; i++) ...[
                            _DailyTopProductRow(product: topProducts[i]),
                            if (i != topProducts.length - 1)
                              const SizedBox(height: 10),
                          ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'পেমেন্ট ব্রেকডাউন',
                    child: Column(
                      children: [
                        for (final slice in paymentSlices) ...[
                          _PaymentAnalysisRow(
                            label: slice.label,
                            amount: _currency(slice.amount),
                            percent:
                                _paymentPercent(slice.amount, paymentSlices),
                            color: slice.color,
                            icon: slice.icon,
                          ),
                          if (slice != paymentSlices.last)
                            const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ReportsExportBar(
            onPdf: () =>
                _showReportSnackBar(context, 'PDF রিপোর্ট তৈরি হয়েছে'),
            onExcel: () =>
                _showReportSnackBar(context, 'Excel রপ্তানি প্রস্তুত'),
            onWhatsApp: () =>
                _showReportSnackBar(context, 'WhatsApp শেয়ার প্রস্তুত'),
          ),
          _ReportsBottomNav(selectedIndex: 3),
        ],
      ),
    );
  }
}
