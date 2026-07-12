part of '../product_screens.dart';

class DokanProductPriceManagementScreen extends ConsumerStatefulWidget {
  const DokanProductPriceManagementScreen({super.key, required this.product});

  final DokanCatalogProduct product;

  @override
  ConsumerState<DokanProductPriceManagementScreen> createState() =>
      _DokanProductPriceManagementScreenState();
}

class _DokanProductPriceManagementScreenState
    extends ConsumerState<DokanProductPriceManagementScreen> {
  late final TextEditingController _purchaseController;
  late final TextEditingController _saleController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _purchaseController =
        TextEditingController(text: widget.product.purchasePrice.toString());
    _saleController =
        TextEditingController(text: widget.product.salePrice.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dokanAppFlowProvider.notifier).refreshPermissions();
    });
  }

  @override
  void dispose() {
    _purchaseController.dispose();
    _saleController.dispose();
    super.dispose();
  }

  void _save() {
    final purchase = int.tryParse(_purchaseController.text.trim()) ?? 0;
    final sale = int.tryParse(_saleController.text.trim()) ?? 0;

    if (purchase <= 0 || sale <= 0) {
      setState(() => _errorText = 'নতুন ক্রয় ও বিক্রয় মূল্য সঠিকভাবে দিন');
      return;
    }
    if (sale < purchase) {
      setState(() =>
          _errorText = 'বিক্রয় মূল্য ক্রয় মূল্যের চেয়ে কম হতে পারে না');
      return;
    }

    Navigator.of(context).pop(
      _PriceChangeResult(
        purchasePrice: purchase,
        salePrice: sale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _inventoryFor(widget.product);
    final purchase =
        int.tryParse(_purchaseController.text.trim()) ?? state.purchasePrice;
    final sale = int.tryParse(_saleController.text.trim()) ?? state.salePrice;
    final profit = sale - purchase;
    final profitPercent =
        purchase > 0 ? ((profit / purchase) * 100).round() : 0;

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
                          'দাম পরিবর্তন',
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailMiniInfo(
                            title: 'বর্তমান ক্রয় মূল্য',
                            value: _currency(state.purchasePrice),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DetailMiniInfo(
                            title: 'বর্তমান বিক্রয় মূল্য',
                            value: _currency(state.salePrice),
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
                      'নতুন দাম লিখুন',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniFormField(
                            label: 'নতুন ক্রয় মূল্য',
                            controller: _purchaseController,
                            hintText: '০',
                            readOnly: !ref.watch(dokanAppFlowProvider).can(DokanPermission.settingsManage),
                            keyboardType: TextInputType.number,
                            inputFormatters: NumericInputFormatters.wholeNumber,
                            onChanged: (_) {
                              if (_errorText != null) {
                                setState(() => _errorText = null);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniFormField(
                            label: 'নতুন বিক্রয় মূল্য',
                            controller: _saleController,
                            hintText: '০',
                            readOnly: !ref.watch(dokanAppFlowProvider).can(DokanPermission.settingsManage),
                            keyboardType: TextInputType.number,
                            inputFormatters: NumericInputFormatters.wholeNumber,
                            onChanged: (_) {
                              if (_errorText != null) {
                                setState(() => _errorText = null);
                              }
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F0),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'রিয়েল-টাইম হিসাব',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailInfoRow(
                      label: 'ক্রয় মূল্য',
                      value: _currency(
                          purchase > 0 ? purchase : state.purchasePrice),
                    ),
                    const SizedBox(height: 8),
                    _DetailInfoRow(
                      label: 'বিক্রয় মূল্য',
                      value: _currency(sale > 0 ? sale : state.salePrice),
                    ),
                    const SizedBox(height: 8),
                    _DetailInfoRow(
                      label: 'মুনাফা',
                      value: _currency(profit),
                      valueColor: profit >= 0
                          ? const Color(0xFF0C8C67)
                          : const Color(0xFFD43B3B),
                    ),
                    const SizedBox(height: 8),
                    _DetailInfoRow(
                      label: 'মুনাফার শতাংশ',
                      value: '${_bnDigits(profitPercent.toString())}%',
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
                      onPressed: ref.watch(dokanAppFlowProvider).can(DokanPermission.settingsManage) ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00694C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: const Text('দাম সংরক্ষণ করুন',
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
            MaterialPageRoute(
                builder: (_) => const DokanPosSalesHistoryScreen()),
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
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: const Color(0xFF3D4943)),
        ),
      ),
    );
  }
}
