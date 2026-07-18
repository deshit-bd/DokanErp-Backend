part of '../reports_screens.dart';

enum DokanReportTimeFilter { today, thisWeek, thisMonth, thisYear, all }

class _ReportFilterNotifier extends Notifier<DokanReportTimeFilter> {
  @override
  DokanReportTimeFilter build() => DokanReportTimeFilter.thisMonth;

  void setFilter(DokanReportTimeFilter value) {
    state = value;
  }
}

final reportFilterProvider =
    NotifierProvider<_ReportFilterNotifier, DokanReportTimeFilter>(
        _ReportFilterNotifier.new);

class _ReportBreakdownTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int value) {
    state = value;
  }
}

final reportBreakdownTabProvider =
    NotifierProvider<_ReportBreakdownTabNotifier, int>(
        _ReportBreakdownTabNotifier.new);

class _ReportRecord {
  const _ReportRecord({
    required this.timestamp,
    required this.kind,
    required this.title,
    required this.category,
    required this.paymentMethod,
    required this.quantity,
    required this.salesAmount,
    required this.profitAmount,
    required this.purchaseAmount,
    required this.expenseAmount,
    required this.note,
    required this.icon,
    required this.color,
  });

  final DateTime timestamp;
  final _ReportRecordKind kind;
  final String title;
  final String category;
  final String paymentMethod;
  final int quantity;
  final int salesAmount;
  final int profitAmount;
  final int purchaseAmount;
  final int expenseAmount;
  final String note;
  final IconData icon;
  final Color color;
}

enum _ReportRecordKind { sale, purchase, expense, returnItem, manual }

class _RemoteReportDashboardData {
  const _RemoteReportDashboardData({
    required this.summary,
    required this.trend,
    required this.payments,
    required this.purchasePayments,
    required this.topProducts,
    required this.activities,
    required this.growth,
  });

  final _ReportSummary summary;
  final List<_TrendPoint> trend;
  final List<_PaymentSlice> payments;
  final List<_PaymentSlice> purchasePayments;
  final List<_TopProductStat> topProducts;
  final List<_ActivityEntry> activities;
  final double growth;
}

class _ReportSummary {
  const _ReportSummary({
    required this.sales,
    required this.profit,
    required this.purchase,
    required this.expense,
    required this.receivable,
    required this.totalProducts,
  });

  final int sales;
  final int profit;
  final int purchase;
  final int expense;
  final int receivable;
  final int totalProducts;
}

class _TrendPoint {
  const _TrendPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;
}

