part of '../auth_screens.dart';

class DokanRegisterScreen extends StatefulWidget {
  const DokanRegisterScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  final VoidCallback? onBack;
  final Future<void> Function(String name, String phone, String password)?
      onContinue;

  @override
  State<DokanRegisterScreen> createState() => _DokanRegisterScreenState();
}

class _DokanRegisterScreenState extends State<DokanRegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showWarning(context, 'মালিকের নাম দিতে হবে।');
      return;
    }
    if (!_isElevenDigitPhone(mobile)) {
      _showWarning(context, 'মোবাইল নম্বর 11 digit হতে হবে।');
      return;
    }
    if (!_isPasswordValid(password)) {
      _showWarning(context, 'পাসওয়ার্ড কমপক্ষে 4 character হতে হবে।');
      return;
    }
    if (confirmPassword != password) {
      _showWarning(context, 'পাসওয়ার্ড মিলছে না।');
      return;
    }

    try {
      await widget.onContinue?.call(name, mobile, password);
    } on NetworkException catch (error) {
      if (mounted) _showWarning(context, error.message);
    } catch (_) {
      if (mounted) _showWarning(context, 'Registration failed. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FlowScreen(
      onBack: widget.onBack,
      accent: const Color(0xFF00694C),
      background: const Color(0xFFF4FBF7),
      title: 'অ্যাকাউন্ট খুলুন',
      subtitle: 'নতুন merchant account তৈরি করে দোকানের সেটআপ শুরু করুন।',
      icon: Icons.storefront_rounded,
      primaryLabel: 'আগে যান',
      onPrimary: _continue,
      children: [
        _FlowInputField(
          label: 'মালিকের নাম',
          hintText: 'আপনার নাম লিখুন',
          icon: Icons.person_outline_rounded,
          controller: _nameController,
        ),
        const SizedBox(height: 16),
        _FlowInputField(
          label: 'মোবাইল নম্বর',
          hintText: '01XXXXXXXXX',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          controller: _mobileController,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
        ),
        const SizedBox(height: 16),
        _FlowInputField(
          label: 'পাসওয়ার্ড',
          hintText: 'কমপক্ষে 4 character',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          onToggleObscure: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          controller: _passwordController,
        ),
        const SizedBox(height: 16),
        _FlowInputField(
          label: 'কনফার্ম পাসওয়ার্ড',
          hintText: 'আবার লিখুন',
          icon: Icons.verified_user_outlined,
          obscureText: _obscureConfirmPassword,
          onToggleObscure: () {
            setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            );
          },
          controller: _confirmPasswordController,
        ),
      ],
    );
  }
}

class DokanOtpLoginScreen extends StatefulWidget {
  const DokanOtpLoginScreen({
    super.key,
    this.onBack,
    this.onSendOtp,
  });

  final VoidCallback? onBack;
  final Future<void> Function(String phone)? onSendOtp;

  @override
  State<DokanOtpLoginScreen> createState() => _DokanOtpLoginScreenState();
}

class _DokanOtpLoginScreenState extends State<DokanOtpLoginScreen> {
  final TextEditingController _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final mobile = _mobileController.text.trim();
    if (!_isElevenDigitPhone(mobile)) {
      _showWarning(context, 'মোবাইল নম্বর 11 digit হতে হবে।');
      return;
    }
    try {
      await widget.onSendOtp?.call(mobile);
    } on NetworkException catch (error) {
      if (mounted) _showWarning(context, error.message);
    } catch (_) {
      if (mounted) _showWarning(context, 'OTP could not be sent.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FlowScreen(
      onBack: widget.onBack,
      accent: const Color(0xFF0E8B69),
      background: const Color(0xFFF1FBFF),
      title: 'OTP Login',
      subtitle: 'মোবাইল নাম্বার দিন, আমরা লগইনের জন্য OTP পাঠাবো।',
      icon: Icons.sms_outlined,
      primaryLabel: 'OTP পাঠান',
      onPrimary: _sendOtp,
      children: [
        _FlowInputField(
          label: 'মোবাইল নম্বর',
          hintText: '01XXXXXXXXX',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          controller: _mobileController,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
        ),
      ],
    );
  }
}

