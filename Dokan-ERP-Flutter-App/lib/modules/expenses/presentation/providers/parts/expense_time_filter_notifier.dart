part of '../expense_provider.dart';

class ExpenseTimeFilterNotifier extends Notifier<DokanExpenseTimeFilter> {
  @override
  DokanExpenseTimeFilter build() => DokanExpenseTimeFilter.today;

  void setFilter(DokanExpenseTimeFilter value) {
    state = value;
  }
}

class ExpenseCategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? value) {
    state = value;
  }
}

class ExpenseSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }
}

final expenseReportControllerProvider =
    AsyncNotifierProvider<DokanExpenseController, List<DokanExpenseRecord>>(
  DokanExpenseController.new,
);

final expenseTimeFilterProvider =
    NotifierProvider<ExpenseTimeFilterNotifier, DokanExpenseTimeFilter>(
  ExpenseTimeFilterNotifier.new,
);

final expenseCategoryFilterProvider =
    NotifierProvider<ExpenseCategoryFilterNotifier, String?>(
  ExpenseCategoryFilterNotifier.new,
);

final expenseSearchQueryProvider =
    NotifierProvider<ExpenseSearchNotifier, String>(
  ExpenseSearchNotifier.new,
);

final filteredExpenseRecordsProvider =
    Provider<List<DokanExpenseRecord>>((Ref ref) {
  final AsyncValue<List<DokanExpenseRecord>> expensesAsync =
      ref.watch(expenseReportControllerProvider);
  final DokanExpenseTimeFilter timeFilter =
      ref.watch(expenseTimeFilterProvider);
  final String categoryFilter =
      ref.watch(expenseCategoryFilterProvider) ?? 'সব';
  final String searchQuery =
      ref.watch(expenseSearchQueryProvider).trim().toLowerCase();
  final List<DokanExpenseRecord> expenses =
      expensesAsync.asData?.value ?? const <DokanExpenseRecord>[];

  return expenses.where((DokanExpenseRecord expense) {
    final bool matchesTime = _matchesTimeFilter(expense.date, timeFilter);
    final bool matchesCategory =
        categoryFilter == 'সব' || expense.category == categoryFilter;
    final bool matchesSearch = searchQuery.isEmpty ||
        expense.title.toLowerCase().contains(searchQuery) ||
        expense.category.toLowerCase().contains(searchQuery) ||
        expense.note.toLowerCase().contains(searchQuery);
    return matchesTime && matchesCategory && matchesSearch;
  }).toList(growable: false);
});

final expenseSummaryProvider = Provider<ExpenseSummary>((Ref ref) {
  final List<DokanExpenseRecord> records =
      ref.watch(filteredExpenseRecordsProvider);
  final double totalAmount = records.fold<double>(
      0, (double sum, DokanExpenseRecord item) => sum + item.amount);
  final int transactionCount = records.length;
  final Map<String, double> categoryTotals = <String, double>{};
  for (final DokanExpenseRecord item in records) {
    categoryTotals.update(item.category, (double value) => value + item.amount,
        ifAbsent: () => item.amount);
  }
  final MapEntry<String, double>? topCategoryEntry =
      categoryTotals.entries.isNotEmpty
          ? categoryTotals.entries.reduce(
              (MapEntry<String, double> a, MapEntry<String, double> b) =>
                  a.value >= b.value ? a : b,
            )
          : null;

  final DokanExpenseTimeFilter timeFilter =
      ref.watch(expenseTimeFilterProvider);
  final List<DokanExpenseRecord> previousRecords =
      _previousPeriodRecords(ref, timeFilter);
  final double previousAmount = previousRecords.fold<double>(
      0, (double sum, DokanExpenseRecord item) => sum + item.amount);
  final double changePercent = previousAmount == 0
      ? (totalAmount == 0 ? 0 : 100)
      : ((totalAmount - previousAmount) / previousAmount) * 100;

  return ExpenseSummary(
    totalAmount: totalAmount,
    transactionCount: transactionCount,
    topCategory: topCategoryEntry?.key ?? 'নেই',
    topCategoryAmount: topCategoryEntry?.value ?? 0,
    previousAmount: previousAmount,
    changePercent: changePercent,
  );
});