class _PaymentSlice {
  const _PaymentSlice({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final int amount;
  final Color color;
  final IconData icon;
}

class _TopProductStat {
  const _TopProductStat({
    required this.rank,
    required this.name,
    required this.salesCount,
    required this.revenue,
    required this.category,
    required this.icon,
    required this.color,
  });

  final int rank;
  final String name;
  final int salesCount;
  final int revenue;
  final String category;
  final IconData icon;
  final Color color;
}

class _ActivityEntry {
  const _ActivityEntry({
    required this.timestamp,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.color,
    required this.icon,
  });

  final DateTime timestamp;
  final String title;
  final String subtitle;
  final String trailing;
  final Color color;
  final IconData icon;
}

String _bnDigits(String input) {
  if (AppStrings.activeLanguage == AppLanguage.english) {
    const map = <String, String>{
      '০': '0',
      '১': '1',
      '২': '2',
      '৩': '3',
      '৪': '4',
      '৫': '5',
      '৬': '6',
      '৭': '7',
      '৮': '8',
      '৯': '9',
    };
    return input.split('').map((char) => map[char] ?? char).join();
  }
  const map = <String, String>{
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };
  return input.split('').map((char) => map[char] ?? char).join();
}

String _currency(int value) => '৳${_bnDigits(value.toString())}';

String _monthName(int month) {
  if (AppStrings.activeLanguage == AppLanguage.english) {
    const names = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
  const names = <String>[
    'জানুয়ারি',
    'ফেব্রুয়ারি',
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
  return names[month - 1];
}

String _formatTime(DateTime dateTime) {
  final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '${_bnDigits(hour12.toString())}:${_bnDigits(dateTime.minute.toString().padLeft(2, '0'))} $suffix';
}

DateTime _startOfWeek(DateTime date) {
  final day = DateUtils.dateOnly(date);
  return day.subtract(Duration(days: day.weekday - 1));
}

bool _matchesFilter(DateTime dateTime, DokanReportTimeFilter filter) {
  final now = DateTime.now();
  final today = DateUtils.dateOnly(now);
  final day = DateUtils.dateOnly(dateTime);
  switch (filter) {
    case DokanReportTimeFilter.today:
      return day == today;
    case DokanReportTimeFilter.thisWeek:
      return !day.isBefore(_startOfWeek(now));
    case DokanReportTimeFilter.thisMonth:
      return day.year == now.year && day.month == now.month;
    case DokanReportTimeFilter.thisYear:
      return day.year == now.year;
    case DokanReportTimeFilter.all:
      return true;
  }
}

List<_ReportRecord> _seedReportRecords() {
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  final threeDaysAgo = now.subtract(const Duration(days: 3));
  final fiveDaysAgo = now.subtract(const Duration(days: 5));
  final sixDaysAgo = now.subtract(const Duration(days: 6));
  final eightDaysAgo = now.subtract(const Duration(days: 8));
  final tenDaysAgo = now.subtract(const Duration(days: 10));
  final fourteenDaysAgo = now.subtract(const Duration(days: 14));
  return <_ReportRecord>[
    _ReportRecord(
      timestamp: DateTime(now.year, now.month, now.day, 9, 40),
      kind: _ReportRecordKind.sale,
      title: 'মিনিকেট চাল ১কেজি বিক্রি',
      category: 'চাল-ডাল',
      paymentMethod: 'নগদ',
      quantity: 12,
      salesAmount: 9600,
      profitAmount: 2040,
      purchaseAmount: 7560,
      expenseAmount: 0,
      note: 'গ্রাহক: করিম সাহেব',
      icon: Icons.shopping_cart_outlined,
      color: const Color(0xFFD43B3B),
    ),
    _ReportRecord(
      timestamp: DateTime(now.year, now.month, now.day, 11, 20),
      kind: _ReportRecordKind.sale,
      title: 'কোকা কোলা ২৫০মি বিক্রি',
      category: 'পানীয়',
      paymentMethod: 'bKash',
      quantity: 18,
      salesAmount: 630,
      profitAmount: 144,
      purchaseAmount: 486,
      expenseAmount: 0,
      note: 'অনলাইন অর্ডার',
      icon: Icons.local_drink_outlined,
      color: const Color(0xFF2F6BFF),
    ),
    _ReportRecord(
      timestamp: DateTime(now.year, now.month, now.day, 14, 5),
      kind: _ReportRecordKind.expense,
      title: 'দোকান খরচ',
      category: 'খরচ',
      paymentMethod: 'নগদ',
      quantity: 0,
      salesAmount: 0,
      profitAmount: 0,
      purchaseAmount: 0,
      expenseAmount: 1240,
      note: 'বিদ্যুৎ ও ভাড়া',
      icon: Icons.receipt_long_outlined,
      color: const Color(0xFF8A8A8A),
    ),
    _ReportRecord(
      timestamp:
          DateTime(yesterday.year, yesterday.month, yesterday.day, 10, 10),
      kind: _ReportRecordKind.sale,
      title: 'সয়াবিন তেল ১লি বিক্রি',
      category: 'তেল-মসলা',
      paymentMethod: 'নগদ',
      quantity: 24,
      salesAmount: 3960,
      profitAmount: 840,
      purchaseAmount: 3120,
      expenseAmount: 0,
      note: 'দোকান ক্রেতা',
      icon: Icons.shopping_bag_outlined,
      color: const Color(0xFF0C8C67),
    ),
    _ReportRecord(
      timestamp:
          DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 45),
      kind: _ReportRecordKind.purchase,
      title: 'নতুন পণ্য ক্রয়',
      category: 'ক্রয়',
      paymentMethod: 'নগদ',
      quantity: 0,
      salesAmount: 0,
      profitAmount: 0,
      purchaseAmount: 7800,
      expenseAmount: 0,
      note: 'সরবরাহকারী: আলম ট্রেডার্স',
      icon: Icons.inventory_2_outlined,
      color: const Color(0xFF0C8C67),
    ),
    _ReportRecord(
      timestamp: now.subtract(const Duration(days: 2, hours: 3)),
      kind: _ReportRecordKind.sale,
      title: 'লাক্স সাবান ১০০গ্রা বিক্রি',
      category: 'সাবান',
      paymentMethod: 'বাকি',
      quantity: 10,
      salesAmount: 580,
      profitAmount: 160,
      purchaseAmount: 420,
      expenseAmount: 0,
      note: 'বাকি হিসেবে যোগ',
      icon: Icons.water_drop_outlined,
      color: const Color(0xFFF49B1A),
    ),
    _ReportRecord(
      timestamp: threeDaysAgo.subtract(const Duration(hours: 5)),
      kind: _ReportRecordKind.returnItem,
      title: 'ফেরত গ্রহণ',
      category: 'রিটার্ন',
      paymentMethod: 'নগদ',
      quantity: 2,
      salesAmount: -190,
      profitAmount: -45,
      purchaseAmount: 0,
      expenseAmount: 0,
      note: 'গ্রাহক ফেরত দিয়েছেন',
      icon: Icons.assignment_return_outlined,
      color: const Color(0xFF2F6BFF),
    ),
    _ReportRecord(
      timestamp: fiveDaysAgo.subtract(const Duration(hours: 2)),
      kind: _ReportRecordKind.sale,
      title: 'চিনি ১কেজি বিক্রি',
      category: 'চাল-ডাল',
      paymentMethod: 'নগদ',
      quantity: 14,
      salesAmount: 1680,
      profitAmount: 210,
      purchaseAmount: 1470,
      expenseAmount: 0,
      note: 'রেগুলার বিক্রয়',
      icon: Icons.shopping_basket_outlined,
      color: const Color(0xFFD43B3B),
    ),
    _ReportRecord(
      timestamp: sixDaysAgo.subtract(const Duration(hours: 1)),
      kind: _ReportRecordKind.manual,
      title: 'স্টক সমন্বয়',
      category: 'ম্যানুয়াল',
      paymentMethod: 'ম্যানুয়াল',
      quantity: 0,
      salesAmount: 0,
      profitAmount: 0,
      purchaseAmount: 0,
      expenseAmount: 0,
      note: 'ভুল এন্ট্রি সংশোধন',
      icon: Icons.edit_outlined,
      color: const Color(0xFF8A8A8A),
    ),
    _ReportRecord(
      timestamp: eightDaysAgo.subtract(const Duration(hours: 3)),
      kind: _ReportRecordKind.sale,
      title: 'বিস্কুট ১ প্যাকেট বিক্রি',
      category: 'বিস্কুট',
      paymentMethod: 'bKash',
      quantity: 20,
      salesAmount: 1200,
      profitAmount: 260,
      purchaseAmount: 940,
      expenseAmount: 0,
      note: 'রেস্টক দরকার',
      icon: Icons.cookie_outlined,
      color: const Color(0xFF0C8C67),
    ),
    _ReportRecord(
      timestamp: tenDaysAgo.subtract(const Duration(hours: 6)),
      kind: _ReportRecordKind.purchase,
      title: 'মিনিকেট চাল ক্রয়',
      category: 'ক্রয়',
      paymentMethod: 'নগদ',
      quantity: 0,
      salesAmount: 0,
      profitAmount: 0,
      purchaseAmount: 12400,
      expenseAmount: 0,
      note: 'নতুন চালান এসেছে',
      icon: Icons.local_shipping_outlined,
      color: const Color(0xFF0C8C67),
    ),
    _ReportRecord(
      timestamp: fourteenDaysAgo.subtract(const Duration(hours: 4)),
      kind: _ReportRecordKind.sale,
      title: 'ডিটারজেন্ট ৫০০গ্রা বিক্রি',
      category: 'সাবান',
      paymentMethod: 'নগদ',
      quantity: 8,
      salesAmount: 680,
      profitAmount: 135,
      purchaseAmount: 545,
      expenseAmount: 0,
      note: 'পুনরায় অর্ডারযোগ্য',
      icon: Icons.cleaning_services_outlined,
      color: const Color(0xFF2F6BFF),
    ),
  ];
}

Map<String, dynamic> _reportFiltersFor(DokanReportTimeFilter filter) {
  final now = DateTime.now();
  final today = DateUtils.dateOnly(now);
  final from = switch (filter) {
    DokanReportTimeFilter.today => today,
    DokanReportTimeFilter.thisWeek => _startOfWeek(now),
    DokanReportTimeFilter.thisMonth => DateTime(now.year, now.month, 1),
    DokanReportTimeFilter.thisYear => DateTime(now.year, 1, 1),
    DokanReportTimeFilter.all => DateTime(2020, 1, 1),
  };
  final to = DateTime(
    today.year,
    today.month,
    today.day,
    23,
    59,
    59,
    999,
  );
  return {
    'from': from.toIso8601String(),
    'to': to.toIso8601String(),
    'range': switch (filter) {
      DokanReportTimeFilter.today => 'today',
      DokanReportTimeFilter.thisWeek => 'week',
      DokanReportTimeFilter.thisMonth => 'month',
      DokanReportTimeFilter.thisYear => 'year',
      DokanReportTimeFilter.all => 'all',
    },
  };
}

Map<String, dynamic> _asStringKeyMap(Map<dynamic, dynamic> input) {
  return input.map((key, value) => MapEntry('$key', value));
}

Map<String, dynamic>? _mapValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return _asStringKeyMap(value);
  }
  return null;
}

List<Map<String, dynamic>> _mapListValue(dynamic value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return value.whereType<Map>().map(_asStringKeyMap).toList(growable: false);
}

dynamic _pickFirstValue(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    if (source.containsKey(key) && source[key] != null) {
      return source[key];
    }
  }
  return null;
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) {
    final normalized = value.replaceAll(',', '').trim();
    return int.tryParse(normalized) ??
        double.tryParse(normalized)?.round() ??
        0;
  }
  return 0;
}

