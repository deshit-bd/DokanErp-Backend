part of '../settings_screens.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF16302E),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PlanDetailsChip extends StatelessWidget {
  const _PlanDetailsChip({
    required this.label,
    required this.value,
    required this.dark,
  });

  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(dark ? 0.16 : 1),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withOpacity(dark ? 0.16 : 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: dark
                    ? Colors.white.withOpacity(0.84)
                    : const Color(0xFF6F8280),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: dark ? Colors.white : const Color(0xFF16302E),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanSummaryRow extends StatelessWidget {
  const _PlanSummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6F8280),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF16302E),
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubscriptionCheckoutScreen extends ConsumerStatefulWidget {
  const _SubscriptionCheckoutScreen({required this.plan});

  final _SubscriptionPlanData plan;

  @override
  ConsumerState<_SubscriptionCheckoutScreen> createState() =>
      _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState
    extends ConsumerState<_SubscriptionCheckoutScreen> {
  final TextEditingController _bkashNumberController = TextEditingController();
  final TextEditingController _bkashTransactionController =
      TextEditingController();
  final TextEditingController _nagadNumberController = TextEditingController();
  final TextEditingController _nagadTransactionController =
      TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();

  String _method = 'বিকাশ';
  bool _confirmed = false;
  bool _processing = false;

  String? _bkashNumberError;
  String? _bkashTransactionError;
  String? _nagadNumberError;
  String? _nagadTransactionError;
  String? _cardHolderError;
  String? _cardNumberError;
  String? _cardExpiryError;
  String? _cardCvvError;
  String? _confirmationError;

  @override
  void dispose() {
    _bkashNumberController.dispose();
    _bkashTransactionController.dispose();
    _nagadNumberController.dispose();
    _nagadTransactionController.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(subscriptionInfoProvider).valueOrNull;
    final amountToPay = (info?.amountDue ?? 0) > 0
        ? info!.amountDue
        : ((info?.billableAccounts ?? 1) * (info?.ratePerAccount ?? 10.0));
    final amountText = '৳${trNum(amountToPay.toInt())}';
    final nextBillText = info != null
        ? '৳${trNum(info.ratePerAccount.toInt())} / ইউজার / দিন'
        : '৳১০ / ইউজার / দিন';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed:
                _processing ? null : () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF4F7FB),
              foregroundColor: const Color(0xFF16302E),
            ),
          ),
        ),
        leadingWidth: 72,
        title: const Text(
          'চেকআউট',
          style: TextStyle(
            color: Color(0xFF16302E),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth > 760 ? 760.0 : constraints.maxWidth;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                  16, 8, 16, 24 + MediaQuery.viewInsetsOf(context).bottom),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 30),
                        duration: const Duration(milliseconds: 500),
                        slideOffset: const Offset(0, 15),
                        child: _CheckoutSectionCard(
                          title: 'নির্বাচিত প্ল্যান',
                          child: _CheckoutPlanCard(plan: widget.plan),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 70),
                        duration: const Duration(milliseconds: 500),
                        slideOffset: const Offset(0, 15),
                        child: _CheckoutSectionCard(
                          title: 'মূল্য সারাংশ',
                          child: Column(
                            children: [
                              _PlanSummaryRow(
                                  label: 'প্ল্যান', value: widget.plan.name),
                              const SizedBox(height: 10),
                              _PlanSummaryRow(label: 'মূল্য', value: amountText),
                              const SizedBox(height: 10),
                              _PlanSummaryRow(
                                label: 'পরবর্তী বিল',
                                value: nextBillText,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 110),
                        duration: const Duration(milliseconds: 500),
                        slideOffset: const Offset(0, 15),
                        child: _CheckoutSectionCard(
                          title: 'পেমেন্ট পদ্ধতি',
                          child: Column(
                            children: [
                              _PaymentMethodChoice(
                                label: 'বিকাশ',
                                selected: _method == 'বিকাশ',
                                icon: Icons.phone_android_rounded,
                                onTap: () => setState(() => _method = 'বিকাশ'),
                              ),
                              const SizedBox(height: 10),
                              _PaymentMethodChoice(
                                label: 'নগদ',
                                selected: _method == 'নগদ',
                                icon: Icons.account_balance_wallet_rounded,
                                onTap: () => setState(() => _method = 'নগদ'),
                              ),
                              const SizedBox(height: 10),
                              _PaymentMethodChoice(
                                label: 'ডেবিট / ক্রেডিট কার্ড',
                                selected: _method == 'ডেবিট / ক্রেডিট কার্ড',
                                icon: Icons.credit_card_rounded,
                                onTap: () => setState(
                                    () => _method = 'ডেবিট / ক্রেডিট কার্ড'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_method == 'বিকাশ') ...[
                        DokanFadeSlideIn(
                          key: const ValueKey('bkash_inputs'),
                          delay: const Duration(milliseconds: 30),
                          duration: const Duration(milliseconds: 400),
                          slideOffset: const Offset(0, 10),
                          child: _CheckoutSectionCard(
                            title: 'বিকাশ তথ্য',
                            child: Column(
                              children: [
                                _CheckoutField(
                                  label: 'বিকাশ নম্বর *',
                                  controller: _bkashNumberController,
                                  keyboardType: TextInputType.phone,
                                  errorText: _bkashNumberError,
                                  hintText: '01XXXXXXXXX',
                                  onChanged: (_) =>
                                      _clearError(() => _bkashNumberError = null),
                                ),
                                const SizedBox(height: 12),
                                _CheckoutField(
                                  label: 'ট্রানজেকশন আইডি *',
                                  controller: _bkashTransactionController,
                                  errorText: _bkashTransactionError,
                                  hintText: 'ট্রানজেকশন আইডি দিন',
                                  onChanged: (_) => _clearError(
                                      () => _bkashTransactionError = null),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (_method == 'নগদ') ...[
                        DokanFadeSlideIn(
                          key: const ValueKey('nagad_inputs'),
                          delay: const Duration(milliseconds: 30),
                          duration: const Duration(milliseconds: 400),
                          slideOffset: const Offset(0, 10),
                          child: _CheckoutSectionCard(
                            title: 'নগদ তথ্য',
                            child: Column(
                              children: [
                                _CheckoutField(
                                  label: 'নগদ নম্বর *',
                                  controller: _nagadNumberController,
                                  keyboardType: TextInputType.phone,
                                  errorText: _nagadNumberError,
                                  hintText: '01XXXXXXXXX',
                                  onChanged: (_) =>
                                      _clearError(() => _nagadNumberError = null),
                                ),
                                const SizedBox(height: 12),
                                _CheckoutField(
                                  label: 'ট্রানজেকশন আইডি *',
                                  controller: _nagadTransactionController,
                                  errorText: _nagadTransactionError,
                                  hintText: 'ট্রানজেকশন আইডি দিন',
                                  onChanged: (_) => _clearError(
                                      () => _nagadTransactionError = null),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (_method == 'ডেবিট / ক্রেডিট কার্ড') ...[
                        DokanFadeSlideIn(
                          key: const ValueKey('card_inputs'),
                          delay: const Duration(milliseconds: 30),
                          duration: const Duration(milliseconds: 400),
                          slideOffset: const Offset(0, 10),
                          child: _CheckoutSectionCard(
                            title: 'কার্ড তথ্য',
                            child: Column(
                              children: [
                                _CheckoutField(
                                  label: 'কার্ডধারীর নাম *',
                                  controller: _cardHolderController,
                                  errorText: _cardHolderError,
                                  hintText: 'নাম লিখুন',
                                  onChanged: (_) =>
                                      _clearError(() => _cardHolderError = null),
                                ),
                                const SizedBox(height: 12),
                                _CheckoutField(
                                  label: 'কার্ড নম্বর *',
                                  controller: _cardNumberController,
                                  keyboardType: TextInputType.number,
                                  errorText: _cardNumberError,
                                  hintText: '১৬ ডিজিট কার্ড নম্বর',
                                  onChanged: (_) =>
                                      _clearError(() => _cardNumberError = null),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _CheckoutField(
                                        label: 'মেয়াদ শেষের তারিখ *',
                                        controller: _cardExpiryController,
                                        errorText: _cardExpiryError,
                                        hintText: 'MM/YY',
                                        onChanged: (_) => _clearError(
                                            () => _cardExpiryError = null),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _CheckoutField(
                                        label: 'CVV *',
                                        controller: _cardCvvController,
                                        keyboardType: TextInputType.number,
                                        obscureText: true,
                                        errorText: _cardCvvError,
                                        hintText: '৩ বা ৪ সংখ্যা',
                                        onChanged: (_) => _clearError(
                                            () => _cardCvvError = null),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 150),
                        duration: const Duration(milliseconds: 500),
                        slideOffset: const Offset(0, 15),
                        child: _CheckoutSectionCard(
                          title: 'নিশ্চিতকরণ',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PlanSummaryRow(
                                  label: 'প্ল্যান', value: widget.plan.name),
                              const SizedBox(height: 10),
                              _PlanSummaryRow(
                                  label: 'মূল্য', value: widget.plan.price),
                              const SizedBox(height: 10),
                              _PlanSummaryRow(
                                  label: 'পেমেন্ট পদ্ধতি', value: _method),
                              if (_confirmationError != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _confirmationError!,
                                  style: const TextStyle(
                                    color: Color(0xFFE15241),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: _processing
                                    ? null
                                    : () => setState(() {
                                          _confirmed = !_confirmed;
                                          _confirmationError = null;
                                        }),
                                borderRadius: BorderRadius.circular(12),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _confirmed,
                                      onChanged: _processing
                                          ? null
                                          : (value) => setState(() {
                                                _confirmed = value ?? false;
                                                _confirmationError = null;
                                              }),
                                      activeColor: const Color(0xFF0E8F5F),
                                    ),
                                    const Expanded(
                                      child: Text(
                                        'আমি প্রদত্ত তথ্য সঠিক বলে নিশ্চিত করছি',
                                        style: TextStyle(
                                          color: Color(0xFF16302E),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      DokanFadeSlideIn(
                        delay: const Duration(milliseconds: 190),
                        duration: const Duration(milliseconds: 500),
                        slideOffset: const Offset(0, 15),
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _processing ? null : _submitPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0E8F5F),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFB9C7C5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          child: Text(
                            _processing
                                ? 'পেমেন্ট যাচাই করা হচ্ছে...'
                                : 'পেমেন্ট সম্পন্ন করুন',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _clearError(VoidCallback clearAction) {
    setState(clearAction);
  }

  bool _isBangladeshPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length == 11 && digits.startsWith('01');
  }

  bool _isExpiryValid(String value) {
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    return regex.hasMatch(value.trim());
  }

  bool _isCardValidNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length == 16;
  }

  bool _isCvvValid(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length == 3 || digits.length == 4;
  }

  bool _validateForm() {
    var valid = true;
    setState(() {
      _bkashNumberError = null;
      _bkashTransactionError = null;
      _nagadNumberError = null;
      _nagadTransactionError = null;
      _cardHolderError = null;
      _cardNumberError = null;
      _cardExpiryError = null;
      _cardCvvError = null;
      _confirmationError = null;

      if (!_confirmed) {
        _confirmationError = 'এই ঘরটি পূরণ করা আবশ্যক';
        valid = false;
      }

      if (_method == 'বিকাশ') {
        if (_bkashNumberController.text.trim().isEmpty) {
          _bkashNumberError = 'এই ঘরটি পূরণ করা আবশ্যক';
          valid = false;
        } else if (!_isBangladeshPhone(_bkashNumberController.text)) {
          _bkashNumberError = 'সঠিক মোবাইল নম্বর দিন';
          valid = false;
        }

        if (_bkashTransactionController.text.trim().isEmpty) {
          _bkashTransactionError = 'এই ঘরটি পূরণ করা আবশ্যক';
          valid = false;
        } else if (_bkashTransactionController.text.trim().length < 4) {
          _bkashTransactionError = 'সঠিক ট্রানজেকশন আইডি দিন';
          valid = false;
        }
      } else if (_method == 'নগদ') {
        if (_nagadNumberController.text.trim().isEmpty) {
          _nagadNumberError = 'এই ঘরটি পূরণ করা আবশ্যক';
          valid = false;
        } else if (!_isBangladeshPhone(_nagadNumberController.text)) {
          _nagadNumberError = 'সঠিক মোবাইল নম্বর দিন';
          valid = false;
        }

        if (_nagadTransactionController.text.trim().isEmpty) {
          _nagadTransactionError = 'এই ঘরটি পূরণ করা আবশ্যক';
          valid = false;
        } else if (_nagadTransactionController.text.trim().length < 4) {
          _nagadTransactionError = 'সঠিক ট্রানজেকশন আইডি দিন';
          valid = false;
        }
      } else {
        if (_cardHolderController.text.trim().isEmpty) {
          _cardHolderError = 'এই ঘরটি পূরণ করা আবশ্যক';
          valid = false;
        }
        if (_cardNumberController.text.trim().isEmpty) {
          _cardNumberError = 'এই ঘরটি পূরণ করা আবশ্যক';
          valid = false;
        } else if (!_isCardValidNumber(_cardNumberController.text)) {
          _cardNumberError = 'সঠিক কার্ড নম্বর দিন';
          valid = false;
        }
        if (_cardExpiryController.text.trim().isEmpty) {
          _cardExpiryError = 'এই ঘরটি পূরণ করা আবশ্যক';
          valid = false;
        } else if (!_isExpiryValid(_cardExpiryController.text)) {
          _cardExpiryError = 'সঠিক মেয়াদ শেষের তারিখ দিন';
          valid = false;
        }
        if (_cardCvvController.text.trim().isEmpty) {
          _cardCvvError = 'এই ঘরটি পূরণ করা আবশ্যক';
          valid = false;
        } else if (!_isCvvValid(_cardCvvController.text)) {
          _cardCvvError = 'সঠিক CVV দিন';
          valid = false;
        }
      }
    });
    return valid;
  }

  Future<void> _submitPayment() async {
    if (!_validateForm()) {
      return;
    }

    final info = ref.read(subscriptionInfoProvider).valueOrNull;
    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সাবস্ক্রিপশন তথ্য পাওয়া যায়নি')),
      );
      return;
    }

    final amountToPay = info.amountDue > 0
        ? info.amountDue
        : (info.billableAccounts * info.ratePerAccount);

    if (amountToPay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('পরিশোধ করার মত কোনো বকেয়া নেই।'),
          backgroundColor: Color(0xFFD9822B),
        ),
      );
      return;
    }

    setState(() => _processing = true);

    try {
      final methodKey = () {
        if (_method == 'বিকাশ') return 'bkash';
        if (_method == 'নগদ') return 'nagad';
        return 'card';
      }();

      final trxId = () {
        if (_method == 'বিকাশ') return _bkashTransactionController.text.trim();
        if (_method == 'নগদ') return _nagadTransactionController.text.trim();
        final last4 = _cardNumberController.text.trim().length >= 4
            ? _cardNumberController.text
                .trim()
                .substring(_cardNumberController.text.trim().length - 4)
            : '1234';
        return 'CARD-$last4-${DateTime.now().millisecondsSinceEpoch}';
      }();

      await ref.read(subscriptionRepositoryProvider).paySubscription(
            amount: amountToPay,
            method: methodKey,
            trxId: trxId,
          );

      ref.invalidate(subscriptionInfoProvider);

      if (!mounted) return;

      setState(() => _processing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.plan.name} পেমেন্ট সফল হয়েছে'),
          backgroundColor: const Color(0xFF0E8F5F),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _processing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('পেমেন্ট ব্যর্থ হয়েছে: $error'),
          backgroundColor: const Color(0xFFE15241),
        ),
      );
    }
  }
}
