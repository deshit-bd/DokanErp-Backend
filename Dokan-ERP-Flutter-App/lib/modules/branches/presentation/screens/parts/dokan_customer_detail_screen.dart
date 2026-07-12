part of '../business_screens.dart';

/// Converts shared [customerPaymentsProvider] entries into [DokanOrderPayment].
List<DokanOrderPayment> _mapCustomerPayments(
    List<CustomerPaymentEntry> entries) {
  return entries.map((e) {
    final method = switch (e.paymentMethod.trim().toLowerCase()) {
      'bkash' => DokanPosPaymentMethod.bkash,
      'nagad' => DokanPosPaymentMethod.nagad,
      'rocket' => DokanPosPaymentMethod.rocket,
      'card' => DokanPosPaymentMethod.card,
      'bank' => DokanPosPaymentMethod.bank,
      _ => DokanPosPaymentMethod.cash,
    };
    return DokanOrderPayment(
      id: e.id,
      amount: e.amount,
      method: method,
      createdAt: e.paidAt,
      reference: e.notes,
    );
  }).toList();
}

class DokanCustomerDetailScreen extends ConsumerStatefulWidget {
  const DokanCustomerDetailScreen({super.key, required this.customerKey});

  final String customerKey;

  @override
  ConsumerState<DokanCustomerDetailScreen> createState() =>
      _DokanCustomerDetailScreenState();
}

