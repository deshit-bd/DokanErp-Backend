part of '../product_screens.dart';

class DokanThresholdSettingScreen extends ConsumerStatefulWidget {
  const DokanThresholdSettingScreen({super.key, this.initialThreshold});

  final int? initialThreshold;

  @override
  ConsumerState<DokanThresholdSettingScreen> createState() =>
      _DokanThresholdSettingScreenState();
}

class _DokanThresholdSettingScreenState
    extends ConsumerState<DokanThresholdSettingScreen> {
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _errorText;
  final Map<String, int> _productThresholds = {};

  @override
  void initState() {
    super.initState();
    _thresholdController.text =
        (widget.initialThreshold ?? ref.read(stockThresholdProvider))
            .toString();

    // Initialize product-wise thresholds from the inventory catalog provider
    Future.microtask(() {
      if (!mounted) return;
      final products = ref.read(dokanInventoryCatalogProvider);
      setState(() {
        for (final product in products) {
          _productThresholds[product.barcode] = product.lowStockThreshold;
        }
      });
    });
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _save() {
    final value = int.tryParse(_thresholdController.text.trim());
    if (value == null || value < 1 || value > 99) {
      setState(() => _errorText = '১ থেকে ৯৯ এর মধ্যে সংখ্যা দিন');
      return;
    }

    // Update global threshold
    ref.read(stockThresholdProvider.notifier).setThreshold(value);

    // Update product-wise thresholds
    final products = ref.read(dokanInventoryCatalogProvider);
    for (final product in products) {
      final customVal = _productThresholds[product.barcode];
      if (customVal != null && customVal != product.lowStockThreshold) {
        ref
            .read(dokanInventoryCatalogProvider.notifier)
            .updateProductThreshold(product, customVal);
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('সতর্কতা সীমা সফলভাবে হালনাগাদ হয়েছে'),
        backgroundColor: Color(0xFF0C8C67),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final threshold = ref.watch(stockThresholdProvider);
    final products = ref.watch(dokanInventoryCatalogProvider);

    // Filter products based on search query
    final query = _searchQuery.trim().toLowerCase();
    final filteredProducts = products.where((product) {
      return query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF111111),
        title: const Text(
          'স্টক সতর্কতা সীমা নির্ধারণ করুন',
          style: TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InventoryPageCard(
            title: 'গ্লোবাল সীমা',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'বর্তমান সীমা: ${_bnDigits(threshold.toString())}টি',
                  style: const TextStyle(
                      color: Color(0xFF141F22), fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                const Text(
                  'এই মান বদলালে সব পণ্য তালিকা, কম স্টক সতর্কতা এবং ড্যাশবোর্ড সাথে সাথে আপডেট হবে।',
                  style: TextStyle(
                      color: Color(0xFF3D4943),
                      fontWeight: FontWeight.w600,
                      height: 1.45),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: NumericInputFormatters.wholeNumber,
                  style: const TextStyle(
                      color: Color(0xFF111111), fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'যেমন: 5',
                    hintStyle: const TextStyle(color: Color(0xFF111111)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF00694C), width: 1.5),
                    ),
                  ),
                  onChanged: (_) {
                    if (_errorText != null) setState(() => _errorText = null);
                  },
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: const TextStyle(
                        color: Color(0xFFD43B3B), fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InventoryPageCard(
            title: 'পণ্য-ভিত্তিক সীমা',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'প্রতিটি পণ্যের জন্য আলাদাভাবে সতর্কতা সীমা নির্ধারণ করুন।',
                  style: TextStyle(
                      color: Color(0xFF3D4943),
                      fontWeight: FontWeight.w600,
                      height: 1.45),
                ),
                const SizedBox(height: 14),
                DokanSearchField(
                  controller: _searchController,
                  hintText: 'পণ্যের নাম বা বারকোড দিয়ে খুঁজুন...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                  showClear: _searchQuery.isNotEmpty,
                  onClear: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                ),
                const SizedBox(height: 14),
                if (filteredProducts.isEmpty)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: const [
                        Icon(Icons.inventory_2_outlined,
                            color: Color(0xFF0C8C67), size: 40),
                        SizedBox(height: 8),
                        Text(
                          'কোনো পণ্য পাওয়া যায়নি',
                          style: TextStyle(
                            color: Color(0xFF141F22),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFFEAF2F0),
                      height: 20,
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final currentVal = _productThresholds[product.barcode] ??
                          product.lowStockThreshold;

                      return Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F7ED),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              product.emoji.isNotEmpty ? product.emoji : '📦',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF141F22),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ক্যাটাগরি: ${product.category} • স্টক: ${_bnDigits(product.stock.toString())}টি',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF5F6A66),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (currentVal > 1) {
                                    setState(() {
                                      _productThresholds[product.barcode] =
                                          currentVal - 1;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5F7ED),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.remove,
                                      size: 16, color: Color(0xFF00694C)),
                                ),
                              ),
                              Container(
                                width: 38,
                                alignment: Alignment.center,
                                child: Text(
                                  _bnDigits(currentVal.toString()),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF141F22),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (currentVal < 99) {
                                    setState(() {
                                      _productThresholds[product.barcode] =
                                          currentVal + 1;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5F7ED),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.add,
                                      size: 16, color: Color(0xFF00694C)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C8C67),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('সংরক্ষণ করুন',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ProductBottomNav(
        selectedIndex: 2,
        onHomeTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanHomeDashboardScreen()),
        ),
        onSalesTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanPosSalesHistoryScreen()),
        ),
        onProductsTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanProductListScreen()),
        ),
        onReportsTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanReportsHomeScreen()),
        ),
        onMoreTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanAroOptionScreen()),
        ),
      ),
    );
  }
}