String _stringValue(dynamic value, {String fallback = ''}) {
  final raw = value?.toString().trim() ?? '';
  return raw.isEmpty ? fallback : raw;
}

DateTime _dateValue(dynamic value, {DateTime? fallback}) {
  if (value is DateTime) return value;
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed.toLocal();
  }
  if (value is num) {
    final millis = value > 9999999999 ? value.toInt() : value.toInt() * 1000;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }
  return fallback ?? DateTime.now();
}

String _paymentLabelFromApi(String value) {
  final normalized = value.trim().toLowerCase().replaceAll('_', '-');
  return switch (normalized) {
    'cash' || 'cash-payment' => 'নগদ',
    'bkash' => 'bKash',
    'nagad' => 'Nagad',
    'rocket' => 'Rocket',
    'card' => 'কার্ড',
    'bank' => 'ব্যাংক',
    'due' => 'বাকি',
    _ => value.isEmpty ? 'নগদ' : value,
  };
}

Color _reportColorFromValue(String value, Color fallback) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'success' || 'green' => const Color(0xFF0C8C67),
    'danger' || 'red' => const Color(0xFFD43B3B),
    'warning' || 'orange' => const Color(0xFFF49B1A),
    'info' || 'blue' => const Color(0xFF2F6BFF),
    'purple' => const Color(0xFF9C4DFF),
    _ => fallback,
  };
}

