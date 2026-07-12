part of '../reports_screens.dart';

class _ExpenseTrendChart extends StatelessWidget {
  const _ExpenseTrendChart({this.points = const []});

  final List<ExpenseTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: CustomPaint(
        painter: _ExpenseTrendChartPainter(points: points),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ExpenseTrendChartPainter extends CustomPainter {
  const _ExpenseTrendChartPainter({this.points = const []});

  final List<ExpenseTrendPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE7EEEC)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xFF0C8C67)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0C8C67).withOpacity(0.18),
          const Color(0xFF0C8C67).withOpacity(0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (var i = 1; i <= 3; i++) {
      final dy = size.height * (i / 4);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    if (points.isEmpty) {
      return;
    }

    final maxValue = points
        .fold<int>(0, (max, item) => math.max(max, item.value))
        .toDouble();
    final minValue = 0.0;
    final chartPoints = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width * 0.5
          : (size.width / (points.length - 1)) * i;
      final ratio = maxValue <= minValue
          ? 0.5
          : (points[i].value / maxValue).clamp(0.0, 1.0);
      final y = size.height * (0.88 - (ratio * 0.62));
      chartPoints.add(Offset(x, y));
    }

    final path = Path()..moveTo(chartPoints.first.dx, chartPoints.first.dy);
    for (var i = 1; i < chartPoints.length; i++) {
      path.lineTo(chartPoints[i].dx, chartPoints[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF0C8C67);
    for (final point in chartPoints) {
      canvas.drawCircle(point, 4.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExpenseTrendChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

String _expenseDateLabel(DateTime date) {
  const months = <String>[
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];
  return '${_bnDigits(date.day.toString())} ${months[date.month - 1]} ${_bnDigits(date.year.toString())}';
}

class _ExpenseEmptyState extends StatelessWidget {
  const _ExpenseEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF0C8C67),
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5F6A66),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

int min(num a, num b) => a < b ? a.toInt() : b.toInt();

int max(num a, num b) => a > b ? a.toInt() : b.toInt();

class _RemoteStockValueReportData {
  const _RemoteStockValueReportData({
    required this.totalStockValue,
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.categories,
    required this.topProducts,
    required this.deadStocks,
  });

  final int totalStockValue;
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final List<_StockCategoryValue> categories;
  final List<_StockValueProduct> topProducts;
  final List<_DeadStockEntry> deadStocks;
}

const _stockValuePalette = <Color>[
  Color(0xFF0C8C67),
  Color(0xFF2F6BFF),
  Color(0xFFF49B1A),
  Color(0xFF8C5CF6),
  Color(0xFFE25A4E),
  Color(0xFF14B8A6),
];

Color _stockValueColorForIndex(int index) =>
    _stockValuePalette[index % _stockValuePalette.length];

IconData _stockValueIconForCategory(String category) {
  final normalized = category.trim().toLowerCase();
  if (normalized.contains('rice') ||
      normalized.contains('grain') ||
      normalized.contains('চাল') ||
      normalized.contains('ডাল')) {
    return Icons.grain_outlined;
  }
  if (normalized.contains('oil') ||
      normalized.contains('drink') ||
      normalized.contains('তেল') ||
      normalized.contains('পান')) {
    return Icons.local_drink_outlined;
  }
  if (normalized.contains('soap') ||
      normalized.contains('care') ||
      normalized.contains('সাবান')) {
    return Icons.spa_outlined;
  }
  if (normalized.contains('biscuit') ||
      normalized.contains('snack') ||
      normalized.contains('cookie') ||
      normalized.contains('বিস্কুট')) {
    return Icons.cookie_outlined;
  }
  if (normalized.contains('coffee') ||
      normalized.contains('tea') ||
      normalized.contains('beverage')) {
    return Icons.local_cafe_outlined;
  }
  return Icons.inventory_2_outlined;
}

final remoteStockValueReportProvider =
    FutureProvider.autoDispose<_RemoteStockValueReportData?>((ref) async {
  if (!ref.watch(reportConfiguredProvider)) {
    return null;
  }

  final payload =
      await ref.watch(reportRepositoryProvider).fetchReport('stock-value');
  if (payload.isEmpty) {
    return null;
  }

  final summaryMap = _mapValue(
        _pickFirstValue(
            payload, const ['summary', 'overview', 'totals', 'kpi']),
      ) ??
      payload;
  final totalStockValue = _intValue(
    _pickFirstValue(
      summaryMap,
      const [
        'totalStockValue',
        'stockValue',
        'totalValue',
        'valuation',
        'inventoryValue',
      ],
    ),
  );
  final totalProducts = _intValue(
    _pickFirstValue(
      summaryMap,
      const [
        'totalProducts',
        'productCount',
        'productsCount',
        'skuCount',
        'itemsCount',
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
      const [
        'outOfStockCount',
        'outOfStock',
        'stockOutCount',
        'zeroStockCount'
      ],
    ),
  );

  final categoryItems = _mapListValue(
    _pickFirstValue(
      payload,
      const [
        'categories',
        'categoryValues',
        'categoryStats',
        'categoryBreakdown',
        'breakdown',
      ],
    ),
  );
  final categories = categoryItems.indexed.map((entry) {
    final index = entry.$1;
    final item = entry.$2;
    final totalValue = _intValue(
      _pickFirstValue(
        item,
        const ['totalValue', 'value', 'amount', 'stockValue'],
      ),
    );
    final percent =
        (_pickFirstValue(item, const ['percentage', 'percent']) as num?)
                ?.round() ??
            (totalStockValue > 0
                ? ((totalValue * 100) / totalStockValue).round()
                : 0);

    return _StockCategoryValue(
      name: _stringValue(
        _pickFirstValue(item, const ['category', 'name', 'label']),
        fallback: 'অন্যান্য',
      ),
      percent: percent.clamp(0, 100),
      totalValue: totalValue,
      color: _stockValueColorForIndex(index),
    );
  }).toList(growable: false);

  final topProductItems = _mapListValue(
    _pickFirstValue(
      payload,
      const [
        'topProducts',
        'top_products',
        'products',
        'topValueProducts',
        'items',
      ],
    ),
  );
  final topProducts = topProductItems.indexed.map((entry) {
    final index = entry.$1;
    final item = entry.$2;
    final rankValue = _intValue(
      _pickFirstValue(item, const ['rank', 'position', 'serial']),
    );
    final category = _stringValue(
      _pickFirstValue(item, const ['category', 'categoryName']),
      fallback: 'স্টক',
    );
    return _StockValueProduct(
      rank: rankValue > 0 ? rankValue : index + 1,
      name: _stringValue(
        _pickFirstValue(item, const ['name', 'productName', 'title']),
        fallback: 'Unnamed product',
      ),
      value: _intValue(
        _pickFirstValue(
          item,
          const ['value', 'totalValue', 'amount', 'stockValue'],
        ),
      ),
      quantity: _intValue(
        _pickFirstValue(item, const ['quantity', 'qty', 'stock', 'onHand']),
      ),
      category: category,
      icon: _stockValueIconForCategory(category),
      color: _stockValueColorForIndex(index),
    );
  }).toList(growable: false);

  final deadStockItems = _mapListValue(
    _pickFirstValue(
      payload,
      const [
        'deadStocks',
        'deadStock',
        'dead_stock',
        'slowMoving',
        'inactiveProducts',
      ],
    ),
  );
  final deadStocks = deadStockItems
      .map(
        (item) => _DeadStockEntry(
          name: _stringValue(
            _pickFirstValue(item, const ['name', 'productName', 'title']),
            fallback: 'Unnamed product',
          ),
          daysSinceSale: _intValue(
            _pickFirstValue(
              item,
              const ['daysSinceSale', 'daysWithoutSale', 'idleDays', 'days'],
            ),
          ),
        ),
      )
      .where((item) => item.name.trim().isNotEmpty)
      .toList(growable: false);

  return _RemoteStockValueReportData(
    totalStockValue: totalStockValue,
    totalProducts: totalProducts,
    lowStockCount: lowStockCount,
    outOfStockCount: outOfStockCount,
    categories: categories,
    topProducts: topProducts,
    deadStocks: deadStocks,
  );
});

class _DokanInventoryStockReportPage extends ConsumerWidget {
  const _DokanInventoryStockReportPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const categories = <_StockCategoryValue>[
      _StockCategoryValue(
        name: 'চাল-ডাল',
        percent: 38,
        totalValue: 88000,
        color: Color(0xFF0C8C67),
      ),
      _StockCategoryValue(
        name: 'তেল-মসলা',
        percent: 22,
        totalValue: 52600,
        color: Color(0xFF2F6BFF),
      ),
      _StockCategoryValue(
        name: 'সাবান',
        percent: 16,
        totalValue: 42000,
        color: Color(0xFFF49B1A),
      ),
      _StockCategoryValue(
        name: 'পানীয়',
        percent: 14,
        totalValue: 39800,
        color: Color(0xFF8C5CF6),
      ),
      _StockCategoryValue(
        name: 'বিস্কুট',
        percent: 10,
        totalValue: 27900,
        color: Color(0xFFE25A4E),
      ),
    ];

    const topProducts = <_StockValueProduct>[
      _StockValueProduct(
        rank: 1,
        name: 'মিনিকেট চাল ৫ কেজি',
        value: 32200,
        quantity: 48,
        category: 'চাল-ডাল',
        icon: Icons.grain_outlined,
        color: Color(0xFF0C8C67),
      ),
      _StockValueProduct(
        rank: 2,
        name: 'সয়াবিন তেল ১ লিটার',
        value: 18650,
        quantity: 24,
        category: 'তেল-মসলা',
        icon: Icons.local_drink_outlined,
        color: Color(0xFF2F6BFF),
      ),
      _StockValueProduct(
        rank: 3,
        name: 'লাক্স সাবান ১০০ গ্রাম',
        value: 14900,
        quantity: 36,
        category: 'সাবান',
        icon: Icons.spa_outlined,
        color: Color(0xFFF49B1A),
      ),
      _StockValueProduct(
        rank: 4,
        name: 'কোকা কোলা ২৫০মি',
        value: 12800,
        quantity: 28,
        category: 'পানীয়',
        icon: Icons.local_cafe_outlined,
        color: Color(0xFF8C5CF6),
      ),
      _StockValueProduct(
        rank: 5,
        name: 'চিনি ১ কেজি',
        value: 10900,
        quantity: 18,
        category: 'চাল-ডাল',
        icon: Icons.cookie_outlined,
        color: Color(0xFFE25A4E),
      ),
    ];

    const deadStocks = <_DeadStockEntry>[
      _DeadStockEntry(name: 'চকলেট বিস্কুট ৫০ গ্রাম', daysSinceSale: 41),
      _DeadStockEntry(name: 'সয়াবিন তেল পুরনো ব্যাচ', daysSinceSale: 36),
      _DeadStockEntry(name: 'মেয়াদোত্তীর্ণ সাবান প্যাক', daysSinceSale: 53),
    ];

    final remoteStockValueAsync = ref.watch(remoteStockValueReportProvider);
    final remote = remoteStockValueAsync.asData?.value;
    final resolvedTotalStockValue = remote?.totalStockValue ?? 280000;
    final resolvedTotalProducts = remote?.totalProducts ?? 185;
    final resolvedLowStockCount = remote?.lowStockCount ?? 14;
    final resolvedOutOfStockCount = remote?.outOfStockCount ?? 6;
    final resolvedCategories =
        remote?.categories.isNotEmpty == true ? remote!.categories : categories;
    final resolvedTopProducts = remote?.topProducts.isNotEmpty == true
        ? remote!.topProducts
        : topProducts;
    final resolvedDeadStocks =
        remote?.deadStocks.isNotEmpty == true ? remote!.deadStocks : deadStocks;

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
          'স্টক ভ্যালু রিপোর্ট',
          style: TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                _showReportSnackBar(context, 'স্টক রিপোর্ট শেয়ার প্রস্তুত'),
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          if (remoteStockValueAsync.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _RemoteReportLoadingBanner(
                  message: 'Stock value API theke data load hocche...',
                ),
              ),
            ),
          if (remoteStockValueAsync.hasError)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _RemoteReportErrorBanner(
                  message:
                      'Stock value API response pawa jayni, tai local fallback dekhano hocche.',
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                      'মোট স্টক মূল্য',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currency(resolvedTotalStockValue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _StockHeroMiniMetric(
                            label: 'মোট পণ্য',
                            value: _bnDigits(resolvedTotalProducts.toString()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StockHeroMiniMetric(
                            label: 'কম স্টক',
                            value: _bnDigits(resolvedLowStockCount.toString()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StockHeroMiniMetric(
                            label: 'স্টক নেই',
                            value:
                                _bnDigits(resolvedOutOfStockCount.toString()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionCard(
                title: 'ক্যাটাগরি ভিত্তিক মূল্য',
                child: resolvedCategories.isEmpty
                    ? const _ExpenseEmptyState(
                        title: 'ক্যাটাগরি ভ্যালু ডাটা পাওয়া যায়নি',
                        subtitle:
                            'স্টক ভ্যালু API থেকে ক্যাটাগরি ব্রেকডাউন এলে এখানে দেখা যাবে।',
                      )
                    : Column(
                        children: [
                          for (var i = 0;
                              i < resolvedCategories.length;
                              i++) ...[
                            _StockCategoryBarItem(item: resolvedCategories[i]),
                            if (i != resolvedCategories.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionCard(
                title: 'শীর্ষ ৫টি পণ্য (মূল্য অনুযায়ী)',
                child: resolvedTopProducts.isEmpty
                    ? const _ExpenseEmptyState(
                        title: 'Top stock products পাওয়া যায়নি',
                        subtitle:
                            'API response এ ranked product list এলে এখানে দেখানো হবে।',
                      )
                    : ListView.builder(
                        itemCount: resolvedTopProducts.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
                            child: _StockValueProductTile(
                              product: resolvedTopProducts[index],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionCard(
                title: 'ডেড স্টক (৩০+ দিন)',
                child: resolvedDeadStocks.isEmpty
                    ? const _ExpenseEmptyState(
                        title: 'Dead stock list পাওয়া যায়নি',
                        subtitle:
                            'যে পণ্যগুলো অনেকদিন বিক্রি হয়নি, API data এলে এখানে দেখা যাবে।',
                      )
                    : ListView.builder(
                        itemCount: resolvedDeadStocks.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
                            child: _DeadStockTile(
                                entry: resolvedDeadStocks[index]),
                          );
                        },
                      ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReportExportActionButton(
                    label: 'PDF ডাউনলোড',
                    icon: Icons.picture_as_pdf_outlined,
                    onTap: () =>
                        _showReportSnackBar(context, 'PDF ডাউনলোড প্রস্তুত'),
                    filled: true,
                  ),
                  const SizedBox(height: 10),
                  _ReportExportActionButton(
                    label: 'Excel রিপোর্ট',
                    icon: Icons.grid_on_outlined,
                    onTap: () =>
                        _showReportSnackBar(context, 'Excel রিপোর্ট প্রস্তুত'),
                    filled: true,
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
