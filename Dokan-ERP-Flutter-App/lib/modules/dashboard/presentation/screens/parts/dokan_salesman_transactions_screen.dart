import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/auth/auth.dart';
import 'package:dokan_erp/modules/sales/sales.dart';

class _SalesmanPerformance {
  _SalesmanPerformance({
    required this.phone,
    required this.name,
    this.totalSales = 0,
    this.orderCount = 0,
    this.totalProfit = 0,
  });
  final String phone;
  final String name;
  int totalSales;
  int orderCount;
  int totalProfit;
}

class DokanSalesmanTransactionsScreen extends ConsumerStatefulWidget {
  const DokanSalesmanTransactionsScreen({super.key});

  @override
  ConsumerState<DokanSalesmanTransactionsScreen> createState() =>
      _DokanSalesmanTransactionsScreenState();
}

class _DokanSalesmanTransactionsScreenState
    extends ConsumerState<DokanSalesmanTransactionsScreen> {
  String? _selectedSalesmanPhone;
  int _selectedPeriod = 0; // 0 = Today, 1 = This Week, 2 = This Month, 3 = All Time

  String _bengaliDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var result = input;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bengali[i]);
    }
    return result;
  }

  String _bengaliNumber(int number) => _bengaliDigits(number.toString());

  String _translateName(String? name) {
    if (name == null || name.isEmpty) return 'সেলসকর্মী';
    final lower = name.toLowerCase().trim();
    if (lower == 'sakib') return 'সাকিব';
    if (lower == 'shamim') return 'শামীম';
    if (lower == 'owner') return 'মালিক';
    // Capitalize first letter if it's still English
    return name[0].toUpperCase() + name.substring(1);
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'পিএম' : 'এএম';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '${_bengaliDigits(hour.toString())}:${_bengaliDigits(minuteStr)} $period';
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(dokanAppFlowProvider);
    final salesHistory = ref.watch(salesHistoryOrdersProvider).valueOrNull ??
        const <DokanPosOrderRecord>[];

    final today = DateTime.now();

    // Filter sales made by salesmen (not the owner) based on selected period
    final periodSalesOrders = salesHistory.where((order) {
      if (order.status == DokanPosOrderStatus.cancelled) return false;
      if (order.salesmanPhone == null || order.salesmanPhone!.isEmpty) return false;
      if (order.salesmanPhone == flow.ownerPhone) return false;

      final orderDate = DateTime(order.createdAt.year, order.createdAt.month, order.createdAt.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      final difference = todayDate.difference(orderDate).inDays;

      if (_selectedPeriod == 0) {
        // Today
        return difference == 0;
      } else if (_selectedPeriod == 1) {
        // This Week (last 7 days)
        return difference < 7;
      } else if (_selectedPeriod == 2) {
        // This Month (last 30 days)
        return difference < 30;
      } else {
        // All Time
        return true;
      }
    }).toList();

    // Calculate performance statistics for each salesman
    final statsMap = <String, _SalesmanPerformance>{};
    for (final order in periodSalesOrders) {
      final phone = order.salesmanPhone!;
      final name = order.salesmanName ?? phone;
      final stats = statsMap.putIfAbsent(
        phone,
        () => _SalesmanPerformance(phone: phone, name: name),
      );
      stats.totalSales += order.totalAmount;
      stats.orderCount += 1;
      stats.totalProfit += order.grossProfit;
    }

    final performanceList = statsMap.values.toList()
      ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

    // Filter orders list by selected salesman
    final filteredOrders = periodSalesOrders.where((order) {
      if (_selectedSalesmanPhone == null) return true;
      return order.salesmanPhone == _selectedSalesmanPhone;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F6),
      appBar: AppBar(
        title: const Text(
          'কর্মচারী বিক্রয় সমূহ',
          style: TextStyle(
            color: Color(0xFF006B53),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF006B53)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time Period Selector Tab
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPeriodTab(0, 'আজ'),
                  _buildPeriodTab(1, '৭ দিন'),
                  _buildPeriodTab(2, '৩০ দিন'),
                  _buildPeriodTab(3, 'সব সময়'),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Salesman Performance Section
            if (performanceList.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'কর্মচারীদের পারফরম্যান্স',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: performanceList.length,
                  itemBuilder: (context, index) {
                    final stats = performanceList[index];
                    final isSelected = _selectedSalesmanPhone == stats.phone;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Material(
                        color: isSelected ? const Color(0xFF006B53) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        elevation: isSelected ? 4 : 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSalesmanPhone = null;
                              } else {
                                _selectedSalesmanPhone = stats.phone;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF006B53) : const Color(0xFFDCE7E4),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: isSelected ? Colors.white24 : const Color(0xFFE6F4F1),
                                      child: Icon(
                                        Icons.person_outline,
                                        size: 14,
                                        color: isSelected ? Colors.white : const Color(0xFF006B53),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _translateName(stats.name),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '৳ ${_bengaliNumber(stats.totalSales)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: isSelected ? Colors.white : const Color(0xFF006B53),
                                      ),
                                    ),
                                    Text(
                                      '${_bengaliNumber(stats.orderCount)} টি অর্ডার',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white70 : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Sales list header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'বিক্রয় তালিকা',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (_selectedSalesmanPhone != null)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedSalesmanPhone = null;
                        });
                      },
                      icon: const Icon(Icons.clear, size: 14, color: Color(0xFF006B53)),
                      label: const Text(
                        'সব দেখুন',
                        style: TextStyle(
                          color: Color(0xFF006B53),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Orders list
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          Text(
                            _selectedSalesmanPhone == null
                                ? 'এই সময়ে কোনো কর্মচারীর বিক্রয় নেই'
                                : 'এই কর্মচারীর কোনো বিক্রয় নেই',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final itemsCount = order.lines.fold<int>(0, (sum, line) => sum + line.quantity);
                        
                        // Check if the order has a real customer (not walk-in or Guest Customer)
                        final hasCustomer = order.customerName.isNotEmpty &&
                            order.customerName != 'Guest Customer' &&
                            order.customerName != 'Guest' &&
                            order.customerName != 'হাঁটা বিক্রয়' &&
                            order.customerName != 'হাঁটা কাস্টমার' &&
                            order.customerName != 'Walk-in Customer';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFDCE7E4), width: 1),
                          ),
                          elevation: 0,
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showOrderDetailsBottomSheet(context, order),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6F4F1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _translateName(order.salesmanName),
                                          style: const TextStyle(
                                            color: Color(0xFF006B53),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatTime(order.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (hasCustomer) ...[
                                    Text(
                                      order.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    if (order.customerNumber != null && order.customerNumber!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        order.customerNumber!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                                  ] else ...[
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'পণ্য: ${_bengaliNumber(itemsCount)} টি',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '৳ ${_bengaliNumber(order.totalAmount)}',
                                        style: const TextStyle(
                                          color: Color(0xFF006B53),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(int periodIndex, String label) {
    final isSelected = _selectedPeriod == periodIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = periodIndex;
          _selectedSalesmanPhone = null; // Reset selection on period change
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF006B53) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsBottomSheet(BuildContext context, DokanPosOrderRecord order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'বিক্রিত পণ্যের বিবরণ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF163732),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: order.lines.length,
                  itemBuilder: (context, index) {
                    final line = order.lines[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '৳ ${_bengaliNumber(line.unitPrice)} x ${_bengaliNumber(line.quantity)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '৳ ${_bengaliNumber(line.lineTotal)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'মোট পরিমাণ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '৳ ${_bengaliNumber(order.totalAmount)}',
                    style: const TextStyle(
                      color: Color(0xFF0D6B55),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
