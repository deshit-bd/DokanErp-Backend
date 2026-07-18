part of '../sales_screens.dart';

class _PaymentBreakdownRow extends StatelessWidget {
  const _PaymentBreakdownRow({
    required this.icon,
    required this.title,
    required this.amount,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String amount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF141F22),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyClosingSuccessScreen extends StatelessWidget {
  const _DailyClosingSuccessScreen({
    required this.dateText,
    required this.salesText,
    required this.profitText,
    required this.dueText,
  });

  final String dateText;
  final String salesText;
  final String profitText;
  final String dueText;

  Widget _bottomNav(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: const BoxDecoration(
          color: Color(0xFFEAF2F0),
          border: Border(
            top: BorderSide(color: Color(0xFFD7E5E0)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SalesBottomNavItem(
              icon: Icons.home_outlined,
              label: 'হোম',
              selected: false,
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            _SalesBottomNavItem(
              icon: Icons.point_of_sale_outlined,
              label: 'বিক্রয়',
              selected: true,
              onTap: () => Navigator.of(context).pop(),
            ),
            _SalesBottomNavItem(
              icon: Icons.inventory_2_outlined,
              label: 'পণ্য',
              selected: false,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => const DokanProductListScreen()),
              ),
            ),
            _SalesBottomNavItem(
              icon: Icons.bar_chart_outlined,
              label: 'রিপোর্ট',
              selected: false,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => const DokanReportsHomeScreen()),
              ),
            ),
            _SalesBottomNavItem(
              icon: Icons.more_horiz,
              label: 'আরও',
              selected: false,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DokanAroOptionScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Container(
              height: 82,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3FAFB),
                border: Border.all(color: const Color(0xFFD9E6E2)),
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.arrow_back, color: Color(0xFF3D4943)),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'দৈনিক ক্লোজিং',
                        style: TextStyle(
                          color: Color(0xFF00694C),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFD9E6E2)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5F7ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Color(0xFF0C8C67), size: 56),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'দৈনিক ক্লোজিং সম্পন্ন হয়েছে',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: Color(0xFF6F7D78),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'ক্লোজিং সফল',
                      style: TextStyle(
                        color: Color(0xFF0C8C67),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailSectionCard(
              child: Column(
                children: [
                  _InvoiceInfoRow(
                      icon: Icons.point_of_sale_outlined,
                      label: 'আজকের বিক্রয়',
                      value: salesText),
                  const SizedBox(height: 14),
                  _InvoiceInfoRow(
                      icon: Icons.show_chart_outlined,
                      label: 'লাভ',
                      value: profitText),
                  const SizedBox(height: 14),
                  _InvoiceInfoRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'বাকি',
                      value: dueText),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 58,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const _DokanSalesHistoryScreen()),
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00694C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'বিক্রয় ইতিহাসে ফিরুন',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }
}

class _DokanSalesHistoryScreen extends ConsumerStatefulWidget {
  const _DokanSalesHistoryScreen();

  @override
  ConsumerState<_DokanSalesHistoryScreen> createState() =>
      _DokanSalesHistoryScreenState();
}

class _DokanSalesHistoryScreenState
    extends ConsumerState<_DokanSalesHistoryScreen> {
  int _selectedFilterIndex = 0;
  int _selectedAmountIndex = 0;
  int _selectedStatusIndex = 0;
  DateTime? _selectedCustomDate;
  bool _showSearchPanel = false;
  bool _showFilterPanel = false;
  final TextEditingController _searchController = TextEditingController();

  static const List<_SalesFilter> _filters = <_SalesFilter>[
    _SalesFilter(label: 'আজ'),
    _SalesFilter(label: 'গতকাল'),
    _SalesFilter(label: 'এই সপ্তাহ'),
    _SalesFilter(label: 'এই মাস'),
    _SalesFilter(label: 'সব'),
  ];

  static const List<String> _statusFilters = <String>[
    'সব অবস্থা',
    'সম্পূর্ণ পরিশোধ',
    'বাকি আছে',
    'আংশিক পরিশোধ',
  ];

  static const List<String> _amountFilters = <String>[
    'সব পরিমাণ',
    '৳১,০০০ এর নিচে',
    '৳১,০০০ - ৳৫,০০০',
    '৳৫,০০০ এর বেশি',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(salesHistoryOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(salesHistoryOrdersProvider);
            try {
              await ref.read(salesHistoryOrdersProvider.future);
            } catch (_) {}
          },
          color: const Color(0xFF0C8C67),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              0,
              0,
              0,
              MediaQuery.of(context).viewInsets.bottom + 96,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              DokanFadeSlideIn(
                delay: const Duration(milliseconds: 30),
                duration: const Duration(milliseconds: 500),
                slideOffset: const Offset(0, -10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _SalesHeaderBar(
                    onBack: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.sales);
                      }
                    },
                    onSearch: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const _SalesSearchScreen(),
                        ),
                      );
                    },
                    onFilter: () async {
                      final selection = await Navigator.of(context)
                          .push<_HistoryFilterSelection>(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => _SalesFilterScreen(
                            initialTime: _selectedFilterIndex,
                            initialStatus: _selectedStatusIndex,
                            initialRange: _selectedAmountIndex,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                      if (!mounted || selection == null) {
                        return;
                      }
                      setState(() {
                        _selectedFilterIndex = selection.timeIndex;
                        _selectedStatusIndex = selection.statusIndex;
                        _selectedAmountIndex = selection.rangeIndex;
                        _selectedCustomDate = null;
                        _showSearchPanel = false;
                        _showFilterPanel = false;
                      });
                    },
                    onCalendar: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedCustomDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF006B53),
                                onPrimary: Colors.white,
                                onSurface: Color(0xFF141F22),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedCustomDate = pickedDate;
                          _selectedFilterIndex = -1;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DokanFadeSlideIn(
                delay: const Duration(milliseconds: 70),
                duration: const Duration(milliseconds: 500),
                slideOffset: const Offset(0, 15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ordersAsync.when(
                    data: (orders) {
                      final visibleOrders = _visibleOrdersFrom(orders);
                      try {
                        final logFile = File(
                            '/Users/macbookair/Desktop/dokan_erp/flutter_debug.log');
                        logFile.writeAsStringSync(
                            '${DateTime.now().toIso8601String()} - [_DokanSalesHistoryScreen] orders size: ${orders.length}, visible: ${visibleOrders.length}\n',
                            mode: FileMode.append);
                        for (var i = 0;
                            i < math.min(visibleOrders.length, 10);
                            i++) {
                          final o = visibleOrders[i];
                          logFile.writeAsStringSync(
                              '  - Order[$i] ID: ${o.id}, customer: ${o.customerName}, total: ${o.totalAmount}, linesCount: ${o.lines.length}\n',
                              mode: FileMode.append);
                        }
                      } catch (_) {}
                      final totalSalesAmount = visibleOrders.fold<int>(
                        0,
                        (sum, order) => sum + order.totalAmount,
                      );
                      final totalDueAmount = visibleOrders.fold<int>(
                        0,
                        (sum, order) => sum + order.dueAmount,
                      );
                      return _SalesSummaryStrip(
                        totalSalesAmount: _formatCurrency(totalSalesAmount),
                        totalOrderCount:
                            '${_banglaDigits(visibleOrders.length.toString())}টি',
                        totalDueAmount: _formatCurrency(totalDueAmount),
                      );
                    },
                    loading: () => const _SalesSummaryStrip(
                      totalSalesAmount: '৳০',
                      totalOrderCount: '০টি',
                      totalDueAmount: '৳০',
                    ),
                    error: (_, __) => const _SalesSummaryStrip(
                      totalSalesAmount: '৳০',
                      totalOrderCount: '০টি',
                      totalDueAmount: '৳০',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: _SalesSearchInlinePanel(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    onClear: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  ),
                ),
                crossFadeState: _showSearchPanel
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  child: _SalesFilterInlinePanel(
                    selectedStatusIndex: _selectedStatusIndex,
                    selectedAmountIndex: _selectedAmountIndex,
                    statusFilters: _statusFilters,
                    amountFilters: _amountFilters,
                    onStatusTap: (index) {
                      setState(() {
                        _selectedStatusIndex = index;
                      });
                    },
                    onAmountTap: (index) {
                      setState(() {
                        _selectedAmountIndex = index;
                      });
                    },
                    onReset: () {
                      setState(() {
                        _selectedStatusIndex = 0;
                        _selectedFilterIndex = 0;
                        _selectedAmountIndex = 0;
                      });
                    },
                  ),
                ),
                crossFadeState: _showFilterPanel
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
              DokanFadeSlideIn(
                delay: const Duration(milliseconds: 110),
                duration: const Duration(milliseconds: 500),
                slideOffset: const Offset(0, 10),
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final selected = _selectedFilterIndex == index;
                      return _FilterChipButton(
                        label: _filters[index].label,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            _selectedFilterIndex = index;
                            _selectedCustomDate = null;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              if (_hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _ActiveFilterSummary(
                    searchText: _searchController.text.trim(),
                    timeLabel: _selectedFilterIndex == -1
                        ? ''
                        : _filters[_selectedFilterIndex].label,
                    statusLabel: _statusFilters[_selectedStatusIndex],
                    amountLabel: _amountFilters[_selectedAmountIndex],
                    customDate: _selectedCustomDate,
                    onClearAll: () {
                      setState(() {
                        _searchController.clear();
                        _selectedFilterIndex = 0;
                        _selectedStatusIndex = 0;
                        _selectedAmountIndex = 0;
                        _selectedCustomDate = null;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 14),
              ...ordersAsync.when(
                data: (orders) {
                  final visibleOrders = _visibleOrdersFrom(orders);
                  final filteredGroups = _groupOrders(
                    visibleOrders
                        .map(_salesItemFromOrder)
                        .toList(growable: false),
                  );
                  final hasItems =
                      filteredGroups.any((group) => group.items.isNotEmpty);
                  if (!hasItems) {
                    return const <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: _SalesEmptyState(),
                      ),
                    ];
                  }
                  int groupIndex = 0;
                  return filteredGroups
                      .map(
                        (group) {
                          final itemDelay = Duration(milliseconds: math.min(300, 150 + groupIndex * 40));
                          groupIndex++;
                          return DokanFadeSlideIn(
                            delay: itemDelay,
                            duration: const Duration(milliseconds: 400),
                            slideOffset: const Offset(0, 15),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                              child: _SalesGroupSection(group: group),
                            ),
                          );
                        },
                      )
                      .toList(growable: false);
                },
                loading: () => const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _SalesHistoryLoadingState(),
                  ),
                ],
                error: (error, _) => <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SalesHistoryErrorState(
                      message: '$error',
                      onRetry: () => ref.invalidate(salesHistoryOrdersProvider),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _selectedFilterIndex != 0 ||
        _selectedStatusIndex != 0 ||
        _selectedAmountIndex != 0 ||
        _selectedCustomDate != null;
  }

  List<DokanPosOrderRecord> _visibleOrdersFrom(
      List<DokanPosOrderRecord> orders) {
    return orders.where(_matchesActiveFilters).toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool _matchesActiveFilters(DokanPosOrderRecord order) {
    final query = _searchController.text.trim().toLowerCase();

    final matchesSearch = query.isEmpty ||
        order.customerName.toLowerCase().contains(query) ||
        order.customerNumber.toLowerCase().contains(query) ||
        order.summary.toLowerCase().contains(query) ||
        order.id.toLowerCase().contains(query) ||
        dokanPosPaymentMethodLabel(order.paymentMethod).toLowerCase().contains(
              query,
            );

    final matchesStatus = switch (_selectedStatusIndex) {
      0 => true,
      1 => order.status == DokanPosOrderStatus.paid,
      2 => order.status == DokanPosOrderStatus.due,
      3 => order.status == DokanPosOrderStatus.partiallyPaid,
      _ => true,
    };

    final matchesTime = _selectedCustomDate != null
        ? _isSameDay(order.createdAt, _selectedCustomDate!)
        : switch (_selectedFilterIndex) {
            0 => _isSameDay(order.createdAt, DateTime.now()),
            1 => _isSameDay(
                order.createdAt,
                DateTime.now().subtract(const Duration(days: 1)),
              ),
            2 => _isSameWeek(order.createdAt, DateTime.now()),
            3 => _isSameMonth(order.createdAt, DateTime.now()),
            4 => true,
            _ => true,
          };

    final matchesAmount = switch (_selectedAmountIndex) {
      0 => true,
      1 => order.totalAmount < 1000,
      2 => order.totalAmount >= 1000 && order.totalAmount <= 5000,
      3 => order.totalAmount > 5000,
      _ => true,
    };

    return matchesSearch && matchesStatus && matchesTime && matchesAmount;
  }

  List<_SalesGroup> _groupOrders(List<_SalesItem> items) {
    final today = <_SalesItem>[];
    final yesterday = <_SalesItem>[];
    final others = <_SalesItem>[];

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    for (final item in items) {
      final createdAt =
          (item.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).toLocal();
      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      if (day == todayDate) {
        today.add(item);
      } else if (day == yesterdayDate) {
        yesterday.add(item);
      } else {
        others.add(item);
      }
    }

    final groups = <_SalesGroup>[];
    if (today.isNotEmpty) {
      groups.add(_SalesGroup(title: 'আজকে', items: today));
    }
    if (yesterday.isNotEmpty) {
      groups.add(_SalesGroup(title: 'গতকাল', items: yesterday));
    }
    if (others.isNotEmpty) {
      groups.add(_SalesGroup(title: 'অন্যান্য', items: others));
    }
    return groups;
  }

  _SalesItem _salesItemFromOrder(DokanPosOrderRecord order) {
    final statusLabel = switch (order.status) {
      DokanPosOrderStatus.paid => 'সম্পূর্ণ পরিশোধ',
      DokanPosOrderStatus.due => 'বাকি আছে',
      DokanPosOrderStatus.partiallyPaid => 'আংশিক পরিশোধ',
      DokanPosOrderStatus.cancelled => 'বাতিল',
    };

    final status = switch (order.status) {
      DokanPosOrderStatus.paid => _SalesStatus.paid,
      DokanPosOrderStatus.due => _SalesStatus.due,
      DokanPosOrderStatus.partiallyPaid => _SalesStatus.partial,
      DokanPosOrderStatus.cancelled => _SalesStatus.due,
    };

    final shortTime = _formatBanglaTime(order.createdAt);
    final itemCount = '${_banglaDigits(order.lines.length.toString())}টি পণ্য';
    final referenceId =
        'রেফ: ${_banglaDigits((order.createdAt.microsecondsSinceEpoch % 10000).toString().padLeft(4, '0'))}';
    final amount = order.totalAmount;
    final profit = order.grossProfit;

    final String displayName;
    final isGuest = order.customerName.trim().isEmpty ||
        order.customerName == 'Guest Customer' ||
        order.customerName == 'Guest' ||
        order.customerName == 'অতিথি গ্রাহক' ||
        order.customerName == 'হাঁটা বিক্রয়';
    if (isGuest && order.lines.isNotEmpty) {
      displayName = order.lines.map((line) => line.productName).join(', ');
    } else {
      displayName = order.customerName.trim().isEmpty
          ? 'অতিথি গ্রাহক'
          : order.customerName;
    }

    return _SalesItem(
      id: order.id,
      customerName: displayName,
      amount: amount,
      profit: profit,
      statusLabel: statusLabel,
      status: status,
      timeText: '$itemCount • $shortTime',
      referenceId: referenceId,
      createdAt: order.createdAt,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  bool _isSameWeek(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    final aMonday =
        DateTime(localA.year, localA.month, localA.day - (localA.weekday - 1));
    final bMonday =
        DateTime(localB.year, localB.month, localB.day - (localB.weekday - 1));
    return _isSameDay(aMonday, bMonday);
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year && localA.month == localB.month;
  }

  String _formatBanglaTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final hour = localDateTime.hour % 12 == 0 ? 12 : localDateTime.hour % 12;
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    final period = _getBanglaPeriod(localDateTime.hour);
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
}

class _SalesHistoryLoadingState extends StatelessWidget {
  const _SalesHistoryLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF0C8C67),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'বিক্রয় ইতিহাস লোড হচ্ছে...',
            style: TextStyle(
              color: Color(0xFF3D4943),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesHistoryErrorState extends StatelessWidget {
  const _SalesHistoryErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: Color(0xFFD43B3B),
          ),
          const SizedBox(height: 10),
          const Text(
            'বিক্রয় ইতিহাস লোড করা যায়নি',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF141F22),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6F7D78),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00694C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'আবার চেষ্টা করুন',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
