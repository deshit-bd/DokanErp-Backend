import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/auth/auth.dart';
import 'package:dokan_erp/modules/sales/sales.dart';

class DokanSalesmanTransactionsScreen extends ConsumerStatefulWidget {
  const DokanSalesmanTransactionsScreen({super.key});

  @override
  ConsumerState<DokanSalesmanTransactionsScreen> createState() =>
      _DokanSalesmanTransactionsScreenState();
}

class _DokanSalesmanTransactionsScreenState
    extends ConsumerState<DokanSalesmanTransactionsScreen> {
  String? _selectedSalesmanPhone;

  String _bengaliNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var input = number.toString();
    for (var i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], bengali[i]);
    }
    return input;
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${_bengaliNumber(hour)}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(dokanAppFlowProvider);
    final salesHistory = ref.watch(salesHistoryOrdersProvider).valueOrNull ??
        const <DokanPosOrderRecord>[];

    // Filter today's sales made by salesmen (not the owner)
    final today = DateTime.now();
    final todaySalesOrders = salesHistory
        .where((order) =>
            order.createdAt.year == today.year &&
            order.createdAt.month == today.month &&
            order.createdAt.day == today.day &&
            order.status != DokanPosOrderStatus.cancelled &&
            order.salesmanPhone != null &&
            order.salesmanPhone!.isNotEmpty &&
            order.salesmanPhone != flow.ownerPhone)
        .toList();

    // Get unique salesmen list from today's orders
    final salesmenMap = <String, String>{};
    for (final order in todaySalesOrders) {
      if (order.salesmanPhone != null) {
        salesmenMap[order.salesmanPhone!] = order.salesmanName ?? order.salesmanPhone!;
      }
    }

    // Filter by selected salesman
    final filteredOrders = todaySalesOrders.where((order) {
      if (_selectedSalesmanPhone == null) return true;
      return order.salesmanPhone == _selectedSalesmanPhone;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FB),
      appBar: AppBar(
        title: const Text(
          'কর্মচারী বিক্রয় সমূহ',
          style: TextStyle(
            color: Color(0xFF0D6B55),
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D6B55)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Salesman Filter Horizontal Chips (Pills)
            if (salesmenMap.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // "সব" (All) Chip
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSalesmanPhone = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedSalesmanPhone == null
                              ? const Color(0xFF0D6B55)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedSalesmanPhone == null
                                ? const Color(0xFF0D6B55)
                                : const Color(0xFFD9E5E1),
                          ),
                        ),
                        child: Text(
                          'সব',
                          style: TextStyle(
                            color: _selectedSalesmanPhone == null
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Individual Salesman Chips
                    ...salesmenMap.entries.map((entry) {
                      final isSelected = _selectedSalesmanPhone == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSalesmanPhone = entry.key;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0D6B55) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0D6B55) : const Color(0xFFD9E5E1),
                              ),
                            ),
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            // Orders list
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Text(
                        'আজ কোনো কর্মচারীর বিক্রয় নেই',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
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
                          ),
                          elevation: 1,
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
                                          color: const Color(0xFFE6FFFA),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          order.salesmanName ?? 'সেলসকর্মী',
                                          style: const TextStyle(
                                            color: Color(0xFF0D9488),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatTime(order.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
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
                                        fontSize: 16,
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
                                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
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
                                        ),
                                      ),
                                      Text(
                                        '৳ ${_bengaliNumber(order.totalAmount)}',
                                        style: const TextStyle(
                                          color: Color(0xFF0D6B55),
                                          fontWeight: FontWeight.w800,
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