IconData _reportIconForKind(String kind) {
  final normalized = kind.trim().toLowerCase().replaceAll('_', '-');
  return switch (normalized) {
    'sale' || 'sales' => Icons.shopping_cart_outlined,
    'purchase' || 'purchases' => Icons.inventory_2_outlined,
    'expense' || 'expenses' => Icons.receipt_long_outlined,
    'return' || 'refund' => Icons.assignment_return_outlined,
    'stock' => Icons.warehouse_outlined,
    'payment' => Icons.payments_outlined,
    _ => Icons.insights_outlined,
  };
}

_ReportSummary _remoteSummaryFromPayload(Map<String, dynamic> payload) {
  final summary = _mapValue(
        _pickFirstValue(payload, const ['summary', 'kpi', 'totals']),
      ) ??
      payload;
  return _ReportSummary(
    sales: _intValue(
      _pickFirstValue(summary, const ['sales', 'totalSales', 'salesTotal']),
    ),
    profit: _intValue(
      _pickFirstValue(summary, const ['profit', 'netProfit', 'totalProfit']),
    ),
    purchase: _intValue(
      _pickFirstValue(
        summary,
        const ['purchase', 'purchases', 'purchaseTotal'],
      ),
    ),
    expense: _intValue(
      _pickFirstValue(summary, const ['expense', 'expenses', 'expenseTotal']),
    ),
    receivable: _intValue(
      _pickFirstValue(summary, const ['receivable', 'receivables', 'dueTotal']),
    ),
    totalProducts: _intValue(
      _pickFirstValue(
          summary, const ['totalProducts', 'productsCount', 'productCount']),
    ),
  );
}

List<_TrendPoint> _remoteTrendFromPayload(Map<String, dynamic> payload) {
  final items = _mapListValue(
    _pickFirstValue(payload, const ['trend', 'salesTrend', 'timeline']),
  );
  return items
      .map(
        (item) => _TrendPoint(
          label: _stringValue(
            _pickFirstValue(item, const ['label', 'name', 'date']),
            fallback: '-',
          ),
          value: _intValue(
            _pickFirstValue(item, const ['value', 'amount', 'sales']),
          ),
        ),
      )
      .where((item) => item.label != '-')
      .toList(growable: false);
}

List<_PaymentSlice> _remotePaymentsFromPayload(Map<String, dynamic> payload) {
  final items = _mapListValue(
    _pickFirstValue(
      payload,
      const ['paymentMethods', 'paymentBreakdown', 'payment_breakdown'],
    ),
  );
  return items.map(
    (item) {
      final rawLabel = _stringValue(
        _pickFirstValue(item, const ['label', 'method', 'name']),
      );
      final label = _paymentLabelFromApi(rawLabel);
      final color = _reportColorFromValue(
        _stringValue(item['color']),
        switch (label) {
          'bKash' => const Color(0xFF2F6BFF),
          'বাকি' => const Color(0xFFD43B3B),
          _ => const Color(0xFF0C8C67),
        },
      );
      return _PaymentSlice(
        label: label,
        amount: _intValue(
          _pickFirstValue(item, const ['amount', 'value', 'sales']),
        ),
        color: color,
        icon: switch (label) {
          'bKash' => Icons.account_balance_wallet_outlined,
          'বাকি' => Icons.pending_actions_outlined,
          'Nagad' || 'Rocket' => Icons.phone_iphone_outlined,
          'কার্ড' => Icons.credit_card_outlined,
          'ব্যাংক' => Icons.account_balance_outlined,
          _ => Icons.payments_outlined,
        },
      );
    },
  ).toList(growable: false);
}

List<_TopProductStat> _remoteTopProductsFromPayload(
    Map<String, dynamic> payload) {
  final items = _mapListValue(
    _pickFirstValue(payload, const ['topProducts', 'top_products', 'products']),
  );
  return [
    for (var i = 0; i < items.length; i++)
      _TopProductStat(
        rank: i + 1,
        name: _stringValue(
          _pickFirstValue(items[i], const ['name', 'title', 'productName']),
          fallback: 'পণ্য',
        ),
        salesCount: _intValue(
          _pickFirstValue(items[i], const ['quantity', 'salesCount', 'count']),
        ),
        revenue: _intValue(
          _pickFirstValue(
              items[i], const ['revenue', 'amount', 'sales', 'value']),
        ),
        category: _stringValue(
          _pickFirstValue(items[i], const ['category', 'categoryName']),
          fallback: 'বিক্রয়',
        ),
        icon: _reportIconForKind(
          _stringValue(_pickFirstValue(items[i], const ['kind', 'type'])),
        ),
        color: _reportColorFromValue(
          _stringValue(items[i]['color']),
          const Color(0xFF0C8C67),
        ),
      ),
  ];
}

