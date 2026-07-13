part of '../business_screens.dart';

String _banglaDigits(String input) {
  const map = <String, String>{
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };
  return input.split('').map((char) => map[char] ?? char).join();
}

String _formatCurrency(int value) {
  final digits = value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
  return '৳ ${_banglaDigits(digits)}';
}

String _formatDate(DateTime date) {
  const months = <String>[
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];
  return '${_banglaDigits(date.day.toString())} ${months[date.month - 1]} ${_banglaDigits(date.year.toString())}';
}

String _formatDateTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${_formatDate(date)} • ${_banglaDigits(hour.toString())}:${_banglaDigits(minute)} $period';
}

String _formatShortTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${_banglaDigits(hour.toString())}:${_banglaDigits(minute)} $period';
}

String _customerKeyForOrder(DokanPosOrderRecord order) {
  final phone = order.customerNumber.trim();
  if (phone.isNotEmpty) {
    return phone;
  }
  final nameLower = order.customerName.trim().toLowerCase();
  if (nameLower == 'guest customer' ||
      nameLower == 'হাঁটা বিক্রয়' ||
      nameLower == 'অতিথি গ্রাহক' ||
      nameLower.isEmpty) {
    return 'guest_customer_unified_key';
  }
  return nameLower;
}

String _customerDisplayName(String value) {
  final text = value.trim();
  final textLower = text.toLowerCase();
  if (textLower == 'guest customer' ||
      textLower == 'হাঁটা বিক্রয়' ||
      textLower == 'অতিথি গ্রাহক' ||
      text.isEmpty) {
    return 'অতিথি গ্রাহক';
  }
  return text;
}

String _customerAddress(String value) {
  final text = value.trim();
  return text.isEmpty ? 'সংরক্ষিত নেই' : text;
}

String _supplierAddress(String value) {
  final text = value.trim();
  return text.isEmpty ? 'ঠিকানা নেই' : text;
}

String _supplierMaskedPhone(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) {
    return 'ফোন নেই';
  }
  if (digits.length <= 4) {
    return digits;
  }
  final lastFour = digits.substring(digits.length - 4);
  final prefix = digits.startsWith('880')
      ? '+880'
      : digits.startsWith('01')
          ? '01'
          : digits.substring(0, 2);
  return '$prefix••••$lastFour';
}

String _supplierInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'স';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1).toUpperCase()}${parts.last.substring(0, 1).toUpperCase()}';
}

String _supplierPhoneDigits(String value) {
  return value.replaceAll(RegExp(r'[^0-9]'), '');
}

String _supplierPhoneForWhatsApp(String value) {
  final digits = _supplierPhoneDigits(value);
  if (digits.startsWith('880')) {
    return digits;
  }
  if (digits.startsWith('01') && digits.length == 11) {
    return '88$digits';
  }
  return digits;
}

String _customerInitials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'গ';
  }
  if (parts.length == 1) {
    return String.fromCharCode(parts.first.runes.first);
  }
  return '${String.fromCharCode(parts.first.runes.first)}${String.fromCharCode(parts[1].runes.first)}';
}

class DokanAddExpenseScreen extends StatelessWidget {
  const DokanAddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DokanExpenseEntryScreen();
  }
}

class DokanExpenseListScreen extends StatelessWidget {
  const DokanExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DokanExpenseReportScreen();
  }
}

class DokanAddNewStaffScreen extends ConsumerStatefulWidget {
  const DokanAddNewStaffScreen({super.key, this.staffKey});

  final String? staffKey;

  @override
  ConsumerState<DokanAddNewStaffScreen> createState() =>
      _DokanAddNewStaffScreenState();
}

