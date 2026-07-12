part of '../reports_screens.dart';

class _RemoteDailyPurchaseReportData {
  const _RemoteDailyPurchaseReportData({
    required this.totalPurchase,
    required this.totalExpense,
    required this.totalProducts,
    required this.purchaseCount,
    required this.avgPurchase,
    required this.hourlyTrend,
    required this.topItems,
    required this.paymentSlices,
  });

  final int totalPurchase;
  final int totalExpense;
  final int totalProducts;
  final int purchaseCount;
  final int avgPurchase;
  final List<_TrendPoint> hourlyTrend;
  final List<_PurchaseRankStat> topItems;
  final List<_PaymentSlice> paymentSlices;
}

final dailyPurchaseReportRemoteProvider = FutureProvider.autoDispose
    .family<_RemoteDailyPurchaseReportData?, DateTime>(
  (ref, selectedDate) async {
    if (!ref.watch(reportConfiguredProvider)) {
      return null;
    }
    final from = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final to = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
      999,
    );
    final payload = await ref.watch(reportRepositoryProvider).fetchReport(
      'purchases-summary',
      filters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      },
    );
    if (payload.isEmpty) {
      return null;
    }

    final summary = _mapValue(
          _pickFirstValue(payload, const ['summary', 'kpi', 'totals']),
        ) ??
        payload;
    final totalPurchase = _intValue(
      _pickFirstValue(
        summary,
        const [
          'purchase',
          'purchases',
          'purchaseTotal',
          'totalPurchase',
          'totalPurchases',
        ],
      ),
    );
    final totalExpense = _intValue(
      _pickFirstValue(summary, const ['expense', 'expenses', 'totalExpense']),
    );
    final totalProducts = _intValue(
      _pickFirstValue(
        summary,
        const ['totalProducts', 'productsCount', 'itemsCount', 'quantity'],
      ),
    );
    final purchaseCount = _intValue(
      _pickFirstValue(
        summary,
        const ['purchaseCount', 'ordersCount', 'count'],
      ),
    );
    final avgPurchase = _intValue(
      _pickFirstValue(
        summary,
        const ['avgPurchase', 'averagePurchase', 'average'],
      ),
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
              _pickFirstValue(item, const ['value', 'amount', 'purchase']),
            ),
          ),
        )
        .where((item) => item.label != '-')
        .toList(growable: false);

    final topItems = _mapListValue(
      _pickFirstValue(payload, const ['topItems', 'top_items', 'products']),
    )
        .asMap()
        .entries
        .map(
          (entry) => _PurchaseRankStat(
            rank: entry.key + 1,
            name: _stringValue(
              _pickFirstValue(
                entry.value,
                const ['name', 'title', 'productName'],
              ),
              fallback: 'পণ্য',
            ),
            units: _intValue(
              _pickFirstValue(
                entry.value,
                const ['quantity', 'units', 'count'],
              ),
            ),
            amount: _intValue(
              _pickFirstValue(
                entry.value,
                const ['amount', 'purchase', 'total'],
              ),
            ),
            category: _stringValue(
              _pickFirstValue(entry.value, const ['category', 'categoryName']),
              fallback: 'ক্রয়',
            ),
            icon: _reportIconForKind(
              _stringValue(
                  _pickFirstValue(entry.value, const ['kind', 'type'])),
            ),
            color: _reportColorFromValue(
              _stringValue(entry.value['color']),
              const Color(0xFF0C8C67),
            ),
          ),
        )
        .toList(growable: false);

    return _RemoteDailyPurchaseReportData(
      totalPurchase: totalPurchase,
      totalExpense: totalExpense,
      totalProducts: totalProducts,
      purchaseCount: purchaseCount,
      avgPurchase: avgPurchase,
      hourlyTrend: trend,
      topItems: topItems,
      paymentSlices: _remotePaymentsFromPayload(payload),
    );
  },
);

class DokanDailyPurchaseReportScreen extends StatelessWidget {
  const DokanDailyPurchaseReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DokanDailyPurchaseReportPage();
  }
}

class _DokanDailyPurchaseReportPage extends ConsumerStatefulWidget {
  const _DokanDailyPurchaseReportPage();

  @override
  ConsumerState<_DokanDailyPurchaseReportPage> createState() =>
      _DokanDailyPurchaseReportPageState();
}