List<_ActivityEntry> _remoteActivitiesFromPayload(
    Map<String, dynamic> payload) {
  final items = _mapListValue(
    _pickFirstValue(
      payload,
      const ['activities', 'recentActivities', 'recent_activity'],
    ),
  );
  return items.map(
    (item) {
      final kind = _stringValue(
        _pickFirstValue(item, const ['kind', 'type', 'category']),
      );
      final accent = _reportColorFromValue(
        _stringValue(item['color']),
        const Color(0xFF0C8C67),
      );
      return _ActivityEntry(
        timestamp: _dateValue(
          _pickFirstValue(item, const ['timestamp', 'createdAt', 'date']),
        ),
        title: _stringValue(
          _pickFirstValue(item, const ['title', 'name']),
          fallback: 'রিপোর্ট অ্যাক্টিভিটি',
        ),
        subtitle: _stringValue(
          _pickFirstValue(item, const ['subtitle', 'description', 'note']),
          fallback: kind.isEmpty ? 'আপডেট' : kind,
        ),
        trailing: _currency(
          _intValue(
            _pickFirstValue(item, const ['amount', 'value', 'sales']),
          ),
        ),
        color: accent,
        icon: _reportIconForKind(kind),
      );
    },
  ).toList(growable: false);
}

_RemoteReportDashboardData _remoteDashboardFromPayload(
  Map<String, dynamic> payload,
) {
  final trendSummary = _mapValue(
        _pickFirstValue(payload, const ['trendSummary', 'trend_summary']),
      ) ??
      const <String, dynamic>{};
  final growth = _intValue(
    _pickFirstValue(trendSummary, const ['changePct', 'salesGrowthPercent']),
  ).toDouble();

  return _RemoteReportDashboardData(
    summary: _remoteSummaryFromPayload(payload),
    trend: _remoteTrendFromPayload(payload),
    payments: _remotePaymentsFromPayload(payload),
    purchasePayments: _remotePurchasePaymentsFromPayload(payload),
    topProducts: _remoteTopProductsFromPayload(payload),
    activities: _remoteActivitiesFromPayload(payload),
    growth: growth,
  );
}

List<_PaymentSlice> _remotePurchasePaymentsFromPayload(
    Map<String, dynamic> payload) {
  final items = _mapListValue(
    _pickFirstValue(
      payload,
      const [
        'purchasePaymentMethods',
        'purchase_payment_methods',
        'purchasePaymentBreakdown'
      ],
    ),
  );
  return items.map(
    (item) {
      final rawLabel = _stringValue(
        _pickFirstValue(item, const ['label', 'method', 'name']),
      );
      final label = _paymentLabelFromApi(rawLabel);
      final color = _reportColorFromValue(
        _stringValue(item['color']),
        switch (label) {
          'bKash' || 'bKash/Nagad/Card' => const Color(0xFF2F6BFF),
          'বাকি' => const Color(0xFFD43B3B),
          _ => const Color(0xFF0C8C67),
        },
      );
      return _PaymentSlice(
        label: label,
        amount: _intValue(
          _pickFirstValue(
              item, const ['amount', 'value', 'sales', 'purchases']),
        ),
        color: color,
        icon: switch (label) {
          'bKash' ||
          'bKash/Nagad/Card' =>
            Icons.account_balance_wallet_outlined,
          'বাকি' => Icons.pending_actions_outlined,
          'Nagad' || 'Rocket' => Icons.phone_iphone_outlined,
          'কার্ড' => Icons.credit_card_outlined,
          'ব্যাংক' => Icons.account_balance_outlined,
          _ => Icons.payments_outlined,
        },
      );
    },
  ).toList(growable: false);
}

String _reportPaymentLabel(String? value) {
  return switch (value) {
    'cash' => 'নগদ',
    'due' => 'বাকি',
    'bkash' => 'bKash',
    'nagad' => 'নগদ',
    'card' => 'কার্ড',
    'rocket' => 'রকেট',
    'bank' => 'ব্যাংক',
    _ => 'নগদ',
  };
}

