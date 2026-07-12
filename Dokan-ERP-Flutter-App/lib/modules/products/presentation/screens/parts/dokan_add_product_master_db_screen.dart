part of '../product_screens.dart';

class DokanAddProductMasterDbScreen extends ConsumerWidget {
  const DokanAddProductMasterDbScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barcodes = ref
        .watch(dokanInventoryCatalogProvider)
        .map((product) => product.barcode)
        .toSet();
    return DokanNewProductAddScreen(
      existingBarcodes: barcodes,
    );
  }
}

class DokanLowStockAlertScreen extends ConsumerStatefulWidget {
  const DokanLowStockAlertScreen({super.key});

  @override
  ConsumerState<DokanLowStockAlertScreen> createState() =>
      _DokanLowStockAlertScreenState();
}

class _DokanLowStockAlertScreenState
    extends ConsumerState<DokanLowStockAlertScreen> {
  void _setFilter(_LowStockAlertFilter filter) {
    ref.read(dokanLowStockFilterProvider.notifier).setFilter(filter);
  }

  List<DokanCatalogProduct> _filteredProducts(
      List<DokanCatalogProduct> products) {
    final filter = ref.watch(dokanLowStockFilterProvider);
    final alertThreshold = ref.watch(stockThresholdProvider);
    final alertItems = products.where((product) {
      final isLow = product.stock > 0 && product.stock < alertThreshold;
      final isOut = product.stock <= 0;
      return switch (filter) {
        _LowStockAlertFilter.all => isLow || isOut,
        _LowStockAlertFilter.lowStock => isLow,
        _LowStockAlertFilter.outOfStock => isOut,
      };
    }).toList();
    alertItems.sort((a, b) => a.stock.compareTo(b.stock));
    return alertItems;
  }

  Color _statusColor(DokanCatalogProduct product, int threshold) {
    final limit = threshold > 0 ? threshold : 5;
    final maxValue = (limit * 2).clamp(1, 1000000);
    final progress = ((product.stock / maxValue) * 100).clamp(0, 100).toInt();
    if (progress <= 0) return const Color(0xFFD43B3B);
    if (progress <= 30) return const Color(0xFFB71C1C);
    if (progress <= 60) return const Color(0xFFF49B1A);
    return const Color(0xFF0C8C67);
  }

  double _progressValue(DokanCatalogProduct product, int threshold) {
    final limit = threshold > 0 ? threshold : 5;
    final maxValue = (limit * 2).clamp(1, 1000000);
    return (product.stock / maxValue).clamp(0, 1).toDouble();
  }

  Future<void> _openStockAdd(DokanCatalogProduct product) async {
    final result = await Navigator.of(context).push<_StockAddResult>(
      MaterialPageRoute(
          builder: (_) => DokanProductStockAddScreen(product: product)),
    );
    if (!mounted || result == null) return;
    ref.read(dokanInventoryCatalogProvider.notifier).applyStockAdd(
          product,
          addAmount: result.addAmount,
          purchasePrice: result.purchasePrice,
          referenceText: result.referenceText,
        );
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

  Future<void> _openOrderPreview() async {
    final products = ref.read(dokanInventoryCatalogProvider);
    final threshold = ref.read(stockThresholdProvider);
    final previewItems = products
        .where((product) => product.stock <= 0 || product.stock < threshold)
        .toList();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DokanPurchaseOrderPreviewScreen(
            products: previewItems, threshold: threshold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(dokanAppFlowProvider);
    final canManageStock =
        flow.can(DokanPermission.stockAdjust);
    final catalogProducts = ref.watch(dokanInventoryCatalogProvider);
    final alertThreshold = ref.watch(stockThresholdProvider);
    final lowStockProducts = ref.watch(lowStockProvider);
    final outOfStockProducts =
        catalogProducts.where((product) => product.stock <= 0).toList();
    final alertItems = _filteredProducts(catalogProducts);
    final filter = ref.watch(dokanLowStockFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF111111),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3D4943)),
        ),
        title: const Text(
          'কম স্টক সতর্কতা',
          style: TextStyle(
            color: Color(0xFF00694C),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
            children: [
              if (!canManageStock)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'সেলসম্যান মোড • আপনি শুধু স্টক দেখতে পারবেন',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              _InventoryPageCard(
                title: 'সারসংক্ষেপ',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryPill(
                            label: 'কম স্টক',
                            value:
                                '${_bnDigits(lowStockProducts.length.toString())}টি',
                            color: const Color(0xFFF49B1A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryPill(
                            label: 'স্টক নেই',
                            value:
                                '${_bnDigits(outOfStockProducts.length.toString())}টি',
                            color: const Color(0xFFD43B3B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7F0),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD9E6E2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'সতর্কতা সীমা: ${_bnDigits(alertThreshold.toString())}টি',
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'এই সীমার নিচে নতুন সতর্কতা ধরা হবে',
                            style: TextStyle(
                              color: Color(0xFF3D4943),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: canManageStock
                                  ? () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DokanThresholdSettingScreen(
                                            initialThreshold: alertThreshold,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C8C67),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.tune_rounded),
                              label: const Text(
                                'সীমা নির্ধারণ করুন',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _AlertFilterChip(
                      label: 'সব',
                      selected: filter == _LowStockAlertFilter.all,
                      onTap: () => _setFilter(_LowStockAlertFilter.all),
                    ),
                    const SizedBox(width: 10),
                    _AlertFilterChip(
                      label: 'কম স্টক',
                      selected: filter == _LowStockAlertFilter.lowStock,
                      onTap: () => _setFilter(_LowStockAlertFilter.lowStock),
                    ),
                    const SizedBox(width: 10),
                    _AlertFilterChip(
                      label: 'স্টক নেই',
                      selected: filter == _LowStockAlertFilter.outOfStock,
                      onTap: () => _setFilter(_LowStockAlertFilter.outOfStock),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (alertItems.isEmpty)
                _InventoryPageCard(
                  title: 'বর্তমান অবস্থা',
                  child: Column(
                    children: const [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF0C8C67),
                        size: 54,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'সব পণ্যের স্টক পর্যাপ্ত আছে',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'বর্তমানে কোনো সতর্কতা নেই',
                        style: TextStyle(
                          color: Color(0xFF3D4943),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: alertItems
                      .map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _LowStockProductCard(
                            product: product,
                            statusColor: _statusColor(
                              product,
                              alertThreshold,
                            ),
                            progress: _progressValue(
                              product,
                              alertThreshold,
                            ),
                            threshold: alertThreshold,
                            onAddStock: canManageStock
                                ? () => _openStockAdd(product)
                                : () {},
                            extraAction: !canManageStock
                                ? TextButton.icon(
                                    onPressed: () {
                                      addSalesmanLowStockNotification(
                                        productName: product.name,
                                        stock: product.stock,
                                        lowStockLimit: alertThreshold,
                                        salesmanId:
                                            flow.currentSalesmanPhone ?? '',
                                        salesmanName:
                                            flow.currentSalesmanName ??
                                                'সেলসম্যান',
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.notifications_active,
                                    ),
                                    label: const Text('স্টক কমেছে'),
                                  )
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomActionBar(
              icon: Icons.local_shipping_rounded,
              text: 'সব সরবরাহকারীকেই অর্ডার পাঠান',
              buttonLabel: 'অর্ডার তৈরি করুন',
              onPressed: _openOrderPreview,
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
