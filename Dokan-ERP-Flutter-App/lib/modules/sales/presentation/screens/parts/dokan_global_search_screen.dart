part of '../sales_screens.dart';

class DokanGlobalSearchScreen extends ConsumerStatefulWidget {
  const DokanGlobalSearchScreen({super.key});

  @override
  ConsumerState<DokanGlobalSearchScreen> createState() =>
      _DokanGlobalSearchScreenState();
}

class _DokanGlobalSearchScreenState
    extends ConsumerState<DokanGlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _selectedTab = 0; // 0: সব, 1: পণ্য, 2: গ্রাহক, 3: সরবরাহকারী, 4: বিক্রয়

  static const List<String> _tabs = <String>[
    'সব',
    'পণ্য',
    'গ্রাহক',
    'সরবরাহকারী',
    'বিক্রয়',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(dokanInventoryCatalogProvider);
    final posState = ref.watch(dokanPosProvider);
    final query = _query.trim();

    // 1. Filter Products
    final matchedProducts = catalog.where((product) {
      return DokanSearchMatcher.match(product.name, query) ||
          DokanSearchMatcher.match(product.barcode, query) ||
          DokanSearchMatcher.match(product.category, query);
    }).toList(growable: false);

    // 2. Filter Customers
    final matchedCustomers = posState.customerProfiles.where((customer) {
      return DokanSearchMatcher.match(customer.name, query) ||
          DokanSearchMatcher.match(customer.phone, query);
    }).toList(growable: false);

    // 3. Filter Suppliers
    final matchedSuppliers = posState.supplierProfiles.where((supplier) {
      return DokanSearchMatcher.match(supplier.name, query) ||
          DokanSearchMatcher.match(supplier.phone, query) ||
          DokanSearchMatcher.match(supplier.productType, query);
    }).toList(growable: false);

    // 4. Filter Sales/Transactions
    final matchedSales = posState.orders.where((order) {
      return DokanSearchMatcher.match(order.customerName, query) ||
          DokanSearchMatcher.match(order.customerNumber, query) ||
          DokanSearchMatcher.match(order.id, query) ||
          order.totalAmount.toString().contains(query);
    }).toList(growable: false);

    final totalMatches = matchedProducts.length +
        matchedCustomers.length +
        matchedSuppliers.length +
        matchedSales.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  _HistoryIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DokanSearchField(
                      controller: _searchController,
                      hintText: 'সব কিছু একসাথে খুঁজুন...',
                      autofocus: true,
                      showClear: _query.isNotEmpty,
                      onChanged: (val) => setState(() => _query = val),
                      onClear: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
                  ),
                  DokanVoiceSearchButton(
                    onResult: (text) {
                      _searchController.text = text;
                      _searchController.selection =
                          TextSelection.collapsed(offset: text.length);
                      setState(() => _query = text);
                    },
                  ),
                ],
              ),
            ),

            // Tab bar chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = _selectedTab == index;
                  return ChoiceChip(
                    label: Text(_tabs[index]),
                    selected: selected,
                    onSelected: (val) => setState(() => _selectedTab = index),
                    selectedColor: const Color(0xFF006B53),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF5F6A66),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selected
                            ? Colors.transparent
                            : const Color(0xFFD6E4E0),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 6),

            // Search results display list
            Expanded(
              child: _query.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'পণ্য, গ্রাহক, সাপ্লায়ার বা বিক্রি খুঁজুন',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : totalMatches == 0
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              const Text(
                                'কোনো ফলাফল পাওয়া যায়নি',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          children: [
                            if (_selectedTab == 0 || _selectedTab == 1) ...[
                              _buildGroupHeader(
                                  'পণ্যসমূহ (${matchedProducts.length})',
                                  Icons.shopping_bag_outlined),
                              ...matchedProducts
                                  .map((p) => _buildProductTile(p)),
                            ],
                            if (_selectedTab == 0 || _selectedTab == 2) ...[
                              _buildGroupHeader(
                                  'গ্রাহকবৃন্দ (${matchedCustomers.length})',
                                  Icons.people_outline_rounded),
                              ...matchedCustomers
                                  .map((c) => _buildCustomerTile(c)),
                            ],
                            if (_selectedTab == 0 || _selectedTab == 3) ...[
                              _buildGroupHeader(
                                  'সরবরাহকারীগণ (${matchedSuppliers.length})',
                                  Icons.local_shipping_outlined),
                              ...matchedSuppliers
                                  .map((s) => _buildSupplierTile(s)),
                            ],
                            if (_selectedTab == 0 || _selectedTab == 4) ...[
                              _buildGroupHeader(
                                  'বিক্রয়সমূহ (${matchedSales.length})',
                                  Icons.receipt_long_outlined),
                              ...matchedSales.map((s) => _buildSaleTile(s)),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF006B53)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF163732),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(DokanCatalogProduct product) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5ECEB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3EF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            product.emoji.isNotEmpty ? product.emoji : '📦',
            style: const TextStyle(fontSize: 22),
          ),
        ),
        title: Text(
          product.name,
          style:
              const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
        ),
        subtitle: Text(
          'স্টক: ${product.stock} টি • দাম: ৳${product.salePrice}',
          style: const TextStyle(
              color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF006B53),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.add_shopping_cart_rounded,
                color: Colors.white, size: 20),
            onPressed: () {
              ref.read(dokanPosProvider.notifier).addItem(product.productId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} কার্টে যোগ করা হয়েছে'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerTile(DokanCustomerProfileRecord customer) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5ECEB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  DokanCustomerDetailScreen(customerKey: customer.key),
            ),
          );
        },
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE7F5EF),
          child: Icon(Icons.person_rounded, color: Color(0xFF0C8C67)),
        ),
        title: Text(
          customer.name,
          style:
              const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
        ),
        subtitle: Text(
          customer.phone.isNotEmpty ? customer.phone : 'মোবাইল নম্বর নেই',
          style: const TextStyle(
              color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: customer.currentDue > 0
            ? Text(
                'বাকি: ৳${customer.currentDue}',
                style: const TextStyle(
                  color: Color(0xFFD43B3B),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              )
            : const Text(
                'পরিশোধিত',
                style: TextStyle(
                  color: Color(0xFF0C8C67),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }

  Widget _buildSupplierTile(DokanSupplierProfileRecord supplier) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5ECEB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  DokanSupplierDetailScreen(supplierKey: supplier.key),
            ),
          );
        },
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF0E2),
          child: Icon(Icons.local_shipping_rounded, color: Color(0xFFB14A12)),
        ),
        title: Text(
          supplier.name,
          style:
              const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
        ),
        subtitle: Text(
          'ক্যাটাগরি: ${supplier.productType.isNotEmpty ? supplier.productType : "সংরক্ষিত নেই"}',
          style: const TextStyle(
              color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }

  Widget _buildSaleTile(DokanPosOrderRecord order) {
    final statusColor = order.status == DokanPosOrderStatus.paid
        ? const Color(0xFF0C8C67)
        : const Color(0xFFD43B3B);
    final statusBg = order.status == DokanPosOrderStatus.paid
        ? const Color(0xFFE1F5E7)
        : const Color(0xFFFDE7E7);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5ECEB)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _DokanSaleDetailScreen(order: order),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: statusBg,
          child: Icon(Icons.receipt_long_rounded, color: statusColor),
        ),
        title: Text(
          order.customerName,
          style:
              const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
        ),
        subtitle: Text(
          '৳${order.totalAmount} • ${_formatRelativeTime(order.createdAt)}',
          style: const TextStyle(
              color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            order.status == DokanPosOrderStatus.paid ? 'পরিশোধিত' : 'বাকি',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '${_banglaDigits(years.toString())} বছর আগে';
    } else if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '${_banglaDigits(months.toString())} মাস আগে';
    } else if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '${_banglaDigits(weeks.toString())} সপ্তাহ আগে';
    } else if (diff.inDays >= 1) {
      return '${_banglaDigits(diff.inDays.toString())} দিন আগে';
    } else if (diff.inHours >= 1) {
      return '${_banglaDigits(diff.inHours.toString())} ঘণ্টা আগে';
    } else if (diff.inMinutes >= 1) {
      return '${_banglaDigits(diff.inMinutes.toString())} মিনিট আগে';
    } else {
      return 'এইমাত্র';
    }
  }

  String _banglaDigits(String englishDigits) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var result = englishDigits;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bangla[i]);
    }
    return result;
  }
}
