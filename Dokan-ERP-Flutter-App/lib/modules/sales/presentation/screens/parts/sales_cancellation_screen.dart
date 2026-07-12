part of '../sales_screens.dart';

class _SalesCancellationScreen extends ConsumerStatefulWidget {
  const _SalesCancellationScreen({this.orderId});

  final String? orderId;

  @override
  ConsumerState<_SalesCancellationScreen> createState() =>
      _SalesCancellationScreenState();
}

class _SalesCancellationScreenState
    extends ConsumerState<_SalesCancellationScreen> {
  int _refundMethodIndex = 0;
  String _selectedReason = 'খদ্দের ফেরত দিয়েছেন';
  final TextEditingController _notesController = TextEditingController();

  static const List<String> _refundMethods = <String>[
    'নগদ ফেরত',
    'bKash/Nagad এ ফেরত',
    'পরে কেনাকাটায় বাদ দিন',
  ];

  static const List<String> _reasons = <String>[
    'খদ্দের ফেরত দিয়েছেন',
    'ভুল বিল হয়েছে',
    'ডুপ্লিকেট বিক্রয়',
    'অন্যান্য',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _goToSuccessPage() async {
    final flow = ref.read(dokanAppFlowProvider);
    if (!flow.can(DokanPermission.salesManage)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বিক্রয় বাতিল করার অনুমতি নেই')),
      );
      return;
    }
    final orders = ref.read(dokanPosProvider).orders;
    String? orderId = widget.orderId;
    if (orderId == null) {
      for (final order in orders) {
        if (order.status != DokanPosOrderStatus.cancelled &&
            order.lines.isNotEmpty) {
          orderId = order.id;
          break;
        }
      }
    }
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বাতিলযোগ্য বিক্রয় পাওয়া যায়নি')),
      );
      return;
    }
    final error = await ref.read(dokanPosProvider.notifier).cancelOrder(
          orderId: orderId,
          reason: _selectedReason,
          refundMethod: _refundMethods[_refundMethodIndex],
        );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    final order = orders.firstWhereOrNull((o) => o.id == orderId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SalesCancellationSuccessScreen(
          refundMethod: _refundMethods[_refundMethodIndex],
          orderId: orderId!,
          refundAmount: order?.totalAmount ?? 0,
        ),
      ),
    );
  }

  Widget _bottomNav() {
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

  Widget _refundOption(String label, int index) {
    final selected = _refundMethodIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _refundMethodIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF0FAF5) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  selected ? const Color(0xFF00694C) : const Color(0xFFD9E6E2),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                index == 0
                    ? Icons.payments_outlined
                    : index == 1
                        ? Icons.account_balance_wallet_outlined
                        : Icons.remove_circle_outline,
                color: const Color(0xFF3D4943),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF141F22),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF00694C)
                        : const Color(0xFF9AA8A2),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        selected ? const Color(0xFF00694C) : Colors.transparent,
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
  Widget build(BuildContext context) {
    final orders = ref.watch(dokanPosProvider).orders;
    final order = orders.firstWhereOrNull((o) => o.id == widget.orderId);
    final catalog = ref.watch(dokanInventoryCatalogProvider);

    final productsToShow = order != null
        ? order.lines.map((line) {
            final catalogProduct =
                catalog.firstWhereOrNull((p) => p.barcode == line.productId);
            return _SaleDetailProduct(
              icon: catalogProduct?.emoji ?? '📦',
              name: line.productName,
              quantity: line.quantity,
              price: line.unitPrice,
              total: line.lineTotal,
            );
          }).toList()
        : const <_SaleDetailProduct>[];

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
                borderRadius: BorderRadius.circular(0),
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
                        'বিক্রয় বাতিল',
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
                color: const Color(0xFFFDEEEF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF4D2D5)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFD43B3B), size: 56),
                  const SizedBox(height: 10),
                  const Text(
                    'এই বিক্রয় বাতিল করবেন?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD43B3B),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'বাতিল করলে স্টক ফিরে আসবে এবং এই বিক্রয়ের রেকর্ড মুছে যাবে',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5F6A66),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Invoice #${_banglaDigits(order?.id.substring(math.max(0, (order?.id.length ?? 0) - 4)) ?? '')} — ৳${_banglaDigits(order?.totalAmount.toString() ?? '০')}',
                      style: const TextStyle(
                        color: Color(0xFFB61F2A),
                        fontSize: 18,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'রিফান্ড পদ্ধতি',
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(
                    _refundMethods.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                          bottom: index == _refundMethods.length - 1 ? 0 : 12),
                      child: _refundOption(_refundMethods[index], index),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD9E6E2)),
                boxShadow: const [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'বাতিলের কারণ',
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedReason,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF00694C), width: 1.6),
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF6F7D78)),
                    dropdownColor: Colors.white,
                    items: _reasons
                        .map(
                          (reason) => DropdownMenuItem<String>(
                            value: reason,
                            child: Text(
                              reason,
                              style: const TextStyle(
                                color: Color(0xFF141F22),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedReason = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'অতিরিক্ত নোট',
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    style: const TextStyle(
                      color: Color(0xFF141F22),
                      fontWeight: FontWeight.w700,
                    ),
                    cursorColor: const Color(0xFF00694C),
                    decoration: InputDecoration(
                      hintText: 'বিস্তারিত লিখুন...',
                      hintStyle: const TextStyle(color: Color(0xFF7C8A84)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF00694C), width: 1.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F8F68),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✓ স্টকে ফিরে আসবে:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...productsToShow.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(product.icon,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              '+${_banglaDigits(product.quantity.toString())}টি',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFC9D4D0), width: 1.6),
                        foregroundColor: const Color(0xFF3D4943),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'বাতিল করব না',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _goToSuccessPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84A4A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'বিক্রয় বাতিল করুন',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }
}
