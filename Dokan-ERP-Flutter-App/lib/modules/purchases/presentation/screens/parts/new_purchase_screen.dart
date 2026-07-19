part of '../purchase_screens.dart';

class DokanNewPurchaseScreen extends ConsumerStatefulWidget {
  const DokanNewPurchaseScreen(
      {super.key, this.initialOrder, this.initialProduct});

  final PurchaseOrder? initialOrder;
  final DokanCatalogProduct? initialProduct;

  @override
  ConsumerState<DokanNewPurchaseScreen> createState() =>
      _DokanNewPurchaseScreenState();
}

class _DokanNewPurchaseScreenState
    extends ConsumerState<DokanNewPurchaseScreen> {
  DokanSupplierProfileRecord? _selectedSupplier;
  final List<_NewPurchaseItem> _items = [];
  final List<TextEditingController> _unitCostControllers = [];
  final List<TextEditingController> _quantityControllers = [];
  final TextEditingController _noteController = TextEditingController();
  String _paymentMethod = 'CASH';

  @override
  void initState() {
    super.initState();
    if (widget.initialOrder != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          final catalog = await ref.read(purchaseProductCatalogProvider.future);
          final suppliers = ref.read(dokanPosProvider).supplierProfiles;

          DokanSupplierProfileRecord? matchedSupplier;
          for (final sup in suppliers) {
            if (sup.key == widget.initialOrder!.supplierKey) {
              matchedSupplier = sup;
              break;
            }
          }

          setState(() {
            _selectedSupplier = matchedSupplier;
            _paymentMethod = widget.initialOrder!.paymentMethod;
            for (final line in widget.initialOrder!.lines) {
              final product = catalog.firstWhere(
                (p) =>
                    p.masterProductId == line.productId ||
                    p.barcode == line.productId,
                orElse: () => DokanCatalogProduct(
                  masterProductId:
                      line.productId.length > 10 ? line.productId : '',
                  name: line.productName,
                  barcode: line.productId.length <= 10
                      ? line.productId
                      : 'LOCAL-${line.productId}',
                  category: 'অন্যান্য',
                  emoji: '📦',
                  salePrice: line.unitCost,
                  purchasePrice: line.unitCost,
                  stock: 0,
                  lowStockThreshold: 5,
                  salesCount: 0,
                  packInfo: 'পিস',
                ),
              );

              final unitCostController =
                  TextEditingController(text: line.unitCost.toString());
              final qtyController =
                  TextEditingController(text: line.orderedQuantity.toString());

              _items.add(_NewPurchaseItem(
                product: product,
                quantity: line.orderedQuantity,
                unitCost: line.unitCost,
              ));
              _unitCostControllers.add(unitCostController);
              _quantityControllers.add(qtyController);
            }
          });
        } catch (_) {}
      });
    } else if (widget.initialProduct != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          final product = widget.initialProduct!;
          final unitCostController =
              TextEditingController(text: product.purchasePrice.toString());
          final qtyController = TextEditingController(text: '1');

          _items.add(_NewPurchaseItem(
            product: product,
            quantity: 1,
            unitCost: product.purchasePrice,
          ));
          _unitCostControllers.add(unitCostController);
          _quantityControllers.add(qtyController);
        });
      });
    }
  }

  bool _submitting = false;

  @override
  void dispose() {
    for (final controller in _unitCostControllers) {
      controller.dispose();
    }
    for (final controller in _quantityControllers) {
      controller.dispose();
    }
    _noteController.dispose();
    super.dispose();
  }

  int get _totalAmount =>
      _items.fold<int>(0, (sum, item) => sum + (item.quantity * item.unitCost));

  void _addProduct(DokanCatalogProduct product) {
    // Check if already in list
    final idx = _items
        .indexWhere((item) => item.product.productId == product.productId);
    if (idx >= 0) {
      setState(() {
        _items[idx].quantity += 1;
        _quantityControllers[idx].text = _items[idx].quantity.toString();
      });
    } else {
      setState(() {
        final controller =
            TextEditingController(text: product.purchasePrice.toString());
        final qtyController = TextEditingController(text: '1');
        _items.add(_NewPurchaseItem(
          product: product,
          quantity: 1,
          unitCost: product.purchasePrice,
        ));
        _unitCostControllers.add(controller);
        _quantityControllers.add(qtyController);
      });
    }
  }

  void _removeProduct(int index) {
    final unitCostController = _unitCostControllers[index];
    final quantityController = _quantityControllers[index];
    setState(() {
      _unitCostControllers.removeAt(index);
      _quantityControllers.removeAt(index);
      _items.removeAt(index);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unitCostController.dispose();
      quantityController.dispose();
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final next = _items[index].quantity + delta;
      if (next > 0) {
        _items[index].quantity = next;
        _quantityControllers[index].text = next.toString();
      }
    });
  }

  void _updateUnitCost(int index, int cost) {
    setState(() {
      if (cost >= 0) {
        _items[index].unitCost = cost;
      }
    });
  }

  Future<void> _submitPurchase() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('দয়া করে সরবরাহকারী নির্বাচন করুন।'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ক্রয় তালিকায় অন্তত একটি পণ্য যোগ করুন।'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    if (_items.any((item) => item.quantity <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('পণ্যের সংখ্যা অবশ্যই ০ এর বেশি হতে হবে।'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final lines = _items
          .map((item) => PurchaseOrderLine(
                productId: item.product.masterProductId.isNotEmpty
                    ? item.product.masterProductId
                    : item.product.productId,
                productName: item.product.name,
                orderedQuantity: item.quantity,
                unitCost: item.unitCost,
              ))
          .toList(growable: false);

      await ref.read(purchaseOrderProvider.notifier).createSubmittedOrder(
            supplierKey: _selectedSupplier!.key,
            supplierName: _selectedSupplier!.name,
            lines: lines,
            note: _noteController.text.trim(),
            paymentMethod: _paymentMethod,
            paidAmount: _paymentMethod == 'DUE' ? 0 : _totalAmount,
          );

      try {
        await ref
            .read(dokanInventoryCatalogProvider.notifier)
            .refreshFromRepository();
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ক্রয় অর্ডার সফলভাবে দাখিল করা হয়েছে।'),
            backgroundColor: Color(0xFF0D6B55),
          ),
        );
        if (widget.initialOrder != null) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const DokanPurchaseListScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(dokanPosProvider).supplierProfiles;
    final catalogAsync = ref.watch(purchaseProductCatalogProvider);
    final catalogProducts =
        catalogAsync.valueOrNull ?? const <DokanCatalogProduct>[];
    final productsLoading = catalogAsync.isLoading && catalogProducts.isEmpty;
    final catalogErrorText =
        catalogAsync.hasError ? catalogAsync.error.toString() : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF16302E),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'নতুন ক্রয় যোগ করুন',
              style: TextStyle(
                color: Color(0xFF0D6B55),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'ডাটাবেস থেকে পণ্য বেছে অর্ডার তৈরি করুন',
              style: TextStyle(
                color: Color(0xFF71827F),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: _submitting
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0D6B55)))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      DokanFadeSlideIn(
                        child: _buildInfoCard(),
                      ),
                      const SizedBox(height: 14),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 40),
                        child: _buildSupplierCard(suppliers),
                      ),
                      const SizedBox(height: 16),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 80),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'পণ্য যোগ করুন',
                                style: TextStyle(
                                  color: Color(0xFF16302E),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: productsLoading
                                  ? null
                                  : () => _showProductSelectionDialog(
                                        catalogProducts,
                                        isLoading: productsLoading,
                                      ),
                              icon: const Icon(Icons.add_circle_outline_rounded,
                                  color: Color(0xFF0D6B55)),
                              label: Text(
                                productsLoading
                                    ? 'লোড হচ্ছে...'
                                    : 'পণ্য নির্বাচন',
                                style: const TextStyle(
                                  color: Color(0xFF0D6B55),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (productsLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            color: Color(0xFF0D6B55),
                            backgroundColor: Color(0xFFE2EBE8),
                          ),
                        ),
                      if (catalogErrorText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'পণ্য লোড করা যায়নি: $catalogErrorText',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (_items.isEmpty)
                        ScrollReveal(
                          delay: const Duration(milliseconds: 120),
                          child: _buildEmptyItemsState(
                              catalogProducts, productsLoading),
                        )
                      else
                        ...List.generate(
                          _items.length,
                          (idx) => ScrollReveal(
                            key: ValueKey('new-purchase-item-${_items[idx].product.productId}-${_items[idx].product.masterProductId}'),
                            delay: Duration(milliseconds: (idx % 5) * 60),
                            child: _buildItemCard(idx),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 160),
                        child: _buildNotesCard(),
                      ),
                      const SizedBox(height: 16),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 180),
                        child: _buildPaymentMethodCard(),
                      ),
                    ],
                  ),
                ),
                _buildFooterBar(),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D6B55), Color(0xFF124C41)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6B55).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF0D6B55),
            radius: 20,
            child: Icon(Icons.shopping_bag_rounded),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ক্রয় অর্ডার তৈরি',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'সরবরাহকারী, পণ্য, এবং নোট একসাথে যোগ করুন',
                  style: TextStyle(
                    color: Color(0xFFD8EFE6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(List<DokanSupplierProfileRecord> suppliers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'সরবরাহকারী',
                style: TextStyle(
                  color: Color(0xFF16302E),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const DokanNewSupplierAddScreen(),
                    ),
                  );
                  if (result == true) {
                    final updatedSuppliers =
                        ref.read(dokanPosProvider).supplierProfiles;
                    if (updatedSuppliers.isNotEmpty) {
                      setState(() {
                        _selectedSupplier = updatedSuppliers.first;
                      });
                    }
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFF0D6B55),
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'যোগ করুন',
                      style: TextStyle(
                        color: Color(0xFF0D6B55),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<DokanSupplierProfileRecord>(
            value: _selectedSupplier,
            isExpanded: true,
            dropdownColor: Colors.white,
            iconEnabledColor: const Color(0xFF0D6B55),
            style: const TextStyle(
              color: Color(0xFF16302E),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'সরবরাহকারী নির্বাচন করুন',
              prefixIcon: const Icon(Icons.local_shipping_rounded,
                  color: Color(0xFF0D6B55)),
              filled: true,
              fillColor: const Color(0xFFF8FBFA),
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
                    const BorderSide(color: Color(0xFF0D6B55), width: 1.4),
              ),
            ),
            items: suppliers
                .map(
                  (s) => DropdownMenuItem<DokanSupplierProfileRecord>(
                    value: s,
                    child: Text(s.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(growable: false),
            onChanged: (val) => setState(() => _selectedSupplier = val),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsState(
      List<DokanCatalogProduct> catalogProducts, bool productsLoading) {
    return GestureDetector(
      onTap: productsLoading
          ? null
          : () => _showProductSelectionDialog(
                catalogProducts,
                isLoading: productsLoading,
              ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2EBE8)),
        ),
        child: const Column(
          children: [
            SizedBox(height: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE5F4EF),
              child: Icon(Icons.inventory_2_outlined, color: Color(0xFF0D6B55)),
            ),
            SizedBox(height: 12),
            Text(
              'এখনও কোনো পণ্য যোগ করা হয়নি',
              style: TextStyle(
                color: Color(0xFF16302E),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'এখানে চাপুন অথবা উপরে "পণ্য নির্বাচন" থেকে পণ্য যোগ করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF71827F),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int idx) {
    final item = _items[idx];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _productThumbnail(
                emoji: item.product.emoji,
                imageUrl: item.product.imageLabel,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF16302E),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.product.category} · ৳ ${_bn(item.product.purchasePrice)}',
                      style: const TextStyle(
                        color: Color(0xFF71827F),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'মুছুন',
                icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                onPressed: () => _removeProduct(idx),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _quantityButton(
                icon: Icons.remove_rounded,
                onTap: () => _updateQuantity(idx, -1),
              ),
              const SizedBox(width: 10),
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2EBE8)),
                ),
                child: TextField(
                  controller: _quantityControllers[idx],
                  keyboardType: TextInputType.number,
                  inputFormatters: NumericInputFormatters.wholeNumber,
                  textAlign: TextAlign.center,
                  cursorColor: const Color(0xFF0D6B55),
                  style: const TextStyle(
                    color: Color(0xFF16302E),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    filled: false,
                    fillColor: Colors.transparent,
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val) ?? 0;
                    setState(() {
                      _items[idx].quantity = parsed;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              _quantityButton(
                icon: Icons.add_rounded,
                onTap: () => _updateQuantity(idx, 1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: NumericInputFormatters.wholeNumber,
                  controller: _unitCostControllers[idx],
                  cursorColor: const Color(0xFF0D6B55),
                  style: const TextStyle(
                    color: Color(0xFF16302E),
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    labelText: 'ক্রয় মূল্য',
                    hintText: '০',
                    filled: true,
                    fillColor: const Color(0xFFF8FBFA),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
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
                          color: Color(0xFF0D6B55), width: 1.3),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.trim().isEmpty) return;
                    final parsed = int.tryParse(val);
                    if (parsed == null) return;
                    _updateUnitCost(idx, parsed);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productThumbnail({
    required String emoji,
    required String imageUrl,
    double size = 40,
  }) {
    final url = imageUrl.trim();
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          color: const Color(0xFFEAF5F1),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Text(emoji, style: TextStyle(fontSize: size * 0.55)),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFFEAF5F1),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.55)),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF5F1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: const Color(0xFF0D6B55)),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'নোট / বিশেষ বিবরণ',
            style: TextStyle(
              color: Color(0xFF16302E),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'ক্রয় সম্পর্কে অতিরিক্ত তথ্য লিখুন...',
              filled: true,
              fillColor: const Color(0xFFF8FBFA),
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
                    const BorderSide(color: Color(0xFF0D6B55), width: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'পেমেন্ট পদ্ধতি',
            style: TextStyle(
              color: Color(0xFF16302E),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPaymentChip(label: 'ক্যাশ (নগদ)', method: 'CASH', icon: Icons.money_rounded),
              _buildPaymentChip(label: 'বিকাশ (bKash)', method: 'BKASH', icon: Icons.mobile_friendly_rounded),
              _buildPaymentChip(label: 'নগদ (Nagad)', method: 'NAGAD', icon: Icons.mobile_screen_share_rounded),
              _buildPaymentChip(label: 'রকেট (Rocket)', method: 'ROCKET', icon: Icons.phonelink_ring_rounded),
              _buildPaymentChip(label: 'বাকি (Due)', method: 'DUE', icon: Icons.hourglass_empty_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip({
    required String label,
    required String method,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == method;
    return ChoiceChip(
      avatar: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFF0D6B55),
        size: 18,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF16302E),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0D6B55),
      backgroundColor: const Color(0xFFF0FDF4),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _paymentMethod = method;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0D6B55) : const Color(0xFFD9E6E2),
          width: 1,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildFooterBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2EBE8))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedNumberString(
                      '${_bn(_items.length)} টি পণ্য',
                      style: const TextStyle(
                        color: Color(0xFF71827F),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedNumberString(
                      '৳ ${_bn(_totalAmount)}',
                      style: const TextStyle(
                        color: Color(0xFF0D6B55),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _submitPurchase,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text(
                  'ক্রয় সম্পন্ন',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6B55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductSelectionDialog(
    List<DokanCatalogProduct> catalogProducts, {
    required bool isLoading,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final searchController = TextEditingController();
        String query = '';
        final selectedProductIds =
            _items.map((item) => item.product.productId).toSet();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = catalogProducts.where((product) {
              final needle = query.trim().toLowerCase();
              if (needle.isEmpty) return true;
              return product.name.toLowerCase().contains(needle) ||
                  product.barcode.toLowerCase().contains(needle) ||
                  product.category.toLowerCase().contains(needle);
            }).toList(growable: false);

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9E6E2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DokanFadeSlideIn(
                            delay: Duration(milliseconds: 30),
                            duration: Duration(milliseconds: 400),
                            slideOffset: Offset(0, -10),
                            child: Text(
                              'পণ্য নির্বাচন করুন',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF16302E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          DokanFadeSlideIn(
                            delay: const Duration(milliseconds: 70),
                            duration: const Duration(milliseconds: 400),
                            slideOffset: const Offset(0, -10),
                            child: Text(
                              isLoading
                                  ? 'ডাটাবেস থেকে পণ্য আনা হচ্ছে...'
                                  : '${filtered.length} টি পণ্য পাওয়া গেছে',
                              style: const TextStyle(
                                color: Color(0xFF71827F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DokanFadeSlideIn(
                            delay: const Duration(milliseconds: 120),
                            duration: const Duration(milliseconds: 450),
                            slideOffset: const Offset(0, 10),
                            child: DokanSearchField(
                              controller: searchController,
                              hintText: 'নাম, বারকোড, বা ক্যাটাগরি দিয়ে খুঁজুন',
                              onChanged: (value) {
                                setSheetState(() => query = value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: catalogProducts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.inventory_2_outlined,
                                        size: 54, color: Color(0xFF0D6B55)),
                                    const SizedBox(height: 12),
                                    Text(
                                      isLoading
                                          ? 'পণ্য লোড হচ্ছে...'
                                          : 'ডাটাবেসে কোনো পণ্য পাওয়া যায়নি',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF16302E),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : filtered.isEmpty
                              ? const Center(
                                  child: Text(
                                    'কোন মিল পাওয়া যায়নি',
                                    style: TextStyle(
                                      color: Color(0xFF71827F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final product = filtered[index];
                                    final isSelected = selectedProductIds
                                        .contains(product.productId);
                                    final itemDelay = Duration(milliseconds: math.min(250, index * 30));
                                    return DokanFadeSlideIn(
                                      delay: itemDelay,
                                      duration: const Duration(milliseconds: 400),
                                      slideOffset: const Offset(0, 15),
                                      child: InkWell(
                                        onTap: () {
                                          setSheetState(() {
                                            if (isSelected) {
                                              selectedProductIds
                                                  .remove(product.productId);
                                            } else {
                                              selectedProductIds
                                                  .add(product.productId);
                                            }
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(18),
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFFF0FDF4)
                                                : const Color(0xFFF8FBFA),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF86EFAC)
                                                  : const Color(0xFFE2EBE8),
                                              width: isSelected ? 1.5 : 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isSelected
                                                    ? Icons.check_circle_rounded
                                                    : Icons
                                                        .radio_button_off_rounded,
                                                color: isSelected
                                                    ? const Color(0xFF0D6B55)
                                                    : const Color(0xFFBDC7C4),
                                                size: 22,
                                              ),
                                              const SizedBox(width: 10),
                                              _productThumbnail(
                                                emoji: product.emoji,
                                                imageUrl: product.imageLabel,
                                                size: 40,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product.name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Color(0xFF16302E),
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${product.category} · বারকোড: ${product.barcode}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Color(0xFF71827F),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '৳ ${_bn(product.purchasePrice)}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF0D6B55),
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  const Text(
                                                    'ক্রয় মূল্য',
                                                    style: TextStyle(
                                                      color: Color(0xFF71827F),
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final controllersToDispose =
                                <TextEditingController>[];
                            setState(() {
                              // 1. Remove items that are no longer selected
                              for (var i = _items.length - 1; i >= 0; i--) {
                                final id = _items[i].product.productId;
                                if (!selectedProductIds.contains(id)) {
                                  controllersToDispose
                                      .add(_unitCostControllers.removeAt(i));
                                  controllersToDispose
                                      .add(_quantityControllers.removeAt(i));
                                  _items.removeAt(i);
                                }
                              }

                              // 2. Add new selected items
                              for (final id in selectedProductIds) {
                                final alreadyExists = _items.any(
                                    (item) => item.product.productId == id);
                                if (!alreadyExists) {
                                  final product = catalogProducts
                                      .firstWhere((p) => p.productId == id);
                                  final controller = TextEditingController(
                                      text: product.purchasePrice.toString());
                                  final qtyController =
                                      TextEditingController(text: '1');
                                  _items.add(_NewPurchaseItem(
                                    product: product,
                                    quantity: 1,
                                    unitCost: product.purchasePrice,
                                  ));
                                  _unitCostControllers.add(controller);
                                  _quantityControllers.add(qtyController);
                                }
                              }
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              for (final controller in controllersToDispose) {
                                controller.dispose();
                              }
                              searchController.dispose();
                            });
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D6B55),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(selectedProductIds.isEmpty
                              ? 'বন্ধ করুন'
                              : 'নির্বাচন নিশ্চিত করুন (${selectedProductIds.length} টি পণ্য)'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NewPurchaseItem {
  _NewPurchaseItem({
    required this.product,
    required this.quantity,
    required this.unitCost,
  });

  final DokanCatalogProduct product;
  int quantity;
  int unitCost;
}
