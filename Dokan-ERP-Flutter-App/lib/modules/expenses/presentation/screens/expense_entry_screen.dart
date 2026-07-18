import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/expenses/presentation/providers/expense_provider.dart';

class DokanExpenseEntryScreen extends ConsumerStatefulWidget {
  const DokanExpenseEntryScreen({
    super.key,
    this.existingExpense,
  });

  final DokanExpenseRecord? existingExpense;

  @override
  ConsumerState<DokanExpenseEntryScreen> createState() =>
      _DokanExpenseEntryScreenState();
}

class _DokanExpenseEntryScreenState
    extends ConsumerState<DokanExpenseEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _receiptController = TextEditingController();

  late String _category;
  late String _paymentMethod;
  late DokanExpenseStatus _status;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  static const List<String> _categories = <String>[
    'পণ্য ক্রয়',
    'বিদ্যুৎ বিল',
    'গ্যাস বিল',
    'ইন্টারনেট বিল',
    'কর্মচারীর বেতন',
    'পরিবহন',
    'ভাড়া',
    'ট্যাক্স',
    'মেরামত',
    'অন্যান্য',
  ];

  static const List<String> _paymentMethods = <String>[
    'নগদ',
    'bKash',
    'Nagad',
    'ব্যাংক',
  ];

  static const List<String> _receiptLabels = <String>[
    'ছবি যোগ করা হয়নি',
    'গ্যালারি থেকে',
    'ক্যামেরা থেকে',
  ];

  @override
  void initState() {
    super.initState();
    final DokanExpenseRecord? expense = widget.existingExpense;
    _titleController.text = expense?.title ?? '';
    if (expense != null) {
      _amountController.text = expense.amount.toStringAsFixed(
        expense.amount.truncateToDouble() == expense.amount ? 0 : 2,
      );
    }
    _noteController.text = expense?.note ?? '';
    _receiptController.text = expense?.receiptLabel.isNotEmpty == true
        ? expense!.receiptLabel
        : 'ছবি যোগ করা হয়নি';
    _category = expense?.category ?? _categories.first;
    _paymentMethod = expense?.paymentMethodLabel ?? _paymentMethods.first;
    _status = expense?.status ?? DokanExpenseStatus.paid;
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _receiptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.existingExpense != null;
    final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F8F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEditMode ? 'খরচ সম্পাদনা করুন' : 'নতুন খরচ যোগ করুন',
          style: const TextStyle(
            color: Color(0xFF163732),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF163732)),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardInset + 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 50),
                  duration: const Duration(milliseconds: 500),
                  slideOffset: const Offset(0, -15),
                  child: const _EntrySectionCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.info_outline, color: Color(0xFF0C8C67)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'এই খরচটি যুক্ত করার সাথে সাথেই রিপোর্ট ও সারসংক্ষেপে দেখাবে এবং locally সংরক্ষিত থাকবে।',
                            style: TextStyle(
                              color: Color(0xFF163732),
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  duration: const Duration(milliseconds: 500),
                  slideOffset: const Offset(0, 20),
                  child: _EntrySectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _LabelText('খরচের শিরোনাম *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          decoration:
                              _fieldDecoration(hintText: 'যেমন: কর্মচারীর বেতন'),
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.w700,
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'খরচের শিরোনাম দিন';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _LabelText('খরচের ধরন *'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: _fieldDecoration(
                              hintText: 'খরচের ধরন নির্বাচন করুন'),
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.w700,
                          ),
                          iconEnabledColor: const Color(0xFF0C8C67),
                          items: _categories
                              .map(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Color(0xFF111111),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => _category = value);
                          },
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'খরচের ধরন নির্বাচন করুন';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _LabelText('পরিমাণ (৳) *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: NumericInputFormatters.decimal,
                          decoration: _fieldDecoration(hintText: 'যেমন: ১৫০০'),
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.w700,
                          ),
                          validator: (String? value) {
                            final double? amount =
                                double.tryParse(value?.trim() ?? '');
                            if (amount == null || amount <= 0) {
                              return 'সঠিক পরিমাণ লিখুন';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _LabelText('তারিখ *'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(16),
                          child: InputDecorator(
                            decoration: _fieldDecoration(),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.date_range_outlined,
                                    color: Color(0xFF0C8C67)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _formatDate(_selectedDate),
                                    style: const TextStyle(
                                      color: Color(0xFF111111),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LabelText('নোট (ঐচ্ছিক)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: _fieldDecoration(
                              hintText: 'খরচের অতিরিক্ত তথ্য লিখুন'),
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LabelText('রসিদের ছবি (ঐচ্ছিক)'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _showReceiptSheet,
                          borderRadius: BorderRadius.circular(16),
                          child: InputDecorator(
                            decoration: _fieldDecoration(),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.photo_outlined,
                                    color: Color(0xFF0C8C67)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _receiptController.text,
                                    style: const TextStyle(
                                      color: Color(0xFF111111),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF6B7280)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  duration: const Duration(milliseconds: 500),
                  slideOffset: const Offset(0, 20),
                  child: _EntrySectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _LabelText('পেমেন্ট মাধ্যম'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          decoration:
                              _fieldDecoration(labelText: 'পেমেন্ট মাধ্যম'),
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.w700,
                          ),
                          iconEnabledColor: const Color(0xFF0C8C67),
                          items: _paymentMethods
                              .map(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Color(0xFF111111),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => _paymentMethod = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        _LabelText('অবস্থা'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<DokanExpenseStatus>(
                          value: _status,
                          decoration: _fieldDecoration(labelText: 'অবস্থা'),
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontWeight: FontWeight.w700,
                          ),
                          iconEnabledColor: const Color(0xFF0C8C67),
                          items: const <DropdownMenuItem<DokanExpenseStatus>>[
                            DropdownMenuItem<DokanExpenseStatus>(
                              value: DokanExpenseStatus.paid,
                              child: Text(
                                'পরিশোধিত',
                                style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DropdownMenuItem<DokanExpenseStatus>(
                              value: DokanExpenseStatus.pending,
                              child: Text(
                                'বাকি',
                                style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (DokanExpenseStatus? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => _status = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                DokanFadeSlideIn(
                  delay: const Duration(milliseconds: 240),
                  duration: const Duration(milliseconds: 500),
                  slideOffset: const Offset(0, 15),
                  child: DokanButton(
                    onPressed: _saving ? null : _saveExpense,
                    text: isEditMode ? 'পরিবর্তন সংরক্ষণ করুন' : 'খরচ সংরক্ষণ করুন',
                    isLoading: _saving,
                    backgroundColor: const Color(0xFF0C8C67),
                    foregroundColor: Colors.white,
                    borderRadius: 16,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hintText, String? labelText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF8B9B99),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: Color(0xFF5D6B69),
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF0C8C67),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFC0D3CF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFC0D3CF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0C8C67), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'তারিখ নির্বাচন করুন',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF0E6D4E),
                ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _showReceiptSheet() async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _receiptLabels
                  .map(
                    (String label) => ListTile(
                      leading: const Icon(Icons.image_outlined,
                          color: Color(0xFF0E6D4E)),
                      title: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(label),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _receiptController.text = selected);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      return;
    }

    final DokanExpenseRecord expense = DokanExpenseRecord(
      id: widget.existingExpense?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _category,
      amount: amount,
      date: _selectedDate,
      note: _noteController.text.trim(),
      receiptLabel: _receiptController.text.trim(),
      paymentMethod: _parsePaymentMethod(_paymentMethod),
      status: _status,
    );

    setState(() => _saving = true);
    try {
      final DokanExpenseController controller =
          ref.read(expenseReportControllerProvider.notifier);
      if (widget.existingExpense == null) {
        await controller.addExpense(expense);
      } else {
        await controller.updateExpense(expense);
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingExpense == null
              ? 'খরচ সফলভাবে সংরক্ষণ করা হয়েছে'
              : 'খরচ সফলভাবে হালনাগাদ করা হয়েছে'),
          backgroundColor: const Color(0xFF0E6D4E),
        ),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('খরচ সংরক্ষণ করা যায়নি'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  DokanExpensePaymentMethod _parsePaymentMethod(String value) {
    switch (value) {
      case 'bKash':
        return DokanExpensePaymentMethod.bkash;
      case 'Nagad':
        return DokanExpensePaymentMethod.nagad;
      case 'ব্যাংক':
        return DokanExpensePaymentMethod.bank;
      case 'নগদ':
      default:
        return DokanExpensePaymentMethod.cash;
    }
  }

  String _formatDate(DateTime date) {
    const List<String> months = <String>[
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
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

class _EntrySectionCard extends StatelessWidget {
  const _EntrySectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E9E4)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LabelText extends StatelessWidget {
  const _LabelText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
