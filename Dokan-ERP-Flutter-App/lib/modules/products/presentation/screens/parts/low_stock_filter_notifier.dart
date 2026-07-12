part of '../product_screens.dart';

class _LowStockFilterNotifier extends Notifier<_LowStockAlertFilter> {
  @override
  _LowStockAlertFilter build() => _LowStockAlertFilter.all;

  void setFilter(_LowStockAlertFilter filter) {
    state = filter;
  }
}

final dokanLowStockFilterProvider =
    NotifierProvider<_LowStockFilterNotifier, _LowStockAlertFilter>(
        _LowStockFilterNotifier.new);

_ProductInventoryState _inventoryFallback(DokanCatalogProduct product) {
  return _ProductInventoryState(
    stock: product.stock,
    purchasePrice: product.purchasePrice,
    salePrice: product.salePrice,
    historyEntries: _historyFor(product),
  );
}

_ProductInventoryState _inventoryFor(DokanCatalogProduct product) {
  return _productInventoryStore.putIfAbsent(
      product.barcode, () => _inventoryFallback(product));
}

void _saveInventory(DokanCatalogProduct product, _ProductInventoryState state) {
  _productInventoryStore[product.barcode] = state;
}

enum DokanStockLedgerFilter { all, today, yesterday, thisWeek, thisMonth }

class DokanStockLedgerEntry {
  const DokanStockLedgerEntry({
    required this.type,
    required this.typeLabel,
    required this.productName,
    required this.category,
    required this.timestamp,
    required this.delta,
    required this.stockSnapshot,
    required this.color,
    required this.icon,
    required this.note,
  });

  final DokanStockMovementType type;
  final String typeLabel;
  final String productName;
  final String category;
  final DateTime timestamp;
  final int delta;
  final int stockSnapshot;
  final Color color;
  final IconData icon;
  final String note;
}

class DokanStockLedgerSummary {
  const DokanStockLedgerSummary({
    required this.totalSales,
    required this.todayChange,
    required this.totalPurchase,
  });

  final int totalSales;
  final int todayChange;
  final int totalPurchase;
}

class _StockLedgerFilterNotifier extends Notifier<DokanStockLedgerFilter> {
  @override
  DokanStockLedgerFilter build() => DokanStockLedgerFilter.all;

  void setFilter(DokanStockLedgerFilter filter) {
    state = filter;
  }
}

final stockLedgerFilterProvider =
    NotifierProvider<_StockLedgerFilterNotifier, DokanStockLedgerFilter>(
        _StockLedgerFilterNotifier.new);

final stockLedgerProvider = Provider<List<DokanStockLedgerEntry>>((ref) {
  final products = ref.watch(dokanInventoryCatalogProvider);
  final ledger = <DokanStockLedgerEntry>[];

  for (final product in products) {
    final inventory = _inventoryFor(product);
    final history = List<_ProductHistoryEntry>.from(inventory.historyEntries);
    if (history.isEmpty) {
      continue;
    }

    final orderedHistory = history.reversed.toList(growable: false);
    final totalDelta =
        orderedHistory.fold<int>(0, (sum, entry) => sum + _historyDelta(entry));
    var snapshot = product.stock - totalDelta;
    if (snapshot < 0) {
      snapshot = 0;
    }

    for (var index = 0; index < orderedHistory.length; index++) {
      final entry = orderedHistory[index];
      final delta = _historyDelta(entry);
      snapshot += delta;
      ledger.add(
        DokanStockLedgerEntry(
          type: _historyType(entry),
          typeLabel: _historyTypeLabel(entry),
          productName: product.name,
          category: product.category,
          timestamp: _historyTimestamp(entry, index),
          delta: delta,
          stockSnapshot: snapshot,
          color: entry.color,
          icon: _historyIcon(entry),
          note: entry.timeLabel,
        ),
      );
    }
  }

  ledger.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return ledger;
});

final filteredLogProvider = Provider<List<DokanStockLedgerEntry>>((ref) {
  final filter = ref.watch(stockLedgerFilterProvider);
  final logs = ref.watch(stockLedgerProvider);
  if (filter == DokanStockLedgerFilter.all) {
    return logs;
  }

  final now = DateTime.now();
  final today = DateUtils.dateOnly(now);
  final yesterday = DateUtils.dateOnly(now.subtract(const Duration(days: 1)));
  final startOfWeek =
      DateUtils.dateOnly(now.subtract(Duration(days: now.weekday - 1)));
  final startOfMonth = DateTime(now.year, now.month, 1);

  return logs.where((entry) {
    final entryDate = DateUtils.dateOnly(entry.timestamp);
    switch (filter) {
      case DokanStockLedgerFilter.today:
        return entryDate == today;
      case DokanStockLedgerFilter.yesterday:
        return entryDate == yesterday;
      case DokanStockLedgerFilter.thisWeek:
        return !entryDate.isBefore(startOfWeek);
      case DokanStockLedgerFilter.thisMonth:
        return !entryDate.isBefore(startOfMonth);
      case DokanStockLedgerFilter.all:
        return true;
    }
  }).toList(growable: false);
});

