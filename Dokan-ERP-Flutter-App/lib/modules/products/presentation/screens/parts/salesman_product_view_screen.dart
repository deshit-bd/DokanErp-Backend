part of '../product_screens.dart';

class DokanSalesmanProductViewScreen extends ConsumerStatefulWidget {
  const DokanSalesmanProductViewScreen({super.key});

  @override
  ConsumerState<DokanSalesmanProductViewScreen> createState() =>
      _DokanSalesmanProductViewScreenState();
}

class _DokanSalesmanProductViewScreenState
    extends ConsumerState<DokanSalesmanProductViewScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'সব';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DokanCatalogProduct> _visibleProducts(
    List<DokanCatalogProduct> products,
    List<String> categories,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    final categoryExists = categories.contains(_selectedCategory);

    return products.where((product) {
      final matchesCategory = _selectedCategory == 'সব' ||
          !categoryExists ||
          product.category == _selectedCategory;
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList()
      ..sort((a, b) {
        final lowStockCompare = a.stock.compareTo(b.stock);
        if (lowStockCompare != 0) return lowStockCompare;
        return a.name.compareTo(b.name);
      });
  }

  Future<void> _sendStockAlert(DokanCatalogProduct product) async {
    final flow = ref.read(dokanAppFlowProvider);
    final threshold = product.lowStockThreshold;
    addSalesmanLowStockNotification(
      productName: product.name,
      stock: product.stock,
      lowStockLimit: threshold,
      salesmanId: flow.currentSalesmanPhone ?? 'salesman',
      salesmanName: flow.currentSalesmanName ?? 'Salesman',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} alert sent to owner'),
        backgroundColor: const Color(0xFF0F766E),
      ),
    );
  }

  void _openReadOnlyDetails(DokanCatalogProduct product) {
    final isLowStock = product.stock <= product.lowStockThreshold;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7E2E0),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isLowStock
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Barcode ${product.barcode}  |  ${product.category}',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _detailChip(
                          title: 'Stock',
                          value: product.stock.toString(),
                          color: isLowStock
                              ? const Color(0xFFD97706)
                              : const Color(0xFF0F766E),
                        ),
                        const SizedBox(width: 10),
                        _detailChip(
                          title: 'Low limit',
                          value: product.lowStockThreshold.toString(),
                          color: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _detailRow('Sale price', '৳${product.salePrice}'),
                    _detailRow('Purchase price', '৳${product.purchasePrice}'),
                    _detailRow('Sales count', product.salesCount.toString()),
                    const SizedBox(height: 18),
                    if (isLowStock)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _sendStockAlert(product);
                          },
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: const Text('Send stock alert'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Inventory edits are locked for salesman access.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(dokanAppFlowProvider);
    final catalogProducts = ref.watch(dokanInventoryCatalogProvider);
    final categories = ref.watch(categoryProvider);
    final threshold = ref.watch(stockThresholdProvider);
    final products = _visibleProducts(catalogProducts, categories);
    final lowStockCount = products
        .where((item) => item.stock > 0 && item.stock <= threshold)
        .length;
    final outOfStockCount = products.where((item) => item.stock <= 0).length;
    final categoryItems = <String>[
      'সব',
      ...categories
          .where((category) => category != DokanCategoryNotifier.uncategorized)
    ];

    if (_selectedCategory != 'সব' &&
        !categoryItems.contains(_selectedCategory)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedCategory = 'সব');
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F4C81), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x223B82F6),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          flow.currentSalesmanName ?? 'Salesman',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'VIEW ONLY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Products and stock are visible here. Inventory changes stay with the owner.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DokanSearchField(
                    controller: _searchController,
                    hintText: 'Search product or barcode',
                    onChanged: (value) => setState(() => _searchQuery = value),
                    showClear: _searchQuery.isNotEmpty,
                    borderRadius: 18,
                    onClear: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _metricCard('Products', products.length.toString(),
                    const Color(0xFF1D4ED8)),
                const SizedBox(width: 10),
                _metricCard('Low stock', lowStockCount.toString(),
                    const Color(0xFFD97706)),
                const SizedBox(width: 10),
                _metricCard(
                    'Out', outOfStockCount.toString(), const Color(0xFFDC2626)),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categoryItems
                    .map(
                      (label) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: _selectedCategory == label,
                          onSelected: (_) =>
                              setState(() => _selectedCategory = label),
                          selectedColor: const Color(0xFFDCE8FF),
                          labelStyle: TextStyle(
                            color: _selectedCategory == label
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFF334155),
                            fontWeight: FontWeight.w800,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                            side: const BorderSide(color: Color(0xFFD8E2F2)),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            if (products.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD8E2F2)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.search_off_outlined,
                        size: 44, color: Color(0xFF1D4ED8)),
                    SizedBox(height: 10),
                    Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...products.map(
                (product) {
                  final isLowStock = product.stock <= product.lowStockThreshold;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _openReadOnlyDetails(product),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isLowStock
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFD8E2F2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildProductThumbnail(product, size: 52),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: isLowStock
                                              ? const Color(0xFFB91C1C)
                                              : const Color(0xFF0F766E),
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.category}  |  ${product.barcode}',
                                        style: const TextStyle(
                                          color: Color(0xFF1F2937),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '৳${product.salePrice}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF0F766E),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLowStock
                                            ? const Color(0xFFFFE4E6)
                                            : const Color(0xFFE3F7EC),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        isLowStock ? 'LOW STOCK' : 'IN STOCK',
                                        style: TextStyle(
                                          color: isLowStock
                                              ? const Color(0xFFB91C1C)
                                              : const Color(0xFF047857),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _infoTile(
                                    title: 'Stock',
                                    value: product.stock.toString(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _infoTile(
                                    title: 'Limit',
                                    value: product.lowStockThreshold.toString(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _infoTile(
                                    title: 'Sales',
                                    value: product.salesCount.toString(),
                                  ),
                                ),
                              ],
                            ),
                            if (isLowStock) ...[
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _sendStockAlert(product),
                                  icon: const Icon(
                                    Icons.notification_important_outlined,
                                  ),
                                  label: const Text('Alert owner'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F766E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD8E2F2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailChip({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProductThumbnail(DokanCatalogProduct product, {double size = 52}) {
  final url = product.imageLabel.trim();
  final isNetworkUrl = url.startsWith('http://') || url.startsWith('https://');
  final isAssetUrl = url.startsWith('assets/');
  final isFileUrl = url.startsWith('/Users/') || url.startsWith('file://') || url.startsWith('/data/');

  if (url.isNotEmpty && url != 'ছবি যোগ করা হয়নি') {
    Widget? imageWidget;
    if (isNetworkUrl) {
      imageWidget = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackEmojiOrIcon(product, size: size),
      );
    } else if (isAssetUrl) {
      imageWidget = Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackEmojiOrIcon(product, size: size),
      );
    } else if (isFileUrl) {
      final filePath = url.replaceFirst('file://', '');
      imageWidget = Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackEmojiOrIcon(product, size: size),
      );
    } else if (url.length > 200 || url.startsWith('data:image')) {
      try {
        final cleanBase64 = url.contains(',') ? url.split(',').last : url;
        final bytes = base64Decode(cleanBase64);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackEmojiOrIcon(product, size: size),
        );
      } catch (_) {
        imageWidget = null;
      }
    }

    if (imageWidget != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: size,
          height: size,
          color: const Color(0xFFEFF4FF),
          child: imageWidget,
        ),
      );
    }
  }

  return _buildFallbackEmojiOrIcon(product, size: size);
}

Widget _buildFallbackEmojiOrIcon(DokanCatalogProduct product, {double size = 52}) {
  final emoji = product.emoji.trim();
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFEFF4FF),
      borderRadius: BorderRadius.circular(16),
    ),
    child: emoji.isNotEmpty && emoji != '📦'
        ? Text(emoji, style: TextStyle(fontSize: size * 0.46))
        : Icon(Icons.inventory_2_outlined, color: const Color(0xFF1D4ED8), size: size * 0.46),
  );
}
