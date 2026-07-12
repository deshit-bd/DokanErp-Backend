part of '../sales_screens.dart';

class _DueCustomerSummary {
  const _DueCustomerSummary({
    required this.customerKey,
    required this.customerName,
    required this.customerNumber,
    required this.totalDue,
    required this.orders,
    required this.lastPaymentAt,
    this.updatedAt,
  });

  final String customerKey;
  final String customerName;
  final String customerNumber;
  final int totalDue;
  final List<DokanPosOrderRecord> orders;
  final DateTime? lastPaymentAt;
  final DateTime? updatedAt;
}

String _dueCustomerKey(DokanPosOrderRecord order) {
  final number = order.customerNumber.trim();
  if (number.isNotEmpty) {
    return 'num:$number';
  }
  final name = order.customerName.trim();
  return name.isEmpty ? 'unknown' : 'name:$name';
}

bool _isGuestCustomerToken(String value) {
  final normalized = value.trim().toLowerCase().replaceAll(' ', '_');
  return normalized == 'unknown' ||
      normalized == 'guest_customer' ||
      normalized == 'guest_customer_unified_key' ||
      normalized == 'হাঁটা_বিক্রয়' ||
      normalized == 'অতিথি_গ্রাহক';
}

bool _isGuestDueOrder(DokanPosOrderRecord order) {
  return order.customerNumber.trim().isEmpty &&
      (order.customerName.trim().isEmpty ||
          _isGuestCustomerToken(order.customerName));
}

String _dueCustomerDisplayName({
  required DokanCustomerProfileRecord profile,
  required List<DokanPosOrderRecord> orders,
  required String fallback,
}) {
  final profileName = profile.name.trim();
  if (profileName.isNotEmpty && !_isGuestCustomerToken(profileName)) {
    return profileName;
  }

  for (final order in orders) {
    final orderName = order.customerName.trim();
    if (orderName.isNotEmpty && !_isGuestCustomerToken(orderName)) {
      return orderName;
    }
  }

  if (fallback.trim().isNotEmpty && !_isGuestCustomerToken(fallback)) {
    return fallback.trim();
  }
  return 'অতিথি গ্রাহক';
}

bool _matchesDueCustomerProfile({
  required DokanCustomerProfileRecord profile,
  required String cleanKey,
  required String cleanPhone,
  required String cleanName,
  required DokanPosOrderRecord order,
}) {
  final orderPhone = order.customerNumber.trim();
  final orderName = order.customerName.trim();
  final profileLooksGuest = _isGuestCustomerToken(profile.key) ||
      _isGuestCustomerToken(profile.id ?? '') ||
      _isGuestCustomerToken(profile.name) ||
      _isGuestCustomerToken(cleanKey) ||
      _isGuestCustomerToken(cleanName);

  if (profileLooksGuest && _isGuestDueOrder(order)) {
    return true;
  }

  if (profile.key.isNotEmpty &&
      (orderPhone == profile.key || orderName == profile.key)) {
    return true;
  }
  if (profile.id != null &&
      profile.id!.isNotEmpty &&
      (orderPhone == profile.id || orderName == profile.id)) {
    return true;
  }
  if (profile.phone.isNotEmpty && orderPhone == profile.phone.trim()) {
    return true;
  }
  if (profile.name.isNotEmpty && orderName == profile.name.trim()) {
    return true;
  }
  if (cleanKey.isNotEmpty &&
      (orderPhone == cleanKey || orderName == cleanKey)) {
    return true;
  }
  if (cleanPhone.isNotEmpty && orderPhone == cleanPhone) return true;
  if (cleanName.isNotEmpty && orderName == cleanName) return true;
  return false;
}

int _effectiveCustomerDue({
  required DokanCustomerProfileRecord profile,
  required List<DokanPosOrderRecord> orders,
  required bool hasStoredProfile,
}) {
  final orderDueSum =
      orders.fold<int>(0, (sum, order) => sum + order.dueAmount);
  if (!hasStoredProfile) {
    return math.max(0, orderDueSum);
  }

  final latestDueOrderAt = orders
      .where((order) => order.dueAmount > 0)
      .fold<DateTime?>(null, (latest, order) {
    if (latest == null || order.createdAt.isAfter(latest)) {
      return order.createdAt;
    }
    return latest;
  });

  if (profile.currentDue <= 0 &&
      orderDueSum > 0 &&
      latestDueOrderAt != null &&
      latestDueOrderAt.isAfter(profile.updatedAt)) {
    return math.max(0, orderDueSum);
  }

  return math.max(0, profile.currentDue);
}

