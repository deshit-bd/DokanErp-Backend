part of '../business_screens.dart';

class DokanSupplierDetailScreen extends ConsumerStatefulWidget {
  const DokanSupplierDetailScreen({super.key, required this.supplierKey});

  final String supplierKey;

  @override
  ConsumerState<DokanSupplierDetailScreen> createState() =>
      _DokanSupplierDetailScreenState();
}

class _DokanSupplierDetailScreenState
    extends ConsumerState<DokanSupplierDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref
            .read(dokanPosProvider.notifier)
            .fetchSupplierLedger(widget.supplierKey);
      } on NetworkException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.message)));
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('সরবরাহকারীর লেজার লোড করা যায়নি।')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dokanPosProvider);
    final summaries = _buildSupplierSummaries(state);
    _SupplierSummary? supplier;
    for (final item in summaries) {
      if (item.key == widget.supplierKey) {
        supplier = item;
        break;
      }
    }

    if (supplier == null) {
      return const _SupplierErrorScreen(
          message: 'সরবরাহকারীর তথ্য পাওয়া যায়নি');
    }

    final selectedSupplier = supplier;
    final purchaseHistory = selectedSupplier.ledger
        .where((entry) => entry.kind == DokanSupplierLedgerKind.purchase)
        .toList(growable: false);
    final paymentHistory = selectedSupplier.ledger
        .where((entry) => entry.kind == DokanSupplierLedgerKind.payment)
        .toList(growable: false);
    final recentActivity =
        selectedSupplier.ledger.take(3).toList(growable: false);
    final hasPhone = selectedSupplier.phone.trim().isNotEmpty;
    final purchaseHistoryKey = GlobalKey();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                _HeaderButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'সরবরাহকারীর বিস্তারিত',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF163732),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD9E5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F5EF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _supplierInitials(selectedSupplier.name),
                          style: const TextStyle(
                            color: Color(0xFF0C8C67),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedSupplier.name,
                              style: const TextStyle(
                                color: Color(0xFF163732),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _supplierAddress(selectedSupplier.address),
                              style: const TextStyle(
                                color: Color(0xFF6B7B79),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _miniInfoChip(
                          icon: Icons.call_rounded,
                          text: hasPhone ? selectedSupplier.phone : 'ফোন নেই'),
                      _miniInfoChip(
                        icon: Icons.inventory_2_rounded,
                        text: selectedSupplier.productType.isEmpty
                            ? 'পণ্যের ধরন নেই'
                            : selectedSupplier.productType,
                      ),
                      _miniInfoChip(
                        icon: Icons.percent_rounded,
                        text: selectedSupplier.creditLimit > 0
                            ? 'ক্রেডিট ${_formatCurrency(selectedSupplier.creditLimit)}'
                            : 'ক্রেডিট নেই',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.shopping_bag_rounded,
                          iconColor: const Color(0xFF0E855D),
                          iconBackground: const Color(0xFFE7F5EF),
                          title: 'মোট ক্রয়',
                          value:
                              _formatCurrency(selectedSupplier.totalPurchase),
                          subtitle: 'এ পর্যন্ত মোট ক্রয়',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFFB14A12),
                          iconBackground: const Color(0xFFFFF0E2),
                          title: 'মোট বকেয়া',
                          value: _formatCurrency(selectedSupplier.totalDue),
                          subtitle: selectedSupplier.totalDue > 0
                              ? 'এখনও বকেয়া আছে'
                              : 'বকেয়া নেই',
                          valueColor: selectedSupplier.totalDue > 0
                              ? const Color(0xFFB3261E)
                              : const Color(0xFF0C8C67),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: selectedSupplier.totalDue > 0
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DokanSupplierPaymentScreen(
                                    supplierKey: selectedSupplier.key),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.payments_rounded),
                    label: const Text('পেমেন্ট করুন'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0C8C67),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final targetContext = purchaseHistoryKey.currentContext;
                      if (targetContext != null) {
                        Scrollable.ensureVisible(
                          targetContext,
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          alignment: 0.08,
                        );
                      }
                    },
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: const Text('ক্রয় ইতিহাস'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF163732),
                      side: const BorderSide(color: Color(0xFFD9E5E1)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (hasPhone)
              OutlinedButton.icon(
                onPressed: () async {
                  final digits =
                      _supplierPhoneForWhatsApp(selectedSupplier.phone);
                  if (digits.isEmpty) {
                    return;
                  }
                  final success = await launchUrl(
                    Uri.parse(
                        'https://wa.me/$digits?text=${Uri.encodeComponent('নতুন পণ্য অর্ডার, ${selectedSupplier.name}')}'),
                    mode: LaunchMode.externalApplication,
                  );
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('WhatsApp চালু করা যায়নি')),
                    );
                  }
                },
                icon: const Icon(Icons.chat_rounded),
                label: const Text('WhatsApp order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF163732),
                  side: const BorderSide(color: Color(0xFFD9E5E1)),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            const SizedBox(height: 14),
            KeyedSubtree(
              key: purchaseHistoryKey,
              child: _DetailSection(
                title: 'ক্রয় ইতিহাস',
                child: _SupplierLedgerHistoryList(
                  emptyLabel: 'কোনো ক্রয় ইতিহাস নেই',
                  records: purchaseHistory,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: 'পেমেন্ট ইতিহাস',
              child: _SupplierLedgerHistoryList(
                emptyLabel: 'কোনো পেমেন্ট ইতিহাস নেই',
                records: paymentHistory,
              ),
            ),
            const SizedBox(height: 14),
            _DetailSection(
              title: 'সাম্প্রতিক কার্যক্রম',
              child: _SupplierLedgerHistoryList(
                emptyLabel: 'কোনো সাম্প্রতিক কার্যক্রম নেই',
                records: recentActivity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DokanAllDuesSummaryScreen extends StatelessWidget {
  const DokanAllDuesSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DokanDueManagementScreen();
  }
}

class DokanDueCollectionScreen extends StatelessWidget {
  const DokanDueCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DokanDueManagementScreen();
  }
}

class DokanCustomerListScreen extends ConsumerStatefulWidget {
  const DokanCustomerListScreen({super.key});

  @override
  ConsumerState<DokanCustomerListScreen> createState() =>
      _DokanCustomerListScreenState();
}

class _DokanCustomerListScreenState
    extends ConsumerState<DokanCustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _ready = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final hasCustomers = ref.read(dokanPosProvider).customerProfiles.isNotEmpty;
    _ready = hasCustomers;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      try {
        if (!hasCustomers) {
          await ref.read(dokanPosProvider.notifier).fetchCustomers();
        } else {
          ref.read(dokanPosProvider.notifier).fetchCustomers().catchError((_) {});
        }
      } catch (_) {}
      if (mounted) {
        setState(() => _ready = true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      await ref.read(dokanPosProvider.notifier).fetchCustomers();
      ref.invalidate(salesHistoryOrdersProvider);
      await ref.read(salesHistoryOrdersProvider.future);
    } catch (_) {}
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dokanPosProvider);
    final ordersAsync = ref.watch(salesHistoryOrdersProvider);
    final orders = mergeSalesHistoryOrders(
      localOrders: state.orders,
      remoteOrders: ordersAsync.value ?? const <DokanPosOrderRecord>[],
    );

    if (!_ready) {
      return const _CustomerLoadingScreen();
    }

    try {
      final customers = _buildCustomerSummaries(state, orders);
      final sortedCustomers = List<_CustomerSummary>.from(customers)
        ..sort((a, b) => b.totalDue.compareTo(a.totalDue));
      final filteredCustomers = _query.trim().isEmpty
          ? sortedCustomers
          : sortedCustomers.where((customer) {
              return DokanSearchMatcher.match(customer.name, _query) ||
                  DokanSearchMatcher.match(customer.phone, _query);
            }).toList(growable: false);

      final totalCustomers = customers.length;
      final totalReceivable =
          customers.fold<int>(0, (sum, customer) => sum + customer.totalDue);
      final dueCustomers =
          customers.where((customer) => customer.totalDue > 0).length;

      return Scaffold(
        backgroundColor: const Color(0xFFF4F8F6),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddCustomerSheet(context, ref),
          backgroundColor: const Color(0xFF0C8C67),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('গ্রাহক যোগ করুন'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DokanFadeSlideIn(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Row(
                    children: [
                      _HeaderButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'গ্রাহক',
                              style: TextStyle(
                                color: Color(0xFF163732),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'গ্রাহকের তথ্য, বাকি ও ট্রানজেকশন',
                              style: TextStyle(
                                color: Color(0xFF6B7B79),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _HeaderButton(
                        icon: Icons.refresh_rounded,
                        onTap: _onRefresh,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color(0xFF0C8C67),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: [
                      ScrollReveal(
                        child: _SearchField(
                          controller: _searchController,
                          query: _query,
                          onChanged: (value) => setState(() => _query = value),
                          onClear: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 80),
                        child: _ReceivableHeroCard(
                          totalReceivable: totalReceivable,
                          totalCustomers: totalCustomers,
                          dueCustomers: dueCustomers,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ScrollReveal(
                        delay: const Duration(milliseconds: 160),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.people_alt_rounded,
                                iconColor: const Color(0xFF0E855D),
                                iconBackground: const Color(0xFFE7F5EF),
                                title: 'গ্রাহক',
                                value: _banglaDigits(totalCustomers.toString()),
                                subtitle: dueCustomers > 0
                                    ? Row(
                                        children: [
                                          const Text(
                                            'বাকি আছে ',
                                            style: TextStyle(
                                              color: Color(0xFF7A8A88),
                                              fontSize: 11.5,
                                              height: 1.25,
                                            ),
                                          ),
                                          AnimatedNumberString(
                                            _banglaDigits(dueCustomers.toString()),
                                            style: const TextStyle(
                                              color: Color(0xFF7A8A88),
                                              fontSize: 11.5,
                                              height: 1.25,
                                            ),
                                          ),
                                          const Text(
                                            ' জন',
                                            style: TextStyle(
                                              color: Color(0xFF7A8A88),
                                              fontSize: 11.5,
                                              height: 1.25,
                                            ),
                                          ),
                                        ],
                                      )
                                    : 'সব হিসাব আপডেট আছে',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                icon: Icons.account_balance_wallet_rounded,
                                iconColor: const Color(0xFFB14A12),
                                iconBackground: const Color(0xFFFFF0E2),
                                title: 'মোট পাওনা',
                                value: _formatCurrency(totalReceivable),
                                subtitle: 'সকল গ্রাহকের বাকি যোগফল',
                                valueColor: const Color(0xFFB3261E),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const DokanDueManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_query.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'ফলাফল: ${_banglaDigits(filteredCustomers.length.toString())} জন গ্রাহক',
                            style: const TextStyle(
                              color: Color(0xFF516462),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (filteredCustomers.isEmpty)
                        const _CustomerEmptyState()
                      else
                        ...filteredCustomers.asMap().entries.map(
                          (entry) {
                            final index = entry.key;
                            final customer = entry.value;
                            return ScrollReveal(
                              delay: Duration(milliseconds: (index % 5) * 60),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Dismissible(
                                  key: ValueKey('customer-${customer.key}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDECEC),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 18),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.delete_rounded,
                                            color: Color(0xFFD6453A)),
                                        SizedBox(width: 8),
                                        Text(
                                          'বাদ দিন',
                                          style: TextStyle(
                                            color: Color(0xFFD6453A),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  confirmDismiss: (_) => _confirmDeleteCustomer(
                                      context, ref, customer),
                                  child: _CustomerListTile(
                                    customer: customer,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => DokanCustomerDetailScreen(
                                            customerKey: customer.key),
                                      ),
                                    ),
                                    onLongPress: () => _confirmDeleteCustomer(
                                        context, ref, customer),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      return const _CustomerErrorScreen();
    }
  }
}