class _LedgerGroup {
  const _LedgerGroup(this.title, this.entries);

  final String title;
  final List<DokanStockLedgerEntry> entries;
}

class DokanStockMovementLogScreen extends ConsumerWidget {
  const DokanStockMovementLogScreen({super.key});

  List<_LedgerGroup> _groupEntries(List<DokanStockLedgerEntry> entries) {
    final today = <DokanStockLedgerEntry>[];
    final yesterday = <DokanStockLedgerEntry>[];
    final previous = <DokanStockLedgerEntry>[];
    final currentDay = DateUtils.dateOnly(DateTime.now());
    final previousDay =
        DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1)));

    for (final entry in entries) {
      final day = DateUtils.dateOnly(entry.timestamp);
      if (day == currentDay) {
        today.add(entry);
      } else if (day == previousDay) {
        yesterday.add(entry);
      } else {
        previous.add(entry);
      }
    }

    return <_LedgerGroup>[
      if (today.isNotEmpty) _LedgerGroup('আজকে', today),
      if (yesterday.isNotEmpty) _LedgerGroup('গতকাল', yesterday),
      if (previous.isNotEmpty) _LedgerGroup('পূর্ববর্তী', previous),
    ];
  }

  String _ledgerDateText(DateTime timestamp) {
    final now = DateUtils.dateOnly(DateTime.now());
    final day = DateUtils.dateOnly(timestamp);
    if (day == now) {
      return 'আজ';
    }
    if (day == now.subtract(const Duration(days: 1))) {
      return 'গতকাল';
    }
    return '${_bnDigits(timestamp.day.toString())}/${_bnDigits(timestamp.month.toString())}/${_bnDigits(timestamp.year.toString())}';
  }

  String _ledgerTimeText(DateTime timestamp) {
    final hour24 = timestamp.hour;
    final suffix = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '${_bnDigits(hour12.toString())}:$minute $suffix';
  }

  String _deltaText(int delta) {
    final sign = delta >= 0 ? '+' : '-';
    return '$sign${_bnDigits(delta.abs().toString())}টি';
  }

  Widget _buildSummaryCard(DokanStockLedgerSummary summary) {
    final changeColor = summary.todayChange >= 0
        ? const Color(0xFF0C8C67)
        : const Color(0xFFD43B3B);
    return _InventoryPageCard(
      title: 'সারসংক্ষেপ',
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SummaryPill(
                label: 'মোট বিক্রয়',
                value: '${_bnDigits(summary.totalSales.toString())}টি',
                color: const Color(0xFFD43B3B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryPill(
                label: 'আজকের পরিবর্তন',
                value:
                    '${summary.todayChange >= 0 ? '+' : '-'}${_bnDigits(summary.todayChange.abs().toString())}টি',
                color: changeColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryPill(
                label: 'মোট ক্রয়',
                value: '${_bnDigits(summary.totalPurchase.toString())}টি',
                color: const Color(0xFF0C8C67),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return _InventoryPageCard(
      title: 'লগ তালিকা',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F7ED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF0C8C67), size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'কোনো স্টক মুভমেন্ট পাওয়া যায়নি',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'নির্বাচিত ফিল্টারে এখনো কোনো লগ পাওয়া যায়নি।',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3D4943),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, _LedgerGroup group) {
    return _InventoryPageCard(
      title: '${group.title} — ${_bnDigits(group.entries.length.toString())}টি',
      child: ListView.separated(
        itemCount: group.entries.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entry = group.entries[index];
          return _StockLogCard(
            entry: entry,
            dateText: _ledgerDateText(entry.timestamp),
            timeText: _ledgerTimeText(entry.timestamp),
            deltaText: _deltaText(entry.delta),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(stockSummaryProvider);
    final logs = ref.watch(filteredLogProvider);
    final filter = ref.watch(stockLedgerFilterProvider);
    final groups = _groupEntries(logs);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF111111),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'স্টক মুভমেন্ট লগ',
          style: TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanThresholdSettingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanLowStockAlertScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          _buildSummaryCard(summary),
          const SizedBox(height: 14),
          _InventoryPageCard(
            title: 'ফিল্টার',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _AlertFilterChip(
                    label: 'সব পণ্য',
                    selected: filter == DokanStockLedgerFilter.all,
                    onTap: () => ref
                        .read(stockLedgerFilterProvider.notifier)
                        .setFilter(DokanStockLedgerFilter.all),
                  ),
                  const SizedBox(width: 10),
                  _AlertFilterChip(
                    label: 'আজকে',
                    selected: filter == DokanStockLedgerFilter.today,
                    onTap: () => ref
                        .read(stockLedgerFilterProvider.notifier)
                        .setFilter(DokanStockLedgerFilter.today),
                  ),
                  const SizedBox(width: 10),
                  _AlertFilterChip(
                    label: 'গতকাল',
                    selected: filter == DokanStockLedgerFilter.yesterday,
                    onTap: () => ref
                        .read(stockLedgerFilterProvider.notifier)
                        .setFilter(DokanStockLedgerFilter.yesterday),
                  ),
                  const SizedBox(width: 10),
                  _AlertFilterChip(
                    label: 'এই সপ্তাহ',
                    selected: filter == DokanStockLedgerFilter.thisWeek,
                    onTap: () => ref
                        .read(stockLedgerFilterProvider.notifier)
                        .setFilter(DokanStockLedgerFilter.thisWeek),
                  ),
                  const SizedBox(width: 10),
                  _AlertFilterChip(
                    label: 'এই মাস',
                    selected: filter == DokanStockLedgerFilter.thisMonth,
                    onTap: () => ref
                        .read(stockLedgerFilterProvider.notifier)
                        .setFilter(DokanStockLedgerFilter.thisMonth),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (logs.isEmpty)
            _buildEmptyState(context)
          else
            ...groups.map(
              (group) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildSection(context, group),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _ProductBottomNav(
        selectedIndex: 2,
        onHomeTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanHomeDashboardScreen()),
        ),
        onSalesTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanPosSalesHistoryScreen()),
        ),
        onProductsTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanProductListScreen()),
        ),
        onReportsTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanReportsHomeScreen()),
        ),
        onMoreTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanAroOptionScreen()),
        ),
      ),
    );
  }
}
