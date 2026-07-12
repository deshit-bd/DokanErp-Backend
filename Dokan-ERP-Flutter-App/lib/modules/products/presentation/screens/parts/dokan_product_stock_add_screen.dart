part of '../product_screens.dart';

class DokanProductStockAddScreen extends ConsumerStatefulWidget {
  const DokanProductStockAddScreen({
    super.key,
    required this.product,
  });

  final DokanCatalogProduct product;

  @override
  ConsumerState<DokanProductStockAddScreen> createState() =>
      _DokanProductStockAddScreenState();
}

class _DokanProductStockAddScreenState
    extends ConsumerState<DokanProductStockAddScreen> {
  final TextEditingController _supplierController = TextEditingController();
  late final TextEditingController _purchaseController;
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  int _addAmount = 10;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _purchaseController =
        TextEditingController(text: widget.product.purchasePrice.toString());
    _referenceController.text = 'restock';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dokanAppFlowProvider.notifier).refreshPermissions();
    });
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _purchaseController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final container = ProviderScope.containerOf(context);
    final flow = container.read(dokanAppFlowProvider);

    if (!flow.can(DokanPermission.stockAdjust)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সেলসম্যান স্টক আপডেট করতে পারবেন না'),
        ),
      );
      return;
    }
    if (_addAmount <= 0) {
      setState(
          () => _errorText = 'যোগ করার পরিমাণ অবশ্যই ১ বা তার বেশি হতে হবে');
      return;
    }
    final purchasePrice = int.tryParse(_purchaseController.text.trim()) ?? 0;
    if (purchasePrice <= 0) {
      setState(() => _errorText = 'ক্রয় মূল্য সঠিকভাবে দিন');
      return;
    }
    Navigator.of(context).pop(
      _StockAddResult(
        addAmount: _addAmount,
        purchasePrice: purchasePrice,
        referenceText: _referenceController.text.trim(),
        supplierName: _supplierController.text.trim(),
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newStock = widget.product.stock + _addAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                        'স্টক যোগ',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'বর্তমান স্টক: ${_bnDigits(widget.product.stock.toString())}টি',
                    style: const TextStyle(
                      color: Color(0xFF5F6A66),
                      fontSize: 13,
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
                    'যোগ করার পরিমাণ',
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F8F7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD9E6E2)),
                    ),
                    child: Row(
                      children: [
                        _StepperButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (_addAmount <= 1) return;
                            setState(() => _addAmount -= 1);
                          },
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '+${_bnDigits(_addAmount.toString())}টি',
                                style: const TextStyle(
                                  color: Color(0xFF0C8C67),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'স্টেপার দিয়ে পরিমাণ নির্ধারণ করুন',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF6F7D78),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        _StepperButton(
                          icon: Icons.add,
                          onTap: () => setState(() => _addAmount += 1),
                          active: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniFormField(
                          label: 'সরবরাহকারী',
                          controller: _supplierController,
                          hintText: 'সরবরাহকারীর নাম',
                          onChanged: (_) {
                            if (_errorText != null)
                              setState(() => _errorText = null);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniFormField(
                          label: 'ক্রয় মূল্য',
                          controller: _purchaseController,
                          hintText: '০',
                          readOnly: !ref.watch(dokanAppFlowProvider).can(DokanPermission.settingsManage),
                          keyboardType: TextInputType.number,
                          inputFormatters: NumericInputFormatters.wholeNumber,
                          onChanged: (_) {
                            if (_errorText != null)
                              setState(() => _errorText = null);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniFormField(
                          label: 'চালান / রেফারেন্স নম্বর',
                          controller: _referenceController,
                          hintText: 'রেফারেন্স লিখুন',
                          onChanged: (_) {
                            if (_errorText != null)
                              setState(() => _errorText = null);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniFormField(
                          label: 'নোট',
                          controller: _noteController,
                          hintText: 'সংক্ষিপ্ত নোট',
                          onChanged: (_) {
                            if (_errorText != null)
                              setState(() => _errorText = null);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      style: const TextStyle(
                        color: Color(0xFFD43B3B),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'লাইভ প্রিভিউ',
                    style: TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DetailInfoRow(
                      label: 'বর্তমান স্টক',
                      value: '${_bnDigits(widget.product.stock.toString())}টি'),
                  const SizedBox(height: 8),
                  _DetailInfoRow(
                    label: 'যোগ হবে',
                    value: '+${_bnDigits(_addAmount.toString())}টি',
                    valueColor: const Color(0xFF0C8C67),
                  ),
                  const SizedBox(height: 8),
                  _DetailInfoRow(
                    label: 'নতুন স্টক',
                    value: '${_bnDigits(newStock.toString())}টি',
                    valueColor: const Color(0xFF00694C),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFC5D4CF), width: 1.4),
                      foregroundColor: const Color(0xFF3D4943),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('বাতিল',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C8C67),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('স্টক যোগ করুন',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
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