final expenseCategoryStatsProvider =
    Provider<List<ExpenseCategoryStat>>((Ref ref) {
  final List<DokanExpenseRecord> records =
      ref.watch(filteredExpenseRecordsProvider);
  if (records.isEmpty) {
    return const <ExpenseCategoryStat>[];
  }
  final Map<String, double> totals = <String, double>{};
  for (final DokanExpenseRecord item in records) {
    totals.update(item.category, (double value) => value + item.amount,
        ifAbsent: () => item.amount);
  }
  final double grandTotal =
      totals.values.fold<double>(0, (double sum, double value) => sum + value);
  return totals.entries.map((MapEntry<String, double> entry) {
    final double percentage =
        grandTotal == 0 ? 0 : (entry.value / grandTotal) * 100;
    return ExpenseCategoryStat(
      category: entry.key,
      totalAmount: entry.value,
      percentage: percentage,
    );
  }).toList()
    ..sort((ExpenseCategoryStat a, ExpenseCategoryStat b) =>
        b.totalAmount.compareTo(a.totalAmount));
});

final expenseTrendProvider = Provider<List<ExpenseTrendPoint>>((Ref ref) {
  final List<DokanExpenseRecord> records =
      ref.watch(filteredExpenseRecordsProvider);
  final DokanExpenseTimeFilter filter = ref.watch(expenseTimeFilterProvider);

  if (records.isEmpty) {
    return const <ExpenseTrendPoint>[];
  }

  switch (filter) {
    case DokanExpenseTimeFilter.today:
      return _buildHourlyTrend(records);
    case DokanExpenseTimeFilter.thisWeek:
      return _buildDailyTrend(records, 7);
    case DokanExpenseTimeFilter.thisMonth:
      return _buildDailyTrend(records, 30);
    case DokanExpenseTimeFilter.thisYear:
      return _buildMonthlyTrend(records);
    case DokanExpenseTimeFilter.all:
      return _buildMonthlyTrend(records);
  }
});

bool _matchesTimeFilter(DateTime date, DokanExpenseTimeFilter filter) {
  final DateTime now = DateTime.now();
  switch (filter) {
    case DokanExpenseTimeFilter.today:
      return DateUtils.isSameDay(date, now);
    case DokanExpenseTimeFilter.thisWeek:
      return now.difference(date).inDays >= 0 &&
          now.difference(date).inDays < 7;
    case DokanExpenseTimeFilter.thisMonth:
      return date.year == now.year && date.month == now.month;
    case DokanExpenseTimeFilter.thisYear:
      return date.year == now.year;
    case DokanExpenseTimeFilter.all:
      return true;
  }
}

List<DokanExpenseRecord> _previousPeriodRecords(
    Ref ref, DokanExpenseTimeFilter filter) {
  final List<DokanExpenseRecord> allRecords =
      ref.read(expenseReportControllerProvider).asData?.value ??
          const <DokanExpenseRecord>[];
  final DateTime now = DateTime.now();

  return allRecords.where((DokanExpenseRecord item) {
    final DateTime date = item.date;
    switch (filter) {
      case DokanExpenseTimeFilter.today:
        return date.day == now.day - 1 &&
            date.month == now.month &&
            date.year == now.year;
      case DokanExpenseTimeFilter.thisWeek:
        return now.difference(date).inDays >= 7 &&
            now.difference(date).inDays < 14;
      case DokanExpenseTimeFilter.thisMonth:
        return date.year == now.year && date.month == now.month - 1;
      case DokanExpenseTimeFilter.thisYear:
        return date.year == now.year - 1;
      case DokanExpenseTimeFilter.all:
        return false;
    }
  }).toList(growable: false);
}