final stockSummaryProvider = Provider<DokanStockLedgerSummary>((ref) {
  final logs = ref.watch(stockLedgerProvider);
  final today = DateUtils.dateOnly(DateTime.now());
  var totalSales = 0;
  var todayChange = 0;
  var totalPurchase = 0;

  for (final entry in logs) {
    if (entry.type == DokanStockMovementType.sale) {
      totalSales += entry.delta.abs();
    }
    if (entry.type == DokanStockMovementType.purchase) {
      totalPurchase += entry.delta.abs();
    }
    if (DateUtils.dateOnly(entry.timestamp) == today) {
      todayChange += entry.delta;
    }
  }

  return DokanStockLedgerSummary(
    totalSales: totalSales,
    todayChange: todayChange,
    totalPurchase: totalPurchase,
  );
});

DateTime _historyTimestamp(_ProductHistoryEntry entry, int orderIndex) {
  final now = DateTime.now();
  final normalized = _latinDigits(entry.timeLabel);
  final match =
      RegExp(r'(\d{1,2})(?::|\.)(\d{2})\s*(AM|PM)', caseSensitive: false)
          .firstMatch(normalized);
  var hour = now.hour;
  var minute = now.minute;
  if (match != null) {
    hour = int.tryParse(match.group(1) ?? '') ?? hour;
    minute = int.tryParse(match.group(2) ?? '') ?? minute;
    final ampm = (match.group(3) ?? 'AM').toUpperCase();
    if (ampm == 'PM' && hour < 12) {
      hour += 12;
    }
    if (ampm == 'AM' && hour == 12) {
      hour = 0;
    }
  }
  if (entry.timestamp != null) {
    return entry.timestamp!;
  }
  if (entry.timeLabel.contains('à¦—à¦¤à¦•à¦¾à¦²')) {
    final day = now.subtract(const Duration(days: 1));
    return DateTime(day.year, day.month, day.day, hour, minute)
        .subtract(Duration(minutes: orderIndex));
  }
  if (entry.timeLabel.contains('à¦†à¦œ')) {
    return DateTime(now.year, now.month, now.day, hour, minute)
        .subtract(Duration(minutes: orderIndex));
  }
  return now.subtract(Duration(minutes: orderIndex * 7 + 3));
}

int _historyDelta(_ProductHistoryEntry entry) {
  final normalized = _latinDigits(entry.amount);
  final match = RegExp(r'([+-]?)\s*(\d+)').firstMatch(normalized);
  final value = int.tryParse(match?.group(2) ?? '') ?? 0;
  if (entry.label.contains('à¦¦à¦¾à¦® à¦ªà¦°à¦¿à¦¬à¦°à§à¦¤à¦¨')) {
    return 0;
  }
  if (match?.group(1) == '-') {
    return -value;
  }
  if (match?.group(1) == '+') {
    return value;
  }
  if (entry.label.contains('à¦¬à¦¿à¦•à§à¦°à¦¯à¦¼') ||
      entry.label.contains('à¦•à¦®à¦¾à¦¨à§‹') ||
      entry.label.contains('à¦•à§à¦·à¦¤à¦¿')) {
    return -value;
  }
  return value;
}

DokanStockMovementType _historyType(_ProductHistoryEntry entry) {
  if (entry.kind != null) return entry.kind!;
  if (entry.label.contains('à¦¬à¦¿à¦•à§à¦°à¦¯à¦¼'))
    return DokanStockMovementType.sale;
  if (entry.label.contains('à¦•à§à¦°à¦¯à¦¼') ||
      entry.label.contains('à¦¸à§à¦Ÿà¦• à¦¯à§‹à¦—')) {
    return DokanStockMovementType.purchase;
  }
  if (entry.label.contains('à¦«à§‡à¦°à¦¤'))
    return DokanStockMovementType.returnItem;
  if (entry.label.contains('à¦•à§à¦·à¦¤à¦¿') ||
      entry.label.contains('à¦•à¦®à¦¾à¦¨à§‹')) {
    return DokanStockMovementType.loss;
  }
  return DokanStockMovementType.manual;
}

String _historyTypeLabel(_ProductHistoryEntry entry) {
  switch (_historyType(entry)) {
    case DokanStockMovementType.sale:
      return 'à¦¬à¦¿à¦•à§à¦°à¦¯à¦¼';
    case DokanStockMovementType.purchase:
      return 'à¦•à§à¦°à¦¯à¦¼';
    case DokanStockMovementType.loss:
      return 'à¦•à§à¦·à¦¤à¦¿';
    case DokanStockMovementType.returnItem:
      return 'à¦°à¦¿à¦Ÿà¦¾à¦°à§à¦¨';
    case DokanStockMovementType.manual:
      return 'à¦®à§à¦¯à¦¾à¦¨à§à¦¯à¦¼à¦¾à¦²';
  }
}

IconData _historyIcon(_ProductHistoryEntry entry) {
  switch (_historyType(entry)) {
    case DokanStockMovementType.sale:
      return Icons.shopping_cart_outlined;
    case DokanStockMovementType.purchase:
      return Icons.inventory_2_outlined;
    case DokanStockMovementType.loss:
      return Icons.warning_amber_rounded;
    case DokanStockMovementType.returnItem:
      return Icons.assignment_return_outlined;
    case DokanStockMovementType.manual:
      return Icons.edit_outlined;
  }
}
