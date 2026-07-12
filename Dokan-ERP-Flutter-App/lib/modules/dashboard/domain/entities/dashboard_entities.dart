import '../../../../core/network/json_value.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.todaySales,
    required this.todayOrders,
    required this.todayPurchases,
    required this.todayExpenses,
    required this.todayProfit,
    required this.receivable,
    required this.payable,
    required this.lowStockCount,
    required this.totalProducts,
    required this.salesGrowthPercent,
  });

  final int todaySales;
  final int todayOrders;
  final int todayPurchases;
  final int todayExpenses;
  final int todayProfit;
  final int receivable;
  final int payable;
  final int lowStockCount;
  final int totalProducts;
  final int salesGrowthPercent;

  String get salesComparisonLabel {
    if (salesGrowthPercent == 0) return 'No sales change';
    final direction = salesGrowthPercent > 0 ? 'growth' : 'drop';
    return '${salesGrowthPercent.abs()}% $direction vs previous period';
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final maps = _candidateMaps(json);
    return DashboardSummary(
      todaySales: _int(maps, const [
        'todaySales',
        'today_sales',
        'salesToday',
        'sales_today',
        'sales',
        'revenue',
      ]),
      todayOrders: _int(maps, const [
        'todayOrders',
        'today_orders',
        'ordersToday',
        'orders_today',
        'orderCount',
        'order_count',
        'saleCount',
        'sale_count',
        'salesCount',
        'sales_count',
        'orders',
      ]),
      todayPurchases: _int(maps, const [
        'todayPurchases',
        'today_purchases',
        'purchaseToday',
        'purchase_today',
        'purchases',
      ]),
      todayExpenses: _int(maps, const [
        'todayExpenses',
        'today_expenses',
        'expenseToday',
        'expense_today',
        'expenses',
      ]),
      todayProfit: _int(maps, const [
        'todayProfit',
        'today_profit',
        'profitToday',
        'profit_today',
        'profit',
        'totalProfit',
        'total_profit',
        'netProfit',
        'net_profit',
      ]),
      receivable: _int(maps, const [
        'receivable',
        'totalReceivable',
        'total_receivable',
        'customerDue',
        'customer_due',
      ]),
      payable: _int(maps, const [
        'payable',
        'totalPayable',
        'total_payable',
        'supplierDue',
        'supplier_due',
      ]),
      lowStockCount: _int(maps, const [
        'lowStockCount',
        'low_stock_count',
        'lowStock',
        'low_stock',
      ]),
      totalProducts: _int(maps, const [
        'totalProducts',
        'total_products',
        'productCount',
        'product_count',
        'products',
      ]),
      salesGrowthPercent: _int(maps, const [
        'salesGrowthPercent',
        'sales_growth_percent',
        'growthPercent',
        'growth_percent',
        'salesComparison',
        'sales_comparison',
      ]),
    );
  }

  static List<Map<String, dynamic>> _candidateMaps(Map<String, dynamic> json) {
    final values = <Map<String, dynamic>>[json];
    for (final key in const [
      'today',
      'summary',
      'kpi',
      'kpis',
      'totals',
      'metrics',
      'dashboard',
      'comparison',
    ]) {
      final value = json[key];
      if (value is Map) {
        values.add(value.map((key, item) => MapEntry('$key', item)));
      }
    }
    return values;
  }

  static int _int(List<Map<String, dynamic>> maps, List<String> keys) {
    for (final map in maps) {
      final value = JsonValue.integer(map, keys, fallback: -1);
      if (value != -1) return value;
    }
    return 0;
  }
}

class DashboardActivityEntry {
  const DashboardActivityEntry({
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.type,
  });

  final String title;
  final String subtitle;
  final DateTime createdAt;
  final String type;

  factory DashboardActivityEntry.fromJson(Map<String, dynamic> json) {
    return DashboardActivityEntry(
      title: JsonValue.string(json, const ['title', 'name', 'action']),
      subtitle: JsonValue.string(json, const ['subtitle', 'message', 'note']),
      createdAt: JsonValue.dateTime(
        json,
        const ['createdAt', 'created_at', 'timestamp', 'time'],
      ),
      type: JsonValue.string(json, const ['type', 'kind', 'category']),
    );
  }
}