class _DokanCustomerDetailScreenState
    extends ConsumerState<DokanCustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await ref.read(dokanPosProvider.notifier).fetchCustomers();
        ref.invalidate(salesHistoryOrdersProvider);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dokanPosProvider);
    final ordersAsync = ref.watch(salesHistoryOrdersProvider);
    final orders = mergeSalesHistoryOrders(
      localOrders: state.orders,
      remoteOrders: ordersAsync.value ?? const <DokanPosOrderRecord>[],
    );

    try {
      final customers = _buildCustomerSummaries(state, orders);
      _CustomerSummary? customer;
      for (final item in customers) {
        if (item.key == widget.customerKey) {
          customer = item;
          break;
        }
      }

      if (customer == null) {
        return const _CustomerErrorScreen(message: 'গ্রাহকের তথ্য পাওয়া যায়নি');
      }
      final selectedCustomer = customer;

      final remotePaymentsAsync = selectedCustomer.id.isNotEmpty
          ? ref.watch(customerPaymentsProvider(selectedCustomer.id))
          : const AsyncValue<List<CustomerPaymentEntry>>.data([]);
      final remotePayments =
          _mapCustomerPayments(remotePaymentsAsync.value ?? const []);

      // Extract unified timeline transactions
      final List<_TransactionHistoryItem> timeline = [];
      for (final order in selectedCustomer.orders) {
        if (order.id.startsWith('opening-')) {
          timeline.add(_TransactionHistoryItem(
            id: order.id,
            title: 'প্রারম্ভিক বাকি',
            subtitle: 'শুরুর ব্যালেন্স',
            amount: order.dueAmount,
            isDue: true,
            date: order.createdAt,
          ));
          continue;
        }

        final itemCount = order.lines.length;
        timeline.add(_TransactionHistoryItem(
          id: order.id,
          title:
              'বিক্রয় — ${itemCount > 0 ? "${_banglaDigits(itemCount.toString())}টি পণ্য" : "পণ্য"}',
          subtitle:
              'ইনভয়েস #${order.id.substring(math.max(0, order.id.length - 5))}',
          amount: order.totalAmount,
          isDue: order.dueAmount > 0,
          date: order.createdAt,
        ));

        for (final payment in order.paymentHistory) {
          final String methodBangla = switch (payment.method) {
            DokanPosPaymentMethod.bkash => 'বিকাশ',
            DokanPosPaymentMethod.nagad => 'নগদ (Nagad)',
            DokanPosPaymentMethod.rocket => 'রকেট',
            DokanPosPaymentMethod.card => 'কার্ড',
            DokanPosPaymentMethod.bank => 'ব্যাংক',
            _ => 'নগদ',
          };
          timeline.add(_TransactionHistoryItem(
            id: payment.id,
            title: 'পেমেন্ট — $methodBangla আদায়',
            subtitle:
                'রিসিট #${payment.id.substring(math.max(0, payment.id.length - 5))}',
            amount: payment.amount,
            isDue: false,
            date: payment.createdAt,
          ));
        }
      }

      for (final payment in remotePayments) {
        if (timeline.any((item) => item.id == payment.id)) {
          continue;
        }
        final String methodBangla = switch (payment.method) {
          DokanPosPaymentMethod.bkash => 'বিকাশ',
          DokanPosPaymentMethod.nagad => 'নগদ (Nagad)',
          DokanPosPaymentMethod.rocket => 'রকেট',
          DokanPosPaymentMethod.card => 'কার্ড',
          DokanPosPaymentMethod.bank => 'ব্যাংক',
          _ => 'নগদ',
        };
        timeline.add(_TransactionHistoryItem(
          id: payment.id,
          title: 'পেমেন্ট — $methodBangla আদায়',
          subtitle:
              'রিসিট #${payment.id.substring(math.max(0, payment.id.length - 5))}',
          amount: payment.amount,
          isDue: false,
          date: payment.createdAt,
        ));
      }

      // Sort timeline by date descending
      timeline.sort((a, b) => b.date.compareTo(a.date));
      final recentTimeline = timeline.take(3).toList(growable: false);

      return Scaffold(
        backgroundColor: const Color(0xFFF4F8F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F8F6),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E293B)),
          ),
          title: const Text(
            'খদ্দের বিস্তারিত',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E293B)),
            ),
            IconButton(
              onPressed: () {
                _confirmDeleteCustomer(context, ref, selectedCustomer)
                    .then((deleted) {
                  if (deleted == true) {
                    Navigator.of(context).pop();
                  }
                });
              },
              icon:
                  const Icon(Icons.more_vert_rounded, color: Color(0xFF1E293B)),
            ),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: RefreshIndicator(
            onRefresh: () async {
              try {
                await ref.read(dokanPosProvider.notifier).fetchCustomers();
                ref.invalidate(salesHistoryOrdersProvider);
                await ref.read(salesHistoryOrdersProvider.future);
              } catch (_) {}
            },
            color: const Color(0xFF0C8C67),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
              children: [
                _CustomerDetailHeaderCard(customer: selectedCustomer),
                const SizedBox(height: 14),
                _TotalDueCard(customer: selectedCustomer),
                const SizedBox(height: 14),
                _DetailCustomerStatsGrid(customer: selectedCustomer),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'লেনদেনের ইতিহাস',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                DokanCustomerTransactionHistoryScreen(
                              customerKey: selectedCustomer.key,
                            ),
                          ),
                        );
                      },
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text(
                        'সব দেখুন',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0C8C67),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (recentTimeline.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'এই গ্রাহকের কোনো লেনদেন নেই',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  ...recentTimeline.map((item) => _TimelineTile(item: item)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: const Color(0xFFF4F8F6),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _sendWhatsAppMessage(context, selectedCustomer),
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 20, color: Color(0xFF128C7E)),
                      label: const Text(
                        'হোয়াটসঅ্যাপ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DokanDuePaymentScreen(
                                customerKey: selectedCustomer.key),
                          ),
                        );
                      },
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: const Text(
                        'বাকি আদায় করুন',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005C47),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (_) {
      return const _CustomerErrorScreen(
          message: 'গ্রাহক প্রোফাইল লোড করা যায়নি');
    }
  }
}

Future<void> _callCustomer(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('কল শুরু করা যায়নি')),
    );
  }
}

