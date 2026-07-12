part of '../sales_screens.dart';

class _SalesSearchScreen extends ConsumerStatefulWidget {
  const _SalesSearchScreen();

  @override
  ConsumerState<_SalesSearchScreen> createState() => _SalesSearchScreenState();
}

class _SalesSearchScreenState extends ConsumerState<_SalesSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedMode = 0;
  _HistoryFilterSelection? _activeFilter;

  static const List<String> _modes = <String>[
    'সব',
    'নগদ',
    'বাকি',
    'আংশিক',
    'আজ',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  String _formatBanglaTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = _getBanglaPeriod(dateTime.hour);
    return '$period ${_banglaDigits(hour.toString())}:${_banglaDigits(minute)}';
  }

  String _getBanglaPeriod(int hour) {
    if (hour >= 4 && hour < 6) return 'ভোর';
    if (hour >= 6 && hour < 12) return 'সকাল';
    if (hour >= 12 && hour < 15) return 'দুপুর';
    if (hour >= 15 && hour < 18) return 'বিকাল';
    if (hour >= 18 && hour < 20) return 'সন্ধ্যা';
    return 'রাত';
  }

  Color _statusBackground(DokanPosOrderStatus status) {
    return switch (status) {
      DokanPosOrderStatus.paid => const Color(0xFFE1F5E7),
      DokanPosOrderStatus.due => const Color(0xFFFDE7E7),
      DokanPosOrderStatus.partiallyPaid => const Color(0xFFFDE7F2),
      DokanPosOrderStatus.cancelled => const Color(0xFFFDE7E7),
    };
  }

  Color _statusTextColor(DokanPosOrderStatus status) {
    return switch (status) {
      DokanPosOrderStatus.paid => const Color(0xFF0C8C67),
      DokanPosOrderStatus.due => const Color(0xFFD43B3B),
      DokanPosOrderStatus.partiallyPaid => const Color(0xFFC2185B),
      DokanPosOrderStatus.cancelled => const Color(0xFFD43B3B),
    };
  }

  String _statusLabel(DokanPosOrderStatus status) {
    return switch (status) {
      DokanPosOrderStatus.paid => 'সম্পূর্ণ পরিশোধ',
      DokanPosOrderStatus.due => 'বাকি আছে',
      DokanPosOrderStatus.partiallyPaid => 'আংশিক পরিশোধ',
      DokanPosOrderStatus.cancelled => 'বাতিল',
    };
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(dokanPosProvider.select((state) => state.orders));
    final query = _searchController.text.trim().toLowerCase();

    final filteredOrders = orders.where((order) {
      final matchesMode = switch (_selectedMode) {
        0 => true,
        1 => order.paymentMethod == DokanPosPaymentMethod.cash,
        2 => order.status == DokanPosOrderStatus.due,
        3 => order.status == DokanPosOrderStatus.partiallyPaid,
        4 => _isToday(order.createdAt),
        _ => true,
      };

      final matchesQuery = query.isEmpty ||
          order.customerName.toLowerCase().contains(query) ||
          order.customerNumber.toLowerCase().contains(query) ||
          order.summary.toLowerCase().contains(query) ||
          order.id.toLowerCase().contains(query) ||
          dokanPosPaymentMethodLabel(order.paymentMethod)
              .toLowerCase()
              .contains(query) ||
          order.totalAmount.toString().contains(query) ||
          order.paidAmount.toString().contains(query);

      bool matchesActiveFilter = true;
      if (_activeFilter != null) {
        final now = DateTime.now();
        final orderTime = order.createdAt;
        final isTimeMatched = switch (_activeFilter!.timeIndex) {
          0 => _isToday(orderTime), // আজ
          1 => orderTime.year == now.year &&
              orderTime.month == now.month &&
              orderTime.day == now.day - 1, // গতকাল
          2 => now.difference(orderTime).inDays <= 7, // এই সপ্তাহ
          3 => orderTime.year == now.year &&
              orderTime.month == now.month, // এই মাস
          _ => true,
        };

        final isStatusMatched = switch (_activeFilter!.statusIndex) {
          0 => true, // সব অবস্থা
          1 => order.status == DokanPosOrderStatus.paid, // সম্পূর্ণ পরিশোধ
          2 => order.status == DokanPosOrderStatus.due, // বাকি আছে
          3 =>
            order.status == DokanPosOrderStatus.partiallyPaid, // আংশিক পরিশোধ
          _ => true,
        };

        final isRangeMatched = switch (_activeFilter!.rangeIndex) {
          0 => true, // সব পরিমাণ
          1 => order.totalAmount < 1000, // ৳১,০০০ এর নিচে
          2 => order.totalAmount >= 1000 &&
              order.totalAmount <= 5000, // ৳১,০০০ - ৳৫,০০০
          3 => order.totalAmount > 5000, // ৳৫,০০০ এর বেশি
          _ => true,
        };

        matchesActiveFilter =
            isTimeMatched && isStatusMatched && isRangeMatched;
      }

      return matchesMode && matchesQuery && matchesActiveFilter;
    }).toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            MediaQuery.of(context).viewInsets.bottom + 96,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _HistoryIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'বিক্রয় খোঁজ',
                      style: TextStyle(
                        color: Color(0xFF00694C),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _HistoryIconButton(
                    icon: Icons.tune,
                    onTap: () async {
                      final result = await Navigator.of(context)
                          .push<_HistoryFilterSelection>(
                        MaterialPageRoute(
                          builder: (_) => _SalesFilterScreen(
                            initialTime: _activeFilter?.timeIndex ?? 0,
                            initialStatus: _activeFilter?.statusIndex ?? 0,
                            initialRange: _activeFilter?.rangeIndex ?? 0,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _activeFilter = result;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D9E75), Color(0xFF00694C)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'দ্রুত বিক্রয় খুঁজুন',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'নাম, রেফারেন্স, সময়, বা পরিশোধ অবস্থা দিয়ে খোঁজ করুন।',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DokanSearchField(
                controller: _searchController,
                hintText: 'নাম, রেফারেন্স, বা পণ্য লিখুন',
                height: 58,
                borderRadius: 18,
                onChanged: (_) => setState(() {}),
                showClear: _searchController.text.trim().isNotEmpty,
                onClear: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _modes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final selected = _selectedMode == index;
                  return _FilterChipButton(
                    label: _modes[index],
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _selectedMode = index;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            ...filteredOrders.map((order) {
              final timeText = _formatBanglaTime(order.createdAt);
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const _DokanSalesHistoryScreen(),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD9E6E2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEAF2F0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              color: Color(0xFF0C8C67),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.customerName,
                                  style: const TextStyle(
                                    color: Color(0xFF141F22),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  order.summary,
                                  style: const TextStyle(
                                    color: Color(0xFF3D4943),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${order.customerNumber} • $timeText • ${dokanPosPaymentMethodLabel(order.paymentMethod)}',
                                  style: const TextStyle(
                                    color: Color(0xFF6F7D78),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(order.totalAmount),
                                style: const TextStyle(
                                  color: Color(0xFF141F22),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusBackground(order.status),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _statusLabel(order.status),
                                  style: TextStyle(
                                    color: _statusTextColor(order.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
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
            }),
            if (filteredOrders.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _SalesEmptyState(),
              ),
          ],
        ),
      ),
    );
  }
}
