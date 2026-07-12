part of '../business_screens.dart';

Future<bool> verifySupplierDueOtp({
  required BuildContext context,
  required WidgetRef ref,
  required _SupplierSummary supplier,
  required int paymentAmount,
  required int dueAmount,
  required String paymentMethodLabel,
  required List<String> notes,
}) async {
  return true;
}

class DokanSupplierDueOtpVerificationScreen extends ConsumerStatefulWidget {
  const DokanSupplierDueOtpVerificationScreen({
    super.key,
    required this.phone,
    required this.supplierName,
    required this.dueAmount,
    required this.paymentAmount,
    required this.paymentMethod,
    required this.notes,
  });

  final String phone;
  final String supplierName;
  final int dueAmount;
  final int paymentAmount;
  final String paymentMethod;
  final List<String> notes;

  @override
  ConsumerState<DokanSupplierDueOtpVerificationScreen> createState() =>
      _DokanSupplierDueOtpVerificationScreenState();
}

class _DokanSupplierDueOtpVerificationScreenState
    extends ConsumerState<DokanSupplierDueOtpVerificationScreen> {
  bool _sending = false;
  bool _verifying = false;
  bool _supplierConfirmed = false;
  String? _errorMessage;
  int _countdown = 600;
  Timer? _timer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _sendOtp();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted || _supplierConfirmed || _verifying) return;
      try {
        final client = ref.read(apiClientProvider);
        final response = await client.post(
          '/app/api/suppliers/verify-due-otp',
          body: {
            'phone': widget.phone,
          },
        );
        if (response.data['verified'] == true) {
          _pollTimer?.cancel();
          setState(() {
            _supplierConfirmed = true;
            _errorMessage = null;
          });
        }
      } catch (_) {
        // Keep polling quietly while the supplier confirms externally.
      }
    });
  }

  void _startTimer() {
    _countdown = 600;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '$minutes মিনিট $remainingSeconds সেকেন্ড';
    }
    return '$remainingSeconds সেকেন্ড';
  }

  Future<void> _sendOtp() async {
    setState(() {
      _sending = true;
      _errorMessage = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(
        '/app/api/suppliers/send-due-otp',
        body: {
          'phone': widget.phone,
          'supplierName': widget.supplierName,
          'dueAmount': widget.dueAmount,
          'paymentAmount': widget.paymentAmount,
          'paymentMethod': widget.paymentMethod,
          'notes': widget.notes,
        },
      );
      final data = response.data;
      final whatsappUrl = data['whatsappUrl']?.toString().trim() ?? '';

      var launchErrorMessage = '';
      if (whatsappUrl.isNotEmpty) {
        final uri = Uri.tryParse(whatsappUrl);
        if (uri == null) {
          launchErrorMessage = 'WhatsApp লিংক তৈরি করা যায়নি।';
        } else {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            launchErrorMessage =
                'নিশ্চিতকরণ লিংক তৈরি হয়েছে, কিন্তু WhatsApp খোলা যায়নি।';
          }
        }
      }

      setState(() {
        _startTimer();
        _errorMessage = launchErrorMessage.isEmpty ? null : launchErrorMessage;
      });
    } on NetworkException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'সার্ভার সংযোগে ত্রুটি ঘটেছে।';
      });
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_supplierConfirmed) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _verifying = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(
        '/app/api/suppliers/verify-due-otp',
        body: {
          'phone': widget.phone,
        },
      );

      if (response.data['verified'] == true) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = response.data['message']?.toString() ??
              'সরবরাহকারী এখনও পেমেন্ট নিশ্চিত করেননি।';
        });
      }
    } on NetworkException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'লেনদেন নিশ্চিতকরণ পরীক্ষা করতে ব্যর্থ হয়েছে।';
      });
    } finally {
      setState(() {
        _verifying = false;
      });
    }
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5F6A66),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF163732),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text(
          'সরবরাহকারী পেমেন্ট যাচাইকরণ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'নিরাপত্তা যাচাইকরণ বিবরণ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5F6A66),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _detailRow('সরবরাহকারীর নাম:', widget.supplierName),
                    const Divider(height: 20, thickness: 0.5),
                    _detailRow('মোবাইল নম্বর:', widget.phone),
                    const Divider(height: 20, thickness: 0.5),
                    _detailRow(
                      'পরিশোধের পরিমাণ:',
                      '${widget.paymentAmount} টাকা',
                      valueColor: const Color(0xFFB3261E),
                    ),
                    const Divider(height: 20, thickness: 0.5),
                    _detailRow('বর্তমান বকেয়া:', '${widget.dueAmount} টাকা'),
                    const Divider(height: 20, thickness: 0.5),
                    _detailRow('পেমেন্ট পদ্ধতি:', widget.paymentMethod),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'পেমেন্ট নোট',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5F6A66),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (widget.notes.isEmpty)
                      const Text(
                        'অতিরিক্ত নোট নেই',
                        style: TextStyle(
                          color: Color(0xFF163732),
                          fontSize: 14,
                        ),
                      )
                    else
                      ...widget.notes.map(
                        (note) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                    color: Color(0xFF0C8C67),
                                    fontWeight: FontWeight.w800,
                                  )),
                              Expanded(
                                child: Text(
                                  note,
                                  style: const TextStyle(
                                    color: Color(0xFF163732),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3C5BF)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFB3261E),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD9E5E1)),
                ),
                child: Column(
                  children: [
                    Text(
                      _supplierConfirmed
                          ? 'সরবরাহকারী পেমেন্ট নিশ্চিত করেছেন'
                          : 'WhatsApp থেকে সরবরাহকারী নিশ্চিত না করা পর্যন্ত অপেক্ষা করুন',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _supplierConfirmed
                            ? const Color(0xFF0C8C67)
                            : const Color(0xFF163732),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _countdown > 0
                          ? 'লিংক কার্যকর থাকবে ${_formatCountdown(_countdown)}'
                          : 'যাচাইকরণ লিংকের সময় শেষ হয়েছে',
                      style: const TextStyle(
                        color: Color(0xFF5F6A66),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _sending || _verifying ? null : _sendOtp,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0C8C67),
                        side: const BorderSide(color: Color(0xFFB6DFD1)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'আবার পাঠান',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _verifying ? null : _verifyOtp,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0C8C67),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _verifying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'যাচাই করুন',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DokanSupplierPaymentScreen extends ConsumerStatefulWidget {
  const DokanSupplierPaymentScreen({super.key, required this.supplierKey});

  final String supplierKey;

  @override
  ConsumerState<DokanSupplierPaymentScreen> createState() =>
      _DokanSupplierPaymentScreenState();
}

class _DokanSupplierPaymentScreenState
    extends ConsumerState<DokanSupplierPaymentScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _bkashPhoneController = TextEditingController();
  final TextEditingController _bkashTransactionController =
      TextEditingController();
  final TextEditingController _bkashAmountController = TextEditingController();
  final TextEditingController _nagadPhoneController = TextEditingController();
  final TextEditingController _nagadTransactionController =
      TextEditingController();
  final TextEditingController _nagadAmountController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardPinController = TextEditingController();
  final TextEditingController _cardAmountController = TextEditingController();
  final TextEditingController _cashAmountController = TextEditingController();
  DokanPosPaymentMethod _selectedMethod = DokanPosPaymentMethod.cash;
  bool _isSubmitting = false;
  String? _bkashPhoneError;
  String? _bkashTransactionError;
  String? _bkashAmountError;
  String? _nagadPhoneError;
  String? _nagadTransactionError;
  String? _nagadAmountError;
  String? _cardNumberError;
  String? _bankNameError;
  String? _cardExpiryError;
  String? _cardPinError;
  String? _cardAmountError;
  String? _cashAmountError;

  @override
  void dispose() {
    _scrollController.dispose();
    _bkashPhoneController.dispose();
    _bkashTransactionController.dispose();
    _bkashAmountController.dispose();
    _nagadPhoneController.dispose();
    _nagadTransactionController.dispose();
    _nagadAmountController.dispose();
    _cardNumberController.dispose();
    _bankNameController.dispose();
    _cardExpiryController.dispose();
    _cardPinController.dispose();
    _cardAmountController.dispose();
    _cashAmountController.dispose();
    super.dispose();
  }

  bool _isValidMobile(String value) =>
      RegExp(r'^01[0-9]{9}$').hasMatch(value.trim());

  bool _isValidAlphanumeric(String value) =>
      RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim());

  bool _isValidCardNumber(String value) =>
      RegExp(r'^[0-9]{16}$').hasMatch(value.trim());

  bool _isValidExpiry(String value) =>
      RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(value.trim());

  bool _isValidPin(String value) =>
      RegExp(r'^[0-9]{4}([0-9]{2})?$').hasMatch(value.trim());

  int? _parseAmount(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }
    return int.tryParse(text);
  }

  void _validateActiveMethod(int dueAmount) {
    setState(() {
      _bkashPhoneError = null;
      _bkashTransactionError = null;
      _bkashAmountError = null;
      _nagadPhoneError = null;
      _nagadTransactionError = null;
      _nagadAmountError = null;
      _cardNumberError = null;
      _bankNameError = null;
      _cardExpiryError = null;
      _cardPinError = null;
      _cardAmountError = null;
      _cashAmountError = null;

      switch (_selectedMethod) {
        case DokanPosPaymentMethod.bkash:
          final phone = _bkashPhoneController.text.trim();
          final transaction = _bkashTransactionController.text.trim();
          final amount = _parseAmount(_bkashAmountController.text);
          _bkashPhoneError = phone.isEmpty || !_isValidMobile(phone)
              ? 'সঠিক bKash নম্বর দিন'
              : null;
          _bkashTransactionError =
              transaction.isEmpty || !_isValidAlphanumeric(transaction)
                  ? 'Transaction ID দিন'
                  : null;
          if (amount == null || amount <= 0) {
            _bkashAmountError = 'টাকা লিখুন';
          } else if (amount > dueAmount) {
            _bkashAmountError = 'বকেয়ার বেশি টাকা দেওয়া যাবে না';
          }
          break;
        case DokanPosPaymentMethod.nagad:
          final phone = _nagadPhoneController.text.trim();
          final transaction = _nagadTransactionController.text.trim();
          final amount = _parseAmount(_nagadAmountController.text);
          _nagadPhoneError = phone.isEmpty || !_isValidMobile(phone)
              ? 'সঠিক Nagad নম্বর দিন'
              : null;
          _nagadTransactionError =
              transaction.isEmpty || !_isValidAlphanumeric(transaction)
                  ? 'Transaction ID দিন'
                  : null;
          if (amount == null || amount <= 0) {
            _nagadAmountError = 'টাকা লিখুন';
          } else if (amount > dueAmount) {
            _nagadAmountError = 'বকেয়ার বেশি টাকা দেওয়া যাবে না';
          }
          break;
        case DokanPosPaymentMethod.card:
          final cardNumber = _cardNumberController.text.trim();
          final bankName = _bankNameController.text.trim();
          final expiry = _cardExpiryController.text.trim();
          final pin = _cardPinController.text.trim();
          final amount = _parseAmount(_cardAmountController.text);
          _cardNumberError =
              _isValidCardNumber(cardNumber) ? null : 'সঠিক কার্ড নম্বর দিন';
          _bankNameError = bankName.isEmpty ? 'ব্যাংকের নাম দিন' : null;
          _cardExpiryError =
              _isValidExpiry(expiry) ? null : 'সঠিক মেয়াদ শেষের তারিখ দিন';
          _cardPinError = _isValidPin(pin) ? null : 'সঠিক PIN দিন';
          if (amount == null || amount <= 0) {
            _cardAmountError = 'টাকা লিখুন';
          } else if (amount > dueAmount) {
            _cardAmountError = 'বকেয়ার বেশি টাকা দেওয়া যাবে না';
          }
          break;
        case DokanPosPaymentMethod.cash:
          final amount = _parseAmount(_cashAmountController.text);
          if (amount == null) {
            _cashAmountError = 'টাকা লিখুন';
          } else if (amount <= 0) {
            _cashAmountError = 'সঠিক টাকা লিখুন';
          } else if (amount > dueAmount) {
            _cashAmountError = 'বকেয়ার বেশি টাকা দেওয়া যাবে না';
          }
          break;
        case DokanPosPaymentMethod.rocket:
        case DokanPosPaymentMethod.bank:
        case DokanPosPaymentMethod.due:
          _cashAmountError = 'এই পেমেন্ট পদ্ধতি এখন সমর্থিত নয়';
          break;
      }
    });
  }

  void _populateAmountForSelectedMethod(String value) {
    switch (_selectedMethod) {
      case DokanPosPaymentMethod.bkash:
        _bkashAmountController.text = value;
        break;
      case DokanPosPaymentMethod.nagad:
        _nagadAmountController.text = value;
        break;
      case DokanPosPaymentMethod.card:
        _cardAmountController.text = value;
        break;
      case DokanPosPaymentMethod.cash:
        _cashAmountController.text = value;
        break;
      case DokanPosPaymentMethod.rocket:
      case DokanPosPaymentMethod.bank:
      case DokanPosPaymentMethod.due:
        break;
    }
  }

  int _currentAmount() {
    switch (_selectedMethod) {
      case DokanPosPaymentMethod.bkash:
        return int.tryParse(_bkashAmountController.text.trim()) ?? 0;
      case DokanPosPaymentMethod.nagad:
        return int.tryParse(_nagadAmountController.text.trim()) ?? 0;
      case DokanPosPaymentMethod.card:
        return int.tryParse(_cardAmountController.text.trim()) ?? 0;
      case DokanPosPaymentMethod.cash:
        return int.tryParse(_cashAmountController.text.trim()) ?? 0;
      case DokanPosPaymentMethod.rocket:
      case DokanPosPaymentMethod.bank:
      case DokanPosPaymentMethod.due:
        return 0;
    }
  }

  String _transactionNote() {
    switch (_selectedMethod) {
      case DokanPosPaymentMethod.bkash:
        return 'bKash ${_bkashPhoneController.text.trim()} | TXN ${_bkashTransactionController.text.trim()}';
      case DokanPosPaymentMethod.nagad:
        return 'Nagad ${_nagadPhoneController.text.trim()} | TXN ${_nagadTransactionController.text.trim()}';
      case DokanPosPaymentMethod.card:
        return 'Card ${_cardNumberController.text.trim()} | ${_bankNameController.text.trim()} | ${_cardExpiryController.text.trim()}';
      case DokanPosPaymentMethod.cash:
        return 'Cash payment';
      case DokanPosPaymentMethod.rocket:
      case DokanPosPaymentMethod.bank:
      case DokanPosPaymentMethod.due:
        return _paymentMethodLabel(_selectedMethod);
    }
  }

  bool _canSubmitForMethod(int dueAmount) {
    final amount = _currentAmount();
    switch (_selectedMethod) {
      case DokanPosPaymentMethod.bkash:
        return _bkashPhoneError == null &&
            _bkashTransactionError == null &&
            _bkashAmountError == null &&
            amount > 0 &&
            amount <= dueAmount;
      case DokanPosPaymentMethod.nagad:
        return _nagadPhoneError == null &&
            _nagadTransactionError == null &&
            _nagadAmountError == null &&
            amount > 0 &&
            amount <= dueAmount;
      case DokanPosPaymentMethod.card:
        return _cardNumberError == null &&
            _bankNameError == null &&
            _cardExpiryError == null &&
            _cardPinError == null &&
            _cardAmountError == null &&
            amount > 0 &&
            amount <= dueAmount;
      case DokanPosPaymentMethod.cash:
        return _cashAmountError == null && amount > 0 && amount <= dueAmount;
      case DokanPosPaymentMethod.rocket:
      case DokanPosPaymentMethod.bank:
      case DokanPosPaymentMethod.due:
        return false;
    }
  }

  Future<void> _showConfirmDialog(_SupplierSummary supplier) async {
    final amount = _currentAmount();
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('আপনি কি নিশ্চিত?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('সরবরাহকারী: ${supplier.name}'),
                  const SizedBox(height: 6),
                  Text(
                      'পেমেন্ট পদ্ধতি: ${_paymentMethodLabel(_selectedMethod)}'),
                  const SizedBox(height: 6),
                  Text('টাকা: ${_formatCurrency(amount)}'),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('বাতিল'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0C8C67),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('নিশ্চিত করুন'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    final notes = <String>[
      'পেমেন্ট পদ্ধতি: ${_paymentMethodLabel(_selectedMethod)}',
      'টাকা: ${_formatCurrency(amount)}',
      if (_transactionNote().trim().isNotEmpty) _transactionNote().trim(),
    ];

    final verified = await verifySupplierDueOtp(
      context: context,
      ref: ref,
      supplier: supplier,
      paymentAmount: amount,
      dueAmount: supplier.totalDue,
      paymentMethodLabel: _paymentMethodLabel(_selectedMethod),
      notes: notes,
    );

    if (!verified) {
      return;
    }

    SupplierPaymentDetails? paymentDetails;
    if (_selectedMethod == DokanPosPaymentMethod.bkash) {
      paymentDetails = SupplierPaymentDetails(
        senderNumber: _bkashPhoneController.text.trim(),
        transactionId: _bkashTransactionController.text.trim(),
      );
    } else if (_selectedMethod == DokanPosPaymentMethod.nagad) {
      paymentDetails = SupplierPaymentDetails(
        senderNumber: _nagadPhoneController.text.trim(),
        transactionId: _nagadTransactionController.text.trim(),
      );
    } else if (_selectedMethod == DokanPosPaymentMethod.card) {
      final cardNumber = _cardNumberController.text.trim();
      paymentDetails = SupplierPaymentDetails(
        cardLast4: cardNumber.substring(cardNumber.length - 4),
        bankName: _bankNameController.text.trim(),
      );
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(dokanPosProvider.notifier).addSupplierPayment(
            supplierKey: supplier.key,
            supplierName: supplier.name,
            amount: amount,
            paymentMethod: _selectedMethod,
            note: _transactionNote(),
            paymentDetails: paymentDetails,
          );
    } on NetworkException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
      return;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('পেমেন্ট সম্পন্ন করা যায়নি।')),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) {
      return;
    }

    final remaining =
        supplier.totalDue - amount < 0 ? 0 : supplier.totalDue - amount;
    final phone = supplier.phone.trim();
    if (phone.isNotEmpty) {
      var cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      if (!cleanPhone.startsWith('88') && cleanPhone.length == 11) {
        cleanPhone = '88$cleanPhone';
      }
      final message = 'প্রিয় ${supplier.name},\n'
          'Dokan ERP-তে আপনার বকেয়া পাওনা থেকে ৳$amount সফলভাবে পরিশোধ করা হয়েছে।\n'
          'আপনার বর্তমান পাওনা পরিমাণ: ৳$remaining।\n'
          'ধন্যবাদ!';
      final text = Uri.encodeComponent(message);
      final urlString =
          'https://api.whatsapp.com/send?phone=$cleanPhone&text=$text';
      final uri = Uri.tryParse(urlString);
      if (uri != null) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          // Ignored
        }
      }
    }

    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('পেমেন্ট সফলভাবে সম্পন্ন হয়েছে')),
    );
  }

  Widget _buildPaymentField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter> inputFormatters = const <TextInputFormatter>[],
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(color: Color(0xFF111111)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: const Color(0xFFF8FAF9),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0C8C67), width: 1.4),
        ),
      ),
    );
  }

  Widget _buildSelectedMethodForm(int dueAmount) {
    switch (_selectedMethod) {
      case DokanPosPaymentMethod.bkash:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('bKash payment flow',
                style: TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _bkashPhoneController,
              label: 'bKash Account Number *',
              hint: '01XXXXXXXXX',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11)
              ],
              errorText: _bkashPhoneError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _bkashTransactionController,
              label: 'Transaction ID *',
              hint: 'Alphanumeric',
              errorText: _bkashTransactionError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _bkashAmountController,
              label: 'Amount *',
              hint: '০১XXXXXXXXX',
              keyboardType: TextInputType.number,
              inputFormatters: NumericInputFormatters.wholeNumber,
              errorText: _bkashAmountError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
          ],
        );
      case DokanPosPaymentMethod.nagad:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nagad payment flow',
                style: TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _nagadPhoneController,
              label: 'Nagad Account Number *',
              hint: '01XXXXXXXXX',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11)
              ],
              errorText: _nagadPhoneError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _nagadTransactionController,
              label: 'Transaction ID *',
              hint: 'Alphanumeric',
              errorText: _nagadTransactionError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _nagadAmountController,
              label: 'Amount *',
              hint: 'Transaction ID',
              keyboardType: TextInputType.number,
              inputFormatters: NumericInputFormatters.wholeNumber,
              errorText: _nagadAmountError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
          ],
        );
      case DokanPosPaymentMethod.card:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Card payment flow',
                style: TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _cardNumberController,
              label: 'Card Number *',
              hint: '16 digit number',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16)
              ],
              errorText: _cardNumberError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _bankNameController.text.trim().isEmpty
                  ? null
                  : _bankNameController.text.trim(),
              decoration: InputDecoration(
                labelText: 'Bank Name *',
                hintText: '১৬ সংখ্যার কার্ড নম্বর',
                errorText: _bankNameError,
                filled: true,
                fillColor: const Color(0xFFF8FAF9),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFD9E5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: Color(0xFF0C8C67), width: 1.4),
                ),
              ),
              dropdownColor: Colors.white,
              items: const <String>[
                'DBBL',
                'BRAC Bank',
                'City Bank',
                'IFIC Bank'
              ]
                  .map((bank) => DropdownMenuItem<String>(
                      value: bank,
                      child: Text(bank,
                          style: TextStyle(color: Color(0xFF111111)))))
                  .toList(growable: false),
              onChanged: (value) {
                setState(() => _bankNameController.text = value ?? '');
                _validateActiveMethod(dueAmount);
              },
            ),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _cardExpiryController,
              label: 'Expiry Date *',
              hint: 'MM/YY',
              errorText: _cardExpiryError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _cardPinController,
              label: 'PIN *',
              hint: '4 or 6 digit PIN',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6)
              ],
              obscureText: true,
              errorText: _cardPinError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _cardAmountController,
              label: 'Amount *',
              hint: 'ব্যাংকের নাম',
              keyboardType: TextInputType.number,
              inputFormatters: NumericInputFormatters.wholeNumber,
              errorText: _cardAmountError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
          ],
        );
      case DokanPosPaymentMethod.cash:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cash payment flow',
                style: TextStyle(
                    color: Color(0xFF163732),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _buildPaymentField(
              controller: _cashAmountController,
              label: 'Amount *',
              hint: 'MM/YY',
              keyboardType: TextInputType.number,
              inputFormatters: NumericInputFormatters.wholeNumber,
              errorText: _cashAmountError,
              onChanged: (_) => _validateActiveMethod(dueAmount),
            ),
          ],
        );
      case DokanPosPaymentMethod.rocket:
      case DokanPosPaymentMethod.bank:
      case DokanPosPaymentMethod.due:
        return const _SupplierSectionEmptyState(
            label: 'এই পেমেন্ট পদ্ধতি এখন সমর্থিত নয়');
    }
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
    final dueAmount = selectedSupplier.totalDue;
    final canSubmit = !_isSubmitting && _canSubmitForMethod(dueAmount);

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
                    'সরবরাহকারী পেমেন্ট',
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
                  const Text(
                    'সরবরাহকারীর বিবরণ',
                    style: TextStyle(
                      color: Color(0xFF163732),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(label: 'নাম', value: selectedSupplier.name),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'বকেয়া',
                    value: _formatCurrency(dueAmount),
                    valueColor: const Color(0xFFB3261E),
                  ),
                ],
              ),
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
                  const Text(
                    'পেমেন্ট তথ্য',
                    style: TextStyle(
                      color: Color(0xFF163732),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSelectedMethodForm(dueAmount),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _actionChip(
                        label: 'Full due',
                        onTap: () {
                          _populateAmountForSelectedMethod(
                              dueAmount.toString());
                          _validateActiveMethod(dueAmount);
                        },
                      ),
                      _actionChip(
                        label: 'Half due',
                        onTap: () {
                          final half = dueAmount ~/ 2;
                          _populateAmountForSelectedMethod(
                              (half <= 0 ? dueAmount : half).toString());
                          _validateActiveMethod(dueAmount);
                        },
                      ),
                      _actionChip(
                        label: 'Custom',
                        onTap: () {
                          _populateAmountForSelectedMethod('');
                          _validateActiveMethod(dueAmount);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'পেমেন্ট পদ্ধতি',
              style: TextStyle(
                color: Color(0xFF163732),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ..._allowedSupplierPaymentMethods.map(
              (method) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SupplierPaymentMethodCard(
                  method: method,
                  selected: _selectedMethod == method,
                  onTap: () {
                    setState(() => _selectedMethod = method);
                    _validateActiveMethod(dueAmount);
                  },
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: canSubmit
                    ? () async {
                        if (!_canSubmitForMethod(dueAmount)) {
                          _validateActiveMethod(dueAmount);
                          return;
                        }
                        await _showConfirmDialog(selectedSupplier);
                      }
                    : null,
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
                    : const Text('পেমেন্ট নিশ্চিত করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