class DokanOtpVerificationScreen extends StatefulWidget {
  const DokanOtpVerificationScreen({
    super.key,
    this.onBack,
    this.onVerified,
  });

  final VoidCallback? onBack;
  final Future<void> Function(String code)? onVerified;

  @override
  State<DokanOtpVerificationScreen> createState() =>
      _DokanOtpVerificationScreenState();
}

class _DokanOtpVerificationScreenState
    extends State<DokanOtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (!_isFourDigitCode(otp)) {
      _showWarning(context, 'OTP 4 digit হতে হবে।');
      return;
    }
    try {
      await widget.onVerified?.call(otp);
    } on NetworkException catch (error) {
      if (mounted) _showWarning(context, error.message);
    } catch (_) {
      if (mounted) _showWarning(context, 'OTP verification failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FlowScreen(
      onBack: widget.onBack,
      accent: const Color(0xFF00694C),
      background: const Color(0xFFF7FBFA),
      title: 'OTP Verification',
      subtitle: 'মোবাইলে আসা ৪ সংখ্যার কোড বসিয়ে যাচাই করুন।',
      icon: Icons.verified_outlined,
      primaryLabel: 'যাচাই করুন',
      onPrimary: _verifyOtp,
      children: [
        _FlowInputField(
          label: 'OTP কোড',
          hintText: '0000',
          icon: Icons.pin_rounded,
          keyboardType: TextInputType.number,
          controller: _otpController,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
        ),
      ],
    );
  }
}

class DokanPinLoginScreen extends StatefulWidget {
  const DokanPinLoginScreen({
    super.key,
    this.onBack,
    this.onLogin,
  });

  final VoidCallback? onBack;
  final VoidCallback? onLogin;

  @override
  State<DokanPinLoginScreen> createState() => _DokanPinLoginScreenState();
}

class _DokanPinLoginScreenState extends State<DokanPinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _login() {
    final pin = _pinController.text.trim();
    if (!_isFourDigitCode(pin)) {
      _showWarning(context, 'PIN 4 digit হতে হবে।');
      return;
    }
    widget.onLogin?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _FlowScreen(
      onBack: widget.onBack,
      accent: const Color(0xFF0A6A4F),
      background: const Color(0xFFF4FBF7),
      title: 'PIN Login',
      subtitle: 'দ্রুত প্রবেশের জন্য ৪ ডিজিটের PIN ব্যবহার করুন।',
      icon: Icons.pin_rounded,
      primaryLabel: 'লগইন করুন',
      onPrimary: _login,
      children: [
        _FlowInputField(
          label: 'PIN',
          hintText: '0000',
          icon: Icons.pin_rounded,
          keyboardType: TextInputType.number,
          controller: _pinController,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
        ),
      ],
    );
  }
}

class DokanPinSetupScreen extends StatefulWidget {
  const DokanPinSetupScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  @override
  State<DokanPinSetupScreen> createState() => _DokanPinSetupScreenState();
}

class _DokanPinSetupScreenState extends State<DokanPinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _continue() {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (!_isFourDigitCode(pin)) {
      _showWarning(context, 'PIN 4 digit হতে হবে।');
      return;
    }
    if (confirmPin != pin) {
      _showWarning(context, 'PIN মিলছে না।');
      return;
    }
    widget.onContinue?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _FlowScreen(
      onBack: widget.onBack,
      accent: const Color(0xFF00694C),
      background: const Color(0xFFF8FCFA),
      title: 'PIN Setup',
      subtitle: 'প্রথমবার লগইনের পর ৪ ডিজিটের PIN সেট করুন।',
      icon: Icons.password_rounded,
      primaryLabel: 'PIN সেট করুন',
      onPrimary: _continue,
      children: [
        _FlowInputField(
          label: 'নতুন PIN',
          hintText: '0000',
          icon: Icons.pin_rounded,
          controller: _pinController,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
        ),
        const SizedBox(height: 16),
        _FlowInputField(
          label: 'PIN পুনরায় লিখুন',
          hintText: 'আবার লিখুন',
          icon: Icons.verified_user_outlined,
          obscureText: false,
          controller: _confirmPinController,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
        ),
      ],
    );
  }
}
