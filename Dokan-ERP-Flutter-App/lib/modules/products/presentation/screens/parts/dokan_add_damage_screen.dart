part of '../product_screens.dart';

class DokanAddDamageScreen extends ConsumerStatefulWidget {
  const DokanAddDamageScreen({super.key, this.initialProduct});

  final DokanCatalogProduct? initialProduct;

  @override
  ConsumerState<DokanAddDamageScreen> createState() =>
      _DokanAddDamageScreenState();
}

class _DokanAddDamageScreenState extends ConsumerState<DokanAddDamageScreen> {
  String? _selectedBarcode;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController =
      TextEditingController(text: '1');
  final TextEditingController _notesController = TextEditingController();
  String _reason = 'ক্ষতিগ্রস্ত';
  String? _errorText;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedBarcode = widget.initialProduct?.barcode;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  DokanCatalogProduct? _findProduct(
      List<DokanCatalogProduct> catalogProducts, String? barcode) {
    if (barcode == null) return null;
    final index = catalogProducts.indexWhere((p) => p.barcode == barcode);
    if (index != -1) return catalogProducts[index];
    if (widget.initialProduct?.barcode == barcode) return widget.initialProduct;
    return null;
  }

  int _getStock(DokanCatalogProduct product) {
    final catalog = ref.watch(dokanInventoryCatalogProvider);
    final index = catalog.indexWhere((p) => p.barcode == product.barcode);
    return index != -1 ? catalog[index].stock : product.stock;
  }

  void _save(DokanCatalogProduct selectedProduct) async {
    final currentStock = _getStock(selectedProduct);
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      setState(() => _errorText = 'কমানোর পরিমাণ অবশ্যই ১ বা তার বেশি হতে হবে');
      return;
    }
    if (amount > currentStock) {
      setState(() => _errorText = 'স্টকের চেয়ে বেশি কমানো যাবে না');
      return;
    }

    final finalReason =
        (_reason == 'অন্যান্য' && _notesController.text.trim().isNotEmpty)
            ? _notesController.text.trim()
            : _reason;

    setState(() => _submitting = true);

    try {
      if (ref.read(apiConfiguredProvider)) {
        await ref.read(productRemoteDataSourceProvider).adjustStock(
              productId: selectedProduct.barcode,
              quantity: amount,
              type: 'DAMAGE',
              reference: 'damage_reduce',
              note: finalReason,
            );
        ref.read(dokanInventoryCatalogProvider.notifier).applyStockReduce(
              selectedProduct,
              amount: amount,
              reason: finalReason,
            );
        await ref
            .read(dokanInventoryCatalogProvider.notifier)
            .refreshFromRepository();
      } else {
        ref.read(dokanInventoryCatalogProvider.notifier).applyStockReduce(
              selectedProduct,
              amount: amount,
              reason: finalReason,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${selectedProduct.name} এর স্টক $amountটি ড্যামেজ হিসেবে নথিভুক্ত করা হয়েছে ($finalReason)।'),
            backgroundColor: const Color(0xFFD43B3B),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: ${e.toString()}'),
            backgroundColor: const Color(0xFFD43B3B),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogProducts = ref.watch(dokanInventoryCatalogProvider);
    final selectedProduct = _findProduct(catalogProducts, _selectedBarcode);

    final dropdownValue = (selectedProduct != null &&
            catalogProducts.any((p) => p.barcode == selectedProduct.barcode))
        ? selectedProduct.barcode
        : null;

    final currentStock =
        selectedProduct != null ? _getStock(selectedProduct) : 0;
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final remaining = currentStock - amount;
    final validRemaining = remaining >= 0 ? remaining : 0;
    final totalLossCost =
        selectedProduct != null ? selectedProduct.purchasePrice * amount : 0;

    return DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: 'Hind Siliguri'),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F8F7),
        appBar: AppBar(
          title: const Text(
            'ড্যামেজ এন্ট্রি যুক্ত করুন',
            style: TextStyle(
              color: Color(0xFF00694C),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          backgroundColor: const Color(0xFFF3FAFB),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF3D4943)),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Select Product Section
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
                      'পণ্য নির্বাচন করুন',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: dropdownValue,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      hint: const Text('পণ্য সিলেক্ট করুন...',
                          style: TextStyle(color: Color(0xFF7C8A84))),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF00694C),
                        size: 28,
                      ),
                      items: catalogProducts.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.barcode,
                          child: Text(
                            '${p.name} (স্টক: ${_bnDigits(_getStock(p).toString())}টি)',
                            style: const TextStyle(
                              color: Color(0xFF141F22),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (barcode) {
                        setState(() {
                          _selectedBarcode = barcode;
                          _errorText = null;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF4F8F7),
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
                    ),
                    if (selectedProduct != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8F7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EFEF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.inventory_2_outlined,
                                  color: Color(0xFF00694C)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedProduct.name,
                                    style: const TextStyle(
                                      color: Color(0xFF141F22),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'বারকোড: ${selectedProduct.barcode} | ক্রয় মূল্য: ৳${_bnDigits(selectedProduct.purchasePrice.toString())}',
                                    style: const TextStyle(
                                      color: Color(0xFF7C8A84),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Quantity & Reason Form
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
                      'কমানোর পরিমাণ (Quantity)',
                      style: TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: NumericInputFormatters.wholeNumber,
                      onChanged: (val) {
                        setState(() => _errorText = null);
                      },
                      style: const TextStyle(
                        color: Color(0xFF141F22),
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: '১',
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
                    const SizedBox(height: 16),
                    const Text(
                      'ক্ষতির কারণ নির্বাচন',
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
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF00694C),
                        size: 28,
                      ),
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
                        fillColor: const Color(0xFFF4F8F7),
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
                        fontSize: 15,
                      ),
                    ),
                    if (_reason == 'অন্যান্য') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        style: const TextStyle(
                          color: Color(0xFF141F22),
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'অন্যান্য কারণের বিবরণ লিখুন (ঐচ্ছিক)',
                          hintStyle: const TextStyle(
                            color: Color(0xFF6F7D78),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF4F8F7),
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
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Live Preview Card
              if (selectedProduct != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F0),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFC2E8D8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'লাইভ হিসাব প্রিভিউ',
                        style: TextStyle(
                          color: Color(0xFF00694C),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('বর্তমান স্টক:',
                              style: TextStyle(color: Color(0xFF5F6A66), fontWeight: FontWeight.w700)),
                          Text('${_bnDigits(currentStock.toString())}টি',
                              style: const TextStyle(color: Color(0xFF141F22), fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('কমবে:',
                              style: TextStyle(color: Color(0xFF5F6A66), fontWeight: FontWeight.w700)),
                          Text('-${_bnDigits(amount.toString())}টি',
                              style: const TextStyle(color: Color(0xFFD43B3B), fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('অবশিষ্ট স্টক:',
                              style: TextStyle(color: Color(0xFF5F6A66), fontWeight: FontWeight.w700)),
                          Text('${_bnDigits(validRemaining.toString())}টি',
                              style: const TextStyle(color: Color(0xFF00694C), fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const Divider(color: Color(0xFFC2E8D8), height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('আর্থিক লোকসান (ক্রয় মূল্য অনুযায়ী):',
                              style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w800, fontSize: 13)),
                          Text('৳${_bnDigits(totalLossCost.toString())}',
                              style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Action Buttons
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
                      onPressed: (_submitting || selectedProduct == null)
                          ? null
                          : () => _save(selectedProduct),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD43B3B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('ড্যামেজ জমা দিন',
                              style: TextStyle(fontWeight: FontWeight.w900)),
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
}
