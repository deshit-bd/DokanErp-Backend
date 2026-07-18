part of '../business_screens.dart';

class DokanNewSupplierAddScreen extends ConsumerStatefulWidget {
  const DokanNewSupplierAddScreen({super.key});

  @override
  ConsumerState<DokanNewSupplierAddScreen> createState() =>
      _DokanNewSupplierAddScreenState();
}

class _DokanNewSupplierAddScreenState
    extends ConsumerState<DokanNewSupplierAddScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();
  final TextEditingController _creditLimitController = TextEditingController();
  bool _isSubmitting = false;
  String? _nameError;
  String? _phoneError;
  String? _creditLimitError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _productTypeController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  bool _isPhoneValid(String value) {
    final text = value.trim();
    return RegExp(r'^(?:\+8801|01)[0-9]{9}$').hasMatch(text);
  }

  bool _isNameValid(String value) => value.trim().isNotEmpty;

  int? _parseCreditLimit() {
    final text = _creditLimitController.text.trim();
    if (text.isEmpty) {
      return 0;
    }
    return int.tryParse(text);
  }

  void _validate() {
    setState(() {
      _nameError =
          _isNameValid(_nameController.text) ? null : 'নাম দেওয়া বাধ্যতামূলক';
      final phoneText = _phoneController.text.trim();
      if (phoneText.isEmpty) {
        _phoneError = 'নম্বর খালি রাখা যাবে না';
      } else if (!_isPhoneValid(phoneText)) {
        _phoneError = 'সঠিক মোবাইল নম্বর দিন';
      } else {
        _phoneError = null;
      }

      final creditText = _creditLimitController.text.trim();
      final credit = creditText.isEmpty ? 0 : int.tryParse(creditText);
      _creditLimitError =
          creditText.isNotEmpty && (credit == null || credit < 0)
              ? 'সঠিক সীমা লিখুন'
              : null;
    });
  }

  bool get _canSubmit {
    final credit = _parseCreditLimit();
    return !_isSubmitting &&
        _isNameValid(_nameController.text) &&
        _phoneController.text.trim().isNotEmpty &&
        _isPhoneValid(_phoneController.text) &&
        credit != null &&
        credit >= 0;
  }

  Future<void> _save() async {
    _validate();
    if (!_canSubmit) {
      return;
    }

    final creditLimit = _parseCreditLimit();
    if (creditLimit == null || creditLimit < 0) {
      setState(() => _creditLimitError = 'সঠিক সীমা লিখুন');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(dokanPosProvider.notifier).addSupplier(
            name: _nameController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            productType: _productTypeController.text,
            creditLimit: creditLimit,
          );
    } on NetworkException catch (error) {
      if (mounted) {
        setState(() => _nameError = error.message);
      }
      return;
    } catch (_) {
      if (mounted) {
        setState(
            () => _nameError = 'সরবরাহকারী যোগ করা যায়নি। আবার চেষ্টা করুন।');
      }
      return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('সরবরাহকারী যোগ করা হয়েছে')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _canSubmit;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'নতুন সরবরাহকারী',
                        style: TextStyle(
                          color: Color(0xFF163732),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'সহজ ফর্ম, পরিষ্কার যাচাই',
                        style: TextStyle(
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
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD9E5E1)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => _validate(),
                    style: const TextStyle(color: Color(0xFF111111)),
                    decoration: InputDecoration(
                      labelText: 'নাম *',
                      hintText: 'সরবরাহকারীর নাম',
                      errorText: _nameError,
                      filled: true,
                      fillColor: const Color(0xFFF8FAF9),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF0C8C67), width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    ],
                    onChanged: (_) => _validate(),
                    style: const TextStyle(color: Color(0xFF111111)),
                    decoration: InputDecoration(
                      labelText: 'মোবাইল *',
                      hintText: '+8801XXXXXXXXX / 01XXXXXXXXX',
                      errorText: _phoneError,
                      filled: true,
                      fillColor: const Color(0xFFF8FAF9),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF0C8C67), width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    style: const TextStyle(color: Color(0xFF111111)),
                    decoration: InputDecoration(
                      labelText: 'ঠিকানা',
                      hintText: 'ঐচ্ছিক',
                      filled: true,
                      fillColor: const Color(0xFFF8FAF9),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF0C8C67), width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _productTypeController,
                    style: const TextStyle(color: Color(0xFF111111)),
                    decoration: InputDecoration(
                      labelText: 'পণ্যের ধরন',
                      hintText: 'ঐচ্ছিক',
                      filled: true,
                      fillColor: const Color(0xFFF8FAF9),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF0C8C67), width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _creditLimitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: NumericInputFormatters.wholeNumber,
                    onChanged: (_) => _validate(),
                    style: const TextStyle(color: Color(0xFF111111)),
                    decoration: InputDecoration(
                      labelText: 'ক্রেডিট লিমিট',
                      hintText: 'ঐচ্ছিক',
                      errorText: _creditLimitError,
                      filled: true,
                      fillColor: const Color(0xFFF8FAF9),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF0C8C67), width: 1.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: canSubmit && !_isSubmitting ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0C8C67),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Text('সংরক্ষণ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DokanSupplierListScreen extends ConsumerStatefulWidget {
  const DokanSupplierListScreen({super.key});

  @override
  ConsumerState<DokanSupplierListScreen> createState() =>
      _DokanSupplierListScreenState();
}

class _DokanSupplierListScreenState
    extends ConsumerState<DokanSupplierListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedSupplierKeys = <String>{};
  bool _ready = false;
  bool _selectionMode = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuppliers();
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
    await _loadSuppliers();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSuppliers() async {
    try {
      await ref.read(dokanPosProvider.notifier).fetchSuppliers();
    } on NetworkException catch (error) {
      if (mounted) _showSupplierError(error.message);
    } catch (_) {
      if (mounted) _showSupplierError('সরবরাহকারীর তালিকা লোড করা যায়নি।');
    }
  }

  void _showSupplierError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _enterSelectionMode(_SupplierSummary supplier) {
    setState(() {
      _selectionMode = true;
      _selectedSupplierKeys.add(supplier.key);
    });
  }

  void _toggleSupplierSelection(_SupplierSummary supplier) {
    setState(() {
      if (_selectedSupplierKeys.contains(supplier.key)) {
        _selectedSupplierKeys.remove(supplier.key);
      } else {
        _selectedSupplierKeys.add(supplier.key);
        _selectionMode = true;
      }
      if (_selectedSupplierKeys.isEmpty) {
        _selectionMode = false;
      }
    });
  }

  void _clearSupplierSelection() {
    setState(() {
      _selectedSupplierKeys.clear();
      _selectionMode = false;
    });
  }

  Future<void> _deleteSelectedSuppliers(
    BuildContext context,
    WidgetRef ref,
    List<_SupplierSummary> selectedSuppliers,
  ) async {
    if (selectedSuppliers.isEmpty) {
      return;
    }

    final confirmed = await _showBulkDeleteDialog(
      context: context,
      entityLabel: 'সরবরাহকারী',
      names: selectedSuppliers.map((item) => item.name).toList(growable: false),
    );
    if (!confirmed) {
      return;
    }

    try {
      for (final supplier in selectedSuppliers) {
        await ref.read(dokanPosProvider.notifier).deleteSupplier(supplier.key);
      }
    } on NetworkException catch (error) {
      if (mounted) _showSupplierError(error.message);
      return;
    } catch (_) {
      if (mounted) _showSupplierError('সরবরাহকারী মুছে ফেলা যায়নি।');
      return;
    }

    if (mounted) {
      _clearSupplierSelection();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dokanPosProvider);
    final flow = ref.watch(dokanAppFlowProvider);
    final canManageSuppliers = flow.can(
      DokanPermission.supplierManage,
    );

    if (!_ready) {
      return const _SupplierLoadingScreen();
    }

    try {
      final suppliers = _buildSupplierSummaries(state);
      final query = _query.trim();
      final filteredSuppliers = query.isEmpty
          ? suppliers
          : suppliers.where((supplier) {
              return DokanSearchMatcher.match(supplier.name, query) ||
                  DokanSearchMatcher.match(supplier.phone, query) ||
                  DokanSearchMatcher.match(supplier.productType, query);
            }).toList(growable: false);

      final totalSuppliers = suppliers.length;
      final totalDue =
          suppliers.fold<int>(0, (sum, supplier) => sum + supplier.totalDue);
      final currentMonthPurchase = suppliers.fold<int>(
          0, (sum, supplier) => sum + supplier.currentMonthPurchase);
      final selectedSuppliers = suppliers
          .where((supplier) => _selectedSupplierKeys.contains(supplier.key))
          .toList(growable: false);
      final canDeleteSelected = _selectionMode && selectedSuppliers.isNotEmpty;

      return Scaffold(
        backgroundColor: const Color(0xFFF4F8F6),
        floatingActionButton: canManageSuppliers
            ? FloatingActionButton.extended(
                onPressed: () async {
                  await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => const DokanNewSupplierAddScreen()),
                  );
                },
                backgroundColor: const Color(0xFF0C8C67),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('নতুন সরবরাহকারী'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              )
            : null,
        bottomNavigationBar: _selectionMode
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: canDeleteSelected
                          ? () => _deleteSelectedSuppliers(
                              context, ref, selectedSuppliers)
                          : null,
                      icon: const Icon(Icons.delete_rounded),
                      label: Text(
                          'ডিলিট করুন (${_banglaDigits(selectedSuppliers.length.toString())})'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD6453A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF0C8C67),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics()),
              padding:
                  EdgeInsets.fromLTRB(16, 12, 16, _selectionMode ? 144 : 96),
              children: [
                DokanFadeSlideIn(
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
                              'সরবরাহকারী তালিকা',
                              style: TextStyle(
                                color: Color(0xFF163732),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'সরবরাহকারী, বাকি ও ক্রয় তথ্য',
                              style: TextStyle(
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
                ),
                const SizedBox(height: 14),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.local_shipping_rounded,
                          iconColor: const Color(0xFF0E855D),
                          iconBackground: const Color(0xFFE7F5EF),
                          title: 'মোট সরবরাহকারী',
                          value: _banglaDigits(totalSuppliers.toString()),
                          subtitle: totalSuppliers > 0
                              ? 'সক্রিয় তালিকা'
                              : 'এখনও সরবরাহকারী নেই',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFFB14A12),
                          iconBackground: const Color(0xFFFFF0E2),
                          title: 'মোট বকেয়া',
                          value: _formatCurrency(totalDue),
                          subtitle: 'সব সরবরাহকারীর বকেয়া',
                          valueColor: const Color(0xFFB3261E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ScrollReveal(
                  delay: const Duration(milliseconds: 160),
                  child: _SummaryCard(
                    icon: Icons.shopping_cart_checkout_rounded,
                    iconColor: const Color(0xFF2564D7),
                    iconBackground: const Color(0xFFEAF2FF),
                    title: 'এই মাসের ক্রয়',
                    value: _formatCurrency(currentMonthPurchase),
                    subtitle: 'বর্তমান মাসের মোট ক্রয় যোগফল',
                  ),
                ),
                const SizedBox(height: 14),
                if (query.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'ফলাফল: ${_banglaDigits(filteredSuppliers.length.toString())} জন সরবরাহকারী',
                      style: const TextStyle(
                        color: Color(0xFF516462),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (filteredSuppliers.isEmpty)
                  const _SupplierEmptyState()
                else
                  ...filteredSuppliers.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final supplier = entry.value;
                      return ScrollReveal(
                        delay: Duration(milliseconds: (index % 5) * 60),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SupplierListTile(
                            supplier: supplier,
                            selected: _selectedSupplierKeys.contains(supplier.key),
                            selectionMode: _selectionMode,
                            onTap: () {
                              if (_selectionMode) {
                                _toggleSupplierSelection(supplier);
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DokanSupplierDetailScreen(
                                        supplierKey: supplier.key),
                                  ),
                                );
                              }
                            },
                            onLongPress: () {
                              if (_selectionMode) {
                                _toggleSupplierSelection(supplier);
                              } else {
                                _enterSelectionMode(supplier);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    } catch (_) {
      return const _SupplierErrorScreen();
    }
  }
}