List<_ReportRecord> _liveSalesReportRecords(List<Map<String, dynamic>> orders) {
  final records = <_ReportRecord>[];
  for (final order in orders) {
    if (order['status'] == 'cancelled') continue;
    final lines =
        (order['lines'] as List?)?.whereType<Map>().toList() ?? const <Map>[];
    if (lines.isEmpty) {
      records.add(
        _ReportRecord(
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            (order['createdAt'] as num?)?.toInt() ?? 0,
          ),
          kind: _ReportRecordKind.sale,
          title:
              ((order['customerName'] as String?)?.trim().isNotEmpty ?? false)
                  ? (order['customerName'] as String).trim()
                  : 'বিক্রয়',
          category: ((order['dueAmount'] as num?)?.toInt() ?? 0) > 0
              ? 'বাকি'
              : 'বিক্রয়',
          paymentMethod: _reportPaymentLabel(order['paymentMethod'] as String?),
          quantity: 1,
          salesAmount: (order['totalAmount'] as num?)?.toInt() ?? 0,
          profitAmount: 0,
          purchaseAmount: 0,
          expenseAmount: 0,
          note: (order['summary'] as String?) ?? '',
          icon: Icons.shopping_cart_outlined,
          color: ((order['status'] as String?) ?? '') == 'due'
              ? const Color(0xFFD43B3B)
              : ((order['status'] as String?) ?? '') == 'partiallyPaid'
                  ? const Color(0xFFF49B1A)
                  : const Color(0xFF0C8C67),
        ),
      );
      continue;
    }
    final orderTotal = (order['totalAmount'] as num?)?.toInt() ?? 0;
    final rawTotal = lines.fold<int>(
      0,
      (sum, raw) =>
          sum +
          ((raw['unitPrice'] as num?)?.toInt() ?? 0) *
              ((raw['quantity'] as num?)?.toInt() ?? 0),
    );
    for (final raw in lines) {
      final line = raw.map((key, value) => MapEntry('$key', value));
      final quantity = (line['quantity'] as num?)?.toInt() ?? 0;
      final unitPrice = (line['unitPrice'] as num?)?.toInt() ?? 0;
      final unitCost = (line['unitCost'] as num?)?.toInt() ?? 0;
      final lineRawTotal = unitPrice * quantity;
      final lineCostTotal = unitCost * quantity;
      final allocatedSales = rawTotal <= 0
          ? lineRawTotal
          : (orderTotal * lineRawTotal / rawTotal).round();
      records.add(
        _ReportRecord(
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            (order['createdAt'] as num?)?.toInt() ?? 0,
          ),
          kind: _ReportRecordKind.sale,
          title: line['productName'] as String? ?? 'বিক্রয়',
          category: 'বিক্রয়',
          paymentMethod: _reportPaymentLabel(order['paymentMethod'] as String?),
          quantity: quantity,
          salesAmount: allocatedSales,
          profitAmount: lineRawTotal - lineCostTotal,
          purchaseAmount: lineCostTotal,
          expenseAmount: 0,
          note: order['summary'] as String? ?? '',
          icon: Icons.shopping_cart_outlined,
          color: const Color(0xFF0C8C67),
        ),
      );
    }
  }
  return records;
}

List<_ReportRecord> _reportRecordsForAnalytics(Ref ref) {
  final liveSales = _liveSalesReportRecords(
    ref.watch(dokanSalesHistorySnapshotProvider),
  );
  final purchases =
      ref.watch(purchaseOrderProvider).asData?.value ?? const <PurchaseOrder>[];
  final purchaseRecords = purchases
      .where((order) => order.status != PurchaseOrderStatus.cancelled)
      .map(
        (order) => _ReportRecord(
          timestamp: order.createdAt,
          kind: _ReportRecordKind.purchase,
          title: order.reference,
          category: 'ক্রয়',
          paymentMethod: 'বাকি',
          quantity: order.lines.fold<int>(
            0,
            (sum, line) => sum + line.orderedQuantity,
          ),
          salesAmount: 0,
          profitAmount: 0,
          purchaseAmount: order.totalAmount,
          expenseAmount: 0,
          note: order.supplierName,
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF0C8C67),
        ),
      );
  final expenses = ref.watch(expenseReportControllerProvider).asData?.value ??
      const <DokanExpenseRecord>[];
  final expenseRecords = expenses.map(
    (expense) => _ReportRecord(
      timestamp: expense.date,
      kind: _ReportRecordKind.expense,
      title: expense.title,
      category: expense.category,
      paymentMethod: expense.paymentMethodLabel,
      quantity: 0,
      salesAmount: 0,
      profitAmount: 0,
      purchaseAmount: 0,
      expenseAmount: expense.amount.round(),
      note: expense.note,
      icon: expense.categoryIcon,
      color: expense.categoryColor,
    ),
  );
  return <_ReportRecord>[
    ...liveSales,
    ...purchaseRecords,
    ...expenseRecords,
  ];
}

/// Provider that exposes all report records for widgets to watch.
final reportRecordsProvider = Provider<List<_ReportRecord>>((ref) {
  return _reportRecordsForAnalytics(ref);
});

List<_ReportRecord> _filteredRecords(
  DokanReportTimeFilter filter,
  Ref ref,
) {
  return _reportRecordsForAnalytics(ref)
      .where((record) => _matchesFilter(record.timestamp, filter))
      .toList(growable: false);
}

