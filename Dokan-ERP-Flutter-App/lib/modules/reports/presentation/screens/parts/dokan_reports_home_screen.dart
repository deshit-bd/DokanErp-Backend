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
    final isWide = MediaQuery.of(context).size.width >= 720;
    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isWide ? 1.4 : 0.9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        ScrollReveal(
          child: _KpiCard(
            label: tr('মোট বিক্রয়', 'Total Sales'),
            value: _currency(summary.sales.abs()),
            accent: const Color(0xFF0C8C67),
            icon: Icons.payments_outlined,
            subtitle: monthLabel,
          ),
        ),
        ScrollReveal(
          delay: const Duration(milliseconds: 100),
          child: _KpiCard(
            label: tr('লাভ', 'Profit'),
            value: _currency(summary.profit.abs()),
            accent: const Color(0xFF0C8C67),
            icon: Icons.trending_up_rounded,
            subtitle: tr('নিট মুনাফা', 'Net Profit'),
          ),
        ),
        ScrollReveal(
          delay: const Duration(milliseconds: 200),
          child: _KpiCard(
            label: tr('ক্রয়', 'Purchase'),
            value: _currency(summary.purchase.abs()),
            accent: const Color(0xFF2F6BFF),
            icon: Icons.shopping_bag_outlined,
            subtitle: tr('পণ্য ক্রয়', 'Product Purchase'),
          ),
        ),
        ScrollReveal(
          delay: const Duration(milliseconds: 300),
          child: _KpiCard(
            label: tr('খরচ', 'Expense'),
            value: _currency(summary.expense.abs()),
            accent: const Color(0xFFD43B3B),
            icon: Icons.receipt_long_outlined,
            subtitle: tr('চলমান ব্যয়', 'Current Expense'),
          ),
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
    final catalogProducts = ref.watch(dokanInventoryCatalogProvider);

    int totalDamagedCount = 0;
    for (final product in catalogProducts) {
      final history = dokanLocalHistoryFor(product);
      for (final entry in history) {
        if (entry.kind == DokanStockMovementType.loss) {
          final cleanAmount = entry.amount.replaceAll(RegExp(r'[^0-9০-৯]'), '');
          int val = 0;
          for (var i = 0; i < cleanAmount.length; i++) {
            final char = cleanAmount[i];
            const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
            final index = digits.indexOf(char);
            if (index != -1) {
              val = val * 10 + index;
            } else {
              val = val * 10 + (int.tryParse(char) ?? 0);
            }
          }
          totalDamagedCount += val;
        }
      }
    }

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
      (
        label: tr('ড্যামেজ রিপোর্ট', 'Damage Report'),
        amount: _bnDigits(totalDamagedCount.toString()) + tr('টি পণ্য', ' items'),
        subtitle: tr('ক্ষতিগ্রস্ত পণ্য তালিকা', 'Total damaged products'),
        icon: Icons.report_problem_outlined,
        color: const Color(0xFFDC2626),
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
            } else if (i == 6) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanDamageReportScreen(),
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

    final isWide = MediaQuery.of(context).size.width >= 720;

    return DokanResponsivePage(
      selectedIndex: 3,
      child: Scaffold(
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
                  if (remoteDashboardAsync.isLoading && !remoteDashboardAsync.hasValue)
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
                  ScrollReveal(
                    child: _SectionCard(
                      title: tr('টাইম ফিল্টার', 'Time Filter'),
                      child: _buildTimeFilterRow(selectedFilter, ref),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ScrollReveal(
                    child: _SectionCard(
                      title: tr('মাসিক সারসংক্ষেপ', 'Monthly Summary'),
                      child: _buildHeroSummaryCard(
                          summary, monthLabel, _trendGrowthValue(trend)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildKpiCardGrid(summary, monthLabel),
                  const SizedBox(height: 14),
                  ScrollReveal(
                    child: _SectionCard(
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
                  ),
                  const SizedBox(height: 14),
                  ScrollReveal(
                    child: _buildBreakdownTabs(selectedBreakdownIndex, ref),
                  ),
                  const SizedBox(height: 14),
                  ScrollReveal(
                    child: _SectionCard(
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
                  ),
                  const SizedBox(height: 14),
                  ScrollReveal(
                    child: _SectionCard(
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
                  ),
                  const SizedBox(height: 14),
                  ScrollReveal(
                    child: _SectionCard(
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
          if (!isWide) _ReportsBottomNav(selectedIndex: 3),
        ],
      ),
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

class DokanDamageReportScreen extends ConsumerWidget {
  const DokanDamageReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogProducts = ref.watch(dokanInventoryCatalogProvider);

    // 1. Damaged products list
    final damagedProducts = <({DokanCatalogProduct product, int damageQty, List<DokanProductHistoryEntry> damageEntries})>[];
    for (final product in catalogProducts) {
      final history = dokanLocalHistoryFor(product);
      final damageEntries = <DokanProductHistoryEntry>[];
      int prodDamage = 0;
      for (final entry in history) {
        if (entry.kind == DokanStockMovementType.loss) {
          damageEntries.add(entry);
          final cleanAmount = entry.amount.replaceAll(RegExp(r'[^0-9০-৯]'), '');
          int val = 0;
          for (var i = 0; i < cleanAmount.length; i++) {
            final char = cleanAmount[i];
            const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
            final index = digits.indexOf(char);
            if (index != -1) {
              val = val * 10 + index;
            } else {
              val = val * 10 + (int.tryParse(char) ?? 0);
            }
          }
          prodDamage += val;
        }
      }
      if (prodDamage > 0) {
        damagedProducts.add((
          product: product,
          damageQty: prodDamage,
          damageEntries: damageEntries,
        ));
      }
    }
    damagedProducts.sort((a, b) => b.damageQty.compareTo(a.damageQty));

    // 2. Expiry warning alerts (Already expired or within 15 days)
    final today = DateTime.now();
    final expiryAlerts = <({DokanCatalogProduct product, DokanProductBatch batch, int daysLeft})>[];
    for (final product in catalogProducts) {
      for (final batch in product.batches) {
        if (batch.expiryDate != null) {
          final diff = batch.expiryDate!.difference(today).inDays;
          if (diff <= 15) {
            expiryAlerts.add((
              product: product,
              batch: batch,
              daysLeft: diff,
            ));
          }
        }
      }
    }
    expiryAlerts.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    // 3. Time-Period Damage Breakdown (Today, Week, Month, Year)
    final todayStart = DateTime(today.year, today.month, today.day);
    final weekAgo = todayStart.subtract(const Duration(days: 7));

    int todayDamageQty = 0;
    int todayDamageLoss = 0;
    int weekDamageQty = 0;
    int weekDamageLoss = 0;
    int monthDamageQty = 0;
    int monthDamageLoss = 0;
    int yearDamageQty = 0;
    int yearDamageLoss = 0;

    for (final product in catalogProducts) {
      final history = dokanLocalHistoryFor(product);
      for (final entry in history) {
        if (entry.kind == DokanStockMovementType.loss) {
          final cleanAmount = entry.amount.replaceAll(RegExp(r'[^0-9০-৯]'), '');
          int val = 0;
          for (var i = 0; i < cleanAmount.length; i++) {
            final char = cleanAmount[i];
            const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
            final index = digits.indexOf(char);
            if (index != -1) {
              val = val * 10 + index;
            } else {
              val = val * 10 + (int.tryParse(char) ?? 0);
            }
          }
          final cost = product.purchasePrice * val;
          final entryDate = entry.timestamp ?? today;

          if (entryDate.year == today.year &&
              entryDate.month == today.month &&
              entryDate.day == today.day) {
            todayDamageQty += val;
            todayDamageLoss += cost;
          }

          if (entryDate.isAfter(weekAgo) || entryDate.isAtSameMomentAs(weekAgo)) {
            weekDamageQty += val;
            weekDamageLoss += cost;
          }

          if (entryDate.year == today.year && entryDate.month == today.month) {
            monthDamageQty += val;
            monthDamageLoss += cost;
          }

          if (entryDate.year == today.year) {
            yearDamageQty += val;
            yearDamageLoss += cost;
          }
        }
      }
    }

    // 4. Loss Analytics Breakdown
    final categoryLossMap = <String, int>{};
    final reasonLossMap = <String, int>{};
    int totalLossAmount = 0;
    for (final product in catalogProducts) {
      final history = dokanLocalHistoryFor(product);
      for (final entry in history) {
        if (entry.kind == DokanStockMovementType.loss) {
          final cleanAmount = entry.amount.replaceAll(RegExp(r'[^0-9০-৯]'), '');
          int val = 0;
          for (var i = 0; i < cleanAmount.length; i++) {
            final char = cleanAmount[i];
            const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
            final index = digits.indexOf(char);
            if (index != -1) {
              val = val * 10 + index;
            } else {
              val = val * 10 + (int.tryParse(char) ?? 0);
            }
          }
          final cost = product.purchasePrice * val;
          if (cost > 0) {
            totalLossAmount += cost;
            final cat = product.category.isEmpty ? 'অন্যান্য' : product.category;
            categoryLossMap[cat] = (categoryLossMap[cat] ?? 0) + cost;
            final reason = entry.label.trim().isEmpty ? 'ক্ষতিগ্রস্ত' : entry.label.trim();
            reasonLossMap[reason] = (reasonLossMap[reason] ?? 0) + cost;
          }
        }
      }
    }

    final sortedCategoryLoss = categoryLossMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final sortedReasonLoss = reasonLossMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F8F7),
        appBar: AppBar(
          title: const Text(
            'ড্যামেজ ও মেয়াদোত্তীর্ণ',
            style: TextStyle(
              color: Color(0xFF00694C),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          backgroundColor: const Color(0xFFF3FAFB),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF3D4943)),
          bottom: const TabBar(
            labelColor: Color(0xFF00694C),
            unselectedLabelColor: Color(0xFF7C8A84),
            indicatorColor: Color(0xFF00694C),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'ড্যামেজ তালিকা'),
              Tab(text: 'মেয়াদোত্তীর্ণ এলার্ট'),
              Tab(text: 'লোকসান এনালাইটিক্স'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Damage List
            Builder(
              builder: (context) {
                int grandTotalDamageQty = 0;
                int grandTotalDamageLossTaka = 0;

                for (final item in damagedProducts) {
                  grandTotalDamageQty += item.damageQty;
                  grandTotalDamageLossTaka +=
                      (item.damageQty * item.product.purchasePrice);
                }

                if (damagedProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.report_problem_outlined,
                            color: Color(0xFFC2D3CE), size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'কোনো ড্যামেজ বা নষ্ট পণ্য পাওয়া যায়নি',
                          style: TextStyle(
                            color: Color(0xFF5A7572),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary Total Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.analytics_rounded,
                                color: Color(0xFFDC2626), size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'মোট ক্ষতিগ্রস্ত পণ্য',
                                  style: TextStyle(
                                    color: Color(0xFF5A7572),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_bnDigits(grandTotalDamageQty.toString())}টি',
                                  style: const TextStyle(
                                    color: Color(0xFF141F22),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            color: const Color(0xFFE8EFEF),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'মোট আর্থিক ক্ষতি',
                                  style: TextStyle(
                                    color: Color(0xFF991B1B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '৳${_bnDigits(grandTotalDamageLossTaka.toString())}',
                                  style: const TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.65,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _TimeDamageCard(
                          title: 'আজকের ড্যামেজ',
                          qty: '${_bnDigits(todayDamageQty.toString())}টি',
                          amount: '৳${_bnDigits(todayDamageLoss.toString())}',
                          badgeColor: const Color(0xFFDC2626),
                          bgColor: const Color(0xFFFEF2F2),
                        ),
                        _TimeDamageCard(
                          title: 'এই সপ্তাহের ড্যামেজ',
                          qty: '${_bnDigits(weekDamageQty.toString())}টি',
                          amount: '৳${_bnDigits(weekDamageLoss.toString())}',
                          badgeColor: const Color(0xFFEA580C),
                          bgColor: const Color(0xFFFFF7ED),
                        ),
                        _TimeDamageCard(
                          title: 'এই মাসের ড্যামেজ',
                          qty: '${_bnDigits(monthDamageQty.toString())}টি',
                          amount: '৳${_bnDigits(monthDamageLoss.toString())}',
                          badgeColor: const Color(0xFFD97706),
                          bgColor: const Color(0xFFFFFBEB),
                        ),
                        _TimeDamageCard(
                          title: 'এই বছরের ড্যামেজ',
                          qty: '${_bnDigits(yearDamageQty.toString())}টি',
                          amount: '৳${_bnDigits(yearDamageLoss.toString())}',
                          badgeColor: const Color(0xFF0284C7),
                          bgColor: const Color(0xFFF0F9FF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.list_alt_rounded,
                            color: Color(0xFF00694C), size: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'ক্ষতিগ্রস্ত পণ্যের বিস্তারিত তালিকা',
                          style: TextStyle(
                            color: Color(0xFF141F22),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_bnDigits(damagedProducts.length.toString())}টি আইটেম',
                          style: const TextStyle(
                            color: Color(0xFF5A7572),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...damagedProducts.map((item) {
                      final itemLossTaka =
                          item.damageQty * item.product.purchasePrice;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFD9E6E2)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB9C8C3).withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          color: Color(0xFF141F22),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'বারকোড: ${item.product.barcode} | ক্ষতি: ৳${_bnDigits(itemLossTaka.toString())}',
                                        style: const TextStyle(
                                          color: Color(0xFF7C8A84),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'মোট ক্ষতি: ${_bnDigits(item.damageQty.toString())}টি',
                                    style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Color(0xFFE8EFEF)),
                            const SizedBox(height: 8),
                            const Text(
                              'ক্ষতির বিবরণী:',
                              style: TextStyle(
                                color: Color(0xFF5A7572),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...item.damageEntries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '• ${entry.timeLabel}',
                                        style: const TextStyle(
                                          color: Color(0xFF141F22),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      entry.amount,
                                      style: const TextStyle(
                                        color: Color(0xFFDC2626),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),

            // Tab 2: Expiry Alerts List
            expiryAlerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_outlined,
                            color: Color(0xFFC2D3CE), size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'কোনো পণ্য মেয়াদোত্তীর্ণের ঝুঁকিতে নেই',
                          style: TextStyle(
                            color: Color(0xFF5A7572),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: expiryAlerts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = expiryAlerts[index];
                      final isExpired = item.daysLeft <= 0;
                      final alertColor = isExpired ? const Color(0xFFDC2626) : const Color(0xFFF49B1A);
                      final alertBg = isExpired ? const Color(0xFFFEE2E2) : const Color(0xFFFFF4E4);
                      final alertText = isExpired
                          ? 'মেয়াদ উত্তীর্ণ!'
                          : '${_bnDigits(item.daysLeft.toString())} দিন বাকি';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFD9E6E2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      color: Color(0xFF141F22),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'ব্যাচ নম্বর: ${item.batch.batchNo.isEmpty ? 'N/A' : item.batch.batchNo}',
                                    style: const TextStyle(
                                      color: Color(0xFF7C8A84),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'মেয়াদ তারিখ: ${item.batch.expiryDate != null ? "${item.batch.expiryDate!.day}/${item.batch.expiryDate!.month}/${item.batch.expiryDate!.year}" : ""}',
                                    style: const TextStyle(
                                      color: Color(0xFF7C8A84),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: alertBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                alertText,
                                style: TextStyle(
                                  color: alertColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

            // Tab 3: Loss Analytics Breakdown
            totalLossAmount == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.analytics_outlined,
                            color: Color(0xFFC2D3CE), size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'বিশ্লেষণ করার মতো লোকসান ডাটা পাওয়া যায়নি',
                          style: TextStyle(
                            color: Color(0xFF5A7572),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECEA),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'মোট ড্যামেজ লোকসান',
                                style: TextStyle(
                                  color: Color(0xFF991B1B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '৳${_bnDigits(totalLossAmount.toString())}',
                                style: const TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'ক্যাটাগরি ভিত্তিক লোকসান',
                          style: TextStyle(
                            color: Color(0xFF00694C),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...sortedCategoryLoss.map((entry) {
                          final pct = entry.value / totalLossAmount;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: Color(0xFF141F22),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '৳${_bnDigits(entry.value.toString())} (${(pct * 100).toStringAsFixed(1)}%)',
                                      style: const TextStyle(
                                        color: Color(0xFF00694C),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFE8EFEF),
                                    color: const Color(0xFF00694C),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        const Text(
                          'কারণ ভিত্তিক লোকসান',
                          style: TextStyle(
                            color: Color(0xFF00694C),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...sortedReasonLoss.map((entry) {
                          final pct = entry.value / totalLossAmount;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: Color(0xFF141F22),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '৳${_bnDigits(entry.value.toString())} (${(pct * 100).toStringAsFixed(1)}%)',
                                      style: const TextStyle(
                                        color: Color(0xFFE15241),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFE8EFEF),
                                    color: const Color(0xFFE15241),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _TimeDamageCard extends StatelessWidget {
  const _TimeDamageCard({
    required this.title,
    required this.qty,
    required this.amount,
    required this.badgeColor,
    required this.bgColor,
  });

  final String title;
  final String qty;
  final String amount;
  final Color badgeColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                qty,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  amount,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
