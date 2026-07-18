part of '../product_screens.dart';

final Set<String> _failedProductImageUrls = {};

extension _DokanProductListActions on _DokanProductListScreenState {
  List<DokanCatalogProduct> _visibleProducts(
      List<DokanCatalogProduct> catalogProducts, List<String> categories) {
    final query = _searchQuery.trim().toLowerCase();
    final categoryExists = categories.contains(_selectedCategory);
    final filtered = catalogProducts.where((product) {
      final matchesCategory = _selectedCategory == 'সব' ||
          !categoryExists ||
          product.category == _selectedCategory;
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    switch (_sortMode) {
      case _ProductSortMode.newest:
        break;
      case _ProductSortMode.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _ProductSortMode.lowStock:
        filtered.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case _ProductSortMode.highestSales:
        filtered.sort((a, b) => b.salesCount.compareTo(a.salesCount));
        break;
    }

    return filtered;
  }

  Future<void> _openAddProductScreen() async {
    final flow = ref.read(dokanAppFlowProvider);

    if (!flow.can(DokanPermission.stockAdjust)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সেলসম্যান নতুন পণ্য যোগ করতে পারবেন না'),
        ),
      );
      return;
    }
    final existingBarcodes = ref
        .read(dokanInventoryCatalogProvider)
        .map((product) => product.barcode)
        .toSet();
    final createdProduct =
        await Navigator.of(context).push<DokanCatalogProduct>(
      MaterialPageRoute(
        builder: (_) =>
            DokanNewProductAddScreen(existingBarcodes: existingBarcodes),
      ),
    );

    if (!mounted || createdProduct == null) {
      return;
    }

    ref.read(dokanInventoryCatalogProvider.notifier).addProduct(createdProduct);
    _updateListState(() {
      _selectedCategory = 'সব';
      _sortMode = _ProductSortMode.name;
      _searchQuery = '';
      _searchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('পণ্য সফলভাবে যোগ করা হয়েছে'),
        backgroundColor: Color(0xFF0C8C67),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openInventoryDrawer() {
    final flow = ref.read(dokanAppFlowProvider);

    if (!flow.can(DokanPermission.stockAdjust)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সেলসম্যান মোডে সেটিংস ব্যবহার করা যাবে না'),
        ),
      );
      return;
    }
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'inventory-drawer',
      barrierColor: Colors.black.withOpacity(0.38),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SafeArea(
            child: FractionallySizedBox(
              widthFactor: 0.86,
              heightFactor: 1,
              child: Material(
                color: const Color(0xFFF7FBF8),
                elevation: 20,
                shadowColor: Colors.black26,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF7F0),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'পণ্য মেনু',
                            style: TextStyle(
                              color: Color(0xFF00694C),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'স্টক, ক্যাটাগরি আর সতর্কতা সেটিংস',
                            style: TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                        children: [
                          _DrawerActionTile(
                            icon: Icons.warning_amber_rounded,
                            title: 'কম স্টক সতর্কতা',
                            subtitle: 'থ্রেশহোল্ড ও সতর্কতা হালনাগাদ করুন',
                            onTap: () {
                              final flow = ref.read(dokanAppFlowProvider);

                              if (!flow.can(DokanPermission.notificationsView)) {
                                Navigator.of(dialogContext).pop();
                                return;
                              }
                              Navigator.of(dialogContext).pop();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const DokanLowStockAlertScreen(),
                                  ),
                                );
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          _DrawerActionTile(
                            icon: Icons.category_rounded,
                            title: 'ক্যাটাগরি সেটিংস',
                            subtitle:
                                'নতুন ক্যাটাগরি যোগ, মুছুন বা সম্পাদনা করুন',
                            onTap: () {
                              final flow = ref.read(dokanAppFlowProvider);

                              if (!flow.can(DokanPermission.stockAdjust)) {
                                Navigator.of(dialogContext).pop();
                                return;
                              }

                              Navigator.of(dialogContext).pop();

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const DokanCategorySettingsScreen(),
                                  ),
                                );
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          _DrawerActionTile(
                            icon: Icons.timeline_rounded,
                            title: 'স্টক মুভমেন্ট লগ',
                            subtitle: 'স্টক add / reduce / sales history',
                            onTap: () {
                              final flow = ref.read(dokanAppFlowProvider);
                              if (!flow.can(DokanPermission.stockAdjust)) {
                                Navigator.of(dialogContext).pop();
                                return;
                              }
                              Navigator.of(dialogContext).pop();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const DokanStockMovementLogScreen(),
                                  ),
                                );
                              });
                            },
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
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  void _openSortMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: DefaultTextStyle.merge(
            style: const TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.w700,
            ),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _ProductSortMode.values.map((mode) {
                  final label = switch (mode) {
                    _ProductSortMode.newest => 'নতুন পণ্য আগে',
                    _ProductSortMode.name => 'নাম অনুযায়ী',
                    _ProductSortMode.lowStock => 'কম স্টক আগে',
                    _ProductSortMode.highestSales => 'বেশি বিক্রি',
                  };
                  return ListTile(
                    leading: Icon(
                      mode == _ProductSortMode.newest
                          ? Icons.fiber_new_rounded
                          : mode == _ProductSortMode.name
                              ? Icons.sort_by_alpha
                              : mode == _ProductSortMode.lowStock
                                  ? Icons.arrow_upward
                                  : Icons.trending_up,
                      color: const Color(0xFF00694C),
                    ),
                    title: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    trailing: _sortMode == mode
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF0C8C67))
                        : null,
                    onTap: () {
                      _updateListState(() => _sortMode = mode);
                      Navigator.of(sheetContext).pop();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openProductDetail(DokanCatalogProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DokanProductDetailScreen(product: product),
      ),
    );
  }

  Widget _buildBottomNav() {
    final isWide = MediaQuery.of(context).size.width >= 720;
    if (isWide) {
      return const SizedBox.shrink();
    }
    return _ProductBottomNav(
      selectedIndex: 2,
      onHomeTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DokanHomeDashboardScreen()),
      ),
      onSalesTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DokanPosSalesHistoryScreen()),
      ),
      onProductsTap: () {},
      onReportsTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DokanReportsHomeScreen()),
      ),
      onMoreTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DokanAroOptionScreen()),
      ),
    );
  }

  Widget _statChip(String title, String value, {Color? accent}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD9E6E2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF5F6A66),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: accent ?? const Color(0xFF141F22),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _translateCategory(String label) {
    if (label == 'সব') return tr('সব', 'All');
    if (label == 'চাল-ডাল') return tr('চাল-ডাল', 'Rice & Lentils');
    if (label == 'তেল-মসলা') return tr('তেল-মসলা', 'Spices & Oil');
    if (label == 'সাবান') return tr('সাবান', 'Soaps & Detergents');
    if (label == 'প্যাকেট আইটেম') return tr('প্যাকেট আইটেম', 'Packaged Items');
    if (label == 'দৈনন্দিন') return tr('দৈনন্দিন', 'Daily Needs');
    return label;
  }

  Widget _categoryChip(String label) {
    final selected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => _updateListState(() => _selectedCategory = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  selected ? const Color(0xFF00694C) : const Color(0xFFEAF2F0),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _translateCategory(label),
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF3D4943),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _productCard(DokanCatalogProduct product, int threshold) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openProductDetail(product),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD9E6E2)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB9C8C3).withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _productThumbnail(product),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.brand.isNotEmpty
                          ? '${product.category} • ${product.brand}'
                          : product.category,
                      style: const TextStyle(
                        color: Color(0xFF5F6A66),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr('বারকোড: ${product.barcode}',
                          'Barcode: ${product.barcode}'),
                      style: const TextStyle(
                        color: Color(0xFF7C8A84),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currency(product.salePrice),
                    style: const TextStyle(
                      color: Color(0xFF00694C),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final activeThreshold = product.lowStockThreshold > 0
                          ? product.lowStockThreshold
                          : threshold;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _stockStatusBackground(
                              product.stock, activeThreshold),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.stock <= 0
                              ? tr('স্টক নেই', 'Out of Stock')
                              : tr(
                                  'স্টক ${_bnDigits(product.stock.toString())}টি',
                                  'Stock: ${_bnDigits(product.stock.toString())} items'),
                          style: TextStyle(
                            color: _stockStatusColor(
                                product.stock, activeThreshold),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DokanNewPurchaseScreen(initialProduct: product),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00694C).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                const Color(0xFF00694C).withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add_shopping_cart_rounded,
                              size: 12, color: Color(0xFF00694C)),
                          SizedBox(width: 4),
                          Text(
                            'ক্রয় করুন',
                            style: TextStyle(
                              color: Color(0xFF00694C),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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
  }

  Widget _productThumbnail(DokanCatalogProduct product) {
    final imageUrl = product.imageLabel.trim();
    if (imageUrl.isNotEmpty && !_failedProductImageUrls.contains(imageUrl)) {
      return ClipOval(
        child: Container(
          width: 62,
          height: 62,
          color: const Color(0xFFEAF2F0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              _failedProductImageUrls.add(imageUrl);
              return Center(
                child: Text(product.emoji, style: const TextStyle(fontSize: 30)),
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 62,
      height: 62,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF2F0),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(product.emoji, style: const TextStyle(fontSize: 30)),
    );
  }
}