class _DokanDailyPurchaseReportPageState
    extends ConsumerState<_DokanDailyPurchaseReportPage> {
  DateTime _selectedDate = DateTime.now();

  String get _dateLabel =>
      '${_bnDigits(_selectedDate.day.toString())} ${_monthName(_selectedDate.month)} ${_bnDigits(_selectedDate.year.toString())}';

  void _shiftDate(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
    });
  }

  List<_TrendPoint> _getHourlyTrend(List<_ReportRecord> purchaseRecords) {
    final byHour = <int, int>{};
    for (final r in purchaseRecords) {
      final hour = r.timestamp.hour;
      byHour[hour] = (byHour[hour] ?? 0) + r.purchaseAmount;
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

  List<_PurchaseRankStat> _getTopItems(List<_ReportRecord> purchaseRecords) {
    final grouped = <String, _PurchaseRankStat>{};
    for (final r in purchaseRecords) {
      final existing = grouped[r.title];
      if (existing == null) {
        grouped[r.title] = _PurchaseRankStat(
          rank: 0,
          name: r.title,
          units: r.quantity,
          amount: r.purchaseAmount,
          category: r.category,
          icon: r.icon,
          color: r.color,
        );
      } else {
        grouped[r.title] = _PurchaseRankStat(
          rank: 0,
          name: r.title,
          units: existing.units + r.quantity,
          amount: existing.amount + r.purchaseAmount,
          category: r.category,
          icon: r.icon,
          color: r.color,
        );
      }
    }
    final sorted = grouped.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return List.generate(math.min(5, sorted.length), (i) {
      return _PurchaseRankStat(
        rank: i + 1,
        name: sorted[i].name,
        units: sorted[i].units,
        amount: sorted[i].amount,
        category: sorted[i].category,
        icon: sorted[i].icon,
        color: sorted[i].color,
      );
    });
  }

  List<_PaymentSlice> _getPaymentSlices(List<_ReportRecord> purchaseRecords) {
    final cash = purchaseRecords
        .where((r) => r.paymentMethod == 'নগদ')
        .fold<int>(0, (sum, r) => sum + r.purchaseAmount);
    final bkash = purchaseRecords
        .where((r) => r.paymentMethod == 'bKash')
        .fold<int>(0, (sum, r) => sum + r.purchaseAmount);
    final due = purchaseRecords
        .where((r) => r.paymentMethod == 'বাকি')
        .fold<int>(0, (sum, r) => sum + r.purchaseAmount);
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

  double _purchasePaymentPercent(int amount, List<_PaymentSlice> slices) {
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.amount.abs());
    if (total <= 0) return 0;
    return amount.abs() / total;
  }

  @override
  Widget build(BuildContext context) {
    final remotePurchaseAsync =
        ref.watch(dailyPurchaseReportRemoteProvider(_selectedDate));
    final dayRecords = ref
        .watch(reportRecordsProvider)
        .where((r) => DateUtils.isSameDay(r.timestamp, _selectedDate))
        .toList();
    final purchaseRecords =
        dayRecords.where((r) => r.kind == _ReportRecordKind.purchase).toList();
    final totalPurchase =
        purchaseRecords.fold<int>(0, (sum, r) => sum + r.purchaseAmount);
    final totalExpense = dayRecords
        .where((r) => r.kind == _ReportRecordKind.expense)
        .fold<int>(0, (sum, r) => sum + r.expenseAmount);
    final totalProducts =
        purchaseRecords.fold<int>(0, (sum, r) => sum + r.quantity);
    final purchaseCount = purchaseRecords.length;
    final avgPurchase =
        purchaseCount > 0 ? (totalPurchase / purchaseCount).round() : 0;

    final remotePurchase = remotePurchaseAsync.asData?.value;
    final resolvedTotalPurchase =
        remotePurchase?.totalPurchase ?? totalPurchase;
    final resolvedTotalExpense = remotePurchase?.totalExpense ?? totalExpense;
    final resolvedTotalProducts =
        remotePurchase?.totalProducts ?? totalProducts;
    final resolvedPurchaseCount =
        remotePurchase?.purchaseCount ?? purchaseCount;
    final resolvedAvgPurchase = remotePurchase?.avgPurchase ?? avgPurchase;
    final hourlyTrend = remotePurchase?.hourlyTrend.isNotEmpty == true
        ? remotePurchase!.hourlyTrend
        : _getHourlyTrend(purchaseRecords);
    final topItems = remotePurchase?.topItems.isNotEmpty == true
        ? remotePurchase!.topItems
        : _getTopItems(purchaseRecords);
    final paymentSlices = remotePurchase?.paymentSlices.isNotEmpty == true
        ? remotePurchase!.paymentSlices
        : _getPaymentSlices(purchaseRecords);

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
          'দৈনিক ক্রয় রিপোর্ট',
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
                  if (remotePurchaseAsync.isLoading)
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
                              'দৈনিক ক্রয় রিপোর্ট লোড হচ্ছে...',
                              style: TextStyle(
                                color: Color(0xFF3D4943),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (remotePurchaseAsync.hasError)
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
                        'Daily purchase report API response pawa jayni, tai local report fallback dekhano hocche.',
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
                          'মোট ক্রয়',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currency(resolvedTotalPurchase),
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
                                label: 'মোট খরচ',
                                value: _currency(resolvedTotalExpense),
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 44,
                                color: Colors.white.withOpacity(0.18)),
                            Expanded(
                              child: _DailyHeroMetric(
                                label: 'মোট পণ্য সংখ্যা',
                                value:
                                    '${_bnDigits(resolvedTotalProducts.toString())}টি',
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 44,
                                color: Colors.white.withOpacity(0.18)),
                            Expanded(
                              child: _DailyHeroMetric(
                                label: 'গড় ক্রয়',
                                value: _currency(resolvedAvgPurchase),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'ঘণ্টা ভিত্তিক ক্রয়',
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
                              'গত মাসের তুলনায় +৯% ↑',
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
                        if (topItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'কোনো পণ্য ক্রয় নেই',
                                style: TextStyle(
                                  color: Color(0xFF8A8A8A),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        else
                          for (var i = 0; i < topItems.length; i++) ...[
                            _DailyPurchaseTopItemRow(product: topItems[i]),
                            if (i != topItems.length - 1)
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
                            percent: _purchasePaymentPercent(
                                slice.amount, paymentSlices),
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
