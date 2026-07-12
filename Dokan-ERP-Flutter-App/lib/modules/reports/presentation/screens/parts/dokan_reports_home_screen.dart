part of '../reports_screens.dart';

class DokanReportsHomeScreen extends StatelessWidget {
  const DokanReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DokanReportsDashboardScreen();
  }
}

class DokanStockValueReportScreen extends StatelessWidget {
  const DokanStockValueReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DokanStockValueReportPage();
  }
}

class DokanProfitLossReportScreen extends StatelessWidget {
  const DokanProfitLossReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DokanReportsDashboardScreen(
      initialFilter: DokanReportTimeFilter.thisMonth,
      initialBreakdownTab: 2,
    );
  }
}

class DokanDailySalesReportScreen extends StatelessWidget {
  const DokanDailySalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DokanDailySalesReportPage();
  }
}

class DokanReportsDashboardScreen extends ConsumerStatefulWidget {
  const DokanReportsDashboardScreen({
    super.key,
    this.initialFilter,
    this.initialBreakdownTab,
  });

  final DokanReportTimeFilter? initialFilter;
  final int? initialBreakdownTab;

  @override
  ConsumerState<DokanReportsDashboardScreen> createState() =>
      _DokanReportsDashboardScreenState();
}

class _DokanReportsDashboardScreenState
    extends ConsumerState<DokanReportsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(salesHistoryOrdersProvider);
      ref.invalidate(reportDashboardRemoteProvider);
      ref.invalidate(purchaseOrderProvider);
      if (widget.initialFilter != null) {
        ref
            .read(reportFilterProvider.notifier)
            .setFilter(widget.initialFilter!);
      }
      if (widget.initialBreakdownTab != null) {
        ref
            .read(reportBreakdownTabProvider.notifier)
            .setTab(widget.initialBreakdownTab!);
        if (widget.initialBreakdownTab == 1) {
          ref.read(paymentAnalysisTypeProvider.notifier).state = 1;
        } else {
          ref.read(paymentAnalysisTypeProvider.notifier).state = 0;
        }
      }
    });
  }

  Widget _buildTimeFilterRow(DokanReportTimeFilter selected, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ReportChip(
            label: tr('আজকে', 'Today'),
            selected: selected == DokanReportTimeFilter.today,
            onTap: () => ref
                .read(reportFilterProvider.notifier)
                .setFilter(DokanReportTimeFilter.today),
          ),
          const SizedBox(width: 10),
          _ReportChip(
            label: tr('এই সপ্তাহ', 'This Week'),
            selected: selected == DokanReportTimeFilter.thisWeek,
            onTap: () => ref
                .read(reportFilterProvider.notifier)
                .setFilter(DokanReportTimeFilter.thisWeek),
          ),
          const SizedBox(width: 10),
          _ReportChip(
            label: tr('এই মাস', 'This Month'),
            selected: selected == DokanReportTimeFilter.thisMonth,
            onTap: () => ref
                .read(reportFilterProvider.notifier)
                .setFilter(DokanReportTimeFilter.thisMonth),
          ),
          const SizedBox(width: 10),
          _ReportChip(
            label: tr('এই বছর', 'This Year'),
            selected: selected == DokanReportTimeFilter.thisYear,
            onTap: () => ref
                .read(reportFilterProvider.notifier)
                .setFilter(DokanReportTimeFilter.thisYear),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCardGrid(_ReportSummary summary, String monthLabel) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _KpiCard(
          label: tr('মোট বিক্রয়', 'Total Sales'),
          value: _currency(summary.sales.abs()),
          accent: const Color(0xFF0C8C67),
          icon: Icons.payments_outlined,
          subtitle: monthLabel,
        ),
        _KpiCard(
          label: tr('লাভ', 'Profit'),
          value: _currency(summary.profit.abs()),
          accent: const Color(0xFF0C8C67),
          icon: Icons.trending_up_rounded,
          subtitle: tr('নিট মুনাফা', 'Net Profit'),
        ),
        _KpiCard(
          label: tr('ক্রয়', 'Purchase'),
          value: _currency(summary.purchase.abs()),
          accent: const Color(0xFF2F6BFF),
          icon: Icons.shopping_bag_outlined,
          subtitle: tr('পণ্য ক্রয়', 'Product Purchase'),
        ),
        _KpiCard(
          label: tr('খরচ', 'Expense'),
          value: _currency(summary.expense.abs()),
          accent: const Color(0xFFD43B3B),
          icon: Icons.receipt_long_outlined,
          subtitle: tr('চলমান ব্যয়', 'Current Expense'),
        ),
      ],
    );
  }

  Widget _buildHeroSummaryCard(
      _ReportSummary summary, String monthLabel, double growth) {
    return Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  tr('এই মাসের সারসংক্ষেপ', "This Month's Summary"),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  monthLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: tr('বিক্রয়', 'Sales'),
                  value: _currency(summary.sales.abs()),
                ),
              ),
              Container(
                  width: 1, height: 54, color: Colors.white.withOpacity(0.18)),
              Expanded(
                child: _HeroMetric(
                  label: tr('লাভ', 'Profit'),
                  value: _currency(summary.profit.abs()),
                ),
              ),
              Container(
                  width: 1, height: 54, color: Colors.white.withOpacity(0.18)),
              Expanded(
                child: _HeroMetric(
                  label: tr('ক্রয়', 'Purchase'),
                  value: _currency(summary.purchase.abs()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.20),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  tr('বৃদ্ধি', 'Growth'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${_growthTextValue(growth)} ↑',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownTabs(int index, WidgetRef ref) {
    final summary = ref.watch(reportSummaryProvider);
    final filter = ref.watch(reportFilterProvider);

    final filterLabel = switch (filter) {
      DokanReportTimeFilter.today => tr('আজকে', 'Today'),
      DokanReportTimeFilter.thisWeek => tr('এই সপ্তাহ', 'This Week'),
      DokanReportTimeFilter.thisMonth => tr('এই মাস', 'This Month'),
      DokanReportTimeFilter.thisYear => tr('এই বছর', 'This Year'),
      DokanReportTimeFilter.all => tr('সর্বমোট', 'Total'),
    };

    final items = <({
      String label,
      String amount,
      String subtitle,
      IconData icon,
      Color color
    })>[
      (
        label: tr('বিক্রয় রিপোর্ট', 'Sales Report'),
        amount: _currency(summary.sales),
        subtitle: '$filterLabel: ${_currency(summary.sales)}',
        icon: Icons.payments_outlined,
        color: const Color(0xFF0C8C67),
      ),
      (
        label: tr('ক্রয় রিপোর্ট', 'Purchase Report'),
        amount: _currency(summary.purchase),
        subtitle: '$filterLabel: ${_currency(summary.purchase)}',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF2F6BFF),
      ),
      (
        label: tr('লাভ-ক্ষতি', 'Profit & Loss'),
        amount: _currency(summary.profit),
        subtitle: '$filterLabel: ${_currency(summary.profit)}',
        icon: Icons.show_chart_rounded,
        color: const Color(0xFF9C4DFF),
      ),
      (
        label: tr('বাকির রিপোর্ট', 'Due Report'),
        amount: _currency(summary.receivable),
        subtitle:
            tr('মোট বাকি: ', 'Total Due: ') + _currency(summary.receivable),
        icon: Icons.pending_actions_outlined,
        color: const Color(0xFFF49B1A),
      ),
      (
        label: tr('খরচ রিপোর্ট', 'Expense Report'),
        amount: _currency(summary.expense),
        subtitle: '$filterLabel: ${_currency(summary.expense)}',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFE25A4E),
      ),
      (
        label: tr('স্টক রিপোর্ট', 'Stock Report'),
        amount: _bnDigits(summary.totalProducts.toString()) +
            tr('টি পণ্য', ' items'),
        subtitle: tr('মোট পণ্য তালিকা', 'Total product list'),
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF18A999),
      ),
    ];
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, i) {
        return _ReportActionCard(
          label: items[i].label,
          subtitle: items[i].subtitle,
          amount: items[i].amount,
          icon: items[i].icon,
          color: items[i].color,
          selected: index == i,
          onTap: () {
            ref.read(reportBreakdownTabProvider.notifier).setTab(i);
            if (i == 0) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanDailySalesReportScreen(),
                ),
              );
            } else if (i == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanDailyPurchaseReportScreen(),
                ),
              );
            } else if (i == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanStockValueReportScreen(),
                ),
              );
            } else if (i == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanDueManagementScreen(),
                ),
              );
            } else if (i == 4) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanExpenseReportScreen(),
                ),
              );
            } else if (i == 5) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanStockReportScreen(),
                ),
              );
            }
          },
        );
      },
    );
  }

  String _growthText(List<_TrendPoint> trend) {
    if (trend.length < 2) return '০%';
    final first = trend.first.value;
    final last = trend.last.value;
    if (first <= 0) return '+১২%';
    final growth = (((last - first) / first) * 100).round();
    final sign = growth >= 0 ? '+' : '';
    return '$sign${_bnDigits(growth.abs().toString())}%';
  }

  String _growthTextValue(double growth) {
    final rounded = growth.round();
    final sign = rounded >= 0 ? '+' : '-';
    return '$sign${_bnDigits(rounded.abs().toString())}%';
  }

  double _trendGrowthValue(List<_TrendPoint> trend) {
    if (trend.length < 2) return 0;
    final first = trend.first.value;
    final last = trend.last.value;
    if (first <= 0) return 12;
    return ((last - first) / first) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(reportFilterProvider);
    final remoteDashboardAsync = ref.watch(reportDashboardRemoteProvider);
    final summary = ref.watch(reportSummaryProvider);
    final trend = ref.watch(salesTrendProvider);
    final paymentSlices = ref.watch(paymentMethodProvider);
    final topProducts = ref.watch(topProductsProvider);
    final activities = ref.watch(activityLogProvider).take(5).toList();
    final selectedBreakdownIndex = ref.watch(reportBreakdownTabProvider);
    final monthLabel = tr('এই মাস: ', 'This Month: ') +
        '${_monthName(DateTime.now().month)} ${_bnDigits(DateTime.now().year.toString())}';
    final bottomPadding = MediaQuery.of(context).padding.bottom + 8;
    final trendLabel = selectedFilter == DokanReportTimeFilter.today
        ? tr('আজকের ট্রেন্ড', 'Today\'s Trend')
        : selectedFilter == DokanReportTimeFilter.thisWeek
            ? tr('সাপ্তাহিক ট্রেন্ড', 'Weekly Trend')
            : selectedFilter == DokanReportTimeFilter.thisYear
                ? tr('বছরভিত্তিক ট্রেন্ড', 'Yearly Trend')
                : tr('মাসভিত্তিক ট্রেন্ড', 'Monthly Trend');

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
        title: Text(
          tr('রিপোর্ট ও বিশ্লেষণ', 'Reports & Analytics'),
          style: const TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (remoteDashboardAsync.isLoading)
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
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tr('রিপোর্ট ডেটা সিঙ্ক হচ্ছে...',
                                  'Syncing report data...'),
                              style: const TextStyle(
                                color: Color(0xFF3D4943),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (remoteDashboardAsync.hasError)
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
                      child: Text(
                        tr('রিপোর্ট API থেকে ডেটা আনা যায়নি, তাই local summary দেখানো হচ্ছে।',
                            'Could not fetch data from report API, showing local summary instead.'),
                        style: const TextStyle(
                          color: Color(0xFF9F2D20),
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  _SectionCard(
                    title: tr('টাইম ফিল্টার', 'Time Filter'),
                    child: _buildTimeFilterRow(selectedFilter, ref),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: tr('মাসিক সারসংক্ষেপ', 'Monthly Summary'),
                    child: _buildHeroSummaryCard(
                        summary, monthLabel, _trendGrowthValue(trend)),
                  ),
                  const SizedBox(height: 14),
                  _buildKpiCardGrid(summary, monthLabel),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: tr('বিক্রয় ট্রেন্ড', 'Sales Trend'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              trendLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF111111),
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '${_growthText(trend)} ↑',
                              style: const TextStyle(
                                color: Color(0xFF0C8C67),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 190,
                          child: _TrendChart(points: trend),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildBreakdownTabs(selectedBreakdownIndex, ref),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title:
                        tr('পেমেন্ট মেথড বিশ্লেষণ', 'Payment Method Analysis'),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    ref
                                        .read(paymentAnalysisTypeProvider
                                            .notifier)
                                        .state = 0;
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: ref.watch(
                                                  paymentAnalysisTypeProvider) ==
                                              0
                                          ? const Color(0xFF0D6B55)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      tr('বিক্রয়', 'Sales'),
                                      style: TextStyle(
                                        color: ref.watch(
                                                    paymentAnalysisTypeProvider) ==
                                                0
                                            ? Colors.white
                                            : const Color(0xFF556663),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    ref
                                        .read(paymentAnalysisTypeProvider
                                            .notifier)
                                        .state = 1;
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: ref.watch(
                                                  paymentAnalysisTypeProvider) ==
                                              1
                                          ? const Color(0xFF0D6B55)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      tr('ক্রয়', 'Purchase'),
                                      style: TextStyle(
                                        color: ref.watch(
                                                    paymentAnalysisTypeProvider) ==
                                                1
                                            ? Colors.white
                                            : const Color(0xFF556663),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final slice in paymentSlices) ...[
                          _PaymentAnalysisRow(
                            label: slice.label,
                            amount: _currency(slice.amount.abs()),
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
                  _SectionCard(
                    title: tr('সেরা বিক্রয় পণ্য', 'Top Selling Products'),
                    child: Column(
                      children: [
                        for (final product in topProducts)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RankedProductCard(product: product),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: tr('সাম্প্রতিক অ্যাক্টিভিটি', 'Recent Activity'),
                    child: activities.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                tr('কোনো সাম্প্রতিক অ্যাক্টিভিটি পাওয়া যায়নি',
                                    'No recent activity found'),
                                style: const TextStyle(
                                  color: Color(0xFF3D4943),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: activities.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = activities[index];
                              return _ActivityTile(entry: item);
                            },
                          ),
                  ),
                  const SizedBox(height: 4),
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
            onPdf: () => _handlePdfExport(context, ref),
            onExcel: () => _handleExcelExport(context, ref),
            onWhatsApp: () => _handleWhatsAppShare(context, ref),
          ),
          _ReportsBottomNav(selectedIndex: 3),
        ],
      ),
    );
  }

  Future<void> _handlePdfExport(BuildContext context, WidgetRef ref) async {
    final remoteDashboard =
        ref.read(reportDashboardRemoteProvider).asData?.value;
    if (remoteDashboard == null) {
      _showReportSnackBar(
          context, tr('রিপোর্ট ডাটা পাওয়া যায়নি!', 'Report data not found!'));
      return;
    }
    _showReportSnackBar(
        context, tr('PDF রিপোর্ট তৈরি হচ্ছে...', 'Generating PDF report...'));
    try {
      final pdfBytes = await _generateReportsDashboardPdf(remoteDashboard, ref);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'dokan_erp_report.pdf',
      );
    } catch (e) {
      _showReportSnackBar(
          context,
          tr('PDF রিপোর্ট তৈরি করতে ত্রুটি হয়েছে: ', 'Error generating PDF: ') +
              e.toString());
    }
  }

  Future<Uint8List> _generateReportsDashboardPdf(
    _RemoteReportDashboardData data,
    WidgetRef ref,
  ) async {
    await BanglaFontManager().initialize();
    final pdf = pw.Document();
    const fontType = BanglaFontType.kalpurush;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'ডোকান ইআরপি - রিপোর্ট ও বিশ্লেষণ'.fix,
                style:
                    fontType.ts(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 10),

            // Summary KPI
            pw.Text(
              'সামারি কেপিআই (Summary KPI)'.fix,
              style: fontType.ts(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('বিবরণ'.fix,
                            style: fontType.ts(
                                fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('টাকা'.fix,
                            style: fontType.ts(
                                fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('মোট বিক্রয়'.fix,
                            style: fontType.ts(fontSize: 8))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                            '${_bnDigits(data.summary.sales.toString())} টাকা'
                                .fix,
                            style: fontType.ts(fontSize: 8))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('মোট লাভ'.fix,
                            style: fontType.ts(fontSize: 8))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                            '${_bnDigits(data.summary.profit.toString())} টাকা'
                                .fix,
                            style: fontType.ts(fontSize: 8))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('মোট ক্রয়'.fix,
                            style: fontType.ts(fontSize: 8))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                            '${_bnDigits(data.summary.purchase.toString())} টাকা'
                                .fix,
                            style: fontType.ts(fontSize: 8))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('মোট খরচ'.fix,
                            style: fontType.ts(fontSize: 8))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                            '${_bnDigits(data.summary.expense.toString())} টাকা'
                                .fix,
                            style: fontType.ts(fontSize: 8))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('মোট বকেয়া'.fix,
                            style: fontType.ts(fontSize: 8))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                            '${_bnDigits(data.summary.receivable.toString())} টাকা'
                                .fix,
                            style: fontType.ts(fontSize: 8))),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Payment Slices
            pw.Text(
              'পেমেন্ট মেথড বিশ্লেষণ (বিক্রয়)'.fix,
              style: fontType.ts(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('মেথড'.fix,
                            style: fontType.ts(
                                fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('পরিমাণ'.fix,
                            style: fontType.ts(
                                fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                for (final slice in data.payments)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(slice.name.fix,
                              style: fontType.ts(fontSize: 8))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                              '${_bnDigits(slice.amount.toString())} টাকা'.fix,
                              style: fontType.ts(fontSize: 8))),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Top Products
            pw.Text(
              'সেরা বিক্রয় পণ্য (Top Products)'.fix,
              style: fontType.ts(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('পণ্য'.fix,
                            style: fontType.ts(
                                fontSize: 9, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('বিক্রয় সংখ্যা'.fix,
                            style: fontType.ts(
                                fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                for (final prod in data.topProducts)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(prod.name.fix,
                              style: fontType.ts(fontSize: 8))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                              '${_bnDigits(prod.salesCount.toString())}টি'.fix,
                              style: fontType.ts(fontSize: 8))),
                    ],
                  ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _handleExcelExport(BuildContext context, WidgetRef ref) async {
    final remoteDashboard =
        ref.read(reportDashboardRemoteProvider).asData?.value;
    if (remoteDashboard == null) {
      _showReportSnackBar(
          context, tr('রিপোর্ট ডাটা পাওয়া যায়নি!', 'Report data not found!'));
      return;
    }
    _showReportSnackBar(
        context, tr('Excel CSV কপি হচ্ছে...', 'Copying Excel CSV...'));
    try {
      final buffer = StringBuffer();
      buffer.writeln('Dokan ERP Report & Analytics');
      buffer.writeln('Generated at: ${DateTime.now().toIso8601String()}');
      buffer.writeln();
      buffer.writeln('SUMMARY KPI');
      buffer.writeln('Metric,Amount (BDT)');
      buffer.writeln('Total Sales,${remoteDashboard.summary.sales}');
      buffer.writeln('Total Profit,${remoteDashboard.summary.profit}');
      buffer.writeln('Total Purchase,${remoteDashboard.summary.purchase}');
      buffer.writeln('Total Expense,${remoteDashboard.summary.expense}');
      buffer.writeln('Total Receivable,${remoteDashboard.summary.receivable}');
      buffer.writeln();
      buffer.writeln('PAYMENT METHOD (SALES)');
      buffer.writeln('Method,Amount (BDT)');
      for (final slice in remoteDashboard.payments) {
        buffer.writeln('${slice.name},${slice.amount}');
      }
      buffer.writeln();
      buffer.writeln('TOP PRODUCTS');
      buffer.writeln('Product Name,Sales Quantity');
      for (final prod in remoteDashboard.topProducts) {
        buffer.writeln('${prod.name},${prod.salesCount}');
      }

      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      _showReportSnackBar(
          context,
          tr('Excel CSV ডাটা ক্লিপবোর্ডে কপি করা হয়েছে! স্প্রেডশীটে পেস্ট করতে পারবেন।',
              'Excel CSV copied to clipboard!'));
    } catch (e) {
      _showReportSnackBar(
          context,
          tr('Excel ডেটা তৈরিতে ত্রুটি হয়েছে: ', 'Excel copy error: ') +
              e.toString());
    }
  }

  Future<void> _handleWhatsAppShare(BuildContext context, WidgetRef ref) async {
    final remoteDashboard =
        ref.read(reportDashboardRemoteProvider).asData?.value;
    if (remoteDashboard == null) {
      _showReportSnackBar(
          context, tr('রিপোর্ট ডাটা পাওয়া যায়নি!', 'Report data not found!'));
      return;
    }
    try {
      final buffer = StringBuffer();
      buffer.writeln('*ডোকান ইআরপি - রিপোর্ট ও বিশ্লেষণ*');
      buffer.writeln(
          'তারিখ: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
      buffer.writeln();
      buffer.writeln('📊 *সামারি কেপিআই:*');
      buffer.writeln('• মোট বিক্রয়: ৳${remoteDashboard.summary.sales}');
      buffer.writeln('• মোট লাভ: ৳${remoteDashboard.summary.profit}');
      buffer.writeln('• মোট ক্রয়: ৳${remoteDashboard.summary.purchase}');
      buffer.writeln('• মোট খরচ: ৳${remoteDashboard.summary.expense}');
      buffer.writeln('• মোট বকেয়া: ৳${remoteDashboard.summary.receivable}');
      buffer.writeln();
      buffer.writeln('💳 *পেমেন্ট মাধ্যম (বিক্রয়):*');
      for (final slice in remoteDashboard.payments) {
        buffer.writeln('• ${slice.name}: ৳${slice.amount}');
      }
      buffer.writeln();
      buffer.writeln('📦 *সেরা বিক্রয় পণ্য:*');
      for (final prod in remoteDashboard.topProducts) {
        buffer.writeln('• ${prod.name}: ${prod.salesCount} টি');
      }

      final text = buffer.toString();
      final url = 'whatsapp://send?text=${Uri.encodeComponent(text)}';
      final fallbackUrl = 'https://wa.me/?text=${Uri.encodeComponent(text)}';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        await launchUrl(Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: text));
        _showReportSnackBar(
            context,
            tr('হোয়াটসঅ্যাপ পাওয়া যায়নি। টেক্সটটি ক্লিপবোর্ডে কপি করা হয়েছে!',
                'WhatsApp not found. Copied to clipboard!'));
      }
    } catch (e) {
      _showReportSnackBar(
          context,
          tr('WhatsApp শেয়ার করতে ত্রুটি হয়েছে: ', 'Error sharing: ') +
              e.toString());
    }
  }

  double _paymentPercent(int amount, List<_PaymentSlice> slices) {
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.amount.abs());
    if (total <= 0) return 0;
    return amount.abs() / total;
  }
}

void _showReportSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF0C8C67),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
