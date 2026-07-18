part of '../reports_screens.dart';

class _DokanStockValueReportPage extends ConsumerStatefulWidget {
  const _DokanStockValueReportPage();

  @override
  ConsumerState<_DokanStockValueReportPage> createState() =>
      _DokanStockValueReportPageState();
}

class _DokanStockValueReportPageState
    extends ConsumerState<_DokanStockValueReportPage> {
  DateTime _selectedDate = DateTime.now();
  int _selectedRange = 0;

  String get _dateLabel =>
      '${_bnDigits(_selectedDate.day.toString())} ${_monthName(_selectedDate.month)} ${_bnDigits(_selectedDate.year.toString())}';

  void _shiftDate(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
      _selectedRange = 4;
    });
  }

  void _selectRange(int value) {
    setState(() {
      _selectedRange = value;
      if (value == 0) {
        _selectedDate = DateTime.now();
      }
    });
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0C8C67),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111111),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _selectedRange = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final remoteProfitLossAsync = ref.watch(
      profitLossReportRemoteProvider(
        _ProfitLossRequestKey(
          selectedDate: _selectedDate,
          selectedRange: _selectedRange,
        ),
      ),
    );
    final requestKey = _ProfitLossRequestKey(
      selectedDate: _selectedDate,
      selectedRange: _selectedRange,
    );
    final localSalesRecords = ref
        .watch(reportRecordsProvider)
        .where((record) =>
            record.kind == _ReportRecordKind.sale &&
            _matchesProfitLossRange(requestKey, record.timestamp))
        .toList(growable: false);
    final localProfit = localSalesRecords.fold<int>(
      0,
      (sum, record) => sum + record.profitAmount,
    );
    final remote = remoteProfitLossAsync.asData?.value;
    final totalSales = remote?.totalSales ?? 0;
    final returnAmount = remote?.returnAmount ?? 0;
    final netSales = remote?.netSales ?? 0;
    final totalPurchase = remote?.totalPurchase ?? 0;
    final totalExpense = remote?.totalExpense ?? 0;
    final localOrders = ref.watch(dokanPosProvider).orders;
    final hasLocalProfit = localOrders.isNotEmpty;
    final grossProfit = hasLocalProfit ? localProfit : remote?.grossProfit ?? 0;
    final netProfit = hasLocalProfit ? localProfit : remote?.netProfit ?? 0;
    final totalCost = remote?.totalCost ?? 0;
    final taxAmount = remote?.taxAmount ?? 0;
    final chargeAmount = remote?.chargeAmount ?? 0;
    final totalOthers = remote?.totalOthers ?? 0;
    final marginPercent = hasLocalProfit && netSales > 0
        ? ((grossProfit * 100) / netSales).round()
        : remote?.marginPercent ?? 0;
    final profitRatio = hasLocalProfit && netSales > 0
        ? ((netProfit * 100) / netSales).round()
        : remote?.profitRatio ?? 0;
    final int profitPercent;
    final int costPercent;
    final int otherPercent;

    if (hasLocalProfit) {
      final localOthers = remote?.totalOthers ?? 0;
      final localRatioSum = math.max(0, netProfit) + totalCost + localOthers;
      if (localRatioSum > 0) {
        profitPercent = ((math.max(0, netProfit) * 100) / localRatioSum).round();
        costPercent = ((totalCost * 100) / localRatioSum).round();
        otherPercent = 100 - profitPercent - costPercent;
      } else {
        profitPercent = 0;
        costPercent = 100;
        otherPercent = 0;
      }
    } else {
      profitPercent = remote?.profitPercent ?? 0;
      costPercent = remote?.costPercent ?? 0;
      otherPercent = remote?.otherPercent ?? 0;
    }

    final ratioSlices = [
      _StockRatioSlice(
          label: AppStrings.activeLanguage == AppLanguage.english
              ? 'Profit'
              : 'প্রফিট',
          value: profitPercent,
          color: const Color(0xFF0C8C67)),
      _StockRatioSlice(
          label: AppStrings.activeLanguage == AppLanguage.english
              ? 'Cost'
              : 'ব্যয়',
          value: costPercent,
          color: const Color(0xFFD43B3B)),
      _StockRatioSlice(
          label: AppStrings.activeLanguage == AppLanguage.english
              ? 'VAT, Tax & Charges'
              : 'ভ্যাট, ট্যাক্স ও চার্জ',
          value: otherPercent,
          color: const Color(0xFF8E9A97)),
    ];

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
          'লাভ-ক্ষতি রিপোর্ট',
          style: TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          if (remoteProfitLossAsync.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _RemoteReportLoadingBanner(
                  message: 'লাভ-ক্ষতির তথ্য লোড হচ্ছে...',
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: DokanFadeSlideIn(
              delay: const Duration(milliseconds: 30),
              duration: const Duration(milliseconds: 500),
              slideOffset: const Offset(0, -10),
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickCustomDate,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFD9E6E2)),
                            ),
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
          ),
          SliverToBoxAdapter(
            child: DokanFadeSlideIn(
              delay: const Duration(milliseconds: 70),
              duration: const Duration(milliseconds: 500),
              slideOffset: const Offset(0, -10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ReportChip(
                        label: 'আজ',
                        selected: _selectedRange == 0,
                        onTap: () => _selectRange(0),
                      ),
                      const SizedBox(width: 10),
                      _ReportChip(
                        label: 'এই সপ্তাহ',
                        selected: _selectedRange == 1,
                        onTap: () => _selectRange(1),
                      ),
                      const SizedBox(width: 10),
                      _ReportChip(
                        label: 'এই মাস',
                        selected: _selectedRange == 2,
                        onTap: () => _selectRange(2),
                      ),
                      const SizedBox(width: 10),
                      _ReportChip(
                        label: 'এই বছর',
                        selected: _selectedRange == 3,
                        onTap: () => _selectRange(3),
                      ),
                      const SizedBox(width: 10),
                      _ReportChip(
                        label: 'কাস্টম',
                        selected: _selectedRange == 4,
                        onTap: _pickCustomDate,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 156),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    duration: const Duration(milliseconds: 500),
                    slideOffset: const Offset(0, 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: _CompactSummaryCard(
                            title: 'গ্রস লাভ',
                            value: _currency(grossProfit),
                            subtitle:
                                '${_bnDigits(marginPercent.toString())}% মার্জিন',
                            background: const Color(0xFFE6F4EE),
                            foreground: const Color(0xFF0C8C67),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CompactSummaryCard(
                            title: 'নিট লাভ',
                            value: _currency(netProfit),
                            subtitle:
                                '${_bnDigits(profitRatio.toString())}% প্রফিট',
                            background: const Color(0xFF0C8C67),
                            foreground: Colors.white,
                            isFilled: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 170),
                    duration: const Duration(milliseconds: 500),
                    slideOffset: const Offset(0, 20),
                    child: _SectionCard(
                      title: 'রাজস্ব (Revenue)',
                      child: Column(
                        children: [
                          _ValueLineItem(
                            label: 'মোট বিক্রয়',
                            value: _currency(totalSales),
                            valueColor: const Color(0xFF0C8C67),
                          ),
                          const SizedBox(height: 12),
                          _ValueLineItem(
                            label: 'রিটার্ন/বাতিল',
                            value: _currency(returnAmount),
                            valueColor: const Color(0xFFD43B3B),
                          ),
                          const SizedBox(height: 12),
                          const _DividerLine(),
                          const SizedBox(height: 12),
                          _ValueLineItem(
                            label: 'নিট বিক্রয়',
                            value: _currency(netSales),
                            valueColor: const Color(0xFF0C8C67),
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 220),
                    duration: const Duration(milliseconds: 500),
                    slideOffset: const Offset(0, 20),
                    child: _SectionCard(
                      title: 'ব্যয় (Cost)',
                      child: Column(
                        children: [
                          _ValueLineItem(
                            label: 'পণ্যের ক্রয়মূল্য',
                            value: _currency(totalPurchase),
                            valueColor: const Color(0xFF111111),
                          ),
                          const SizedBox(height: 12),
                          _ValueLineItem(
                            label: 'পরিচালন খরচ',
                            value: _currency(totalExpense),
                            valueColor: const Color(0xFF111111),
                          ),
                          const SizedBox(height: 12),
                          const _DividerLine(),
                          const SizedBox(height: 12),
                          _ValueLineItem(
                            label: 'মোট ব্যয়',
                            value: _currency(totalCost),
                            valueColor: const Color(0xFFD43B3B),
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 270),
                    duration: const Duration(milliseconds: 500),
                    slideOffset: const Offset(0, 20),
                    child: _SectionCard(
                      title: 'ভ্যাট, ট্যাক্স ও চার্জ',
                      child: Column(
                        children: [
                          _ValueLineItem(
                            label: 'ভ্যাট ও ট্যাক্স',
                            value: _currency(taxAmount),
                            valueColor: const Color(0xFF111111),
                          ),
                          const SizedBox(height: 12),
                          _ValueLineItem(
                            label: 'ডেলিভারি ও অন্যান্য চার্জ',
                            value: _currency(chargeAmount),
                            valueColor: const Color(0xFF111111),
                          ),
                          const SizedBox(height: 12),
                          const _DividerLine(),
                          const SizedBox(height: 12),
                          _ValueLineItem(
                            label: 'মোট অন্যান্য',
                            value: _currency(totalOthers),
                            valueColor: const Color(0xFF555555),
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 320),
                    duration: const Duration(milliseconds: 500),
                    slideOffset: const Offset(0, 20),
                    child: _SectionCard(
                      title: 'আর্থিক অনুপাত বিশ্লেষণ',
                      child: Column(
                        children: [
                          SizedBox(
                            height: 210,
                            child: _StockRatioChart(
                                slices: ratioSlices,
                                centerLabel:
                                    netProfit < 0 ? 'নিট লোকসান' : 'নিট লাভ',
                                centerValue:
                                    '${_bnDigits(profitRatio.abs().toString())}%'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (final slice in ratioSlices)
                                _RatioLegendItem(
                                    label: slice.label, color: slice.color),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2F0),
              border: Border(top: BorderSide(color: const Color(0xFFD7E5E0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ReportExportActionButton(
                    label: 'PDF ডাউনলোড',
                    icon: Icons.picture_as_pdf_outlined,
                    onTap: () =>
                        _showReportSnackBar(context, 'PDF ডাউনলোড প্রস্তুত'),
                    filled: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ReportExportActionButton(
                    label: 'Excel রিপোর্ট',
                    icon: Icons.grid_on_outlined,
                    onTap: () =>
                        _showReportSnackBar(context, 'Excel রিপোর্ট প্রস্তুত'),
                    filled: true,
                  ),
                ),
              ],
            ),
          ),
          _ReportsBottomNav(selectedIndex: 3),
        ],
      ),
    );
  }
}

class DokanStockReportScreen extends StatelessWidget {
  const DokanStockReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DokanStockReportPage();
  }
}

class DokanExpenseReportScreen extends StatelessWidget {
  const DokanExpenseReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExpenseReportDashboardBody();
  }
}

class _ProfitLossRequestKey {
  const _ProfitLossRequestKey({
    required this.selectedDate,
    required this.selectedRange,
  });

  final DateTime selectedDate;
  final int selectedRange;

  @override
  bool operator ==(Object other) {
    return other is _ProfitLossRequestKey &&
        other.selectedRange == selectedRange &&
        DateUtils.isSameDay(other.selectedDate, selectedDate);
  }

  @override
  int get hashCode => Object.hash(
      selectedRange, selectedDate.year, selectedDate.month, selectedDate.day);
}

class _RemoteProfitLossReportData {
  const _RemoteProfitLossReportData({
    required this.totalSales,
    required this.returnAmount,
    required this.netSales,
    required this.totalPurchase,
    required this.totalExpense,
    required this.totalCost,
    required this.grossProfit,
    required this.netProfit,
    required this.marginPercent,
    required this.profitRatio,
    required this.profitPercent,
    required this.costPercent,
    required this.otherPercent,
    required this.taxAmount,
    required this.chargeAmount,
    required this.totalOthers,
  });

  final int totalSales;
  final int returnAmount;
  final int netSales;
  final int totalPurchase;
  final int totalExpense;
  final int totalCost;
  final int grossProfit;
  final int netProfit;
  final int marginPercent;
  final int profitRatio;
  final int profitPercent;
  final int costPercent;
  final int otherPercent;
  final int taxAmount;
  final int chargeAmount;
  final int totalOthers;
}

Map<String, dynamic> _profitLossFiltersFor(_ProfitLossRequestKey key) {
  final bounds = _profitLossBoundsFor(key);
  final from = bounds.first;
  final to = bounds.last;

  String apiDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  return {
    'range': switch (key.selectedRange) {
      0 => 'today',
      1 => 'week',
      2 => 'month',
      3 => 'year',
      _ => 'custom',
    },
    'startDate': apiDate(from),
    'endDate': apiDate(to),
  };
}

bool _matchesProfitLossRange(_ProfitLossRequestKey key, DateTime timestamp) {
  final bounds = _profitLossBoundsFor(key);
  return !timestamp.isBefore(bounds.first) && !timestamp.isAfter(bounds.last);
}

List<DateTime> _profitLossBoundsFor(_ProfitLossRequestKey key) {
  DateTime from;
  DateTime to;
  final selectedDay = DateTime(
    key.selectedDate.year,
    key.selectedDate.month,
    key.selectedDate.day,
  );
  switch (key.selectedRange) {
    case 0:
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
    case 1:
      from = _startOfWeek(key.selectedDate);
      to = from
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      break;
    case 2:
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
    case 3:
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
  return <DateTime>[from, to];
}

class ProfitLossReportLocalCache {
  static const _keyPrefix = 'dokan_profit_loss_report_cache_v2_';

  static String _storageKey(_ProfitLossRequestKey key) {
    return '$_keyPrefix${key.selectedDate.year}_${key.selectedDate.month}_${key.selectedDate.day}_${key.selectedRange}';
  }

  static Future<Map<String, dynamic>?> load(_ProfitLossRequestKey key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey(key));
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> save(_ProfitLossRequestKey key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey(key), jsonEncode(data));
    } catch (_) {}
  }
}

class ProfitLossReportRemoteNotifier extends AutoDisposeFamilyAsyncNotifier<_RemoteProfitLossReportData?, _ProfitLossRequestKey> {
  @override
  Future<_RemoteProfitLossReportData?> build(_ProfitLossRequestKey arg) async {
    // 1. Try to load from cache
    final cached = await ProfitLossReportLocalCache.load(arg);
    if (cached != null) {
      // Trigger background network fetch
      _fetchAndSave(arg);
      return _parse(cached);
    }

    // 2. If no cache, perform remote fetch
    return _fetchAndSave(arg);
  }

  Future<_RemoteProfitLossReportData?> _fetchAndSave(_ProfitLossRequestKey arg) async {
    try {
      if (!ref.read(reportConfiguredProvider)) return null;
      final payload = await ref.read(reportRepositoryProvider).fetchReport(
            'profit-loss',
            filters: _profitLossFiltersFor(arg),
          );
      if (payload.isNotEmpty) {
        await ProfitLossReportLocalCache.save(arg, payload);
        final parsed = _parse(payload);
        state = AsyncData(parsed);
        return parsed;
      }
    } catch (_) {}
    return null;
  }

  _RemoteProfitLossReportData? _parse(Map<String, dynamic> payload) {
    final summary = _mapValue(
          _pickFirstValue(payload, const ['summary', 'kpi', 'totals']),
        ) ??
        payload;
    final revenue = _mapValue(_pickFirstValue(payload, const ['revenue'])) ??
        const <String, dynamic>{};
    final cost = _mapValue(_pickFirstValue(payload, const ['cost', 'costs'])) ??
        const <String, dynamic>{};
    final totalSales = _intValue(
      _pickFirstValue(summary, const ['sales', 'revenue', 'totalSales']) ??
          _pickFirstValue(revenue, const ['totalSales', 'sales', 'grossSales']),
    );
    final returnAmount = _intValue(
      _pickFirstValue(summary, const ['returns', 'returnAmount']) ??
          _pickFirstValue(revenue, const ['returns', 'returnAmount']),
    );
    final netSales = _intValue(
      _pickFirstValue(summary, const ['netSales']) ??
          _pickFirstValue(revenue, const ['netSales']),
    );
    final totalPurchase = _intValue(
      _pickFirstValue(
            summary,
            const ['purchase', 'purchases', 'cogs', 'totalPurchase'],
          ) ??
          _pickFirstValue(cost, const ['purchaseCost', 'cogs', 'totalPurchase']),
    );
    final totalExpense = _intValue(
      _pickFirstValue(summary, const ['expense', 'expenses', 'totalExpense']) ??
          _pickFirstValue(cost, const ['operatingExpenses', 'expenses']),
    );
    final totalCost = _intValue(
      _pickFirstValue(summary, const ['totalCost', 'cost']) ??
          _pickFirstValue(cost, const ['totalCost']),
    );
    final grossProfit = _intValue(
      _pickFirstValue(summary, const ['grossProfit', 'gross_profit', 'profit']),
    );
    final netProfit = _intValue(
      _pickFirstValue(summary, const ['netProfit', 'net_profit']),
    );
    final marginPercent = _intValue(
      _pickFirstValue(
          summary, const ['marginPercent', 'margin_percentage', 'grossMargin']),
    );
    final profitRatio = _intValue(
      _pickFirstValue(
          summary, const ['profitRatio', 'profit_percentage', 'netMargin']),
    );

    final ratios =
        _mapValue(_pickFirstValue(payload, const ['ratios', 'ratioBreakdown'])) ??
            const <String, dynamic>{};
    final profitPercent = _intValue(
      _pickFirstValue(ratios, const ['profitPercent', 'profit']),
    );
    final costPercent = _intValue(
      _pickFirstValue(ratios, const ['costPercent', 'cost']),
    );
    final otherPercent = _intValue(
      _pickFirstValue(ratios, const ['otherPercent', 'other']),
    );

    final others = _mapValue(_pickFirstValue(payload, const ['others'])) ??
        const <String, dynamic>{};
    final taxAmount = _intValue(_pickFirstValue(others, const ['tax', 'taxAmount']));
    final chargeAmount = _intValue(_pickFirstValue(others, const ['charge', 'chargeAmount']));
    final totalOthers = _intValue(_pickFirstValue(others, const ['totalOthers', 'others']));

    final safeNetSales =
        netSales == 0 ? math.max(0, totalSales - returnAmount) : netSales;
    final safeTotalCost =
        totalCost == 0 ? totalPurchase + totalExpense : totalCost;
    final safeGrossProfit =
        grossProfit == 0 ? safeNetSales - totalPurchase : grossProfit;
    final safeNetProfit =
        netProfit == 0 ? safeNetSales - safeTotalCost : netProfit;
    final safeMargin = marginPercent == 0 && safeNetSales > 0
        ? ((safeGrossProfit * 100) / safeNetSales).round()
        : marginPercent;
    final safeProfitRatio = profitRatio == 0 && safeNetSales > 0
        ? ((safeNetProfit * 100) / safeNetSales).round()
        : profitRatio;
    final int safeProfitPercent;
    final int safeCostPercent;
    final int safeOtherPercent;

    if (ratios.isNotEmpty) {
      safeProfitPercent = profitPercent;
      safeCostPercent = costPercent;
      safeOtherPercent = otherPercent;
    } else {
      if (safeNetProfit <= 0) {
        safeProfitPercent = 0;
        safeCostPercent = 100;
        safeOtherPercent = 0;
      } else {
        final totalRatioSum = safeNetProfit + safeTotalCost;
        safeProfitPercent = ((safeNetProfit * 100) / totalRatioSum).round();
        safeCostPercent = ((safeTotalCost * 100) / totalRatioSum).round();
        safeOtherPercent = 100 - safeProfitPercent - safeCostPercent;
      }
    }

    return _RemoteProfitLossReportData(
      totalSales: totalSales,
      returnAmount: returnAmount,
      netSales: safeNetSales,
      totalPurchase: totalPurchase,
      totalExpense: totalExpense,
      totalCost: safeTotalCost,
      grossProfit: safeGrossProfit,
      netProfit: safeNetProfit,
      marginPercent: safeMargin,
      profitRatio: safeProfitRatio,
      profitPercent: safeProfitPercent,
      costPercent: safeCostPercent,
      otherPercent: safeOtherPercent.clamp(0, 100),
      taxAmount: taxAmount,
      chargeAmount: chargeAmount,
      totalOthers: totalOthers,
    );
  }
}

final profitLossReportRemoteProvider = AsyncNotifierProvider.autoDispose
    .family<ProfitLossReportRemoteNotifier, _RemoteProfitLossReportData?, _ProfitLossRequestKey>(
  ProfitLossReportRemoteNotifier.new,
);

class RemoteExpenseReportData {
  const RemoteExpenseReportData({
    required this.summary,
    required this.categoryStats,
    required this.trendPoints,
    required this.paymentMethods,
    required this.recentExpenses,
  });

  final ExpenseSummary summary;
  final List<ExpenseCategoryStat> categoryStats;
  final List<ExpenseTrendPoint> trendPoints;
  final List<ExpensePaymentMethodStat> paymentMethods;
  final List<DokanExpenseRecord> recentExpenses;
}

class ExpenseReportLocalCache {
  static const _prefPrefix = 'dokan_expense_report_cache_';

  static Future<Map<String, dynamic>?> load(DokanExpenseTimeFilter filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefPrefix${filter.name}');
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> save(DokanExpenseTimeFilter filter, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefPrefix${filter.name}', jsonEncode(data));
    } catch (_) {}
  }
}

class RemoteExpenseReportNotifier extends AsyncNotifier<RemoteExpenseReportData?> {
  @override
  Future<RemoteExpenseReportData?> build() async {
    ref.watch(expenseReportControllerProvider);
    final filter = ref.watch(expenseTimeFilterProvider);

    // 1. Try to load from cache
    final cached = await ExpenseReportLocalCache.load(filter);
    if (cached != null) {
      // Trigger background network fetch
      _fetchAndSave(filter);
      return _parse(cached);
    }

    // 2. If no cache, perform remote fetch
    return _fetchAndSave(filter);
  }

  Future<RemoteExpenseReportData?> _fetchAndSave(DokanExpenseTimeFilter filter) async {
    try {
      if (!ref.read(reportConfiguredProvider)) return null;
      final payload = await ref.read(reportRepositoryProvider).fetchReport(
        'expenses-summary',
        filters: {
          ..._reportFiltersFor(
            switch (filter) {
              DokanExpenseTimeFilter.today => DokanReportTimeFilter.today,
              DokanExpenseTimeFilter.thisWeek => DokanReportTimeFilter.thisWeek,
              DokanExpenseTimeFilter.thisMonth => DokanReportTimeFilter.thisMonth,
              DokanExpenseTimeFilter.thisYear => DokanReportTimeFilter.thisYear,
              DokanExpenseTimeFilter.all => DokanReportTimeFilter.all,
            },
          ),
          'limit': 200,
        },
      );
      if (payload.isNotEmpty) {
        await ExpenseReportLocalCache.save(filter, payload);
        final parsed = _parse(payload);
        state = AsyncData(parsed);
        return parsed;
      }
    } catch (_) {}
    return null;
  }

  RemoteExpenseReportData? _parse(Map<String, dynamic> payload) {
    final summaryMap = _mapValue(
          _pickFirstValue(payload, const ['summary', 'kpi', 'totals']),
        ) ??
        payload;
    final trendSummaryMap = _mapValue(payload['trendSummary']) ?? const {};

    final totalAmount = _intValue(
      _pickFirstValue(
        summaryMap,
        const [
          'expense',
          'expenses',
          'totalExpense',
          'totalExpenses',
          'totalAmount'
        ],
      ),
    ).toDouble();
    final transactionCount = _intValue(
      _pickFirstValue(
        summaryMap,
        const ['transactionCount', 'totalTransactions', 'expenseCount', 'count'],
      ),
    );
    final topCategory = _stringValue(
      _pickFirstValue(summaryMap, const ['topCategory', 'category']),
      fallback: 'নেই',
    );
    final rawTopCategoryAmount = _intValue(
      _pickFirstValue(
        summaryMap,
        const ['topCategoryAmount', 'categoryAmount'],
      ),
    ).toDouble();
    final previousAmount = _intValue(
      _pickFirstValue(summaryMap, const ['previousAmount', 'previousExpense']) ??
          _pickFirstValue(
              trendSummaryMap, const ['previousTotal', 'previousAmount']),
    ).toDouble();
    final changePercentVal = _pickFirstValue(
            summaryMap, const ['changePercent', 'change_percentage']) ??
        _pickFirstValue(trendSummaryMap, const ['changePct', 'changePercent']);
    final changePercent = (changePercentVal as num?)?.toDouble() ?? 0;

    final categoryStats = _mapListValue(
      _pickFirstValue(
          payload, const ['categories', 'categoryStats', 'breakdown']),
    )
        .map(
          (item) => ExpenseCategoryStat(
            category: _stringValue(
              _pickFirstValue(item, const ['category', 'name']),
              fallback: 'অন্যান্য',
            ),
            totalAmount: _intValue(
              _pickFirstValue(item, const ['amount', 'total', 'value']),
            ).toDouble(),
            percentage: (_pickFirstValue(
                  item,
                  const ['percentage', 'percent'],
                ) as num?)
                    ?.toDouble() ??
                0,
          ),
        )
        .toList(growable: false);
    final matchingTopCategories =
        categoryStats.where((item) => item.category == topCategory).toList();
    final topCategoryAmount = rawTopCategoryAmount > 0
        ? rawTopCategoryAmount
        : matchingTopCategories.isNotEmpty
            ? matchingTopCategories.first.totalAmount
            : 0.0;

    final trendPoints = _mapListValue(
      _pickFirstValue(payload, const ['trend', 'timeline', 'series']),
    )
        .map(
          (item) => ExpenseTrendPoint(
            label: _stringValue(
              _pickFirstValue(item, const ['label', 'name', 'date']),
              fallback: '-',
            ),
            amount: _intValue(
              _pickFirstValue(item, const ['amount', 'value', 'expense']),
            ).toDouble(),
          ),
        )
        .where((item) => item.label != '-')
        .toList(growable: false);

    final paymentMethods = _mapListValue(
      _pickFirstValue(payload, const ['paymentMethods', 'payment_methods']),
    )
        .map(
          (item) => ExpensePaymentMethodStat(
            method: _stringValue(
              _pickFirstValue(item, const ['method']),
              fallback: 'CASH',
            ),
            label: _stringValue(
              _pickFirstValue(item, const ['label']),
              fallback: 'নগদ',
            ),
            amount: _intValue(
              _pickFirstValue(item, const ['amount']),
            ).toDouble(),
            percentage: (_pickFirstValue(
                  item,
                  const ['percentage', 'percent'],
                ) as num?)
                    ?.toDouble() ??
                0,
          ),
        )
        .toList(growable: false);

    final recentExpenses = _mapListValue(
      _pickFirstValue(
        payload,
        const ['expenses', 'transactions', 'items', 'recentExpenses'],
      ),
    )
        .map(_expenseRecordFromRemoteItem)
        .whereType<DokanExpenseRecord>()
        .toList(growable: false);

    return RemoteExpenseReportData(
      summary: ExpenseSummary(
        totalAmount: totalAmount,
        transactionCount: transactionCount,
        topCategory: topCategory,
        topCategoryAmount: topCategoryAmount,
        previousAmount: previousAmount,
        changePercent: changePercent,
      ),
      categoryStats: categoryStats,
      trendPoints: trendPoints,
      paymentMethods: paymentMethods,
      recentExpenses: recentExpenses,
    );
  }
}

final remoteExpenseReportProvider =
    AsyncNotifierProvider<RemoteExpenseReportNotifier, RemoteExpenseReportData?>(
  RemoteExpenseReportNotifier.new,
);

DokanExpenseRecord? _expenseRecordFromRemoteItem(Map<String, dynamic> item) {
  final id = _stringValue(
    _pickFirstValue(item, const ['id', 'expenseId', 'transactionId']),
  );
  final category = _stringValue(
    _pickFirstValue(item, const ['category', 'categoryName']),
    fallback: 'অন্যান্য',
  );
  final rawDesc = _stringValue(
    _pickFirstValue(item, const ['description', 'title', 'note', 'remarks']),
  );
  final parts = rawDesc.split(' | ');
  final titleVal = parts.isNotEmpty ? parts[0] : '';
  final noteVal = parts.length > 1 ? parts.sublist(1).join(' | ') : '';

  final description = titleVal.isEmpty ? category : titleVal;
  final amount = _intValue(
    _pickFirstValue(item, const ['amount', 'total', 'value']),
  ).toDouble();
  final rawDate = _pickFirstValue(
    item,
    const ['expenseDate', 'date', 'createdAt', 'timestamp'],
  );
  final date = rawDate is DateTime
      ? rawDate
      : DateTime.tryParse(_stringValue(rawDate)) ?? DateTime.now();
  final method = _expensePaymentMethodFromApi(
    _stringValue(_pickFirstValue(item, const ['paymentMethod', 'method'])),
  );
  final status =
      _stringValue(_pickFirstValue(item, const ['status'])).toUpperCase() ==
              'PENDING'
          ? DokanExpenseStatus.pending
          : DokanExpenseStatus.paid;

  if (id.isEmpty && amount <= 0 && description == category) {
    return null;
  }

  return DokanExpenseRecord(
    id: id.isEmpty ? 'remote-${date.millisecondsSinceEpoch}-$category' : id,
    title: description,
    category: category,
    amount: amount,
    date: date,
    note: noteVal.isNotEmpty
        ? noteVal
        : _stringValue(_pickFirstValue(item, const ['note', 'remarks'])),
    receiptLabel: _stringValue(
      _pickFirstValue(item, const ['receiptLabel', 'receipt', 'attachment']),
    ),
    paymentMethod: method,
    status: status,
  );
}

DokanExpensePaymentMethod _expensePaymentMethodFromApi(String value) {
  return switch (value.trim().toUpperCase()) {
    'BKASH' || 'WALLET' => DokanExpensePaymentMethod.bkash,
    'NAGAD' => DokanExpensePaymentMethod.nagad,
    'BANK' || 'CARD' => DokanExpensePaymentMethod.bank,
    _ => DokanExpensePaymentMethod.cash,
  };
}

class _ExpenseReportDashboardBody extends ConsumerWidget {
  const _ExpenseReportDashboardBody();

  int _filterIndex(DokanExpenseTimeFilter filter) {
    return switch (filter) {
      DokanExpenseTimeFilter.today => 0,
      DokanExpenseTimeFilter.thisWeek => 1,
      DokanExpenseTimeFilter.thisMonth => 2,
      DokanExpenseTimeFilter.thisYear => 3,
      DokanExpenseTimeFilter.all => 4,
    };
  }

  DokanExpenseTimeFilter _filterFromIndex(int index) {
    return switch (index) {
      0 => DokanExpenseTimeFilter.today,
      1 => DokanExpenseTimeFilter.thisWeek,
      2 => DokanExpenseTimeFilter.thisMonth,
      3 => DokanExpenseTimeFilter.thisYear,
      _ => DokanExpenseTimeFilter.all,
    };
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DokanExpenseRecord expense,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('খরচ মুছে ফেলবেন?'),
          content: const Text('এই খরচটি স্থায়ীভাবে মুছে যাবে।'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('না'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD43B3B),
                foregroundColor: Colors.white,
              ),
              child: const Text('হ্যাঁ, মুছে ফেলুন'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true || !context.mounted) return;
    await ref
        .read(expenseReportControllerProvider.notifier)
        .deleteExpense(expense.id);
    ref.invalidate(profitLossReportRemoteProvider);
    ref.invalidate(dashboardSummaryProvider);
    if (!context.mounted) return;
    _showReportSnackBar(context, 'খরচ মুছে ফেলা হয়েছে');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExpenses = ref.watch(expenseReportControllerProvider);
    final remoteExpenseAsync = ref.watch(remoteExpenseReportProvider);
    final localSummary = ref.watch(expenseSummaryProvider);
    final localCategoryStats = ref.watch(expenseCategoryStatsProvider);
    final localTrendPoints = ref.watch(expenseTrendProvider);
    final filteredExpenses = ref.watch(filteredExpenseRecordsProvider);
    final selectedFilter = ref.watch(expenseTimeFilterProvider);
    final summary = remoteExpenseAsync.asData?.value?.summary ?? localSummary;
    final categoryStats =
        remoteExpenseAsync.asData?.value?.categoryStats ?? localCategoryStats;
    final trendPoints =
        remoteExpenseAsync.asData?.value?.trendPoints ?? localTrendPoints;
    final paymentMethods = remoteExpenseAsync.asData?.value?.paymentMethods ??
        const <ExpensePaymentMethodStat>[];
    final remoteRecentExpenses =
        remoteExpenseAsync.asData?.value?.recentExpenses ??
            const <DokanExpenseRecord>[];
    final detailExpenses =
        filteredExpenses.isNotEmpty ? filteredExpenses : remoteRecentExpenses;

    if (asyncExpenses.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F8F7),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0C8C67)),
        ),
      );
    }

    if (asyncExpenses.hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F8F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3FAFB),
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          ),
          title: const Text(
            'খরচ রিপোর্ট',
            style: TextStyle(
                color: Color(0xFF00694C), fontWeight: FontWeight.w900),
          ),
        ),
        body: const Center(
          child: Text(
            'খরচের তথ্য লোড করা যায়নি',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final kpis = <_ExpenseSummaryKpi>[
      _ExpenseSummaryKpi(
        label: 'মোট খরচ',
        value: _currency(summary.totalExpense),
        icon: Icons.payments_outlined,
        accent: const Color(0xFF0C8C67),
        trend: summary.changePercent >= 0
            ? '+${_bnDigits(summary.changePercent.abs().round().toString())}%'
            : '-${_bnDigits(summary.changePercent.abs().round().toString())}%',
      ),
      _ExpenseSummaryKpi(
        label: 'লেনদেন',
        value: '${_bnDigits(summary.totalTransactions.toString())}টি',
        icon: Icons.receipt_long_outlined,
        accent: const Color(0xFF2F6BFF),
        trend: 'সক্রিয়',
      ),
      _ExpenseSummaryKpi(
        label: 'শীর্ষ ক্যাটাগরি',
        value: summary.topCategory,
        icon: Icons.category_outlined,
        accent: const Color(0xFFF49B1A),
        trend: 'শীর্ষ',
      ),
      _ExpenseSummaryKpi(
        label: 'পরিবর্তন',
        value:
            '${summary.changePercent >= 0 ? '+' : ''}${_bnDigits(summary.changePercent.abs().round().toString())}%',
        icon: Icons.trending_up_rounded,
        accent: const Color(0xFF9C4DFF),
        trend: 'গত সময়ের তুলনায়',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        centerTitle: true,
        title: const Text(
          'খরচ রিপোর্ট',
          style: TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                    builder: (_) => const DokanExpenseEntryScreen()),
              );
              if (!context.mounted || result != true) return;
              ref.invalidate(expenseReportControllerProvider);
              ref.invalidate(remoteExpenseReportProvider);
              ref.invalidate(profitLossReportRemoteProvider);
              ref.invalidate(dashboardSummaryProvider);
              _showReportSnackBar(context, 'খরচ সংরক্ষণ করা হয়েছে');
            },
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Color(0xFF00694C)),
          ),
          IconButton(
            onPressed: () =>
                _showReportSnackBar(context, 'খরচ রিপোর্ট শেয়ার প্রস্তুত'),
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          if (remoteExpenseAsync.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _RemoteReportLoadingBanner(
                  message: 'খরচের তথ্য লোড হচ্ছে...',
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: ScrollReveal(
                delay: const Duration(milliseconds: 40),
                child: _TimeTabRow(
                  selectedIndex: _filterIndex(selectedFilter),
                  labels: const ['আজ', 'এই সপ্তাহ', 'এই মাস', 'এই বছর', 'সব'],
                  onChanged: (index) => ref
                      .read(expenseTimeFilterProvider.notifier)
                      .setFilter(_filterFromIndex(index)),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: DokanFadeSlideIn(
                child: _SectionCard(
                  title: 'আজকের সারসংক্ষেপ',
                  child: GridView.builder(
                    itemCount: kpis.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.25,
                    ),
                    itemBuilder: (context, index) {
                      final item = kpis[index];
                      return _ExpenseKpiCard(
                        item: item,
                        onTap: () => _handleKpiTap(
                          context,
                          item.label,
                          summary,
                          categoryStats,
                          paymentMethods,
                          detailExpenses,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: ScrollReveal(
                delay: const Duration(milliseconds: 80),
                child: _SectionCard(
                  title: 'ট্রেন্ড অ্যানালিটিক্স',
                  child: Column(
                    children: [
                      _ExpenseTrendChart(points: trendPoints),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          switch (selectedFilter) {
                            DokanExpenseTimeFilter.today => 'আজকের খরচের ট্রেন্ড',
                            DokanExpenseTimeFilter.thisWeek =>
                              'সাপ্তাহিক খরচের ট্রেন্ড',
                            DokanExpenseTimeFilter.thisMonth =>
                              'মাসভিত্তিক খরচের ট্রেন্ড',
                            DokanExpenseTimeFilter.thisYear =>
                              'বার্ষিক খরচের ট্রেন্ড',
                            DokanExpenseTimeFilter.all =>
                              'সব সময়ের খরচের ট্রেন্ড',
                          },
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: ScrollReveal(
                key: ValueKey('expense-list-section-${selectedFilter.name}'),
                delay: const Duration(milliseconds: 120),
                child: _SectionCard(
                  title: 'খরচের বিবরণ তালিকা',
                  child: detailExpenses.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'কোনো খরচের তথ্য পাওয়া যায়নি',
                            style: const TextStyle(
                              color: Color(0xFF5F6A66),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: detailExpenses.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final expense = detailExpenses[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAF9),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE5ECE9)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.title,
                                        style: const TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0C8C67)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              expense.category,
                                              style: const TextStyle(
                                                color: Color(0xFF0C8C67),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2F6BFF)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              expense.paymentMethodLabel,
                                              style: const TextStyle(
                                                color: Color(0xFF2F6BFF),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _expenseDateLabel(expense.date),
                                            style: const TextStyle(
                                              color: Color(0xFF5F6A66),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (expense.note.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          expense.note,
                                          style: const TextStyle(
                                            color: Color(0xFF7F8A86),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedNumberString(
                                      '৳${_bnDigits(expense.amount.round().toString())}',
                                      style: const TextStyle(
                                        color: Color(0xFF0C8C67),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Color(0xFFD43B3B),
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _confirmDelete(context, ref, expense),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 92),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _ReportExportActionButton(
                      label: 'PDF Export',
                      icon: Icons.picture_as_pdf_outlined,
                      onTap: () =>
                          _showReportSnackBar(context, 'PDF রপ্তানি প্রস্তুত'),
                      filled: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ReportExportActionButton(
                      label: 'Excel Export',
                      icon: Icons.grid_on_outlined,
                      onTap: () => _showReportSnackBar(
                          context, 'Excel রপ্তানি প্রস্তুত'),
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const DokanExpenseEntryScreen()),
          );
          if (!context.mounted || result != true) return;
          ref.invalidate(expenseReportControllerProvider);
          ref.invalidate(remoteExpenseReportProvider);
          ref.invalidate(profitLossReportRemoteProvider);
          ref.invalidate(dashboardSummaryProvider);
          _showReportSnackBar(context, 'খরচ সংরক্ষণ করা হয়েছে');
        },
        backgroundColor: const Color(0xFF0C8C67),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'নতুন খরচ',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      bottomNavigationBar: _ReportsBottomNav(selectedIndex: 3),
    );
  }

  void _handleKpiTap(
    BuildContext context,
    String label,
    ExpenseSummary summary,
    List<ExpenseCategoryStat> categoryStats,
    List<ExpensePaymentMethodStat> paymentMethods,
    List<DokanExpenseRecord> filteredExpenses,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: switch (label) {
              'মোট খরচ' || 'লেনদেন' => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'খরচ ও লেনদেনের বিবরণ',
                        style: TextStyle(
                          color: Color(0xFF5F6A66),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _detailRow('মোট খরচ',
                        '৳${_bnDigits(summary.totalExpense.toString())}'),
                    _detailRow('মোট লেনদেন',
                        '${_bnDigits(summary.totalTransactions.toString())}টি'),
                    _detailRow(
                      'গড় খরচ (প্রতি লেনদেন)',
                      '৳${_bnDigits((summary.totalAmount / math.max(1, summary.transactionCount)).round().toString())}',
                    ),
                    _detailRow('পূর্ববর্তী মেয়াদের খরচ',
                        '৳${_bnDigits(summary.previousAmount.round().toString())}'),
                    if (filteredExpenses.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'তারিখভিত্তিক খরচের তালিকা:',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filteredExpenses.map((expense) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAF9),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE5ECE9)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.title,
                                        style: const TextStyle(
                                          color: Color(0xFF111111),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0C8C67)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              expense.category,
                                              style: const TextStyle(
                                                color: Color(0xFF0C8C67),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2F6BFF)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              expense.paymentMethodLabel,
                                              style: const TextStyle(
                                                color: Color(0xFF2F6BFF),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _expenseDateLabel(expense.date),
                                            style: const TextStyle(
                                              color: Color(0xFF5F6A66),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '৳${_bnDigits(expense.amount.round().toString())}',
                                  style: const TextStyle(
                                    color: Color(0xFF0C8C67),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    if (paymentMethods.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'পেমেন্ট মাধ্যম বিশ্লেষণ:',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...paymentMethods.map((pm) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    pm.label,
                                    style: const TextStyle(
                                      color: Color(0xFF111111),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '৳${_bnDigits(pm.amount.round().toString())} (${_bnDigits(pm.percentage.round().toString())}%)',
                                    style: const TextStyle(
                                      color: Color(0xFF2F6BFF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: pm.percentage / 100,
                                  backgroundColor: const Color(0xFFE5ECE9),
                                  color: const Color(0xFF2F6BFF),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              'শীর্ষ ক্যাটাগরি' => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'ক্যাটাগরিভিত্তিক খরচ বিশ্লেষণ',
                        style: TextStyle(
                          color: Color(0xFF5F6A66),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _detailRow('শীর্ষ ক্যাটাগরি',
                        '${summary.topCategory} (৳${_bnDigits(summary.topCategoryAmount.round().toString())})'),
                    const SizedBox(height: 10),
                    const Text(
                      'ক্যাটাগরি তালিকা:',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (categoryStats.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('কোনো ক্যাটাগরি তথ্য নেই'),
                        ),
                      )
                    else
                      ...categoryStats.map((stat) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    stat.category,
                                    style: const TextStyle(
                                      color: Color(0xFF111111),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '৳${_bnDigits(stat.totalAmount.round().toString())} (${_bnDigits(stat.percentage.round().toString())}%)',
                                    style: const TextStyle(
                                      color: Color(0xFF0C8C67),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: stat.percentage / 100,
                                  backgroundColor: const Color(0xFFE5ECE9),
                                  color: const Color(0xFF0C8C67),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              _ => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'খরচের পরিবর্তন বিশ্লেষণ',
                        style: TextStyle(
                          color: Color(0xFF5F6A66),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _detailRow('বর্তমান মেয়াদের খরচ',
                        '৳${_bnDigits(summary.totalExpense.toString())}'),
                    _detailRow('পূর্ববর্তী মেয়াদের খরচ',
                        '৳${_bnDigits(summary.previousAmount.round().toString())}'),
                    _detailRow(
                      'নিট পরিবর্তন',
                      '৳${_bnDigits((summary.totalAmount - summary.previousAmount).abs().round().toString())} '
                          '(${summary.totalAmount - summary.previousAmount >= 0 ? "বৃদ্ধি" : "হ্রাস"})',
                      valueColor:
                          summary.totalAmount - summary.previousAmount >= 0
                              ? const Color(0xFFF49B1A)
                              : const Color(0xFF0C8C67),
                    ),
                    _detailRow(
                      'পরিবর্তনের হার',
                      '${summary.changePercent >= 0 ? '+' : ''}${_bnDigits(summary.changePercent.abs().round().toString())}%',
                      valueColor: summary.changePercent >= 0
                          ? const Color(0xFFF49B1A)
                          : const Color(0xFF0C8C67),
                    ),
                  ],
                ),
            },
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5F6A66),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF111111),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Divider(color: Color(0xFFE5ECE9), height: 16),
        ],
      ),
    );
  }
}
