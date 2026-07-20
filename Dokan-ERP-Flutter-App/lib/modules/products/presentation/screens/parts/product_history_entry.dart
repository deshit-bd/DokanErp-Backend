part of '../product_screens.dart';

typedef _ProductHistoryEntry = DokanProductHistoryEntry;

DokanProductHistoryEntry dokanRemoteHistoryEntryFromJson(Map<String, dynamic> json) {
  return _historyEntryFromRemoteJson(json);
}

_ProductHistoryEntry _historyEntryFromRemoteJson(Map<String, dynamic> json) {
  final type = (json['movementType'] as String? ?? '').toUpperCase();
  final timestamp = DateTime.tryParse(json['createdAt'] as String? ?? '');
  final delta = (json['quantityDelta'] as num?)?.toDouble() ?? 0;
  final note = (json['note'] as String?)?.trim() ?? '';
  final referenceNo = (json['referenceNo'] as String?)?.trim() ?? '';
  final referenceType =
      (json['referenceType'] as String? ?? '').trim().toUpperCase();
  final stockAfter = (json['stockAfter'] as num?)?.toDouble();
  final purchasePrice = (json['purchasePrice'] as num?)?.toInt();
  final salePrice = (json['salePrice'] as num?)?.toInt();

  return _ProductHistoryEntry(
    label: _historyRemoteLabel(type, note: note, referenceType: referenceType),
    amount: _historyRemoteAmount(
      type: type,
      delta: delta,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
    ),
    timeLabel: _historyRemoteTimeLabel(
      timestamp,
      type: type,
      note: note,
      referenceType: referenceType,
      referenceNo: referenceNo,
      stockAfter: stockAfter,
    ),
    color: _historyRemoteColor(type),
    timestamp: timestamp,
    kind: _historyRemoteKind(type),
  );
}

String _historyRemoteLabel(
  String type, {
  required String note,
  required String referenceType,
}) {
  switch (type) {
    case 'PURCHASE':
    case 'MANUAL_ADD':
      return 'ক্রয়';
    case 'SALE':
      return 'বিক্রয়';
    case 'SALE_CANCEL':
      return 'বিক্রয় রিটার্ন';
    case 'PURCHASE_RETURN':
      return 'ক্রয় ফেরত';
    case 'DAMAGE':
    case 'MANUAL_REDUCE':
      return _isDamageMovement(note, referenceType) || type == 'DAMAGE' ? 'ক্ষতি' : 'স্টক হ্রাস';
    case 'PRICE_CHANGE':
      return 'দাম পরিবর্তন';
    default:
      return 'স্টক আপডেট';
  }
}

String _historyRemoteAmount({
  required String type,
  required double delta,
  required int? purchasePrice,
  required int? salePrice,
}) {
  if (type == 'PRICE_CHANGE') {
    final buy = purchasePrice ?? 0;
    final sale = salePrice ?? 0;
    return 'ক্রয় ${_currency(buy)} → বিক্রয় ${_currency(sale)}';
  }

  final normalized = delta.abs() % 1 == 0
      ? delta.abs().toInt().toString()
      : delta.abs().toStringAsFixed(3);
  final sign = delta > 0
      ? '+'
      : delta < 0
          ? '-'
          : '';
  return '$sign${_bnDigits(normalized)}টি';
}

String _historyRemoteTimeLabel(
  DateTime? timestamp, {
  required String type,
  required String note,
  required String referenceType,
  required String referenceNo,
  required double? stockAfter,
}) {
  final dateLabel = _historyDateLabel(timestamp);
  final cleanedNote = _historyRemoteNote(
    type,
    note: note,
    referenceType: referenceType,
  );
  final secondary = cleanedNote.isNotEmpty
      ? cleanedNote
      : referenceNo.isNotEmpty
          ? 'রেফ: $referenceNo'
          : stockAfter == null
              ? 'হিস্টোরি সিঙ্ক'
              : 'স্টক ${_bnDigits(stockAfter.toStringAsFixed(stockAfter % 1 == 0 ? 0 : 3))}';
  return '$dateLabel • $secondary';
}

