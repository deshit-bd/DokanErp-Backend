part of '../product_screens.dart';

class DokanPurchaseOrderPreviewScreen extends ConsumerWidget {
  const DokanPurchaseOrderPreviewScreen(
      {super.key, required this.products, required this.threshold});

  final List<DokanCatalogProduct> products;
  final int threshold;

  int _suggestedQty(DokanCatalogProduct product) {
    final limit = threshold > 0 ? threshold : 5;
    final value = (limit * 2) - product.stock;
    return value <= 0 ? 1 : value;
  }

  int _totalSuggested() =>
      products.fold<int>(0, (sum, product) => sum + _suggestedQty(product));

  Future<void> _sendOrders(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2_rounded,
                      color: Color(0xFF0C8C67), size: 26),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'অর্ডার পাঠানোর নিশ্চিতকরণ',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${_bnDigits(products.length.toString())}টি কম স্টক পণ্যের জন্য অর্ডার তৈরি হবে। আপনি কি নিশ্চিত?',
                style: const TextStyle(
                  color: Color(0xFF3D4943),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF111111),
                        side: const BorderSide(color: Color(0xFFD9E6E2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'বাতিল',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C8C67),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'অর্ডার পাঠান',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final suppliers = ref.read(dokanPosProvider).supplierProfiles;
    final supplier = suppliers.isEmpty ? null : suppliers.first;
    final order =
        await ref.read(purchaseOrderProvider.notifier).createSubmittedOrder(
              supplierKey: supplier?.key ?? 'unassigned',
              supplierName: supplier?.name ?? 'সরবরাহকারী নির্ধারিত নয়',
              lines: products
                  .map(
                    (product) => PurchaseOrderLine(
                      productId: product.masterProductId.isNotEmpty
                          ? product.masterProductId
                          : product.productId,
                      productName: product.name,
                      orderedQuantity: _suggestedQty(product),
                      unitCost: product.purchasePrice,
                    ),
                  )
                  .toList(growable: false),
              note: 'কম স্টক থেকে স্বয়ংক্রিয় ক্রয় আদেশ',
            );
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (successContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF0C8C67), size: 56),
              const SizedBox(height: 12),
              const Text(
                'অর্ডার সফলভাবে পাঠানো হয়েছে',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${order.reference} তৈরি হয়েছে এবং ${order.supplierName}-এর জন্য সংরক্ষিত হয়েছে।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF3D4943),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(successContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C8C67),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'ঠিক আছে',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF111111),
        title: const Text(
          'ক্রয় অর্ডার প্রিভিউ',
          style:
              TextStyle(color: Color(0xFF00694C), fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InventoryPageCard(
            title: 'অর্ডার সারসংক্ষেপ',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'মোট পণ্য: ${_bnDigits(products.length.toString())}টি',
                  style: const TextStyle(
                      color: Color(0xFF111111), fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'মোট সুপারিশকৃত পরিমাণ: ${_bnDigits(_totalSuggested().toString())}টি',
                  style: const TextStyle(
                      color: Color(0xFF3D4943), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...products.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD9E6E2)),
                ),
                child: Row(
                  children: [
                    Text(product.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                                color: Color(0xFF111111),
                                fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'সুপারিশকৃত: ${_bnDigits(_suggestedQty(product).toString())}টি',
                            style: const TextStyle(
                                color: Color(0xFF3D4943),
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      product.stock <= 0 ? 'স্টক নেই' : 'কম স্টক',
                      style: const TextStyle(
                          color: Color(0xFFF49B1A),
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () => _sendOrders(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C8C67),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('সব সরবরাহকারীকেই অর্ডার পাঠান',
                  style: TextStyle(fontWeight: FontWeight.w900)),
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

class DokanPurchaseOrderSuccessScreen extends StatelessWidget {
  const DokanPurchaseOrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF111111),
        title: const Text(
          'অর্ডার পাঠানো হয়েছে',
          style:
              TextStyle(color: Color(0xFF00694C), fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _InventoryPageCard(
            title: 'সফলতা',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF0C8C67), size: 72),
                const SizedBox(height: 14),
                const Text(
                  'অর্ডার সফলভাবে পাঠানো হয়েছে',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'সব সরবরাহকারীর কাছে অর্ডার গেছে',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFF3D4943), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C8C67),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('পণ্য তালিকায় ফিরুন',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ),
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