List<ExpenseTrendPoint> _buildHourlyTrend(List<DokanExpenseRecord> records) {
  final Map<int, double> totals = <int, double>{};
  for (final DokanExpenseRecord item in records) {
    totals.update(item.date.hour, (double value) => value + item.amount,
        ifAbsent: () => item.amount);
  }
  final List<int> hours = totals.keys.toList()..sort();
  return hours
      .map((int hour) => ExpenseTrendPoint(
            label: _hourLabel(hour),
            amount: totals[hour] ?? 0,
          ))
      .toList(growable: false);
}

List<ExpenseTrendPoint> _buildDailyTrend(
    List<DokanExpenseRecord> records, int days) {
  final DateTime now = DateTime.now();
  final Map<String, double> totals = <String, double>{};
  for (int index = days - 1; index >= 0; index--) {
    final DateTime day = now.subtract(Duration(days: index));
    totals[_dateKey(day)] = 0;
  }
  for (final DokanExpenseRecord item in records) {
    final String key = _dateKey(item.date);
    if (totals.containsKey(key)) {
      totals[key] = (totals[key] ?? 0) + item.amount;
    }
  }
  return totals.entries
      .map((MapEntry<String, double> entry) => ExpenseTrendPoint(
            label: _compactDateLabel(entry.key),
            amount: entry.value,
          ))
      .toList(growable: false);
}

List<ExpenseTrendPoint> _buildMonthlyTrend(List<DokanExpenseRecord> records) {
  final Map<int, double> totals = <int, double>{};
  for (final DokanExpenseRecord item in records) {
    totals.update(item.date.month, (double value) => value + item.amount,
        ifAbsent: () => item.amount);
  }
  final List<int> months = totals.keys.toList()..sort();
  return months
      .map((int month) => ExpenseTrendPoint(
            label: _monthName(month),
            amount: totals[month] ?? 0,
          ))
      .toList(growable: false);
}

String _hourLabel(int hour) {
  final int normalized = hour % 12 == 0 ? 12 : hour % 12;
  final String suffix = hour >= 12 ? 'PM' : 'AM';
  return '$normalized$suffix';
}

String _dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _compactDateLabel(String key) {
  final List<String> parts = key.split('-');
  if (parts.length != 3) {
    return key;
  }
  final int month = int.tryParse(parts[1]) ?? 1;
  final int day = int.tryParse(parts[2]) ?? 1;
  return '$day/${month.toString().padLeft(2, '0')}';
}

String _monthName(int month) {
  const List<String> names = <String>[
    '',
    'জানু',
    'ফেব',
    'মার্চ',
    'এপ্রি',
    'মে',
    'জুন',
    'জুলা',
    'আগ',
    'সেপ্টে',
    'অক্টো',
    'নভে',
    'ডিসে',
  ];
  return names[month];
}

extension DokanExpenseObjectCompat on Object {
  DokanExpenseRecord? get _asExpense =>
      this is DokanExpenseRecord ? this as DokanExpenseRecord : null;

  String get title => _asExpense?.title ?? '';

  String get name => title;

  String get category => _asExpense?.category ?? '';

  double get amount => _asExpense?.amount ?? 0;

  DateTime get date => _asExpense?.date ?? DateTime.now();

  String get note => _asExpense?.note ?? '';

  String get receiptLabel => _asExpense?.receiptLabel ?? '';

  String get paymentMethodLabel => _asExpense?.paymentMethodLabel ?? '';

  String get statusLabel => _asExpense?.statusLabel ?? '';

  String get dateLabel => _asExpense?.dateLabel ?? '';

  String get amountLabel =>
      '৳${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';

  String get displayAmount => amountLabel;

  Color get color => _asExpense?.statusColor ?? const Color(0xFF0E6D4E);

  IconData get icon => _asExpense?.categoryIcon ?? Icons.receipt_long_outlined;
}