Future<bool> _showBulkDeleteDialog({
  required BuildContext context,
  required String entityLabel,
  required List<String> names,
}) async {
  final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('আপনি কি নিশ্চিত?'),
            content: Text(
              '${names.join(' • ')}\n\nনির্বাচিত $entityLabel(গুলো) মুছতে চান?',
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('বাতিল'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD6453A),
                  foregroundColor: Colors.white,
                ),
                child: const Text('মুছুন'),
              ),
            ],
          );
        },
      ) ??
      false;
  return confirmed;
}

Future<bool> _confirmDeleteCustomer(
  BuildContext context,
  WidgetRef ref,
  _CustomerSummary customer,
) async {
  final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('গ্রাহক বাদ দিন'),
            content: Text(
              '${customer.name} গ্রাহককে তালিকা থেকে বাদ দিতে চান?\n\nসতর্কতা: এটি তালিকা থেকে সরিয়ে দেবে, কিন্তু আগের লেনদেনের ডাটা সিস্টেমে থাকতে পারে।',
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('বাতিল'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD6453A),
                  foregroundColor: Colors.white,
                ),
                child: const Text('বাদ দিন'),
              ),
            ],
          );
        },
      ) ??
      false;

  if (confirmed) {
    ref.read(dokanPosProvider.notifier).deleteCustomer(customer.key);
  }

  return confirmed;
}

Future<void> _showAddCustomerSheet(BuildContext context, WidgetRef ref) async {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final openingDueController = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      bool isSubmitting = false;
      String? nameError;
      String? phoneError;
      String? openingDueError;

      bool isPhoneValid(String value) =>
          RegExp(r'^[0-9]{11}$').hasMatch(value.trim());
      bool isNameValid(String value) => value.trim().isNotEmpty;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final openingDueText = openingDueController.text.trim();
          final openingDueValue =
              openingDueText.isEmpty ? 0 : int.tryParse(openingDueText);
          final openingDueHasError = openingDueText.isNotEmpty &&
              (openingDueValue == null || openingDueValue < 0);
          final canSubmit = !isSubmitting &&
              isNameValid(nameController.text) &&
              isPhoneValid(phoneController.text) &&
              !openingDueHasError;

          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 12),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E4E0),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'গ্রাহক যোগ করুন',
                        style: TextStyle(
                          color: Color(0xFF163732),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        onChanged: (_) {
                          setSheetState(() {
                            nameError = isNameValid(nameController.text)
                                ? null
                                : 'নাম দিতে হবে';
                          });
                        },
                        style: const TextStyle(color: Color(0xFF111111)),
                        decoration: InputDecoration(
                          labelText: 'নাম *',
                          errorText: nameError,
                          filled: true,
                          fillColor: const Color(0xFFF7FAF9),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) {
                          setSheetState(() {
                            phoneError = isPhoneValid(phoneController.text)
                                ? null
                                : '১১ সংখ্যার সঠিক নম্বর লিখুন';
                          });
                        },
                        style: const TextStyle(color: Color(0xFF111111)),
                        decoration: InputDecoration(
                          labelText: 'ফোন নম্বর *',
                          errorText: phoneError,
                          filled: true,
                          fillColor: const Color(0xFFF7FAF9),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        style: const TextStyle(color: Color(0xFF111111)),
                        decoration: InputDecoration(
                          labelText: 'ঠিকানা',
                          filled: true,
                          fillColor: const Color(0xFFF7FAF9),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: openingDueController,
                        keyboardType: TextInputType.number,
                        inputFormatters: NumericInputFormatters.wholeNumber,
                        onChanged: (_) {
                          setSheetState(() {
                            final text = openingDueController.text.trim();
                            final amount =
                                text.isEmpty ? 0 : int.tryParse(text);
                            openingDueError =
                                text.isEmpty || (amount != null && amount >= 0)
                                    ? null
                                    : 'বাকি টাকার পরিমাণ সঠিক নয়';
                          });
                        },
                        style: const TextStyle(color: Color(0xFF111111)),
                        decoration: InputDecoration(
                          labelText: 'প্রারম্ভিক বাকি',
                          errorText: openingDueError,
                          filled: true,
                          fillColor: const Color(0xFFF7FAF9),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: canSubmit
                              ? () async {
                                  setSheetState(() {
                                    nameError = isNameValid(nameController.text)
                                        ? null
                                        : 'নাম দিতে হবে';
                                    phoneError =
                                        isPhoneValid(phoneController.text)
                                            ? null
                                            : '১১ সংখ্যার সঠিক নম্বর লিখুন';
                                    final text =
                                        openingDueController.text.trim();
                                    final amount =
                                        text.isEmpty ? 0 : int.tryParse(text);
                                    openingDueError = text.isEmpty ||
                                            (amount != null && amount >= 0)
                                        ? null
                                        : 'বাকি টাকার পরিমাণ সঠিক নয়';
                                  });

                                  if (!isNameValid(nameController.text) ||
                                      !isPhoneValid(phoneController.text)) {
                                    return;
                                  }

                                  final openingDueText =
                                      openingDueController.text.trim();
                                  final openingDue = openingDueText.isEmpty
                                      ? 0
                                      : int.tryParse(openingDueText) ?? -1;
                                  if (openingDue < 0) {
                                    setSheetState(() => openingDueError =
                                        'বাকি টাকার পরিমাণ সঠিক নয়');
                                    return;
                                  }

                                  setSheetState(() => isSubmitting = true);
                                  try {
                                    await ref
                                        .read(dokanPosProvider.notifier)
                                        .addCustomer(
                                          name: nameController.text,
                                          phone: phoneController.text,
                                          address: addressController.text,
                                          openingDue: openingDue,
                                        );
                                  } on NetworkException catch (error) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(error.message)),
                                      );
                                    }
                                    if (sheetContext.mounted) {
                                      setSheetState(() => isSubmitting = false);
                                    }
                                    return;
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('গ্রাহক যোগ করা যায়নি')),
                                      );
                                    }
                                    if (sheetContext.mounted) {
                                      setSheetState(() => isSubmitting = false);
                                    }
                                    return;
                                  }
                                  if (sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop();
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('গ্রাহক যোগ করা হয়েছে')),
                                    );
                                  }
                                }
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0C8C67),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('সংরক্ষণ'),
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
    },
  );
}

