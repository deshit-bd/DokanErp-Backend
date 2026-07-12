part of '../auth_screens.dart';

bool _isElevenDigitPhone(String value) => RegExp(r'^\d{11}$').hasMatch(value.trim());

bool _isFourDigitCode(String value) => RegExp(r'^\d{4}$').hasMatch(value);

bool _isPasswordValid(String value) => value.trim().length >= 4;

void _showWarning(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFFB42318),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

class DokanLoginScreen extends ConsumerStatefulWidget {
  const DokanLoginScreen({
    super.key,
    this.onBack,
    this.onLogin,
    this.onOtpLogin,
    this.onAccountOpen,
    this.initialRole = 0,
    this.onRoleChanged,
  });

  final VoidCallback? onBack;
  final VoidCallback? onLogin;
  final VoidCallback? onOtpLogin;
  final VoidCallback? onAccountOpen;
  final int initialRole;
  final ValueChanged<int>? onRoleChanged;

  @override
  ConsumerState<DokanLoginScreen> createState() => _DokanLoginScreenState();
}

class _DokanLoginScreenState extends ConsumerState<DokanLoginScreen> {
  late int _selectedRole;
  bool _rememberMe = true;
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _shopIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _shopIdError;
  String? _phoneError;
  String? _passwordError;
  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _shopIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final mobile = _mobileController.text.trim();
    final shopId = _shopIdController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _shopIdError = null;
      _phoneError = null;
      _passwordError = null;
    });

    bool hasError = false;

    if (_selectedRole == 1 && shopId.isEmpty) {
      setState(() => _shopIdError = 'দোকান নম্বর (Dokan ID) দেওয়া আবশ্যক।');
      hasError = true;
    }

    if (mobile.isEmpty) {
      setState(() => _phoneError = 'মোবাইল নম্বর দেওয়া আবশ্যক।');
      hasError = true;
    } else if (!_isElevenDigitPhone(mobile)) {
      setState(() => _phoneError = 'সঠিক ১১ ডিজিট মোবাইল নম্বর দিন।');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'পাসওয়ার্ড দেওয়া আবশ্যক।');
      hasError = true;
    } else if (!_isPasswordValid(password)) {
      setState(() => _passwordError = 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে।');
      hasError = true;
    }

    if (hasError) return;

    final gateway = ref.read(authGatewayProvider);
    if (gateway != null) {
      setState(() => _submitting = true);
      try {
        final user = await gateway.login(
          phone: mobile,
          password: password,
          role: _selectedRole,
          shopId: _selectedRole == 1 ? shopId : null,
          rememberMe: _rememberMe,
        );
        await ref.read(dokanAppFlowProvider.notifier).loginUser(
              role: user.role.index,
              salesmanPhone:
                  user.role.index == 1 ? (user.phone ?? mobile) : null,
              salesmanName: user.role.index == 1 ? user.name : null,
              shopId: user.shopId,
              shopName: user.shopName,
              shopCode: user.shopCode,
              permissions: user.permissions,
            );
        widget.onLogin?.call();
      } on NetworkException catch (error) {
        if (mounted) setState(() => _passwordError = error.message);
      } catch (_) {
        if (mounted) {
          setState(() => _passwordError = 'Login failed. Please try again.');
        }
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
      return;
    }

    final flow = ref.read(dokanAppFlowProvider);
    final posState = ref.read(dokanPosProvider);

    if (_selectedRole == 0) {
      // Owner Login

      final passwordValid = await ref
          .read(dokanAppFlowProvider.notifier)
          .verifyOwnerPassword(password);
      if (mobile != flow.ownerPhone || !passwordValid) {
        setState(() => _phoneError = 'মোবাইল নম্বর অথবা পাসওয়ার্ড ভুল।');
        return;
      }

      await ref.read(dokanAppFlowProvider.notifier).loginUser(
            role: 0,
          );
      widget.onLogin?.call();
    } else {
      // Salesman Login

      bool isShopMatch(String identifier, String targetId, String targetCode) {
        final cleanId = identifier.trim().toLowerCase();
        if (cleanId == targetId.toLowerCase()) return true;
        if (targetCode.isNotEmpty && cleanId == targetCode.toLowerCase()) return true;
        
        final match = RegExp(r'(\d+)$').firstMatch(cleanId);
        if (match != null) {
          final digits = match.group(0)!;
          if (targetId.endsWith(digits) || (targetCode.isNotEmpty && targetCode.endsWith(digits))) {
            return true;
          }
        }
        return false;
      }

      if (flow.shopId.isNotEmpty && !isShopMatch(shopId, flow.shopId, flow.shopCode)) {
        setState(() => _shopIdError = 'দোকান নম্বর (Dokan ID) মিলছে না।');
        return;
      }

      final matchingStaff = posState.staffProfiles
          .where((staff) =>
              staff.phone == mobile && staff.role == 'Salesman' && staff.active)
          .toList();

      if (matchingStaff.isEmpty) {
        setState(
            () => _phoneError = 'এই নম্বরে কোনো সক্রিয় সেলসম্যান পাওয়া যায়নি।');
        return;
      }

      final staff = matchingStaff.first;

      if (staff.pinCode == null ||
          !CredentialHasher.verify(password, staff.pinCode!)) {
        setState(() => _passwordError = 'PIN ভুল।');
        return;
      }

      await ref.read(dokanAppFlowProvider.notifier).loginUser(
            role: 1,
            salesmanPhone: staff.phone,
            salesmanName: staff.name,
          );
      widget.onLogin?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FBFF),
      body: SafeArea(
        child: Column(
          children: [
            _LoginHeader(
                onBack: widget.onBack ?? () => Navigator.maybePop(context)),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 10,
                              offset: Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RoleToggle(
                                    selectedIndex: _selectedRole,
                                    onChanged: (index) {
                                      setState(() => _selectedRole = index);
                                      widget.onRoleChanged?.call(index);
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  _LoginFormHeader(
                                    isSalesman: _selectedRole == 1,
                                  ),
                                  const SizedBox(height: 24),
                                  if (_selectedRole == 1) ...[
                                    _LoginInputField(
                                      label: 'দোকান নম্বর (Dokan ID)',
                                      hintText: 'Dokan ID',
                                      helperText:
                                          'যে দোকানে কাজ করেন সেই Dokan ID লিখুন',
                                      keyboardType: TextInputType.text,
                                      prefix: const _FieldIcon(
                                          icon: Icons.storefront_rounded),
                                      controller: _shopIdController,
                                    ),
                                    if (_shopIdError != null) ...[
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _shopIdError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                  ],
                                  _LoginInputField(
                                    label: _selectedRole == 1
                                        ? 'সেলসম্যান মোবাইল নম্বর'
                                        : 'মোবাইল নম্বর',
                                    hintText: '01XXXXXXXXX',
                                    helperText: '১১ ডিজিটের মোবাইল নম্বর',
                                    keyboardType: TextInputType.phone,
                                    prefix: const _CountryPrefix(),
                                    controller: _mobileController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                  ),
                                  if (_phoneError != null) ...[
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _phoneError!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  _LoginInputField(
                                    label: _selectedRole == 1
                                        ? 'PIN'
                                        : 'পাসওয়ার্ড',
                                    hintText: _selectedRole == 1
                                        ? 'সেলসম্যান PIN লিখুন'
                                        : 'পাসওয়ার্ড লিখুন',
                                    helperText: _selectedRole == 1
                                        ? 'সেলসম্যান PIN'
                                        : 'কমপক্ষে ৪ ডিজিট',
                                    prefix: const _FieldIcon(
                                        icon: Icons.lock_outline_rounded),
                                    obscureText: _obscurePassword,
                                    onToggleObscure: () {
                                      setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      );
                                    },
                                    controller: _passwordController,
                                  ),
                                  if (_passwordError != null) ...[
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _passwordError!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  _RememberForgotRow(
                                    rememberMe: _rememberMe,
                                    onRememberChanged: (value) {
                                      setState(
                                          () => _rememberMe = value ?? false);
                                    },
                                    onForgotPressed: widget.onOtpLogin,
                                  ),
                                  const SizedBox(height: 20),
                                  _PrimaryActionButton(
                                    label: 'লগইন করুন',
                                    onPressed:
                                        _submitting ? null : _submitLogin,
                                  ),
                                  const SizedBox(height: 20),
                                  const _DividerWithLabel(label: 'অথবা'),
                                  const SizedBox(height: 20),
                                  _OutlineActionButton(
                                    label: 'OTP Login',
                                    icon: Icons.sms_outlined,
                                    onPressed: widget.onOtpLogin,
                                  ),
                                  const SizedBox(height: 16),
                                  if (_selectedRole == 0)
                                    _RegistrationLink(
                                        label: 'অ্যাকাউন্ট খুলুন',
                                        onPressed: widget.onAccountOpen)
                                  else
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2),
                                      child: Text(
                                        'সেলসম্যান অ্যাকাউন্ট তৈরি করতে পারবেন না।',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6D7A73),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const _SecurityFooter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
