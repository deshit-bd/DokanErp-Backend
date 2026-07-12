part of '../purchase_screens.dart';

class DokanPurchaseListScreen extends ConsumerStatefulWidget {
  const DokanPurchaseListScreen({super.key});

  @override
  ConsumerState<DokanPurchaseListScreen> createState() =>
      _DokanPurchaseListScreenState();
}

class _DokanPurchaseListScreenState
    extends ConsumerState<DokanPurchaseListScreen> {
  String _selectedStatus = 'ALL'; // ALL, submitted, received, cancelled
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load suppliers to populate supplier state for creations
    Future.microtask(() {
      try {
        ref.read(dokanPosProvider.notifier).fetchSuppliers();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseOrderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3FAFB),
        elevation: 0,
        foregroundColor: const Color(0xFF16302E),
        title: const Text(
          'ক্রয় ও রিসিভ',
          style: TextStyle(
            color: Color(0xFF0D6B55),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(purchaseOrderProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildListHeader(),
          // List View
          Expanded(
            child: purchaseState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D6B55)),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.redAccent),
                      const SizedBox(height: 8),
                      const Text(
                        'তথ্য লোড করতে সমস্যা হয়েছে',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16302E)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.refresh(purchaseOrderProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6B55),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('আবার চেষ্টা করুন',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              data: (orders) {
                // Apply filters
                var filtered = orders;
                if (_selectedStatus != 'ALL') {
                  filtered = filtered
                      .where((o) => o.status.name == _selectedStatus)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  final lower = _searchQuery.toLowerCase();
                  filtered = filtered
                      .where((o) =>
                          o.id.toLowerCase().contains(lower) ||
                          o.supplierName.toLowerCase().contains(lower) ||
                          (o.reference.toLowerCase().contains(lower)))
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.local_shipping_outlined,
                          size: 64,
                          color: const Color(0xFF71827F),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'কোন মিল পাওয়া যায়নি'
                              : 'কোন ক্রয়ের রেকর্ড নেই',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF71827F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return _orderCard(order);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokanNewPurchaseScreen()),
        ),
        backgroundColor: const Color(0xFF0D6B55),
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
        label: const Text(
          'নতুন ক্রয়',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF3FAFB),
        border: Border(bottom: BorderSide(color: Color(0xFFE2EBE8))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D6B55), Color(0xFF124C41)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ক্রয় ও রিসিভ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'অর্ডার ট্র্যাক করুন, রিসিভ করুন, বা প্রত্যাখ্যান করুন',
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
          ),
          const SizedBox(height: 14),
          DokanSearchField(
            controller: _searchController,
            hintText: 'সরবরাহকারী বা অর্ডার আইডি দিয়ে খুঁজুন...',
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            showClear: _searchQuery.isNotEmpty,
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusFilterChip('সব', 'ALL'),
                const SizedBox(width: 10),
                _statusFilterChip('অপেক্ষায়', 'submitted'),
                const SizedBox(width: 10),
                _statusFilterChip('রিসিভড', 'received'),
                const SizedBox(width: 10),
                _statusFilterChip('প্রত্যাখ্যাত', 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D6B55) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF0D6B55) : const Color(0xFFD9E6E2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF16302E),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _orderCard(PurchaseOrder order) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (order.status) {
      case PurchaseOrderStatus.submitted:
        statusColor = const Color(0xFFDF8B1D);
        statusText = 'অপেক্ষমাণ';
        statusIcon = Icons.pending_actions_rounded;
        break;
      case PurchaseOrderStatus.received:
        statusColor = const Color(0xFF0E8F5F);
        statusText = 'রিসিভড';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case PurchaseOrderStatus.partiallyReceived:
        statusColor = const Color(0xFF4A6CF7);
        statusText = 'আংশিক রিসিভড';
        statusIcon = Icons.hourglass_bottom_rounded;
        break;
      case PurchaseOrderStatus.cancelled:
        statusColor = const Color(0xFFE15241);
        statusText = 'প্রত্যাখ্যাত';
        statusIcon = Icons.cancel_outlined;
        break;
      case PurchaseOrderStatus.draft:
        statusColor = const Color(0xFF71827F);
        statusText = 'খসড়া';
        statusIcon = Icons.edit_note_rounded;
        break;
    }

    final isPending = order.status == PurchaseOrderStatus.submitted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPending ? const Color(0xFFF1D7A7) : const Color(0xFFE2EBE8),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB9C8C3).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DokanPurchaseDetailScreen(order: order),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        statusColor.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          order.supplierName,
                          style: const TextStyle(
                            color: Color(0xFF16302E),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'অর্ডার: ${order.reference.isNotEmpty ? order.reference : order.id}',
                    style: const TextStyle(
                      color: Color(0xFF71827F),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FBFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2EBE8)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'মোট পরিমাণ',
                                style: TextStyle(
                                  color: Color(0xFF71827F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '৳ ${_bn(order.totalAmount)}',
                                style: const TextStyle(
                                  color: Color(0xFF0D6B55),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'তারিখ',
                              style: TextStyle(
                                color: Color(0xFF71827F),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_bn(order.createdAt.day)}/${_bn(order.createdAt.month)}/${_bn(order.createdAt.year)}',
                              style: const TextStyle(
                                color: Color(0xFF16302E),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  DokanNewPurchaseScreen(initialOrder: order),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6B55),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.repeat_rounded, size: 16),
                        label: const Text(
                          'পুনরায় ক্রয়',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
