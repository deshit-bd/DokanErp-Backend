part of '../sales_screens.dart';

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE1F0EC) : const Color(0xFFF4F7F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF006B53) : const Color(0xFFD6E4E0),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CartStepperButton extends StatelessWidget {
  const _CartStepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6E4E0)),
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}

class _CartDock extends StatelessWidget {
  const _CartDock({
    required this.count,
    required this.total,
    required this.onTap,
  });

  final int count;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = count == 0;
    return Material(
      color: isEmpty ? const Color(0xFF0C8C67) : const Color(0xFF24333A),
      elevation: 16,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C8C67),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmpty
                          ? tr('কার্ট খালি আছে। পণ্য যোগ করুন।',
                              'Cart is empty. Add products.')
                          : tr('কার্টে ${trNum(count)}টি পণ্য আছে',
                              'Cart has ${trNum(count)} items'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isEmpty ? 14 : 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '৳${trNum(total)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEmpty
                      ? const Color(0xFFFFFFFF).withOpacity(0.14)
                      : const Color(0xFF0C8C67),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  tr('কার্ট দেখুন →', 'View Cart →'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  const _BottomNavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF006B53) : Colors.black87;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRegisterTile extends StatelessWidget {
  const _OrderRegisterTile({
    required this.record,
    required this.accent,
    this.showDueAmount = false,
  });

  final DokanPosOrderRecord record;
  final Color accent;
  final bool showDueAmount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                record.status == DokanPosOrderStatus.paid
                    ? Icons.check
                    : record.status == DokanPosOrderStatus.partiallyPaid
                        ? Icons.timelapse_outlined
                        : Icons.error_outline,
                color: accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.customerName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.customerNumber.isEmpty
                        ? record.summary
                        : '${record.customerNumber}  •  ${dokanPosPaymentMethodLabel(record.paymentMethod)}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _orderStatusLabel(record.status),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '৳${record.totalAmount}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (showDueAmount)
                  Text(
                    'বাকি ৳${record.dueAmount}',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _orderStatusLabel(DokanPosOrderStatus status) {
    switch (status) {
      case DokanPosOrderStatus.paid:
        return 'পরিশোধিত';
      case DokanPosOrderStatus.due:
        return 'বাকি রয়েছে';
      case DokanPosOrderStatus.partiallyPaid:
        return 'আংশিক পরিশোধিত';
      case DokanPosOrderStatus.cancelled:
        return 'বাতিল';
    }
  }
}

Future<int?> _showDueAmountSheet(
  BuildContext context, {
  required String title,
  required String hint,
  required int maxAmount,
  required String confirmLabel,
  String warningText = 'বেশি টাকা দেওয়া যাবে না',
}) async {
  final controller = TextEditingController();
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      String? errorText;
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            expand: false,
            minChildSize: 0.34,
            initialChildSize: 0.58,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const ClampingScrollPhysics(),
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
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: NumericInputFormatters.wholeNumber,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: hint,
                              filled: true,
                              fillColor: const Color(0xFFF7FAF9),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD6E4E0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD6E4E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                    color: Color(0xFF0C8C67), width: 1.4),
                              ),
                            ),
                          ),
                          if (errorText != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3F3),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: const Color(0xFFB3261E)),
                              ),
                              child: Text(
                                errorText!,
                                style: const TextStyle(
                                  color: Color(0xFFB3261E),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(sheetContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black87,
                                    side: const BorderSide(
                                        color: Color(0xFFD6E4E0)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: const Text('বাতিল',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    final amount =
                                        int.tryParse(controller.text.trim()) ??
                                            0;
                                    if (amount <= 0) {
                                      setSheetState(() => errorText =
                                          'পরিমাণ ০ এর বেশি হতে হবে');
                                      return;
                                    }
                                    if (amount > maxAmount) {
                                      setSheetState(
                                          () => errorText = warningText);
                                      return;
                                    }
                                    Navigator.of(sheetContext).pop(amount);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0C8C67),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: Text(confirmLabel,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
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
    },
  );
}

Future<Map<String, String>?> _showNewDueRecordSheet(
    BuildContext context) async {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final amountController = TextEditingController();

  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      String? nameError;
      String? numberError;
      String? amountError;
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            expand: false,
            minChildSize: 0.34,
            initialChildSize: 0.68,
            maxChildSize: 0.96,
            builder: (context, scrollController) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const ClampingScrollPhysics(),
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
                            'নতুন বাকি যোগ করুন',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'নাম',
                              errorText: nameError,
                              filled: true,
                              fillColor: nameError != null
                                  ? const Color(0xFFFFF3F3)
                                  : const Color(0xFFF7FAF9),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: numberController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'নম্বর',
                              errorText: numberError,
                              filled: true,
                              fillColor: numberError != null
                                  ? const Color(0xFFFFF3F3)
                                  : const Color(0xFFF7FAF9),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: NumericInputFormatters.wholeNumber,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'বাকি টাকার পরিমাণ',
                              errorText: amountError,
                              filled: true,
                              fillColor: amountError != null
                                  ? const Color(0xFFFFF3F3)
                                  : const Color(0xFFF7FAF9),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(sheetContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black87,
                                    side: const BorderSide(
                                        color: Color(0xFFD6E4E0)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: const Text('বাতিল',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    final name = nameController.text.trim();
                                    final number = numberController.text.trim();
                                    final amount = int.tryParse(
                                            amountController.text.trim()) ??
                                        0;
                                    final nextNameError = name.isEmpty
                                        ? 'নাম লিখুন'
                                        : RegExp(r'^[0-9]+$').hasMatch(name)
                                            ? 'নামে সংখ্যা ব্যবহার করা যাবে না'
                                            : null;
                                    final nextNumberError =
                                        RegExp(r'^[0-9]{11}$').hasMatch(number)
                                            ? null
                                            : '১১ সংখ্যার সঠিক নম্বর লিখুন';
                                    final nextAmountError = amount > 0
                                        ? null
                                        : 'বাকি টাকার পরিমাণ সঠিক নয়';

                                    if (nextNameError != null ||
                                        nextNumberError != null ||
                                        nextAmountError != null) {
                                      setSheetState(() {
                                        nameError = nextNameError;
                                        numberError = nextNumberError;
                                        amountError = nextAmountError;
                                      });
                                      return;
                                    }

                                    Navigator.of(sheetContext)
                                        .pop(<String, String>{
                                      'name': name,
                                      'number': number,
                                      'amount': amount.toString(),
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0C8C67),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: const Text('সংরক্ষণ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800)),
                                ),
                              ),
                            ],
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
    },
  );
}

String _dueDateLabel(DateTime date) {
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