List<_CustomerSummary> _buildCustomerSummaries(
    DokanPosState state, List<DokanPosOrderRecord> orders) {
  final grouped = <String, List<DokanPosOrderRecord>>{};
  for (final order in orders) {
    final key = _customerKeyForOrder(order);
    if (state.hiddenCustomerKeys.contains(key)) {
      continue;
    }
    grouped.putIfAbsent(key, () => <DokanPosOrderRecord>[]).add(order);
  }

  final profilesByKey = <String, DokanCustomerProfileRecord>{
    for (final profile in state.customerProfiles) profile.key: profile,
  };

  final allKeys = <String>{...grouped.keys, ...profilesByKey.keys}
      .where((key) => !state.hiddenCustomerKeys.contains(key))
      .toList(growable: false);

  final customers = allKeys.map((key) {
    final profile = profilesByKey[key];
    final purchaseOrders = List<DokanPosOrderRecord>.from(
        grouped[key] ?? const <DokanPosOrderRecord>[])
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final openingDue = profile?.openingDue ?? 0;
    final localTotalPurchase =
        purchaseOrders.fold<int>(0, (sum, order) => sum + order.totalAmount);
    final localTotalPaid =
        purchaseOrders.fold<int>(0, (sum, order) => sum + order.paidAmount);
    final localOrderDue =
        purchaseOrders.fold<int>(0, (sum, order) => sum + order.dueAmount);
    final hasProfileFinance = profile != null &&
        (profile.totalSales > 0 ||
            profile.totalPaid > 0 ||
            profile.currentDue > 0 ||
            profile.openingDue > 0);
    final totalPurchase = hasProfileFinance
        ? math.max(localTotalPurchase, profile.totalSales)
        : localTotalPurchase;
    final totalPaid = hasProfileFinance
        ? math.max(localTotalPaid, profile.totalPaid)
        : localTotalPaid;
    final totalDue =
        hasProfileFinance ? profile.currentDue : (localOrderDue + openingDue);
    final name = _customerDisplayName(
      profile?.name ??
          (purchaseOrders.isNotEmpty ? purchaseOrders.first.customerName : key),
    );
    final phone = profile?.phone.trim().isNotEmpty == true
        ? profile!.phone.trim()
        : (purchaseOrders.isNotEmpty
            ? purchaseOrders.first.customerNumber.trim()
            : '');
    final address = _customerAddress(profile?.address ?? '');
    final firstTransactionAt = purchaseOrders.isNotEmpty
        ? purchaseOrders.last.createdAt
        : (profile?.createdAt ?? DateTime.now());
    final lastTransactionAt = purchaseOrders.isNotEmpty
        ? purchaseOrders.first.createdAt
        : (profile?.updatedAt ?? firstTransactionAt);
    final openingRecord = openingDue > 0
        ? DokanPosOrderRecord(
            id: 'opening-$key',
            customerName: name,
            customerNumber: phone,
            totalAmount: openingDue,
            paidAmount: 0,
            dueAmount: openingDue,
            paymentMethod: DokanPosPaymentMethod.cash,
            status: DokanPosOrderStatus.due,
            summary: 'প্রারম্ভিক বাকি',
            createdAt: purchaseOrders.isNotEmpty
                ? firstTransactionAt.subtract(const Duration(microseconds: 1))
                : firstTransactionAt,
          )
        : null;
    final openingRecords = openingRecord == null
        ? const <DokanPosOrderRecord>[]
        : <DokanPosOrderRecord>[openingRecord];
    final historyOrders = <DokanPosOrderRecord>[
      ...openingRecords,
      ...purchaseOrders,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _CustomerSummary(
      id: profile?.id ?? '',
      key: key,
      name: name,
      phone: phone,
      address: address,
      totalPurchase: totalPurchase,
      totalPaid: totalPaid,
      totalDue: totalDue,
      openingDue: openingDue,
      orders: List<DokanPosOrderRecord>.unmodifiable(historyOrders),
      transactionOrders: List<DokanPosOrderRecord>.unmodifiable(purchaseOrders),
      firstTransactionAt: firstTransactionAt,
      lastTransactionAt: lastTransactionAt,
      createdAt: profile?.createdAt ?? firstTransactionAt,
    );
  }).toList(growable: false)
    ..sort((a, b) {
      final dueCompare = b.totalDue.compareTo(a.totalDue);
      if (dueCompare != 0) {
        return dueCompare;
      }
      return b.lastTransactionAt.compareTo(a.lastTransactionAt);
    });

  return customers;
}

class _CustomerDetailHeaderCard extends StatelessWidget {
  const _CustomerDetailHeaderCard({required this.customer});
  final _CustomerSummary customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF007A5E),
            child: Text(
              _customerInitials(customer.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
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
                  customer.name,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                if (customer.phone.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Text(
                        customer.phone,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                if (customer.address.isNotEmpty &&
                    customer.address != 'সংরক্ষিত নেই') ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          customer.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (customer.totalDue > 0) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DokanDuePaymentScreen(customerKey: customer.key),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005C47),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
              child: const Text(
                'বাকি আদায়',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TotalDueCard extends StatelessWidget {
  const _TotalDueCard({required this.customer});
  final _CustomerSummary customer;

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().difference(customer.createdAt).inDays;
    final ageText = '${_banglaDigits(math.max(1, days).toString())} দিন ধরে';
    final limit = 15000;
    final usagePercentage =
        math.min(100, ((customer.totalDue / limit) * 100).round());

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2), // Reddish light background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book_rounded,
                      color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'মোট বাকি',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // Amber 100
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ageText,
                  style: const TextStyle(
                    color: Color(0xFFD97706), // Amber 700
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _formatCurrency(customer.totalDue),
            style: const TextStyle(
              color: Color(0xFFE11D48), // Rose 600
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: usagePercentage / 100,
              color: const Color(0xFFE11D48),
              backgroundColor: const Color(0xFFFDA4AF),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'সীমা: ${_formatCurrency(limit)}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_banglaDigits(usagePercentage.toString())}% ব্যবহৃত',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCustomerStatsGrid extends StatelessWidget {
  const _DetailCustomerStatsGrid({required this.customer});
  final _CustomerSummary customer;

  @override
  Widget build(BuildContext context) {
    final orderCount =
        customer.orders.where((o) => !o.id.startsWith('opening-')).length;

    return Row(
      children: [
        Expanded(
          child: _DetailMiniStatCard(
            title: 'মোট কেনাকাটা',
            value: _formatCurrency(customer.totalPurchase),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DetailMiniStatCard(
            title: 'মোট পরিশোধ',
            value: _formatCurrency(customer.totalPaid),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DetailMiniStatCard(
            title: 'কেনার সংখ্যা',
            value: '${_banglaDigits(orderCount.toString())}টি',
          ),
        ),
      ],
    );
  }
}

class _DetailMiniStatCard extends StatelessWidget {
  const _DetailMiniStatCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionHistoryItem {
  _TransactionHistoryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isDue,
    required this.date,
  });

  final String id;
  final String title;
  final String subtitle;
  final int amount;
  final bool isDue;
  final DateTime date;
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.item});
  final _TransactionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final stripColor =
        item.isDue ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final iconColor =
        item.isDue ? const Color(0xFFDC2626) : const Color(0xFF15803D);
    final iconBg =
        item.isDue ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7);
    final statusText = item.isDue ? 'বাকি' : 'জমা';
    final statusColor =
        item.isDue ? const Color(0xFFB91C1C) : const Color(0xFF15803D);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              color: stripColor,
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isDue
                      ? Icons.shopping_cart_outlined
                      : Icons.payments_outlined,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_relativeTime(item.date)} • ${item.subtitle}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatCurrency(item.amount),
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
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

String _relativeTime(DateTime date) {
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

Future<void> _sendWhatsAppMessage(
    BuildContext context, _CustomerSummary customer) async {
  if (customer.phone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('গ্রাহকের কোনো ফোন নম্বর নেই')),
    );
    return;
  }
  var phone = customer.phone.replaceAll(RegExp(r'\D'), '');
  if (!phone.startsWith('88') && phone.length == 11) {
    phone = '88$phone';
  }
  final text = Uri.encodeComponent('প্রিয় ${customer.name},\n'
      'Dokan ERP-তে আপনার বর্তমান বকেয়া (Due) বাকি পরিমাণ: ৳${customer.totalDue}।\n'
      'অনুগ্রহ করে দ্রুত বাকি পরিশোধ করার জন্য অনুরোধ করা হলো। ধন্যবাদ!');
  final urlString = 'https://api.whatsapp.com/send?phone=$phone&text=$text';
  final uri = Uri.parse(urlString);
  final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!success && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('WhatsApp ওপেন করা যায়নি')),
    );
  }
}

class DokanCustomerTransactionHistoryScreen extends ConsumerWidget {
  const DokanCustomerTransactionHistoryScreen({
    super.key,
    required this.customerKey,
  });

  final String customerKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dokanPosProvider);
    final ordersAsync = ref.watch(salesHistoryOrdersProvider);
    final orders = mergeSalesHistoryOrders(
      localOrders: state.orders,
      remoteOrders: ordersAsync.value ?? const <DokanPosOrderRecord>[],
    );

    try {
      final customers = _buildCustomerSummaries(state, orders);
      _CustomerSummary? customer;
      for (final item in customers) {
        if (item.key == customerKey) {
          customer = item;
          break;
        }
      }

      if (customer == null) {
        return const _CustomerErrorScreen(message: 'গ্রাহকের তথ্য পাওয়া যায়নি');
      }
      final selectedCustomer = customer;

      final remotePaymentsAsync = selectedCustomer.id.isNotEmpty
          ? ref.watch(customerPaymentsProvider(selectedCustomer.id))
          : const AsyncValue<List<CustomerPaymentEntry>>.data([]);
      final remotePayments =
          _mapCustomerPayments(remotePaymentsAsync.value ?? const []);

      // Extract unified timeline transactions
      final List<_TransactionHistoryItem> timeline = [];
      for (final order in selectedCustomer.orders) {
        if (order.id.startsWith('opening-')) {
          timeline.add(_TransactionHistoryItem(
            id: order.id,
            title: 'প্রারম্ভিক বাকি',
            subtitle: 'শুরুর ব্যালেন্স',
            amount: order.dueAmount,
            isDue: true,
            date: order.createdAt,
          ));
          continue;
        }

        final itemCount = order.lines.length;
        timeline.add(_TransactionHistoryItem(
          id: order.id,
          title:
              'বিক্রয় — ${itemCount > 0 ? "${_banglaDigits(itemCount.toString())}টি পণ্য" : "পণ্য"}',
          subtitle:
              'ইনভয়েস #${order.id.substring(math.max(0, order.id.length - 5))}',
          amount: order.totalAmount,
          isDue: order.dueAmount > 0,
          date: order.createdAt,
        ));

        for (final payment in order.paymentHistory) {
          final String methodBangla = switch (payment.method) {
            DokanPosPaymentMethod.bkash => 'বিকাশ',
            DokanPosPaymentMethod.nagad => 'নগদ (Nagad)',
            DokanPosPaymentMethod.rocket => 'রকেট',
            DokanPosPaymentMethod.card => 'কার্ড',
            DokanPosPaymentMethod.bank => 'ব্যাংক',
            _ => 'নগদ',
          };
          timeline.add(_TransactionHistoryItem(
            id: payment.id,
            title: 'পেমেন্ট — $methodBangla আদায়',
            subtitle:
                'রিসিট #${payment.id.substring(math.max(0, payment.id.length - 5))}',
            amount: payment.amount,
            isDue: false,
            date: payment.createdAt,
          ));
        }
      }

      for (final payment in remotePayments) {
        if (timeline.any((item) => item.id == payment.id)) {
          continue;
        }
        final String methodBangla = switch (payment.method) {
          DokanPosPaymentMethod.bkash => 'বিকাশ',
          DokanPosPaymentMethod.nagad => 'নগদ (Nagad)',
          DokanPosPaymentMethod.rocket => 'রকেট',
          DokanPosPaymentMethod.card => 'কার্ড',
          DokanPosPaymentMethod.bank => 'ব্যাংক',
          _ => 'নগদ',
        };
        timeline.add(_TransactionHistoryItem(
          id: payment.id,
          title: 'পেমেন্ট — $methodBangla আদায়',
          subtitle:
              'রিসিট #${payment.id.substring(math.max(0, payment.id.length - 5))}',
          amount: payment.amount,
          isDue: false,
          date: payment.createdAt,
        ));
      }

      // Sort timeline by date descending
      timeline.sort((a, b) => b.date.compareTo(a.date));

      return Scaffold(
        backgroundColor: const Color(0xFFF4F8F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF4F8F6),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1E293B)),
          ),
          title: Text(
            '${selectedCustomer.name} - লেনদেনের ইতিহাস',
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              try {
                await ref.read(dokanPosProvider.notifier).fetchCustomers();
                ref.invalidate(salesHistoryOrdersProvider);
                await ref.read(salesHistoryOrdersProvider.future);
              } catch (_) {}
            },
            color: const Color(0xFF0C8C67),
            child: timeline.isEmpty
                ? const Center(
                    child: Text(
                      'এই গ্রাহকের কোনো লেনদেন নেই',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics()),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: timeline.length,
                    itemBuilder: (context, index) {
                      return _TimelineTile(item: timeline[index]);
                    },
                  ),
          ),
        ),
      );
    } catch (_) {
      return const _CustomerErrorScreen(
          message: 'লেনদেনের ইতিহাস লোড করা যায়নি');
    }
  }
}
