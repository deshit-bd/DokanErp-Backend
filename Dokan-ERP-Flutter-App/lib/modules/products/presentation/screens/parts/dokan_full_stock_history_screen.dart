part of '../product_screens.dart';

class DokanFullStockHistoryScreen extends ConsumerWidget {
  const DokanFullStockHistoryScreen({super.key, required this.product});

  final DokanCatalogProduct product;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync =
        ref.watch(productStockHistoryProvider(product.barcode));
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
                        'সম্পূর্ণ স্টক ইতিহাস',
                        style: TextStyle(
                          color: Color(0xFF00694C),
                          fontSize: 22,
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
                    product.name,
                    style: const TextStyle(
                      color: Color(0xFF141F22),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.category} • ${product.packInfo}',
                    style: const TextStyle(
                      color: Color(0xFF5F6A66),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  historyAsync.when(
                    data: (history) {
                      if (history.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'কোনো স্টক ইতিহাস পাওয়া যায়নি',
                            style: TextStyle(
                              color: Color(0xFF6F7D78),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: history
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
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00694C),
                        ),
                      ),
                    ),
                    error: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'স্টক ইতিহাস লোড করা যায়নি',
                        style: TextStyle(
                          color: Color(0xFFB3261E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFF0C8C67) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: active ? Colors.white : const Color(0xFF3D4943),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _MiniFormField extends StatelessWidget {
  const _MiniFormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF141F22),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          readOnly: readOnly,
          style: const TextStyle(
            color: Color(0xFF141F22),
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF6F7D78),
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: const Color(0xFFF4F8F7),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF00694C), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class DokanProductStockReduceScreen extends StatefulWidget {
  const DokanProductStockReduceScreen({super.key, required this.product});

  final DokanCatalogProduct product;

  @override
  State<DokanProductStockReduceScreen> createState() =>
      _DokanProductStockReduceScreenState();
}

class _DokanProductStockReduceScreenState
    extends State<DokanProductStockReduceScreen> {
  final TextEditingController _amountController =
      TextEditingController(text: '1');
  String _reason = 'ক্ষতিগ্রস্ত';
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save(int currentStock) {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      setState(() => _errorText = 'কমানোর পরিমাণ অবশ্যই ১ বা তার বেশি হতে হবে');
      return;
    }
    if (amount > currentStock) {
      setState(() => _errorText = 'স্টকের চেয়ে বেশি কমানো যাবে না');
      return;
    }

    Navigator.of(context).pop(
      _StockReduceResult(amount: amount, reason: _reason),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
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
                'স্টক কমান',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _inventoryFor(widget.product);
    final currentStock = state.stock;
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final remaining = currentStock - amount;
    final validRemaining = remaining >= 0 ? remaining : 0;

    return DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: 'Hind Siliguri'),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F8F7),
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              _buildHeader(context),
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
                    const SizedBox(height: 6),
                    Text(
                      'বর্তমান স্টক: ${_bnDigits(currentStock.toString())}টি',
                      style: const TextStyle(
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
                      'কমানোর পরিমাণ',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: NumericInputFormatters.wholeNumber,
                      onChanged: (value) {
                        if (_errorText != null) {
                          setState(() => _errorText = null);
                        } else {
                          setState(() {});
                        }
                      },
                      style: const TextStyle(
                        color: Color(0xFF141F22),
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: '০',
                        hintStyle: const TextStyle(
                          color: Color(0xFF6F7D78),
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F8F7),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        errorText: _errorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9E6E2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _errorText == null
                                ? const Color(0xFFD9E6E2)
                                : const Color(0xFFD43B3B),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF00694C), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'কারণ নির্বাচন',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _reason,
                      dropdownColor: Colors.white,
                      items: const [
                        DropdownMenuItem(
                            value: 'ক্ষতিগ্রস্ত', child: Text('ক্ষতিগ্রস্ত')),
                        DropdownMenuItem(
                            value: 'মেয়াদোত্তীর্ণ',
                            child: Text('মেয়াদোত্তীর্ণ')),
                        DropdownMenuItem(
                            value: 'হারিয়ে গেছে', child: Text('হারিয়ে গেছে')),
                        DropdownMenuItem(
                            value: 'নমুনা ব্যবহার',
                            child: Text('নমুনা ব্যবহার')),
                        DropdownMenuItem(
                            value: 'অন্যান্য', child: Text('অন্যান্য')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _reason = value);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9E6E2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9E6E2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF00694C), width: 1.5),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF141F22),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                      'লাইভ প্রিভিউ',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailInfoRow(
                      label: 'বর্তমান স্টক',
                      value: '${_bnDigits(currentStock.toString())}টি',
                    ),
                    const SizedBox(height: 8),
                    _DetailInfoRow(
                      label: 'কমবে',
                      value: '-${_bnDigits(amount.toString())}টি',
                      valueColor: const Color(0xFFD43B3B),
                    ),
                    const SizedBox(height: 8),
                    _DetailInfoRow(
                      label: 'অবশিষ্ট',
                      value: '${_bnDigits(validRemaining.toString())}টি',
                      valueColor: const Color(0xFF0C8C67),
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
                      onPressed: () => _save(currentStock),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD43B3B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: const Text('স্টক কমান',
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