final reportSummaryProvider = Provider<_ReportSummary>((ref) {
  final filter = ref.watch(reportFilterProvider);
  final records = _filteredRecords(filter, ref);
  final sales = records
      .fold<int>(0, (sum, record) => sum + record.salesAmount)
      .clamp(-999999, 999999);
  final profit = records
      .fold<int>(0, (sum, record) => sum + record.profitAmount)
      .clamp(-999999, 999999);
  final purchase = records
      .fold<int>(0, (sum, record) => sum + record.purchaseAmount)
      .clamp(-999999, 999999);
  final expense = records
      .fold<int>(0, (sum, record) => sum + record.expenseAmount)
      .clamp(-999999, 999999);
  final receivable = records
      .where((record) => record.paymentMethod == 'বাকি')
      .fold<int>(0, (sum, record) => sum + record.salesAmount)
      .clamp(-999999, 999999);
  final remote = ref.watch(reportDashboardRemoteProvider).asData?.value;

  int totalProducts = 0;
  try {
    totalProducts = ref.read(dokanInventoryCatalogProvider).length;
  } catch (_) {
    totalProducts = records.map((r) => r.title).toSet().length;
  }

  if (remote != null) {
    return _ReportSummary(
      sales: remote.summary.sales,
      profit: records.any((record) => record.kind == _ReportRecordKind.sale)
          ? profit
          : remote.summary.profit,
      purchase: remote.summary.purchase,
      expense: remote.summary.expense,
      receivable: remote.summary.receivable,
      totalProducts: remote.summary.totalProducts == 0
          ? totalProducts
          : remote.summary.totalProducts,
    );
  }

  return _ReportSummary(
    sales: sales,
    profit: profit,
    purchase: purchase,
    expense: expense,
    receivable: receivable,
    totalProducts: totalProducts,
  );
});

final salesTrendProvider = Provider<List<_TrendPoint>>((ref) {
  final remote = ref.watch(reportDashboardRemoteProvider).asData?.value;
  if (remote != null && remote.trend.isNotEmpty) {
    return remote.trend;
  }
  final filter = ref.watch(reportFilterProvider);
  final records = _filteredRecords(filter, ref)
      .where((record) => record.kind == _ReportRecordKind.sale);
  final now = DateTime.now();

  if (filter == DokanReportTimeFilter.today) {
    final byHour = <int, int>{};
    for (final record in records) {
      byHour.update(
          record.timestamp.hour, (value) => value + record.salesAmount,
          ifAbsent: () => record.salesAmount);
    }
    return List<_TrendPoint>.generate(6, (index) {
      final hour = now.hour - (5 - index);
      final hourValue = hour % 24;
      final label = '${_bnDigits(hourValue.toString())}h';
      return _TrendPoint(label: label, value: byHour[hourValue] ?? 0);
    });
  }

  if (filter == DokanReportTimeFilter.thisWeek) {
    final start = _startOfWeek(now);
    return List<_TrendPoint>.generate(7, (index) {
      final day = start.add(Duration(days: index));
      final value = records
          .where((record) =>
              DateUtils.dateOnly(record.timestamp) == DateUtils.dateOnly(day))
          .fold<int>(0, (sum, record) => sum + record.salesAmount);
      const labels = <String>['সো', 'ম', 'ম', 'বু', 'বৃহ', 'শু', 'শনি'];
      return _TrendPoint(label: labels[index], value: value);
    });
  }

  const monthAbbreviations = <String>[
    'জানু',
    'ফেব',
    'মার্চ',
    'এপ্রি',
    'মে',
    'জুন',
    'জুল',
    'আগ',
    'সেপ্ট',
    'অক্টো',
    'নভে',
    'ডিসে',
  ];
  final monthData = <String, int>{};
  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    monthData[monthAbbreviations[month.month - 1]] = 0;
  }
  for (final record in records) {
    final key = monthAbbreviations[record.timestamp.month - 1];
    if (monthData.containsKey(key)) {
      monthData[key] = monthData[key]! + record.salesAmount;
    }
  }
  return monthData.entries
      .map((entry) => _TrendPoint(label: entry.key, value: entry.value))
      .toList(growable: false);
});

final paymentAnalysisTypeProvider = StateProvider<int>((ref) => 0);

