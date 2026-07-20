part of '../sales_screens.dart';

String _banglaText(String value, {String fallback = 'পণ্যের নাম নেই'}) {
  final text = value.trim();
  return text.isEmpty ? fallback : text;
}

String _banglaDigits(String input) {
  const map = <String, String>{
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };
  return input.split('').map((char) => map[char] ?? char).join();
}

String _formatCurrency(int value) {
  return '৳${_banglaDigits(value.toString())}';
}

class DokanPosMainScreen extends ConsumerStatefulWidget {
  const DokanPosMainScreen({super.key});

  @override
  ConsumerState<DokanPosMainScreen> createState() => _DokanPosMainScreenState();
}

class _DokanPosMainScreenState extends ConsumerState<DokanPosMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerNumberController =
      TextEditingController();
  final TextEditingController _customerAddressController =
      TextEditingController();
  final TextEditingController _customerOpeningDueController =
      TextEditingController();
  final TextEditingController _paymentTransactionController =
      TextEditingController();
  final TextEditingController _cashReceivedController = TextEditingController();
  final TextEditingController _creditDueAmountController =
      TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _cardLast4Controller = TextEditingController();
  final TextEditingController _cardApprovalController = TextEditingController();
  final TextEditingController _cardBankController = TextEditingController();
  final TextEditingController _bankSenderController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankReferenceController =
      TextEditingController();
  final TextEditingController _bankRoutingController = TextEditingController();

  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  Map<String, String> _paymentFieldErrors = <String, String>{};

  static const List<_Category> _categories = <_Category>[
    _Category(label: 'সব পণ্য', englishLabel: 'All Products', key: 'all'),
    _Category(label: 'চাল-ডাল', englishLabel: 'Rice & Lentils', key: 'rice'),
    _Category(label: 'তেল-মসলা', englishLabel: 'Oil & Spices', key: 'oil'),
    _Category(
        label: 'প্যাকেট আইটেম', englishLabel: 'Packaged Items', key: 'pack'),
    _Category(label: 'দৈনন্দিন', englishLabel: 'Daily Needs', key: 'daily'),
  ];
  @override
  void initState() {
    super.initState();
    _discountController.text = '0';
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dokanInventoryCatalogProvider.notifier).refreshFromRepository();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _customerNameController.dispose();
    _customerNumberController.dispose();
    _customerAddressController.dispose();
    _customerOpeningDueController.dispose();
    _paymentTransactionController.dispose();
    _cashReceivedController.dispose();
    _creditDueAmountController.dispose();
    _dueDateController.dispose();
    _cardHolderController.dispose();
    _cardLast4Controller.dispose();
    _cardApprovalController.dispose();
    _cardBankController.dispose();
    _bankSenderController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankReferenceController.dispose();
    _bankRoutingController.dispose();
    super.dispose();
  }

  List<_Product> get _visibleProducts {
    final category = _categories[_selectedCategoryIndex].key;
    final catalog = ref.watch(dokanInventoryCatalogProvider);
    final sortedCatalog = List<DokanCatalogProduct>.from(catalog)
      ..sort((a, b) => b.salesCount.compareTo(a.salesCount));
    return sortedCatalog.map(_productFromCatalog).where((product) {
      final matchesCategory =
          category == 'all' || product.categoryKey == category;
      final matchesQuery = _searchQuery.isEmpty ||
          DokanSearchMatcher.match(product.name, _searchQuery) ||
          product.searchTerms
              .any((term) => DokanSearchMatcher.match(term, _searchQuery));
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  _Product _productFromCatalog(DokanCatalogProduct product) {
    return _Product(
      id: product.productId,
      name: product.name,
      imageUrl: product.imageLabel,
      price: product.salePrice,
      stock: product.stock,
      categoryKey: _categoryKeyFor(product.category),
      icon: _iconForCategory(product.category),
      searchTerms: <String>[
        product.name,
        product.productId,
        product.category,
      ],
    );
  }

  String _categoryKeyFor(String category) {
    switch (category) {
      case 'চাল-ডাল':
        return 'rice';
      case 'তেল-মসলা':
        return 'oil';
      case 'প্যাকেট আইটেম':
        return 'pack';
      case 'দৈনন্দিন':
        return 'daily';
      default:
        return 'all';
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'চাল-ডাল':
        return Icons.rice_bowl_outlined;
      case 'তেল-মসলা':
        return Icons.water_drop_outlined;
      case 'প্যাকেট আইটেম':
        return Icons.local_drink_outlined;
      case 'দৈনন্দিন':
        return Icons.local_laundry_service_outlined;
      case 'বিস্কুট':
        return Icons.cookie_outlined;
      case 'সাবান':
        return Icons.spa_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  void _addToCart(_Product product) {
    ref
        .read(dokanPosProvider.notifier)
        .addItem(product.id, stockLimit: product.stock);
  }

  void _removeFromCart(_Product product) {
    ref.read(dokanPosProvider.notifier).removeItem(product.id);
  }

  DokanCatalogProduct? _findCatalogProduct(String productId) {
    final catalog = ref.read(dokanInventoryCatalogProvider);
    for (final product in catalog) {
      if (product.productId == productId) {
        return product;
      }
    }
    return null;
  }

  Future<void> _openSalesSideMenu() async {
    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'বিক্রয় মেনু',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: _PosSalesSideMenu(
                onClose: () => Navigator.of(context).pop(),
                onTapHistory: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DokanPosSalesHistoryScreen(),
                    ),
                  );
                },
                onTapClosing: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DokanPosDailyClosingScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: offset, child: child);
      },
    );
  }

  void _showQuickNote(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF0C8C67),
          content: Text(
            tr(message, message),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  }

  void _showAlertDialog({
    required String title,
    required String message,
    required Color accent,
  }) {
    final isSuccess = accent == const Color(0xFF0C8C67);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 3),
          backgroundColor: isSuccess ? const Color(0xFF0C8C67) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: accent.withOpacity(0.45)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(title, title),
                style: TextStyle(
                  color: isSuccess ? Colors.white : accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr(message, message),
                style: TextStyle(
                  color: isSuccess ? Colors.white : Colors.red.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _showEmptyCartNotice() {
    _showAlertDialog(
      title: 'কার্ট খালি',
      message: 'কার্ট খালি আছে। অনুগ্রহ করে পণ্য যোগ করুন।',
      accent: const Color(0xFF0C8C67),
    );
  }

  String? _validatePhoneField(String value, String label) {
    final text = value.trim();
    if (text.isEmpty) {
      return '$label পূরণ করুন।';
    }
    if (!RegExp(r'^[0-9]{11}$').hasMatch(text)) {
      return '$label ১১ সংখ্যার হতে হবে।';
    }
    return null;
  }

  String? _validateTransactionField(String value, String label) {
    final text = value.trim();
    if (text.isEmpty) {
      return '$label পূরণ করুন।';
    }
    if (text.length < 6) {
      return '$label কমপক্ষে ৬ অক্ষরের হতে হবে।';
    }
    if (text.length > 20) {
      return '$label ২০ অক্ষরের বেশি হতে পারবে না।';
    }
    if (!RegExp(r'^[0-9A-Za-z]+$').hasMatch(text)) {
      return '$label-এ শুধু সংখ্যা ও ইংরেজি অক্ষর ব্যবহার করুন।';
    }
    return null;
  }

  String? _validateCardLast4(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return 'কার্ডের শেষ ৪ সংখ্যা পূরণ করুন।';
    }
    if (text.length != 4) {
      return 'কার্ডের শেষ ৪ সংখ্যা ঠিক ৪টি হতে হবে।';
    }
    if (!RegExp(r'^[0-9]{4}$').hasMatch(text)) {
      return 'কার্ডের শেষ ৪ সংখ্যা কেবল সংখ্যা হতে হবে।';
    }
    return null;
  }

  String? _validateAccountField(String value, String label) {
    final text = value.trim();
    if (text.isEmpty) {
      return '$label পূরণ করুন।';
    }
    if (text.length < 8) {
      return '$label কমপক্ষে ৮ সংখ্যার হতে হবে।';
    }
    if (text.length > 20) {
      return '$label ২০ সংখ্যার বেশি হতে পারবে না।';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
      return '$label শুধু সংখ্যা হতে হবে।';
    }
    return null;
  }

  Map<String, String> _validateCheckoutForm(DokanPosState state) {
    final result = ref.read(dokanPosProvider.notifier).validateCheckoutResult();
    return result.fieldErrors;
  }

  String _statusLabel(DokanPosOrderStatus status) {
    switch (status) {
      case DokanPosOrderStatus.paid:
        return 'পরিশোধিত';
      case DokanPosOrderStatus.due:
        return 'বাকি রয়েছে';
      case DokanPosOrderStatus.partiallyPaid:
        return 'আংশিক পরিশোধিত';
      case DokanPosOrderStatus.cancelled:
        return 'বাতিল';
    }
  }

  Color _statusColor(DokanPosOrderStatus status) {
    switch (status) {
      case DokanPosOrderStatus.paid:
        return const Color(0xFF0C8C67);
      case DokanPosOrderStatus.partiallyPaid:
        return const Color(0xFFC77700);
      case DokanPosOrderStatus.due:
      case DokanPosOrderStatus.cancelled:
        return const Color(0xFFB3261E);
    }
  }

  void _updateState(VoidCallback callback) => setState(callback);

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final flow = ref.watch(dokanAppFlowProvider);
    final isSalesman = flow.isSalesman;
    final products = _visibleProducts;
    final cartCount =
        ref.watch(dokanPosProvider.select((state) => state.cartCount));
    final grandTotal =
        ref.watch(dokanPosProvider.select((state) => state.total));
    final syncError = ref.watch(productSyncErrorProvider);

    final isWide = MediaQuery.of(context).size.width >= 720;

    return DokanResponsivePage(
      selectedIndex: 1,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          await handleDokanBackNavigation(context);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF2F7F6),
        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(dokanInventoryCatalogProvider.notifier)
                      .refreshFromRepository();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(16, 14, 16, isWide ? 110 : 185),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DokanFadeSlideIn(
                        delay: Duration.zero,
                        child: _buildTopBar(),
                      ),
                      if (syncError != null)
                        DokanFadeSlideIn(
                          delay: const Duration(milliseconds: 40),
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                              ),
                            ),
                            child: Text(
                              'Sync Error: $syncError',
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (isSalesman)
                        DokanFadeSlideIn(
                          delay: const Duration(milliseconds: 40),
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: const Text(
                              'সেলসম্যান মোড',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 80),
                        child: _buildSearchRow(),
                      ),
                      const SizedBox(height: 16),
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: SizedBox(
                          height: 46,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final selected = _selectedCategoryIndex == index;
                              return _CategoryChip(
                                label: tr(_categories[index].label,
                                    _categories[index].englishLabel),
                                selected: selected,
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 160),
                        child: Text(
                          tr('পণ্যসমূহ', 'Products'),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (products.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFD6E4E0)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 52,
                                color: Color(0xFF99BCB3),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                tr('কোন পণ্য পাওয়া যায়নি', 'No products found'),
                                style: const TextStyle(
                                  color: Color(0xFF52776E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (!isSalesman) ...[
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final scaffold = ScaffoldMessenger.of(context);
                                    Navigator.of(context)
                                        .push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const DokanAddProductMasterDbScreen(),
                                      ),
                                    )
                                        .then(
                                      (added) {
                                        if (added == true) {
                                          scaffold.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'নতুন পণ্য সফলভাবে যুক্ত হয়েছে'),
                                            ),
                                          );
                                          ref
                                              .read(
                                                  dokanInventoryCatalogProvider
                                                      .notifier)
                                              .refreshFromRepository();
                                        }
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF006B53),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text(
                                    'নতুন পণ্য যোগ করুন',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 4 : 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.77,
                          ),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final quantity = ref.watch(
                              dokanPosProvider.select((state) =>
                                  state.cartQuantities[product.id] ?? 0),
                            );
                            final selected = ref.watch(
                              dokanPosProvider.select(
                                  (state) => state.isSelected(product.id)),
                            );
                            return ScrollReveal(
                              key: ValueKey('pos-prod-$_selectedCategoryIndex-${product.id}-${product.name}'),
                              delay: Duration(milliseconds: (index % (isWide ? 4 : 2)) * 80),
                              child: _ProductCard(
                                product: product,
                                quantity: quantity,
                                selected: selected,
                                onAdd: () => _addToCart(product),
                                onRemove: () => _removeFromCart(product),
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
            ),
            if (cartCount > 0)
              Positioned(
                left: 16,
                right: 16,
                bottom: isWide ? 8 : 84,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: DokanFadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    offset: 30,
                    child: _CartDock(
                      count: cartCount,
                      total: grandTotal,
                      onTap: _openCartSheet,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: isWide
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2F0),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFD6E4E0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BottomNavButton(
                        icon: Icons.home_outlined,
                        label: AppStrings.tabHome,
                        selected: false,
                        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                      _BottomNavButton(
                        icon: Icons.point_of_sale_outlined,
                        label: AppStrings.tabSales,
                        selected: true,
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => DokanPosMainScreen(key: UniqueKey()),
                          ),
                        ),
                      ),
                      _BottomNavButton(
                        icon: Icons.inventory_2_outlined,
                        label: AppStrings.tabProducts,
                        selected: false,
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const DokanProductListScreen(),
                          ),
                        ),
                      ),
                      _BottomNavButton(
                        icon: Icons.bar_chart_outlined,
                        label: AppStrings.tabReports,
                        selected: false,
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const DokanReportsHomeScreen(),
                          ),
                        ),
                      ),
                      _BottomNavButton(
                        icon: Icons.more_horiz,
                        label: AppStrings.tabMore,
                        selected: false,
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const DokanAroOptionScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE7E4)),
      ),
      child: Row(
        children: [
          _TopIconButton(
            icon: Icons.menu,
            onTap: _openSalesSideMenu,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Center(
              child: Text(
                tr('বিক্রয় করুন', 'POS'),
                style: const TextStyle(
                  color: Color(0xFF006B53),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F2F0),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 10, color: Color(0xFF006B53)),
                const SizedBox(width: 6),
                Text(
                  tr('ONLINE', 'ONLINE'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _TopIconButton(
            icon: Icons.mic_none_rounded,
            onTap: () {
              final flow = ref.read(dokanAppFlowProvider);
              if (!FeatureAccessControl.can(
                flow.currentRole,
                DokanFeature.voiceAssist,
              )) {
                _showQuickNote(tr('ফিচার শিগগিরই আসছে', 'Feature coming soon'));
                return;
              }
              _showQuickNote(tr('ফিচার শিগগিরই আসছে', 'Feature coming soon'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: DokanSearchField(
            controller: _searchController,
            hintText: tr(
                'পণ্য খুঁজুন বা স্ক্যান করুন...', 'Search or scan products...'),
            height: 58,
            borderRadius: 18,
            showClear: _searchQuery.isNotEmpty,
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF006B53),
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            onPressed: () async {
              final status = await ref
                  .read(dokanScannerPermissionServiceProvider)
                  .ensureCameraPermission();
              if (!context.mounted) return;
              if (!status.isGranted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ক্যামেরা অনুমতি না পেলে স্ক্যান হবে না'),
                    backgroundColor: Color(0xFFB3261E),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DokanBarcodeScannerScreen(),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