List<_DueCustomerSummary> _buildDueCustomers(
  DokanPosState state,
  List<DokanPosOrderRecord> allOrders,
) {
  final customerSummaries = <_DueCustomerSummary>[];
  final processedKeys = <String>{};

  final dueOrders = allOrders
      .where((order) =>
          order.status == DokanPosOrderStatus.due ||
          order.status == DokanPosOrderStatus.partiallyPaid)
      .toList(growable: false);

  for (final profile in state.customerProfiles) {
    if (state.hiddenCustomerKeys.contains(profile.key)) {
      continue;
    }

    final cleanKey = profile.key;
    final cleanPhone = cleanKey.startsWith('num:')
        ? cleanKey.substring(4).trim()
        : (cleanKey.startsWith('name:')
            ? ''
            : (RegExp(r'^\d+$').hasMatch(cleanKey) ? cleanKey.trim() : ''));
    final cleanName = cleanKey.startsWith('name:')
        ? cleanKey.substring(5).trim()
        : (cleanKey.startsWith('num:')
            ? ''
            : (RegExp(r'^\d+$').hasMatch(cleanKey) ? '' : cleanKey.trim()));

    final matchedDueOrders = dueOrders.where((order) {
      return _matchesDueCustomerProfile(
        profile: profile,
        cleanKey: cleanKey,
        cleanPhone: cleanPhone,
        cleanName: cleanName,
        order: order,
      );
    }).toList();

    final totalDue = _effectiveCustomerDue(
      profile: profile,
      orders: matchedDueOrders,
      hasStoredProfile: true,
    );

    if (totalDue > 0) {
      processedKeys.add(profile.key);
      if (profile.id != null && profile.id!.isNotEmpty) {
        processedKeys.add(profile.id!);
      }
      customerSummaries.add(_DueCustomerSummary(
        customerKey: profile.key,
        customerName: _dueCustomerDisplayName(
          profile: profile,
          orders: matchedDueOrders,
          fallback: matchedDueOrders.isEmpty
              ? 'গ্রাহক'
              : matchedDueOrders.first.customerName,
        ),
        customerNumber: profile.phone.trim().isNotEmpty
            ? profile.phone
            : (matchedDueOrders.isEmpty
                ? ''
                : matchedDueOrders.first.customerNumber),
        totalDue: totalDue,
        orders: matchedDueOrders,
        lastPaymentAt:
            matchedDueOrders.isEmpty ? null : matchedDueOrders.first.createdAt,
        updatedAt: profile.updatedAt,
      ));
    }
  }

  final groupedOrphanOrders = <String, List<DokanPosOrderRecord>>{};
  for (final order in dueOrders) {
    final key = _dueCustomerKey(order);

    final number = order.customerNumber.trim();
    final name = order.customerName.trim();
    if (processedKeys.contains(key) ||
        (number.isNotEmpty && processedKeys.contains(number)) ||
        (name.isNotEmpty && processedKeys.contains(name)) ||
        processedKeys.contains('num:$number') ||
        processedKeys.contains('name:$name')) {
      continue;
    }

    groupedOrphanOrders
        .putIfAbsent(key, () => <DokanPosOrderRecord>[])
        .add(order);
  }

  for (final entry in groupedOrphanOrders.entries) {
    final orders = entry.value;
    final due = orders.fold<int>(0, (sum, item) => sum + item.dueAmount);
    if (due > 0) {
      customerSummaries.add(_DueCustomerSummary(
        customerKey: entry.key,
        customerName: orders.first.customerName,
        customerNumber: orders.first.customerNumber,
        totalDue: due,
        orders: orders,
        lastPaymentAt: orders.first.createdAt,
        updatedAt: orders.first.createdAt,
      ));
    }
  }

  customerSummaries.sort((a, b) {
    final timeA = a.updatedAt ??
        a.lastPaymentAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final timeB = b.updatedAt ??
        b.lastPaymentAt ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final timeCompare = timeB.compareTo(timeA);
    if (timeCompare != 0) return timeCompare;
    return b.totalDue.compareTo(a.totalDue);
  });
  return customerSummaries;
}

