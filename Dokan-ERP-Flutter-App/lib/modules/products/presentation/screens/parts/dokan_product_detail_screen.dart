part of '../product_screens.dart';

class DokanProductDetailScreen extends ConsumerStatefulWidget {
  const DokanProductDetailScreen({super.key, this.product});

  final DokanCatalogProduct? product;

  @override
  ConsumerState<DokanProductDetailScreen> createState() =>
      _DokanProductDetailScreenState();
}

class _DokanProductDetailScreenState
    extends ConsumerState<DokanProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dokanAppFlowProvider.notifier).refreshPermissions();
    });
  }

  DokanCatalogProduct get _item {
    final catalog = ref.watch(dokanInventoryCatalogProvider);
    final barcode = widget.product?.barcode;
    if (barcode != null) {
      for (final item in catalog) {
        if (item.barcode == barcode) return item;
      }
    }
    return widget.product ?? catalog.first;
  }

  Future<void> _showAddStockSheet(DokanCatalogProduct item) async {
    final result = await Navigator.of(context).push<_StockAddResult>(
      MaterialPageRoute(
        builder: (_) => DokanProductStockAddScreen(product: item),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    try {
      await ref.read(productInventoryGatewayProvider).adjustStock(
            barcode: item.barcode,
            amount: result.addAmount,
            referenceText: result.referenceText,
            note: result.note,
            purchasePrice: result.purchasePrice,
          );
      ref.invalidate(productStockHistoryProvider(item.barcode));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('স্টক সার্ভারে সংরক্ষণ করা যায়নি'),
          backgroundColor: Color(0xFFB3261E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (result.supplierName.isNotEmpty) {
      final supplierKey = dokanSupplierRecordKey(result.supplierName, '');
      final notifier = ref.read(dokanPosProvider.notifier);
      await notifier.addSupplier(name: result.supplierName);
      await notifier.addSupplierPurchase(
        supplierKey: supplierKey,
        supplierName: result.supplierName,
        amount: result.addAmount * result.purchasePrice,
        note: result.note.isEmpty
            ? 'স্টক গ্রহণ ${result.referenceText}'
            : result.note,
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('স্টক সফলভাবে যোগ করা হয়েছে'),
        backgroundColor: Color(0xFF0C8C67),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openPriceManagement(DokanCatalogProduct item) async {
    final result = await Navigator.of(context).push<_PriceChangeResult>(
      MaterialPageRoute(
        builder: (_) => DokanProductPriceManagementScreen(product: item),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    try {
      await ref.read(productInventoryGatewayProvider).updatePrice(
            barcode: item.barcode,
            purchasePrice: result.purchasePrice,
            salePrice: result.salePrice,
          );
      ref.invalidate(productStockHistoryProvider(item.barcode));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('দাম সার্ভারে সংরক্ষণ করা যায়নি'),
          backgroundColor: Color(0xFFB3261E),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('দাম সফলভাবে পরিবর্তন করা হয়েছে'),
        backgroundColor: Color(0xFF0C8C67),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openHistory(DokanCatalogProduct item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DokanFullStockHistoryScreen(product: item),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return _ProductBottomNav(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final threshold = ref.watch(stockThresholdProvider);
    final state = _inventoryFor(item);
    final effectiveItem = item.copyWith(
      stock: state.stock,
      purchasePrice: state.purchasePrice,
      salePrice: state.salePrice,
    );
    final activeThreshold = effectiveItem.lowStockThreshold > 0
        ? effectiveItem.lowStockThreshold
        : threshold;
    final stockStatus = _stockStatusLabel(effectiveItem.stock, activeThreshold);
    final stockColor = _stockStatusColor(effectiveItem.stock, activeThreshold);
    final profitPerUnit = effectiveItem.salePrice - effectiveItem.purchasePrice;
    final historyAsync = ref.watch(productStockHistoryProvider(item.barcode));

    return DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: 'Hind Siliguri'),
      child: Scaffold(
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
                          child:
                              Icon(Icons.arrow_back, color: Color(0xFF3D4943)),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'পণ্য বিস্তারিত',
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD9E6E2)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF2F0),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(effectiveItem.emoji,
                          style: const TextStyle(fontSize: 34)),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      effectiveItem.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${effectiveItem.category} • ${effectiveItem.brand.isNotEmpty ? effectiveItem.brand : effectiveItem.packInfo}',
                      style: const TextStyle(
                        color: Color(0xFF5F6A66),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              final flow = ref.read(dokanAppFlowProvider);
                              if (!flow.can(DokanPermission.settingsManage)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('পণ্যের দাম পরিবর্তন করার অনুমতি নেই'),
                                  ),
                                );
                                return;
                              }
                              _openPriceManagement(effectiveItem);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: _DetailMiniInfo(
                              title: 'বর্তমান বিক্রয় মূল্য',
                              value: _currency(effectiveItem.salePrice),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              final flow = ref.read(dokanAppFlowProvider);
                              if (!flow.can(DokanPermission.settingsManage)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('পণ্যের দাম পরিবর্তন করার অনুমতি নেই'),
                                  ),
                                );
                                return;
                              }
                              _openPriceManagement(effectiveItem);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: _DetailMiniInfo(
                              title: 'বর্তমান ক্রয় মূল্য',
                              value: _currency(effectiveItem.purchasePrice),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD9E6E2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'স্টক সতর্কতা সীমা',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailInfoRow(
                      label: 'সীমা',
                      value: '${_bnDigits(activeThreshold.toString())}টি',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'স্টক ${_bnDigits(activeThreshold.toString())}টির নিচে গেলে সতর্কতা আসবে',
                      style: TextStyle(
                        color: Color(0xFF5F6A66),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD9E6E2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'স্টক তথ্য',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () {
                        final flow = ref.read(dokanAppFlowProvider);
                        if (!flow.can(DokanPermission.stockAdjust)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('স্টক পরিবর্তন করার অনুমতি নেই'),
                            ),
                          );
                          return;
                        }
                        _showAddStockSheet(effectiveItem);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: _DetailInfoRow(
                          label: 'বর্তমান স্টক',
                          value:
                              '${_bnDigits(effectiveItem.stock.toString())}টি'),
                    ),
                    const SizedBox(height: 10),
                    _DetailInfoRow(
                        label: 'কম স্টক সীমা',
                        value: '${_bnDigits(activeThreshold.toString())}টি'),
                    const SizedBox(height: 10),
                    _DetailInfoRow(
                        label: 'স্ট্যাটাস',
                        value: stockStatus,
                        valueColor: stockColor),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD9E6E2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'বিক্রয় তথ্য',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _SalesMetricCard(
                            title: 'মোট বিক্রি',
                            value:
                                '${_bnDigits(effectiveItem.salesCount.toString())}টি',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SalesMetricCard(
                            title: 'মোট আয়',
                            value: _currency(effectiveItem.salesCount *
                                effectiveItem.salePrice),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SalesMetricCard(
                      title: 'মোট লাভ',
                      value:
                          _currency(profitPerUnit * effectiveItem.salesCount),
                      emphasis: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD9E6E2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'স্টক ইতিহাস',
                          style: TextStyle(
                            color: Color(0xFF141F22),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _openHistory(effectiveItem),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF00694C),
                          ),
                          child: const Text('সব দেখুন',
                              style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    historyAsync.when(
                      data: (history) {
                        if (history.isEmpty) {
                          return const Text(
                            'এখনও কোনো স্টক ইতিহাস পাওয়া যায়নি',
                            style: TextStyle(
                              color: Color(0xFF6F7D78),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }
                        return Column(
                          children: history
                              .take(3)
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _StockHistoryTile(entry: entry),
                                ),
                              )
                              .toList(growable: false),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00694C),
                          ),
                        ),
                      ),
                      error: (_, __) => const Text(
                        'স্টক ইতিহাস লোড করা যায়নি',
                        style: TextStyle(
                          color: Color(0xFFB3261E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        bottomNavigationBar: _bottomNav(context),
      ),
    );
  }
}