class _DokanAddNewStaffScreenState
    extends ConsumerState<DokanAddNewStaffScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _shopIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _nameError;
  String? _phoneError;
  String? _roleError;
  String? _shopIdError;
  String? _passwordError;
  String _role = 'Salesman';

  // Salesman permissions state (added per request)
  bool _canSell = true;
  bool _canViewStock = true;
  bool _canViewReports = false;
  bool _canChangePrice = false;
  bool _canCollectDue = true;
  bool _showValidationError = false;

  static const List<String> _roles = <String>[
    'Salesman',
    'Manager',
    'Cashier',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final flow = ref.read(dokanAppFlowProvider);
        String shopVal = flow.shopCode.isNotEmpty ? flow.shopCode : flow.shopId;

        // Fetch active shopCode from API if empty
        if (shopVal.length > 20 && !shopVal.startsWith('DID-') && !shopVal.startsWith('SID-')) {
          try {
            final client = ref.read(apiClientProvider);
            final response = await client.get('/app/api/auth/me');
            final sessionData = response.data['session'] as Map<String, dynamic>?;
            final rawShopCode = sessionData?['shopCode'] as String?;
            if (rawShopCode != null && rawShopCode.isNotEmpty) {
              final match = RegExp(r'(\d+)$').firstMatch(rawShopCode);
              final shopCodeSuffix = match != null ? match.group(0) : '';
              if (shopCodeSuffix != null && shopCodeSuffix.isNotEmpty) {
                shopVal = 'DID-$shopCodeSuffix';
              } else {
                shopVal = rawShopCode;
              }
            }
          } catch (_) {
            // fallback if offline
          }
        }

        // Fallback hardcoded values for deshit and current active test shop
        if (shopVal == 'cmr0gdhu7005kw8g06c2lngfc') {
          shopVal = 'DID-236606';
        } else if (shopVal == 'cmrbi29xh0002w8ne4rbmj6ue') {
          shopVal = 'DID-200371';
        } else if (shopVal.startsWith('SID-')) {
          shopVal = shopVal.replaceFirst('SID-', 'DID-');
        }

        setState(() {
          _shopIdController.text = shopVal;
        });
      }

      final staff = _resolveStaff();
      if (staff == null || !mounted) {
        return;
      }
      final perms = staff.permissions.toSet();
      setState(() {
        _nameController.text = staff.name;
        _phoneController.text = staff.phone;
        _addressController.text = '';
        _noteController.text = staff.note;
        _role = staff.role;
        _canSell = perms.contains('sales.sell');
        _canViewStock = perms.contains('inventory.view');
        _canViewReports = perms.contains('reports.view');
        _canChangePrice = perms.contains('sales.changePrice');
        _canCollectDue = perms.contains('sales.collectDue');
      });
    });
  }

  Future<void> _savePermissions() async {
    setState(() => _isSubmitting = true);
    final staff = _resolveStaff();
    if (staff == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    String staffUserId = staff.address;
    if (staffUserId.isEmpty) {
      final profiles = ref.read(dokanPosProvider).staffProfiles;
      try {
        final match = profiles.firstWhere(
          (p) => p.phone == staff.phone || p.key == staff.key || p.phone == staff.key,
        );
        if (match.address.isNotEmpty) {
          staffUserId = match.address;
        }
      } catch (_) {}
    }
    if (staffUserId.isEmpty) {
      staffUserId = staff.key;
    }

    try {
      final client = ref.read(apiClientProvider);
      await client.post(
        '/app/api/staff/$staffUserId/permissions',
        headers: const <String, String>{
          'X-HTTP-Method-Override': 'PATCH',
        },
        body: {
          'canSell': _canSell,
          'canViewStock': _canViewStock,
          'canViewReports': _canViewReports,
          'canChangePrice': _canChangePrice,
          'canCollectDue': _canCollectDue,
        },
      );
      final nextPerms = <String>[];
      if (_canSell) nextPerms.add('sales.sell');
      if (_canViewStock) nextPerms.add('inventory.view');
      if (_canViewReports) nextPerms.add('reports.view');
      if (_canChangePrice) nextPerms.add('sales.changePrice');
      if (_canCollectDue) nextPerms.add('sales.collectDue');

      ref.read(dokanPosProvider.notifier).updateStaffPermissions(
            staff.key,
            nextPerms,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কর্মচারী আপডেট করা হয়েছে')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('আপডেট করতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'),
          backgroundColor: Color(0xFFB42318),
        ),
      );
    }
  }

  _StaffSummary? _resolveStaff() {
    if (widget.staffKey == null) {
      return null;
    }
    final state = ref.read(dokanPosProvider);
    final staff = _buildStaffSummaries(state)
        .where((item) => item.key == widget.staffKey)
        .toList(growable: false);
    return staff.isEmpty ? null : staff.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _shopIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidMobile(String value) =>
      RegExp(r'^(?:\+8801|01)[0-9]{9}$').hasMatch(value.trim());

  void _validate() {
    if (!_showValidationError) return;
    setState(() {
      _nameError =
          _nameController.text.trim().isEmpty ? 'নাম দেওয়া বাধ্যতামূলক' : null;
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _phoneError = 'মোবাইল নম্বর খালি রাখা যাবে না';
      } else if (!_isValidMobile(phone)) {
        _phoneError = 'সঠিক মোবাইল নম্বর দিন (যেমন: 01XXXXXXXXX)';
      } else {
        _phoneError = null;
      }
      _roleError = _role.trim().isEmpty ? 'ভূমিকা নির্বাচন করুন' : null;
      _shopIdError = _shopIdController.text.trim().isEmpty
          ? 'দোকান নম্বর (Dokan ID) দেওয়া আবশ্যক'
          : null;
      _passwordError = _passwordController.text.trim().isEmpty
          ? 'পাসওয়ার্ড দেওয়া আবশ্যক'
          : _passwordController.text.trim().length < 4
              ? 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে'
              : null;
    });
  }

  bool get _canSubmit {
    return !_isSubmitting &&
        _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _isValidMobile(_phoneController.text) &&
        _role.trim().isNotEmpty &&
        _shopIdController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _passwordController.text.trim().length >= 4;
  }

  Future<void> _save() async {
    setState(() {
      _showValidationError = true;
    });
    _validate();
    if (!_canSubmit) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final client = ref.read(apiClientProvider);
      final shopId = _shopIdController.text.trim();
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      final response = await client.post(
        '/app/api/auth/register-salesman',
        body: {
          'shopId': shopId,
          'name': name,
          'mobile': phone,
          'password': password,
          'permissions': {
            'canSell': _canSell,
            'canViewStock': _canViewStock,
            'canViewReports': _canViewReports,
            'canChangePrice': _canChangePrice,
            'canCollectDue': _canCollectDue,
          }
        },
      );

      final responseData = response.data;
      final registeredUser = responseData['user'] as Map<String, dynamic>?;
      final salesmanId = registeredUser?['id'] as String? ?? '';

      ref.read(dokanPosProvider.notifier).addStaff(
            name: name,
            phone: phone,
            role: _role,
            address: salesmanId.isNotEmpty ? salesmanId : _addressController.text,
            note: _noteController.text,
            permissions: _defaultPermissionsForRole(_role),
            pinCode: password,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কর্মচারী সংরক্ষণ করা হয়েছে')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is NetworkException
                ? error.message
                : 'কর্মচারী যোগ করতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।',
          ),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'কর্মচারী',
                    style: TextStyle(
                      color: Color(0xFF163732),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
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
                    readOnly: widget.staffKey != null,
                    onChanged: (_) => _validate(),
                    style: TextStyle(
                      color: widget.staffKey != null
                          ? const Color(0xFF6B7B79)
                          : const Color(0xFF111111),
                    ),
                    decoration: InputDecoration(
                      labelText: 'নাম *',
                      errorText: _nameError,
                      filled: true,
                      fillColor: widget.staffKey != null
                          ? const Color(0xFFF1F5F4)
                          : const Color(0xFFF8FAF9),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: widget.staffKey != null
                              ? const Color(0xFFD9E5E1)
                              : const Color(0xFF0C8C67),
                          width: widget.staffKey != null ? 1.0 : 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    readOnly: widget.staffKey != null,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))
                    ],
                    onChanged: (_) => _validate(),
                    style: TextStyle(
                      color: widget.staffKey != null
                          ? const Color(0xFF6B7B79)
                          : const Color(0xFF111111),
                    ),
                    decoration: InputDecoration(
                      labelText: 'মোবাইল নম্বর *',
                      hintText: '+8801XXXXXXXXX / 01XXXXXXXXX',
                      errorText: _phoneError,
                      filled: true,
                      fillColor: widget.staffKey != null
                          ? const Color(0xFFF1F5F4)
                          : const Color(0xFFF8FAF9),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: widget.staffKey != null
                              ? const Color(0xFFD9E5E1)
                              : const Color(0xFF0C8C67),
                          width: widget.staffKey != null ? 1.0 : 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _shopIdController,
                    readOnly: true,
                    style: const TextStyle(color: Color(0xFF6B7B79)),
                    decoration: InputDecoration(
                      labelText: 'দোকান নম্বর (Dokan ID) *',
                      errorText: _shopIdError,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F4),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFFD9E5E1), width: 1.0),
                      ),
                    ),
                  ),
                  if (widget.staffKey == null) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) => _validate(),
                      style: const TextStyle(color: Color(0xFF111111)),
                      decoration: InputDecoration(
                        labelText: 'পাসওয়ার্ড *',
                        errorText: _passwordError,
                        filled: true,
                        fillColor: const Color(0xFFF8FAF9),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF6B7B79),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
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
                    DropdownButtonFormField<String>(
                      value: _role,
                      items: _roles
                          .map(
                            (role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(growable: false),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF6B7B79),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _role = value;
                          if (_role == 'Salesman') {
                            _canSell = true;
                            _canViewStock = true;
                            _canViewReports = false;
                            _canChangePrice = false;
                            _canCollectDue = true;
                          } else if (_role == 'Manager') {
                            _canSell = true;
                            _canViewStock = true;
                            _canViewReports = true;
                            _canChangePrice = true;
                            _canCollectDue = true;
                          } else if (_role == 'Cashier') {
                            _canSell = true;
                            _canViewStock = false;
                            _canViewReports = false;
                            _canChangePrice = false;
                            _canCollectDue = true;
                          }
                        });
                        _validate();
                      },
                      decoration: InputDecoration(
                        labelText: 'ভূমিকা *',
                        errorText: _roleError,
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
                      controller: _noteController,
                      maxLines: 3,
                      style: const TextStyle(color: Color(0xFF111111)),
                      decoration: InputDecoration(
                        labelText: 'নোট',
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
                  const SizedBox(height: 16),
                  const Text(
                    'অনুমতিসমূহ (Permissions)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00694C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD9E5E1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _buildPermissionSwitch(
                          title: 'পণ্য বিক্রয় (Sales)',
                          value: _canSell,
                          onChanged: (val) => setState(() => _canSell = val),
                        ),
                        const Divider(height: 1, color: Color(0xFFE8ECEB)),
                        _buildPermissionSwitch(
                          title: 'স্টক দেখা (View Stock)',
                          value: _canViewStock,
                          onChanged: (val) => setState(() => _canViewStock = val),
                        ),
                        const Divider(height: 1, color: Color(0xFFE8ECEB)),
                        _buildPermissionSwitch(
                          title: 'পণ্যের ডিসকাউন্ট ও দাম পরিবর্তন (Price & Discount)',
                          value: _canChangePrice,
                          onChanged: (val) => setState(() => _canChangePrice = val),
                        ),
                        const Divider(height: 1, color: Color(0xFFE8ECEB)),
                        _buildPermissionSwitch(
                          title: 'রিপোর্ট দেখা (View Reports)',
                          value: _canViewReports,
                          onChanged: (val) => setState(() => _canViewReports = val),
                        ),
                        const Divider(height: 1, color: Color(0xFFE8ECEB)),
                        _buildPermissionSwitch(
                          title: 'বকেয়া সংগ্রহ (Collect Due)',
                          value: _canCollectDue,
                          onChanged: (val) => setState(() => _canCollectDue = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSubmitting
                    ? null
                    : (widget.staffKey != null
                        ? _savePermissions
                        : _save),
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

  Widget _buildPermissionSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF0C8C67),
            activeTrackColor: const Color(0xFFD0F0E8),
          ),
        ],
      ),
    );
  }
}