final paymentMethodProvider = Provider<List<_PaymentSlice>>((ref) {
  final analysisType = ref.watch(paymentAnalysisTypeProvider);
  final remote = ref.watch(reportDashboardRemoteProvider).asData?.value;

  if (analysisType == 1) {
    if (remote != null && remote.purchasePayments.isNotEmpty) {
      return remote.purchasePayments;
    }
    final filter = ref.watch(reportFilterProvider);
    final records = _filteredRecords(filter, ref)
        .where((record) => record.kind == _ReportRecordKind.purchase);
    final cash = records
        .where((record) =>
            record.paymentMethod == 'নগদ' || record.paymentMethod == 'CASH')
        .fold<int>(0, (sum, record) => sum + record.purchaseAmount);
    final bkash = records
        .where((record) =>
            record.paymentMethod == 'bKash' ||
            record.paymentMethod == 'BKASH' ||
            record.paymentMethod == 'NAGAD' ||
            record.paymentMethod == 'ROCKET')
        .fold<int>(0, (sum, record) => sum + record.purchaseAmount);
    final due = records
        .where((record) =>
            record.paymentMethod == 'বাকি' || record.paymentMethod == 'DUE')
        .fold<int>(0, (sum, record) => sum + record.purchaseAmount);
    return <_PaymentSlice>[
      _PaymentSlice(
        label: 'নগদ',
        amount: cash,
        color: const Color(0xFF0C8C67),
        icon: Icons.payments_outlined,
      ),
      _PaymentSlice(
        label: 'bKash',
        amount: bkash,
        color: const Color(0xFF2F6BFF),
        icon: Icons.account_balance_wallet_outlined,
      ),
      _PaymentSlice(
        label: 'বাকি',
        amount: due,
        color: const Color(0xFFD43B3B),
        icon: Icons.pending_actions_outlined,
      ),
    ];
  } else {
    if (remote != null && remote.payments.isNotEmpty) {
      return remote.payments;
    }
    final filter = ref.watch(reportFilterProvider);
    final records = _filteredRecords(filter, ref)
        .where((record) => record.kind == _ReportRecordKind.sale);
    final cash = records
        .where((record) => record.paymentMethod == 'নগদ')
        .fold<int>(0, (sum, record) => sum + record.salesAmount);
    final bkash = records
        .where((record) => record.paymentMethod == 'bKash')
        .fold<int>(0, (sum, record) => sum + record.salesAmount);
    final due = records
        .where((record) => record.paymentMethod == 'বাকি')
        .fold<int>(0, (sum, record) => sum + record.salesAmount);
    return <_PaymentSlice>[
      _PaymentSlice(
        label: 'নগদ',
        amount: cash,
        color: const Color(0xFF0C8C67),
        icon: Icons.payments_outlined,
      ),
      _PaymentSlice(
        label: 'bKash',
        amount: bkash,
        color: const Color(0xFF2F6BFF),
        icon: Icons.account_balance_wallet_outlined,
      ),
      _PaymentSlice(
        label: 'বাকি',
        amount: due,
        color: const Color(0xFFD43B3B),
        icon: Icons.pending_actions_outlined,
      ),
    ];
  }
});

final topProductsProvider = Provider<List<_TopProductStat>>((ref) {
  final remote = ref.watch(reportDashboardRemoteProvider).asData?.value;
  if (remote != null && remote.topProducts.isNotEmpty) {
    return remote.topProducts;
  }
  final filter = ref.watch(reportFilterProvider);
  final records = _filteredRecords(filter, ref)
      .where((record) => record.kind == _ReportRecordKind.sale)
      .toList(growable: false);
  final grouped = <String, _TopProductStat>{};

  for (final record in records) {
    final existing = grouped[record.title];
    if (existing == null) {
      grouped[record.title] = _TopProductStat(
        rank: 0,
        name: record.title,
        salesCount: record.quantity,
        revenue: record.salesAmount,
        category: record.category,
        icon: record.icon,
        color: record.color,
      );
    } else {
      grouped[record.title] = _TopProductStat(
        rank: 0,
        name: record.title,
        salesCount: existing.salesCount + record.quantity,
        revenue: existing.revenue + record.salesAmount,
        category: record.category,
        icon: record.icon,
        color: record.color,
      );
    }
  }

  final sorted = grouped.values.toList()
    ..sort((a, b) => b.revenue.compareTo(a.revenue));

  return [
    for (var i = 0; i < math.min(5, sorted.length); i++)
      _TopProductStat(
        rank: i + 1,
        name: sorted[i].name,
        salesCount: sorted[i].salesCount,
        revenue: sorted[i].revenue,
        category: sorted[i].category,
        icon: sorted[i].icon,
        color: sorted[i].color,
      ),
  ];
});

final activityLogProvider = Provider<List<_ActivityEntry>>((ref) {
  final remote = ref.watch(reportDashboardRemoteProvider).asData?.value;
  if (remote != null && remote.activities.isNotEmpty) {
    return remote.activities;
  }
  final filter = ref.watch(reportFilterProvider);
  final records = _filteredRecords(filter, ref).toList(growable: false)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return records
      .map(
        (record) => _ActivityEntry(
          timestamp: record.timestamp,
          title: record.title,
          subtitle: '${record.category} • ${record.note}',
          trailing: record.kind == _ReportRecordKind.expense
              ? _currency(record.expenseAmount)
              : record.kind == _ReportRecordKind.purchase
                  ? _currency(record.purchaseAmount)
                  : _currency(record.salesAmount.abs()),
          color: record.color,
          icon: record.icon,
        ),
      )
      .toList(growable: false);
});

final reportDashboardRemoteProvider =
    FutureProvider<_RemoteReportDashboardData?>((ref) async {
  ref.keepAlive();
  if (!ref.watch(reportConfiguredProvider)) {
    return null;
  }
  final filter = ref.watch(reportFilterProvider);
  final payload = await ref.watch(reportRepositoryProvider).fetchReport(
        'dashboard',
        filters: _reportFiltersFor(filter),
      );
  if (payload.isEmpty) {
    return null;
  }
  return _remoteDashboardFromPayload(payload);
});
