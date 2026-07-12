part of '../product_screens.dart';

class DokanProductListScreen extends ConsumerStatefulWidget {
  const DokanProductListScreen({super.key});

  @override
  ConsumerState<DokanProductListScreen> createState() =>
      _DokanProductListScreenState();
}

class _DokanProductListScreenState
    extends ConsumerState<DokanProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'সব';
  _ProductSortMode _sortMode = _ProductSortMode.newest;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateListState(VoidCallback callback) => setState(callback);

  @override
  Widget build(BuildContext context) {
    ref.watch(languageProvider);
    final flow = ref.watch(dokanAppFlowProvider);
    final isSalesman = flow.isSalesman;
    if (isSalesman) {
      return const DokanSalesmanProductViewScreen();
    }

    final catalogProducts = ref.watch(dokanInventoryCatalogProvider);
    final categories = ref.watch(categoryProvider);
    final threshold = ref.watch(stockThresholdProvider);
    final visibleProducts = _visibleProducts(catalogProducts, categories);
    final syncError = ref.watch(productSyncErrorProvider);
    final normalizedCategories = <String>[
      'সব',
      ...categories
          .where((category) => category != DokanCategoryNotifier.uncategorized)
    ];
    if (_selectedCategory != 'সব' &&
        !normalizedCategories.contains(_selectedCategory)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_selectedCategory != 'সব' &&
            !ref.read(categoryProvider).contains(_selectedCategory)) {
          setState(() => _selectedCategory = 'সব');
        }
      });
    }
    final lowStockCount = visibleProducts.where((item) {
      final activeThreshold =
          item.lowStockThreshold > 0 ? item.lowStockThreshold : threshold;
      return item.stock > 0 && item.stock <= activeThreshold;
    }).length;
    final outOfStockCount =
        visibleProducts.where((item) => item.stock <= 0).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (syncError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  'Sync Error: $syncError',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                      onTap: _openInventoryDrawer,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.menu, color: Color(0xFF3D4943)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        tr('পণ্য তালিকা', 'Product List'),
                        style: const TextStyle(
                          color: Color(0xFF00694C),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.qr_code_scanner_rounded,
                    onTap: () async {
                      final status = await ref
                          .read(dokanScannerPermissionServiceProvider)
                          .ensureCameraPermission();
                      if (!context.mounted) return;
                      if (!status.isGranted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('ক্যামেরা অনুমতি না পেলে স্ক্যান হবে না'),
                            backgroundColor: Color(0xFFB3261E),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const DokanBarcodeScannerScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _HeaderIconButton(
                    icon: Icons.tune_rounded,
                    onTap: _openSortMenu,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            DokanSearchField(
              controller: _searchController,
              hintText: tr('পণ্যের নাম বা বারকোড লিখুন...',
                  'Enter product name or barcode...'),
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
            const SizedBox(height: 12),
            Row(
              children: [
                _statChip(tr('মোট পণ্য', 'Total Products'),
                    _bnDigits(visibleProducts.length.toString())),
                const SizedBox(width: 10),
                _statChip(tr('কম স্টক', 'Low Stock'),
                    _bnDigits(lowStockCount.toString()),
                    accent: const Color(0xFFF49B1A)),
                const SizedBox(width: 10),
                _statChip(tr('স্টক নেই', 'Out of Stock'),
                    _bnDigits(outOfStockCount.toString()),
                    accent: const Color(0xFFD43B3B)),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: normalizedCategories.map(_categoryChip).toList(),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  tr('ফিল্টার:', 'Filter:'),
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.white,
                    ),
                    child: DropdownButtonFormField<_ProductSortMode>(
                      value: _sortMode,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF6F6F6F)),
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
                              color: Color(0xFF00694C), width: 1.4),
                        ),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.w800,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _ProductSortMode.newest,
                          child: Text(
                            tr('নতুন পণ্য আগে', 'Newest First'),
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: _ProductSortMode.name,
                          child: Text(
                            tr('নাম অনুযায়ী', 'By Name'),
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: _ProductSortMode.lowStock,
                          child: Text(
                            tr('কম স্টক আগে', 'Low Stock First'),
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: _ProductSortMode.highestSales,
                          child: Text(
                            tr('বেশি বিক্রি', 'Highest Sales'),
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _sortMode = value);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (visibleProducts.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFD9E6E2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        color: Color(0xFF0C8C67), size: 48),
                    const SizedBox(height: 10),
                    Text(
                      tr('কোনো পণ্য পাওয়া যায়নি', 'No products found'),
                      style: const TextStyle(
                        color: Color(0xFF141F22),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleProducts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) => DokanFadeSlideIn(
                  delay: Duration(milliseconds: 45 * (index.clamp(0, 9))),
                  child: _productCard(visibleProducts[index], threshold),
                ),
              ),
            const SizedBox(height: 18),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isSalesman ? null : _openAddProductScreen,
        backgroundColor: const Color(0xFF00694C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}