String _historyDateLabel(DateTime? timestamp) {
  if (timestamp == null) {
    return 'আজ';
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
  final diff = today.difference(date).inDays;
  if (diff == 0) {
    return 'আজ';
  }
  if (diff == 1) {
    return 'গতকাল';
  }
  return '${_bnDigits(timestamp.day.toString())}/${_bnDigits(timestamp.month.toString())}/${_bnDigits(timestamp.year.toString())}';
}

Color _historyRemoteColor(String type) {
  switch (type) {
    case 'PURCHASE':
    case 'MANUAL_ADD':
    case 'SALE_CANCEL':
      return const Color(0xFF0C8C67);
    case 'SALE':
    case 'PURCHASE_RETURN':
      return const Color(0xFFF49B1A);
    case 'DAMAGE':
    case 'MANUAL_REDUCE':
      return const Color(0xFFD43B3B);
    case 'PRICE_CHANGE':
      return const Color(0xFF00694C);
    default:
      return const Color(0xFF6F7D78);
  }
}

String _historyRemoteNote(
  String type, {
  required String note,
  required String referenceType,
}) {
  if (type == 'DAMAGE' || type == 'MANUAL_REDUCE') {
    if (_isDamageMovement(note, referenceType) || type == 'DAMAGE') {
      return note.isEmpty || note == 'Manual stock reduction.' || note == 'Damaged stock removed.'
          ? 'ক্ষতিগ্রস্ত পণ্য বাদ'
          : note;
    }
    if (note == 'Manual stock reduction.') {
      return 'স্টক হ্রাস';
    }
  }

  if (type == 'MANUAL_ADD' && note == 'Manual stock increase.') {
    return 'স্টক যোগ করা হয়েছে';
  }

  if (type == 'SALE' && note == 'Stock reduced from sale.') {
    return 'বিক্রয়ের কারণে স্টক কমেছে';
  }

  return note;
}

bool _isDamageMovement(String note, String referenceType) {
  if (referenceType == 'DAMAGE') {
    return true;
  }

  final normalizedNote = note.trim().toLowerCase();
  return normalizedNote == 'manual stock reduction.' ||
      normalizedNote.contains('damage') ||
      normalizedNote.contains('expired') ||
      normalizedNote.contains('lost') ||
      normalizedNote.contains('wastage') ||
      note.contains('ক্ষতি') ||
      note.contains('ক্ষতিগ্রস্ত') ||
      note.contains('মেয়াদ') ||
      note.contains('হারিয়ে');
}

DokanStockMovementType _historyRemoteKind(String type) {
  switch (type) {
    case 'PURCHASE':
    case 'MANUAL_ADD':
      return DokanStockMovementType.purchase;
    case 'SALE':
      return DokanStockMovementType.sale;
    case 'SALE_CANCEL':
      return DokanStockMovementType.returnItem;
    case 'PURCHASE_RETURN':
    case 'DAMAGE':
    case 'MANUAL_REDUCE':
      return DokanStockMovementType.loss;
    case 'PRICE_CHANGE':
      return DokanStockMovementType.manual;
    default:
      return DokanStockMovementType.manual;
  }
}

class _StockAddResult {
  const _StockAddResult({
    required this.addAmount,
    required this.purchasePrice,
    required this.referenceText,
    this.supplierName = '',
    this.note = '',
  });

  final int addAmount;
  final int purchasePrice;
  final String referenceText;
  final String supplierName;
  final String note;
}

class _StockReduceResult {
  const _StockReduceResult({
    required this.amount,
    required this.reason,
  });

  final int amount;
  final String reason;
}

class DokanNewProductAddScreen extends ConsumerStatefulWidget {
  const DokanNewProductAddScreen({super.key, required this.existingBarcodes});

  final Set<String> existingBarcodes;

  @override
  ConsumerState<DokanNewProductAddScreen> createState() =>
      _DokanNewProductAddScreenState();
}

class _DokanNewProductAddScreenState
    extends ConsumerState<DokanNewProductAddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _stockController =
      TextEditingController(text: '0');
  final TextEditingController _lowStockController =
      TextEditingController(text: '5');

  String _selectedCategory = 'চাল-ডাল';
  String _selectedUnit = 'পিস';
  String _selectedImageLabel = 'ছবি যোগ করা হয়নি';
  bool _isSaving = false;
  String? _imageHint;
  String? _imageError;
  String? _formError;

  static const List<String> _units = <String>[
    'পিস',
    'কেজি',
    'লিটার',
    'প্যাকেট'
  ];

  @override
  void initState() {
    super.initState();
    _barcodeController.text = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dokanAppFlowProvider.notifier).refreshPermissions();
    });
    _categoryController.text = _selectedCategory;
    _unitController.text = _selectedUnit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _barcodeController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  int _parseInt(String value, {int fallback = 0}) {
    final parsed = int.tryParse(value.trim());
    return parsed ?? fallback;
  }

  void _showNameSelectionSheet() {
    final catalog = ref.read(dokanInventoryCatalogProvider);
    final categories = ref.read(categoryProvider);
    final categoryOptions = _productCategoryOptions(categories);
    final uniqueProducts = <String, DokanCatalogProduct>{};
    for (final p in catalog) {
      if (p.name.trim().isNotEmpty) {
        uniqueProducts[p.name.trim().toLowerCase()] = p;
      }
    }
    final existingProducts = uniqueProducts.values.toList();
    existingProducts.sort((a, b) => a.name.compareTo(b.name));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final searchController = TextEditingController();
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = existingProducts.where((p) {
              final needle = query.trim().toLowerCase();
              if (needle.isEmpty) return true;
              return p.name.toLowerCase().contains(needle) ||
                  p.barcode.toLowerCase().contains(needle) ||
                  p.category.toLowerCase().contains(needle);
            }).toList();

            final showAddNew = query.trim().isNotEmpty &&
                !existingProducts.any(
                    (p) => p.name.toLowerCase() == query.trim().toLowerCase());

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
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
                          const Text(
                            'পণ্যের নাম নির্বাচন করুন',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF16302E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DokanSearchField(
                            controller: searchController,
                            hintText:
                                'পণ্যের নাম, বারকোড বা ক্যাটাগরি দিয়ে খুঁজুন...',
                            autofocus: true,
                            onChanged: (val) {
                              setSheetState(() {
                                query = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        children: [
                          if (showAddNew)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color:
                                    const Color(0xFF0D6B55).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    final newName = query.trim();
                                    _nameController.text = newName;
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Color(0xFF0D6B55)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'নতুন পণ্য যোগ করুন: "$query"',
                                            style: const TextStyle(
                                              color: Color(0xFF0D6B55),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ...filtered.map((product) {
                            final isSelected =
                                _nameController.text.trim().toLowerCase() ==
                                    product.name.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: isSelected
                                    ? const Color(0xFF0D6B55).withOpacity(0.06)
                                    : const Color(0xFFF8FBFA),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    _nameController.text = product.name;
                                    _brandController.text = product.brand;
                                    _barcodeController.text = product.barcode;
                                    _salePriceController.text =
                                        product.salePrice.toString();
                                    _purchasePriceController.text =
                                        product.purchasePrice.toString();
                                    if (categoryOptions
                                        .contains(product.category)) {
                                      _selectedCategory = product.category;
                                      _categoryController.text =
                                          product.category;
                                    }
                                    if (_units.contains(product.packInfo)) {
                                      _selectedUnit = product.packInfo;
                                      _unitController.text = product.packInfo;
                                    }
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: isSelected
                                              ? const Color(0xFF0D6B55)
                                              : const Color(0xFF71827F),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFF16302E),
                                                  fontWeight: isSelected
                                                      ? FontWeight.w800
                                                      : FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'ক্যাটাগরি: ${product.category} • বারকোড: ${product.barcode}',
                                                style: const TextStyle(
                                                  color: Color(0xFF71827F),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (filtered.isEmpty && !showAddNew)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  'কোনো পণ্য পাওয়া যায়নি। টাইপ করে নতুন পণ্যের নাম যোগ করুন।',
                                  style: TextStyle(color: Color(0xFF71827F)),
                                ),
                              ),
                            ),
                        ],
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

  void _showCategorySelectionSheet() {
    final categories = ref.read(categoryProvider);
    final categoryOptions = _productCategoryOptions(categories);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final searchController = TextEditingController();
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = categoryOptions.where((cat) {
              final needle = query.trim().toLowerCase();
              if (needle.isEmpty) return true;
              return cat.toLowerCase().contains(needle);
            }).toList();

            final showAddNew = query.trim().isNotEmpty &&
                !categoryOptions
                    .any((c) => c.toLowerCase() == query.trim().toLowerCase());

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
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
                          const Text(
                            'ক্যাটাগরি নির্বাচন করুন',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF16302E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DokanSearchField(
                            controller: searchController,
                            hintText:
                                'ক্যাটাগরি খুঁজুন বা নতুন ক্যাটাগরি লিখুন...',
                            autofocus: true,
                            onChanged: (val) {
                              setSheetState(() {
                                query = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        children: [
                          if (showAddNew)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color:
                                    const Color(0xFF0D6B55).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    final newCat = query.trim();
                                    ref
                                        .read(categoryProvider.notifier)
                                        .addCategory(newCat);
                                    _selectedCategory = newCat;
                                    _categoryController.text = newCat;
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Color(0xFF0D6B55)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'নতুন ক্যাটাগরি যোগ করুন: "$query"',
                                            style: const TextStyle(
                                              color: Color(0xFF0D6B55),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ...filtered.map((cat) {
                            final isSelected =
                                _selectedCategory.toLowerCase() ==
                                    cat.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: isSelected
                                    ? const Color(0xFF0D6B55).withOpacity(0.06)
                                    : const Color(0xFFF8FBFA),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    _selectedCategory = cat;
                                    _categoryController.text = cat;
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: isSelected
                                              ? const Color(0xFF0D6B55)
                                              : const Color(0xFF71827F),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          cat,
                                          style: TextStyle(
                                            color: const Color(0xFF16302E),
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (filtered.isEmpty && !showAddNew)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  'কোনো ক্যাটাগরি পাওয়া যায়নি। টাইপ করে নতুন ক্যাটাগরি যোগ করুন।',
                                  style: TextStyle(color: Color(0xFF71827F)),
                                ),
                              ),
                            ),
                        ],
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

  void _showUnitSelectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final searchController = TextEditingController();
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = _units.where((unit) {
              final needle = query.trim().toLowerCase();
              if (needle.isEmpty) return true;
              return unit.toLowerCase().contains(needle);
            }).toList();

            final showAddNew = query.trim().isNotEmpty &&
                !_units
                    .any((u) => u.toLowerCase() == query.trim().toLowerCase());

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
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
                          const Text(
                            'পরিমাণের একক নির্বাচন করুন',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF16302E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DokanSearchField(
                            controller: searchController,
                            hintText: 'একক খুঁজুন বা নতুন একক লিখুন...',
                            autofocus: true,
                            onChanged: (val) {
                              setSheetState(() {
                                query = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        children: [
                          if (showAddNew)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color:
                                    const Color(0xFF0D6B55).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    final newUnit = query.trim();
                                    if (!_units.contains(newUnit)) {
                                      _units.add(newUnit);
                                    }
                                    _selectedUnit = newUnit;
                                    _unitController.text = newUnit;
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Color(0xFF0D6B55)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'নতুন একক যোগ করুন: "$query"',
                                            style: const TextStyle(
                                              color: Color(0xFF0D6B55),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ...filtered.map((unit) {
                            final isSelected = _selectedUnit.toLowerCase() ==
                                unit.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: isSelected
                                    ? const Color(0xFF0D6B55).withOpacity(0.06)
                                    : const Color(0xFFF8FBFA),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    _selectedUnit = unit;
                                    _unitController.text = unit;
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: isSelected
                                              ? const Color(0xFF0D6B55)
                                              : const Color(0xFF71827F),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          unit,
                                          style: TextStyle(
                                            color: const Color(0xFF16302E),
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (filtered.isEmpty && !showAddNew)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  'কোনো একক পাওয়া যায়নি। টাইপ করে নতুন একক যোগ করুন।',
                                  style: TextStyle(color: Color(0xFF71827F)),
                                ),
                              ),
                            ),
                        ],
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

  void _showBrandSelectionSheet() {
    final catalog = ref.read(dokanInventoryCatalogProvider);
    final existingBrands = catalog
        .map((p) => p.brand.trim())
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();
    if (existingBrands.isEmpty) {
      existingBrands.addAll([
        'PRAN',
        'Radhuni',
        'Ruchi',
        'Square',
        'Akij',
        'Aarong',
        'Fresh',
        'Teer'
      ]);
    }
    existingBrands.sort();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final searchController = TextEditingController();
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = existingBrands.where((brand) {
              final needle = query.trim().toLowerCase();
              if (needle.isEmpty) return true;
              return brand.toLowerCase().contains(needle);
            }).toList();

            final showAddNew = query.trim().isNotEmpty &&
                !existingBrands
                    .any((b) => b.toLowerCase() == query.trim().toLowerCase());

            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
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
                          const Text(
                            'ব্র্যান্ড নির্বাচন করুন',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF16302E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DokanSearchField(
                            controller: searchController,
                            hintText:
                                'ব্র্যান্ড খুঁজুন বা নতুন ব্র্যান্ড টাইপ করুন...',
                            autofocus: true,
                            onChanged: (val) {
                              setSheetState(() {
                                query = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        children: [
                          if (showAddNew)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color:
                                    const Color(0xFF0D6B55).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    final newBrandName = query.trim();
                                    _brandController.text = newBrandName;
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Color(0xFF0D6B55)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'নতুন ব্র্যান্ড যোগ করুন: "$query"',
                                            style: const TextStyle(
                                              color: Color(0xFF0D6B55),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ...filtered.map((brand) {
                            final isSelected =
                                _brandController.text.trim().toLowerCase() ==
                                    brand.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: isSelected
                                    ? const Color(0xFF0D6B55).withOpacity(0.06)
                                    : const Color(0xFFF8FBFA),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    _brandController.text = brand;
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.check_circle_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: isSelected
                                              ? const Color(0xFF0D6B55)
                                              : const Color(0xFF71827F),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          brand,
                                          style: TextStyle(
                                            color: const Color(0xFF16302E),
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (filtered.isEmpty && !showAddNew)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  'কোনো ব্র্যান্ড পাওয়া যায়নি। টাইপ করে নতুন ব্র্যান্ড যোগ করুন।',
                                  style: TextStyle(color: Color(0xFF71827F)),
                                ),
                              ),
                            ),
                        ],
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

  Future<void> _chooseImageSource() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ছবি নির্বাচন',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined,
                      color: Color(0xFF111111)),
                  title: const Text(
                    'গ্যালারি থেকে',
                    style: TextStyle(
                        color: Color(0xFF111111), fontWeight: FontWeight.w700),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined,
                      color: Color(0xFF111111)),
                  title: const Text(
                    'ক্যামেরা থেকে',
                    style: TextStyle(
                        color: Color(0xFF111111), fontWeight: FontWeight.w700),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.do_not_disturb_alt_outlined,
                      color: Color(0xFF111111)),
                  title: const Text(
                    'ছবি বাদ দিন',
                    style: TextStyle(
                        color: Color(0xFF111111), fontWeight: FontWeight.w700),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('remove'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || choice == null) {
      return;
    }

    setState(() {
      if (choice == 'remove') {
        _selectedImageLabel = 'ছবি যোগ করা হয়নি';
        _imageHint = null;
        _imageError = null;
      } else if (choice == 'camera') {
        _selectedImageLabel = 'ক্যামেরা থেকে ছবি';
        _imageHint = 'ছবি নির্বাচিত';
        _imageError = null;
      } else {
        _selectedImageLabel = 'গ্যালারি থেকে ছবি';
        _imageHint = 'ছবি নির্বাচিত';
        _imageError = null;
      }
    });
  }

  String? _validateBarcode(String? value) {
    final barcode = value?.trim() ?? '';
    if (barcode.isEmpty) return null;
    if (widget.existingBarcodes.contains(barcode)) {
      return 'এই বারকোডটি ইতিমধ্যে আছে';
    }
    return null;
  }

  String? _validateRequiredText(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() => _imageError = null);
    setState(() => _formError = null);

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    final name = _nameController.text.trim();
    final barcode = _barcodeController.text.trim();
    final barcodeRequired = ref.read(appPreferencesProvider).barcodeRequired;
    final effectiveBarcode = barcode.isNotEmpty
        ? barcode
        : (barcodeRequired
            ? ''
            : 'AUTO-${DateTime.now().millisecondsSinceEpoch}');
    final salePrice = _parseInt(_salePriceController.text);
    final purchasePrice = _parseInt(_purchasePriceController.text);
    final stock = _parseInt(_stockController.text, fallback: 0);
    final lowStock = _parseInt(_lowStockController.text, fallback: 5);
    final brand = _brandController.text.trim();
    final categoryOptions = _productCategoryOptions(ref.read(categoryProvider));
    final category = categoryOptions.contains(_selectedCategory)
        ? _selectedCategory
        : categoryOptions.first;

    if (name.isEmpty ||
        (barcodeRequired && effectiveBarcode.isEmpty) ||
        brand.isEmpty) {
      setState(() => _formError = 'সব আবশ্যিক তথ্য পূরণ করুন');
      setState(() => _isSaving = false);
      return;
    }

    Navigator.of(context).pop(
      DokanCatalogProduct(
        name: name,
        barcode: effectiveBarcode,
        category: category,
        emoji: _emojiForCategory(category),
        brand: brand,
        unit: _selectedUnit,
        imageLabel: _selectedImageLabel,
        salePrice: salePrice,
        purchasePrice: purchasePrice,
        stock: stock,
        lowStockThreshold: lowStock <= 0 ? 5 : lowStock,
        salesCount: 0,
        packInfo: _selectedUnit,
      ),
    );
  }

  Widget _buildFieldCard({
    required String label,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E6E2)),
      ),
      child: Column(
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
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF8FA29F),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD9E6E2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF00694C), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD43B3B), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD43B3B), width: 1.5),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFD43B3B),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final categoryOptions = _productCategoryOptions(categories);
    final selectedCategory = categoryOptions.contains(_selectedCategory)
        ? _selectedCategory
        : categoryOptions.first;
    return DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: 'Hind Siliguri'),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F8F7),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                DokanFadeSlideIn(
                  delay: Duration.zero,
                  child: Container(
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
                            onTap: _isSaving
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(Icons.arrow_back,
                                  color: Color(0xFF3D4943)),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'নতুন পণ্য যোগ করুন',
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
                ),
                const SizedBox(height: 14),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 40),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FBFA),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD8E6E1)),
                    ),
                    child: const Text(
                      'এই পণ্যটি আপনার দোকানে সাথে সাথে যোগ হবে এবং আমাদের টিম যাচাই করে Master DB তে যুক্ত করবে',
                      style: TextStyle(
                        color: Color(0xFF55605C),
                        fontSize: 13,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: GestureDetector(
                    onTap: _isSaving ? null : _chooseImageSource,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _imageHint == null
                              ? const Color(0xFFD9E6E2)
                              : const Color(0xFF0C8C67),
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF7F0),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _imageHint == null
                                  ? Icons.photo_outlined
                                  : Icons.check_circle_outline,
                              color: const Color(0xFF0C8C67),
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ছবি যোগ করুন (ঐচ্ছিক)',
                                  style: TextStyle(
                                    color: Color(0xFF111111),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _selectedImageLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF111111),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_imageHint != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _imageHint!,
                                    style: const TextStyle(
                                      color: Color(0xFF111111),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_imageError != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      _imageError!,
                      style: const TextStyle(
                        color: Color(0xFFD43B3B),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                if (_formError != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD43B3B)),
                    ),
                    child: const Text(
                      'সব আবশ্যিক তথ্য পূরণ করুন',
                      style: TextStyle(
                        color: Color(0xFFD43B3B),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: _buildFieldCard(
                    label: 'পণ্যের নাম (আবশ্যিক) *',
                    child: TextFormField(
                      controller: _nameController,
                      readOnly: true,
                      onTap: _showNameSelectionSheet,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'পণ্যের নাম দিন';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        hintText: 'যেমন: প্রাণ আলু চিপস',
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF6F7D78),
                        ),
                      ),
                      style: const TextStyle(
                          color: Color(0xFF111111), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  child: _buildFieldCard(
                    label: 'ক্যাটাগরি *',
                    child: TextFormField(
                      controller: _categoryController,
                      readOnly: true,
                      onTap: _showCategorySelectionSheet,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'ক্যাটাগরি নির্বাচন করুন';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        hintText: 'ক্যাটাগরি নির্বাচন করুন',
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF6F7D78),
                        ),
                      ),
                      style: const TextStyle(
                          color: Color(0xFF111111), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: _buildFieldCard(
                    label: 'ব্র্যান্ড *',
                    child: TextFormField(
                      controller: _brandController,
                      readOnly: true,
                      onTap: _showBrandSelectionSheet,
                      validator: (value) =>
                          _validateRequiredText(value, 'ব্র্যান্ড দিন'),
                      decoration: _inputDecoration(
                        hintText: 'যেমন: প্রাণ',
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF6F7D78),
                        ),
                      ),
                      style: const TextStyle(
                          color: Color(0xFF111111), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 240),
                  child: _buildFieldCard(
                    label: 'পরিমাণের একক *',
                    child: TextFormField(
                      controller: _unitController,
                      readOnly: true,
                      onTap: _showUnitSelectionSheet,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'পরিমাণের একক নির্বাচন করুন';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        hintText: 'পিস / কেজি / লিটার / প্যাকেট',
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF6F7D78),
                        ),
                      ),
                      style: const TextStyle(
                          color: Color(0xFF111111), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 280),
                  child: _buildFieldCard(
                    label: 'বারকোড *',
                    child: TextFormField(
                      controller: _barcodeController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final textError =
                            _validateRequiredText(value, 'বারকোড দিন');
                        if (textError != null) return textError;
                        if (value!.trim().length < 6) {
                          return 'কমপক্ষে ৬ সংখ্যা দিন';
                        }
                        return _validateBarcode(value);
                      },
                      decoration: _inputDecoration(hintText: 'বারকোড লিখুন'),
                      style: const TextStyle(
                          color: Color(0xFF111111), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 320),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFieldCard(
                          label: 'বিক্রয় মূল্য ৳ *',
                          child: TextFormField(
                            controller: _salePriceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: NumericInputFormatters.wholeNumber,
                            readOnly: !ref.watch(dokanAppFlowProvider).can(DokanPermission.settingsManage),
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              final parsed = int.tryParse(value?.trim() ?? '');
                              if (parsed == null || parsed <= 0) {
                                return 'বিক্রয় মূল্য দিন';
                              }
                              return null;
                            },
                            decoration: _inputDecoration(hintText: '৳ ০'),
                            style: const TextStyle(
                                color: Color(0xFF111111),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFieldCard(
                          label: 'ক্রয় মূল্য ৳',
                          child: TextFormField(
                            controller: _purchasePriceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: NumericInputFormatters.wholeNumber,
                            readOnly: !ref.watch(dokanAppFlowProvider).can(DokanPermission.settingsManage),
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'ক্রয় মূল্য দিন';
                              }
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null || parsed < 0) {
                                return 'সঠিক ক্রয় মূল্য দিন';
                              }
                              return null;
                            },
                            decoration: _inputDecoration(hintText: '৳ ০'),
                            style: const TextStyle(
                                color: Color(0xFF111111),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 360),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFieldCard(
                          label: 'বর্তমান স্টক',
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            inputFormatters: NumericInputFormatters.wholeNumber,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'বর্তমান স্টক দিন';
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null || parsed < 0) {
                                return 'সঠিক স্টক দিন';
                              }
                              return null;
                            },
                            decoration: _inputDecoration(hintText: '০'),
                            style: const TextStyle(
                                color: Color(0xFF111111),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFieldCard(
                          label: 'কম স্টক সীমা',
                          child: TextFormField(
                            controller: _lowStockController,
                            keyboardType: TextInputType.number,
                            inputFormatters: NumericInputFormatters.wholeNumber,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'কম স্টক সীমা দিন';
                              final parsed = int.tryParse(value.trim());
                              if (parsed == null || parsed < 0) {
                                return 'সঠিক সীমা দিন';
                              }
                              return null;
                            },
                            decoration: _inputDecoration(hintText: '৫'),
                            style: const TextStyle(
                                color: Color(0xFF111111),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F0),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'প্রিভিউ',
                          style: TextStyle(
                            color: Color(0xFF141F22),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _nameController.text.trim().isEmpty
                              ? 'পণ্যের নাম'
                              : _nameController.text.trim(),
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ক্যাটাগরি: $_selectedCategory • একক: $_selectedUnit',
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'বারকোড: ${_barcodeController.text.trim().isEmpty ? 'স্বয়ংক্রিয়ভাবে তৈরি হবে' : _barcodeController.text.trim()}',
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 440),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FBFA),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD8E6E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.check_circle_rounded,
                                color: Color(0xFF0C8C67), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'পণ্যের তথ্য যাচাই করলে দ্রুত Master DB তে যুক্ত হবে',
                                style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 480),
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C8C67),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: Colors.white),
                            )
                          : const Text(
                              'পণ্য যোগ করুন',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildFieldCard(
                  label: 'স্মারক',
                  child: Text(
                    _selectedImageLabel,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
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
