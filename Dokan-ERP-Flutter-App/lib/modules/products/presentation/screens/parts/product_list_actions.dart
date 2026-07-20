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

  Widget _statChip(String title, String value, {Color? accent, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
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
    final activeThreshold = product.lowStockThreshold > 0
        ? product.lowStockThreshold
        : threshold;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openProductDetail(product),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _productThumbnail(product),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.brand.isNotEmpty
                          ? '${product.category} • ${product.brand}'
                          : product.category,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr('বারকোড: ${product.barcode}',
                          'Barcode: ${product.barcode}'),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currency(product.salePrice),
                    style: const TextStyle(
                      color: Color(0xFF00694C),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
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
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DokanNewPurchaseScreen(initialProduct: product),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00694C).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF00694C)
                                .withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add_shopping_cart_rounded,
                              size: 12, color: Color(0xFF00694C)),
                          SizedBox(width: 3),
                          Text(
                            'ক্রয় করুন',
                            style: TextStyle(
                              color: Color(0xFF00694C),
                              fontSize: 10.5,
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
    final url = product.imageLabel.trim();
    final isNetworkUrl = url.startsWith('http://') || url.startsWith('https://');
    final isAssetUrl = url.startsWith('assets/');
    final isFileUrl = url.startsWith('/Users/') || url.startsWith('file://') || url.startsWith('/data/');

    if (url.isNotEmpty && url != 'ছবি যোগ করা হয়নি' && !_failedProductImageUrls.contains(url)) {
      Widget? imageWidget;
      if (isNetworkUrl) {
        imageWidget = Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            _failedProductImageUrls.add(url);
            return _productFallbackCircle(product);
          },
        );
      } else if (isAssetUrl) {
        imageWidget = Image.asset(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            _failedProductImageUrls.add(url);
            return _productFallbackCircle(product);
          },
        );
      } else if (isFileUrl) {
        final filePath = url.replaceFirst('file://', '');
        imageWidget = Image.file(
          File(filePath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            _failedProductImageUrls.add(url);
            return _productFallbackCircle(product);
          },
        );
      } else if (url.length > 200 || url.startsWith('data:image')) {
        try {
          final cleanBase64 = url.contains(',') ? url.split(',').last : url;
          final bytes = base64Decode(cleanBase64);
          imageWidget = Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              _failedProductImageUrls.add(url);
              return _productFallbackCircle(product);
            },
          );
        } catch (_) {
          imageWidget = null;
        }
      }

      if (imageWidget != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 48,
            height: 48,
            color: const Color(0xFFF1F5F9),
            child: imageWidget,
          ),
        );
      }
    }

    return _productFallbackCircle(product);
  }

  Widget _productFallbackCircle(DokanCatalogProduct product) {
    final emoji = product.emoji.trim();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: emoji.isNotEmpty && emoji != '📦'
          ? Text(emoji, style: const TextStyle(fontSize: 22))
          : const Icon(Icons.inventory_2_outlined, color: Color(0xFF0F766E), size: 22),
    );
  }
}