class DokanDueManagementScreen extends ConsumerStatefulWidget {
  const DokanDueManagementScreen({super.key});

  @override
  ConsumerState<DokanDueManagementScreen> createState() =>
      _DokanDueManagementScreenState();
}

class _DokanDueManagementScreenState
    extends ConsumerState<DokanDueManagementScreen> {
  String? _selectedCustomerKey;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dokanPosProvider);
    final ordersAsync = ref.watch(salesHistoryOrdersProvider);
    final allOrders = mergeSalesHistoryOrders(
      localOrders: state.orders,
      remoteOrders: ordersAsync.value ?? const <DokanPosOrderRecord>[],
    );
    final customers = _buildDueCustomers(state, allOrders);
    final activeCustomer = customers.isEmpty
        ? null
        : customers.firstWhere(
            (item) => item.customerKey == _selectedCustomerKey,
            orElse: () => customers.first,
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'বাকি আদায়',
          style: TextStyle(
            color: Color(0xFF006B53),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
        itemCount: customers.isEmpty ? 1 : customers.length + 1,
        itemBuilder: (context, index) {
          if (customers.isEmpty) {
            return const _DueEmptyState();
          }
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0C8C67), Color(0xFF0A6A4F)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'বাকি গ্রাহক',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_banglaDigits(customers.length.toString())} জন',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'মোট বাকি ${_formatCurrency(customers.fold<int>(0, (sum, item) => sum + item.totalDue))}',
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }
          final customer = customers[index - 1];
          final selected = activeCustomer?.customerKey == customer.customerKey;
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _DueCustomerCard(
              customer: customer,
              selected: selected,
              onTap: () {
                setState(() => _selectedCustomerKey = customer.customerKey);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DokanDueDetailScreen(customerKey: customer.customerKey),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF7FBFA),
              border: Border(top: BorderSide(color: Color(0xFFD6E4E0))),
            ),
            child: ElevatedButton(
              onPressed: () async {
                final result = await _showNewDueRecordSheet(context);
                if (!context.mounted || result == null) return;
                ref.read(dokanPosProvider.notifier).addCustomerDueAmount(
                      customerName: result['name'] ?? '',
                      customerNumber: result['number'] ?? '',
                      amount: int.tryParse(result['amount'] ?? '0') ?? 0,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C8C67),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('নতুন বাকি যোগ করুন',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }
}

class DokanDueDetailScreen extends ConsumerStatefulWidget {
  const DokanDueDetailScreen({super.key, required this.customerKey});

  final String customerKey;

  @override
  ConsumerState<DokanDueDetailScreen> createState() =>
      _DokanDueDetailScreenState();
}

class _DokanDueDetailScreenState extends ConsumerState<DokanDueDetailScreen> {
  String _displayNameFromKey(String key) {
    final raw = key.replaceFirst(RegExp(r'^(num:|name:)'), '');
    return raw.trim().isEmpty ? 'গ্রাহক' : raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dokanPosProvider);
    final ordersAsync = ref.watch(salesHistoryOrdersProvider);
    final allOrders = mergeSalesHistoryOrders(
      localOrders: state.orders,
      remoteOrders: ordersAsync.value ?? const <DokanPosOrderRecord>[],
    );

    final String cleanKey = widget.customerKey;
    final String cleanPhone = cleanKey.startsWith('num:')
        ? cleanKey.substring(4).trim()
        : (cleanKey.startsWith('name:')
            ? ''
            : (RegExp(r'^\d+$').hasMatch(cleanKey) ? cleanKey.trim() : ''));
    final String cleanName = cleanKey.startsWith('name:')
        ? cleanKey.substring(5).trim()
        : (cleanKey.startsWith('num:')
            ? ''
            : (RegExp(r'^\d+$').hasMatch(cleanKey) ? '' : cleanKey.trim()));

    final profileIndex = state.customerProfiles.indexWhere((p) {
      if (p.key == cleanKey || p.id == cleanKey) return true;
      if (cleanPhone.isNotEmpty &&
          (p.phone.trim() == cleanPhone || p.key == cleanPhone)) return true;
      if (cleanName.isNotEmpty &&
          (p.name.trim() == cleanName || p.key == cleanName)) return true;
      return false;
    });
    final hasStoredProfile = profileIndex >= 0;
    final profile = hasStoredProfile
        ? state.customerProfiles[profileIndex]
        : () {
            // Look up by name or phone in local orders if not found in profiles
            final localOrders = allOrders.where((order) {
              final orderPhone = order.customerNumber.trim();
              final orderName = order.customerName.trim();
              if (cleanPhone.isNotEmpty && orderPhone == cleanPhone)
                return true;
              if (cleanName.isNotEmpty && orderName == cleanName) return true;
              return false;
            }).toList();

            final String nameFallback = localOrders.isNotEmpty
                ? localOrders.first.customerName
                : (cleanName.isNotEmpty ? cleanName : 'গ্রাহক');
            final String phoneFallback = localOrders.isNotEmpty
                ? localOrders.first.customerNumber
                : (cleanPhone.isNotEmpty ? cleanPhone : '');

            return DokanCustomerProfileRecord(
              key: widget.customerKey,
              name: nameFallback,
              phone: phoneFallback,
              address: '',
              openingDue: 0,
              currentDue: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }();

    final orders = allOrders.where((order) {
      return _matchesDueCustomerProfile(
        profile: profile,
        cleanKey: cleanKey,
        cleanPhone: cleanPhone,
        cleanName: cleanName,
        order: order,
      );
    }).toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final totalDue = _effectiveCustomerDue(
      profile: profile,
      orders: orders,
      hasStoredProfile: hasStoredProfile,
    );

    final customerName = _dueCustomerDisplayName(
      profile: profile,
      orders: orders,
      fallback: orders.isEmpty
          ? _displayNameFromKey(widget.customerKey)
          : orders.first.customerName,
    );
    final lastPayment = orders.isEmpty ? null : orders.first.createdAt;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FBFA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          customerName,
          style: const TextStyle(
            color: Color(0xFF006B53),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0C8C67), Color(0xFF0A6A4F)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'মোট বাকি',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(totalDue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lastPayment == null
                      ? 'কোনো ট্রানজেকশন নেই'
                      : 'সর্বশেষ আপডেট ${_dueDateLabel(lastPayment)}',
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD6E4E0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ট্রানজেকশন / বাকি ইতিহাস',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (orders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'এই গ্রাহকের কোনো রেকর্ড পাওয়া যায়নি',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w700),
                    ),
                  )
                else
                  ListView.builder(
                    itemCount: orders.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) =>
                        _DueHistoryTile(record: orders[index]),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF7FBFA),
              border: Border(top: BorderSide(color: Color(0xFFD6E4E0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: orders.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DokanDuePaymentScreen(
                                  customerKey: widget.customerKey,
                                ),
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF006B53),
                      side: const BorderSide(color: Color(0xFF006B53)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('বাকি আদায়',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final customerPhone =
                          orders.isEmpty ? '' : orders.first.customerNumber;

                      ref
                          .read(dokanPosProvider.notifier)
                          .setCustomerName(customerName);
                      ref
                          .read(dokanPosProvider.notifier)
                          .setCustomerNumber(customerPhone);

                      Navigator.of(context).pushNamed(AppRoutes.sales);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C8C67),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('বাকি যোগ',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DokanDuePaymentScreen extends ConsumerStatefulWidget {
  const DokanDuePaymentScreen({super.key, required this.customerKey});

  final String customerKey;

  @override
  ConsumerState<DokanDuePaymentScreen> createState() =>
      _DokanDuePaymentScreenState();
}

class _DokanDuePaymentScreenState extends ConsumerState<DokanDuePaymentScreen> {
  String _typedAmount = '';
  DokanPosPaymentMethod _selectedPaymentMethod = DokanPosPaymentMethod.cash;
  String _selectedQuickChip = 'full'; // 'full', '500', '250', 'custom'
  bool _isLoading = false;

  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _senderNumberController = TextEditingController();
  final TextEditingController _transactionIdController =
      TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await ref.read(dokanPosProvider.notifier).fetchCustomers();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _senderNumberController.dispose();
    _transactionIdController.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  String _banglaDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var result = input;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bangla[i]);
    }
    return result;
  }

  int _getEnteredAmount(int totalDue) {
    if (_selectedQuickChip == 'full') {
      return totalDue;
    } else if (_selectedQuickChip == '500') {
      return 500;
    } else if (_selectedQuickChip == '250') {
      return 250;
    } else {
      return int.tryParse(_typedAmount) ?? 0;
    }
  }

  InputDecoration _customInputDecoration({
    required String hintText,
    String? labelText,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF005C47), width: 1.5),
      ),
    );
  }

  Future<void> _sendWhatsAppReceipt({
    required BuildContext context,
    required String name,
    required String phone,
    required int amount,
    required int remaining,
  }) async {
    if (phone.isEmpty) return;
    var cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (!cleanPhone.startsWith('88') && cleanPhone.length == 11) {
      cleanPhone = '88$cleanPhone';
    }
    final text = Uri.encodeComponent('প্রিয় $name,\n'
        'Dokan ERP-তে আপনার বকেয়া বাকি থেকে ৳$amount সফলভাবে পরিশোধ করা হয়েছে।\n'
        'আপনার বর্তমান বকেয়া বাকি পরিমাণ: ৳$remaining।\n'
        'ধন্যবাদ!');
    final urlString =
        'https://api.whatsapp.com/send?phone=$cleanPhone&text=$text';
    final uri = Uri.parse(urlString);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp ওপেন করা যায়নি')),
      );
    }
  }

  void _onNumpadPressed(String key) {
    setState(() {
      if (_selectedQuickChip != 'custom') {
        _selectedQuickChip = 'custom';
        _typedAmount = '';
      }
      if (_typedAmount == '0') {
        _typedAmount = key;
      } else {
        if (_typedAmount.length >= 7) return; // limit input length
        _typedAmount += key;
      }
      _customAmountController.text = _typedAmount;
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_selectedQuickChip != 'custom') {
        _selectedQuickChip = 'custom';
        _typedAmount = '0';
        _customAmountController.text = '0';
        return;
      }
      if (_typedAmount.isNotEmpty) {
        _typedAmount = _typedAmount.substring(0, _typedAmount.length - 1);
      }
      if (_typedAmount.isEmpty) {
        _typedAmount = '0';
      }
      _customAmountController.text = _typedAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dokanPosProvider);
    final ordersAsync = ref.watch(salesHistoryOrdersProvider);
    final allOrders = mergeSalesHistoryOrders(
      localOrders: state.orders,
      remoteOrders: ordersAsync.value ?? const <DokanPosOrderRecord>[],
    );

    final String cleanKey = widget.customerKey;
    final String cleanPhone = cleanKey.startsWith('num:')
        ? cleanKey.substring(4).trim()
        : (cleanKey.startsWith('name:')
            ? ''
            : (RegExp(r'^\d+$').hasMatch(cleanKey) ? cleanKey.trim() : ''));
    final String cleanName = cleanKey.startsWith('name:')
        ? cleanKey.substring(5).trim()
        : (cleanKey.startsWith('num:')
            ? ''
            : (RegExp(r'^\d+$').hasMatch(cleanKey) ? '' : cleanKey.trim()));

    final profileIndex = state.customerProfiles.indexWhere((p) {
      if (p.key == cleanKey || p.id == cleanKey) return true;
      if (cleanPhone.isNotEmpty &&
          (p.phone.trim() == cleanPhone || p.key == cleanPhone)) return true;
      if (cleanName.isNotEmpty &&
          (p.name.trim() == cleanName || p.key == cleanName)) return true;
      return false;
    });
    final hasStoredProfile = profileIndex >= 0;
    final profile = hasStoredProfile
        ? state.customerProfiles[profileIndex]
        : () {
            // Look up by name or phone in local orders if not found in profiles
            final localOrders = allOrders.where((order) {
              final orderPhone = order.customerNumber.trim();
              final orderName = order.customerName.trim();
              if (cleanPhone.isNotEmpty && orderPhone == cleanPhone)
                return true;
              if (cleanName.isNotEmpty && orderName == cleanName) return true;
              return false;
            }).toList();

            final String nameFallback = localOrders.isNotEmpty
                ? localOrders.first.customerName
                : (cleanName.isNotEmpty ? cleanName : 'গ্রাহক');
            final String phoneFallback = localOrders.isNotEmpty
                ? localOrders.first.customerNumber
                : (cleanPhone.isNotEmpty ? cleanPhone : '');

            return DokanCustomerProfileRecord(
              key: widget.customerKey,
              name: nameFallback,
              phone: phoneFallback,
              address: '',
              openingDue: 0,
              currentDue: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }();

    final orders = allOrders.where((order) {
      return _matchesDueCustomerProfile(
        profile: profile,
        cleanKey: cleanKey,
        cleanPhone: cleanPhone,
        cleanName: cleanName,
        order: order,
      );
    }).toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final totalDue = _effectiveCustomerDue(
      profile: profile,
      orders: orders,
      hasStoredProfile: hasStoredProfile,
    );

    final customerName = _dueCustomerDisplayName(
      profile: profile,
      orders: orders,
      fallback: orders.isEmpty ? 'গ্রাহক' : orders.first.customerName,
    );

    final enteredAmount = _getEnteredAmount(totalDue);
    final remainingDue = math.max(0, totalDue - enteredAmount);
    final isFullPaid = enteredAmount == totalDue;
    final isOverPaid = enteredAmount > totalDue;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F9F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B)),
        ),
        title: const Text(
          'বাকি আদায়',
          style: TextStyle(
            color: Color(0xFF005C47),
            fontWeight: FontWeight.w900,
            fontSize: 16.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  // Customer Header Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFEE2E2)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: const Color(0xFF005C47),
                          child: Text(
                            customerName.isNotEmpty ? customerName[0] : 'ক',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'মোট বাকি: ${_banglaDigits(totalDue.toString())}',
                                style: const TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Center(
                    child: Text(
                      'কত টাকা আদায় করলেন?',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Large Amount Input Indicator
                  Center(
                    child: Text(
                      '৳ ${_banglaDigits(enteredAmount.toString())}',
                      style: const TextStyle(
                        color: Color(0xFF005C47),
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quick Action Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Chip 1: Custom amount TextField/Input
                      Container(
                        width: 110,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _selectedQuickChip == 'custom'
                              ? const Color(0xFF005C47)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _selectedQuickChip == 'custom'
                                ? const Color(0xFF005C47)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _customAmountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: NumericInputFormatters.wholeNumber,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedQuickChip == 'custom'
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                          decoration: InputDecoration(
                            filled: false,
                            fillColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hintText: 'নিজে লিখুন',
                            hintStyle: TextStyle(
                              color: _selectedQuickChip == 'custom'
                                  ? Colors.white.withOpacity(0.8)
                                  : const Color(0xFF475569),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedQuickChip = 'custom';
                              if (_typedAmount == '0' || _typedAmount.isEmpty) {
                                _typedAmount = '';
                                _customAmountController.text = '';
                              }
                            });
                          },
                          onChanged: (value) {
                            setState(() {
                              final clean = value.replaceAll(RegExp(r'\D'), '');
                              _typedAmount = clean;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Chip 2: Full payment
                      _quickChip(
                        label:
                            '${_banglaDigits(totalDue.toString())} (সম্পূর্ণ)',
                        chipKey: 'full',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Numerical Keyboard Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF3F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.85,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        _keyboardButton('১', '1'),
                        _keyboardButton('২', '2'),
                        _keyboardButton('৩', '3'),
                        _keyboardButton('৪', '4'),
                        _keyboardButton('৫', '5'),
                        _keyboardButton('৬', '6'),
                        _keyboardButton('৭', '7'),
                        _keyboardButton('৮', '8'),
                        _keyboardButton('৯', '9'),
                        const SizedBox.shrink(),
                        _keyboardButton('০', '0'),
                        GestureDetector(
                          onTap: _onBackspacePressed,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.backspace_outlined,
                                color: Color(0xFFDC2626),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Status Indicator Banner
                  if (isOverPaid)
                    _statusBanner(
                      color: const Color(0xFFFEF2F2),
                      textColor: const Color(0xFFDC2626),
                      icon: Icons.warning_amber_rounded,
                      text: 'বাকি টাকার চেয়ে বেশি নেওয়া যাবে না',
                    )
                  else if (isFullPaid)
                    _statusBanner(
                      color: const Color(0xFFEAF5F2),
                      textColor: const Color(0xFF0C8C67),
                      icon: Icons.check_circle_outline_rounded,
                      text: '✓ সম্পূর্ণ বাকি পরিশোধ হবে',
                    )
                  else
                    _statusBanner(
                      color: const Color(0xFFFFF7ED),
                      textColor: const Color(0xFFD97706),
                      icon: Icons.info_outline_rounded,
                      text:
                          'বাকি থাকবে ৳ ${_banglaDigits(remainingDue.toString())}',
                    ),
                  const SizedBox(height: 16),

                  // Payment Method Title
                  const Text(
                    'পেমেন্ট মাধ্যম',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Payment Method Selector Buttons in a Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _paymentMethodChip(
                        label: 'নগদ',
                        icon: Icons.payments_outlined,
                        method: DokanPosPaymentMethod.cash,
                      ),
                      _paymentMethodChip(
                        label: 'bKash',
                        icon: Icons.phone_android_rounded,
                        method: DokanPosPaymentMethod.bkash,
                      ),
                      _paymentMethodChip(
                        label: 'Nagad',
                        icon: Icons.phone_android_rounded,
                        method: DokanPosPaymentMethod.nagad,
                      ),
                      _paymentMethodChip(
                        label: 'Rocket',
                        icon: Icons.phone_android_rounded,
                        method: DokanPosPaymentMethod.rocket,
                      ),
                      _paymentMethodChip(
                        label: 'Card',
                        icon: Icons.credit_card_rounded,
                        method: DokanPosPaymentMethod.card,
                      ),
                    ],
                  ),

                  // Dynamic Fields Section
                  if (_selectedPaymentMethod == DokanPosPaymentMethod.bkash ||
                      _selectedPaymentMethod == DokanPosPaymentMethod.nagad ||
                      _selectedPaymentMethod ==
                          DokanPosPaymentMethod.rocket) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'লেনদেনের তথ্য',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _senderNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: _customInputDecoration(
                        hintText: 'প্রেরকের মোবাইল নম্বর লিখুন',
                        labelText: 'প্রেরক নম্বর',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _transactionIdController,
                      decoration: _customInputDecoration(
                        hintText: 'ট্রানজেকশন আইডি (TxnID) লিখুন',
                        labelText: 'লেনদেন আইডি (TxnID)',
                      ),
                    ),
                  ] else if (_selectedPaymentMethod ==
                      DokanPosPaymentMethod.card) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'কার্ডের তথ্য',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cardHolderController,
                      decoration: _customInputDecoration(
                        hintText: 'কার্ডধারী ব্যক্তির নাম লিখুন',
                        labelText: 'কার্ডধারী',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: _customInputDecoration(
                        hintText: 'কার্ডের ১৬ ডিজিটের নম্বর লিখুন',
                        labelText: 'কার্ড নম্বর',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cardExpiryController,
                            decoration: _customInputDecoration(
                              hintText: 'MM/YY',
                              labelText: 'মেয়াদ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _cardCvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: _customInputDecoration(
                              hintText: 'CVV',
                              labelText: 'সিভিভি (CVV)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Confirm Bottom Action Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              color: const Color(0xFFF4F9F7),
              child: SizedBox(
                height: 58,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: enteredAmount <= 0 || isOverPaid || _isLoading
                      ? null
                      : () async {
                          // Dynamic validation
                          if (_selectedPaymentMethod ==
                                  DokanPosPaymentMethod.bkash ||
                              _selectedPaymentMethod ==
                                  DokanPosPaymentMethod.nagad ||
                              _selectedPaymentMethod ==
                                  DokanPosPaymentMethod.rocket) {
                            if (_senderNumberController.text.trim().isEmpty ||
                                _transactionIdController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFFDC2626),
                                  content: Text(
                                    'দয়া করে প্রেরক নম্বর এবং লেনদেন আইডি পূরণ করুন।',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              );
                              return;
                            }
                          } else if (_selectedPaymentMethod ==
                              DokanPosPaymentMethod.card) {
                            if (_cardHolderController.text.trim().isEmpty ||
                                _cardNumberController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFFDC2626),
                                  content: Text(
                                    'দয়া করে কার্ড নম্বর এবং কার্ডধারীর নাম পূরণ করুন।',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              );
                              return;
                            }
                          }

                          setState(() => _isLoading = true);
                          try {
                            Map<String, dynamic>? paymentDetails;
                            String reference =
                                'Due payment collected via Mobile UI';
                            if (_selectedPaymentMethod ==
                                    DokanPosPaymentMethod.bkash ||
                                _selectedPaymentMethod ==
                                    DokanPosPaymentMethod.nagad ||
                                _selectedPaymentMethod ==
                                    DokanPosPaymentMethod.rocket) {
                              reference =
                                  'Payment: ${_selectedPaymentMethod.name.toUpperCase()} | Sender: ${_senderNumberController.text.trim()} | TxnID: ${_transactionIdController.text.trim()}';
                              paymentDetails = {
                                'senderNumber':
                                    _senderNumberController.text.trim(),
                                'transactionId':
                                    _transactionIdController.text.trim(),
                              };
                            } else if (_selectedPaymentMethod ==
                                DokanPosPaymentMethod.card) {
                              reference =
                                  'Payment: CARD | Cardholder: ${_cardHolderController.text.trim()} | Card Number: ${_cardNumberController.text.trim()} | Expiry: ${_cardExpiryController.text.trim()} | CVV: ${_cardCvvController.text.trim()}';
                              paymentDetails = {
                                'cardHolderName':
                                    _cardHolderController.text.trim(),
                                'cardLast4': _cardNumberController.text
                                            .trim()
                                            .length >=
                                        4
                                    ? _cardNumberController.text
                                        .trim()
                                        .substring(_cardNumberController.text
                                                .trim()
                                                .length -
                                            4)
                                    : _cardNumberController.text.trim(),
                                'cardType': 'UNKNOWN',
                                'approvalCode':
                                    _transactionIdController.text.trim(),
                                'transactionId':
                                    _transactionIdController.text.trim(),
                              };
                            }

                            await ref
                                .read(dokanPosProvider.notifier)
                                .collectDuePayment(
                                  customerKey: widget.customerKey,
                                  amount: enteredAmount,
                                  collectedAt: DateTime.now(),
                                  reference: reference,
                                  paymentMethod: _selectedPaymentMethod,
                                  paymentDetails: paymentDetails,
                                );

                            if (!mounted) return;
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF0C8C67),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  content: Text(
                                    'মোট ${_banglaDigits(enteredAmount.toString())} টাকা বাকি আদায় সফল হয়েছে।',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              );

                            final customerPhone =
                                profile.phone.trim().isNotEmpty
                                    ? profile.phone
                                    : (orders.isEmpty
                                        ? ''
                                        : orders.first.customerNumber);

                            if (customerPhone.isNotEmpty) {
                              await _sendWhatsAppReceipt(
                                context: context,
                                name: customerName,
                                phone: customerPhone,
                                amount: enteredAmount,
                                remaining: remainingDue,
                              );
                            }

                            if (!mounted) return;
                            Navigator.of(context).pop();
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFDC2626),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 3),
                                  content: Text(
                                    'আদায় সংরক্ষণ করা যায়নি: $e',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005C47),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF94A3B8),
                    disabledForegroundColor: Colors.white70,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'আদায় নিশ্চিত করুন — ${_banglaDigits(enteredAmount.toString())}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isFullPaid
                                  ? 'বাকি সম্পূর্ণ পরিশোধ হবে ✓'
                                  : 'বাকি থাকবে ৳ ${_banglaDigits(remainingDue.toString())} ✓',
                              style: const TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip({required String label, required String chipKey}) {
    final isSelected = _selectedQuickChip == chipKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedQuickChip = chipKey;
          if (chipKey == 'custom') {
            _typedAmount = '';
            _customAmountController.text = '';
          } else {
            _typedAmount = '';
            _customAmountController.text = '';
            FocusScope.of(context).unfocus();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005C47) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF005C47) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  Widget _keyboardButton(String bangla, String english) {
    return GestureDetector(
      onTap: () => _onNumpadPressed(english),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Center(
          child: Text(
            bangla,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBanner({
    required Color color,
    required Color textColor,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodChip({
    required String label,
    required IconData icon,
    required DokanPosPaymentMethod method,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF5F2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF005C47) : const Color(0xFFCBD5E1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF005C47)
                  : const Color(0xFF64748B),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF005C47)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
