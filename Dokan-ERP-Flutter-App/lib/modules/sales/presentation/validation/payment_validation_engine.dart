part of '../providers/cart_provider.dart';

class DokanPaymentValidationResult {
  const DokanPaymentValidationResult({
    required this.fieldErrors,
    required this.dueAmount,
    required this.paidAmount,
    required this.requiresDueConfirmation,
    required this.paymentMethod,
  });

  final Map<String, String> fieldErrors;
  final int dueAmount;
  final int paidAmount;
  final bool requiresDueConfirmation;
  final DokanPosPaymentMethod paymentMethod;

  bool get hasBlockingErrors => fieldErrors.isNotEmpty;
  bool get canSubmit => !hasBlockingErrors;
  bool get isFullyValid => !hasBlockingErrors && !requiresDueConfirmation;

  String? get firstErrorMessage {
    if (fieldErrors.isEmpty) {
      return null;
    }
    return fieldErrors.values.first;
  }
}

class PaymentValidationEngine {
  const PaymentValidationEngine();

  DokanPaymentValidationResult validate(DokanPosState state) {
    final fieldErrors = <String, String>{};
    final total = state.total;

    if (total <= 0) {
      fieldErrors['cart'] = 'কার্টে কোনো পণ্য নেই';
      return DokanPaymentValidationResult(
        fieldErrors: fieldErrors,
        dueAmount: 0,
        paidAmount: 0,
        requiresDueConfirmation: false,
        paymentMethod: state.paymentMethod,
      );
    }

    final customerName = state.customerName.trim();
    final customerNumber = state.customerNumber.trim();
    final paymentMethod = state.paymentMethod;

    bool isPhoneValid(String value) => RegExp(r'^[0-9]{11}$').hasMatch(value);
    bool isLengthInRange(String value, int min, int max) =>
        value.trim().length >= min && value.trim().length <= max;
    bool isExactDigits(String value, int length) =>
        RegExp('^[0-9]{$length}\$').hasMatch(value.trim());

    void requireCustomerIdentity() {
      if (customerName.isEmpty) {
        fieldErrors['customerName'] = 'গ্রাহকের নাম পূরণ করুন';
      }
      if (!isPhoneValid(customerNumber)) {
        fieldErrors['customerNumber'] = 'গ্রাহকের নম্বর সঠিক নয়';
      }
    }

    int dueAmount = 0;
    int paidAmount = total;
    var requiresDueConfirmation = false;

    switch (paymentMethod) {
      case DokanPosPaymentMethod.cash:
        if (state.cashReceived <= 0) {
          fieldErrors['cashReceived'] = 'প্রাপ্ত নগদ দিন';
        } else {
          paidAmount = math.min(state.cashReceived, total);
          dueAmount = math.max(0, total - state.cashReceived);

          final nameLower = customerName.toLowerCase();
          final isWalkIn = nameLower == 'guest customer' ||
              nameLower == 'হাঁটা বিক্রয়' ||
              nameLower == 'অতিথি গ্রাহক' ||
              nameLower.isEmpty ||
              customerNumber.isEmpty;

          if (isWalkIn && dueAmount > 0) {
            fieldErrors['cashReceived'] =
                'হাঁটা গ্রাহকের জন্য সম্পূর্ণ টাকা পরিশোধ করতে হবে';
          } else if (dueAmount > 0) {
            requiresDueConfirmation = true;
          }
        }
        break;
      case DokanPosPaymentMethod.due:
        requireCustomerIdentity();
        if (state.creditDueAmount <= 0) {
          fieldErrors['creditDueAmount'] = 'বাকির পরিমাণ দিন';
        } else if (state.creditDueAmount > total) {
          fieldErrors['creditDueAmount'] =
              'বাকির পরিমাণ মোট টাকার চেয়ে বেশি হতে পারে না';
        } else {
          dueAmount = state.creditDueAmount;
          paidAmount = total - dueAmount;
        }
        break;
      case DokanPosPaymentMethod.bkash:
      case DokanPosPaymentMethod.nagad:
      case DokanPosPaymentMethod.rocket:
        final senderMobile = state.bankSenderName.trim();
        if (!isPhoneValid(senderMobile)) {
          fieldErrors['senderMobile'] = 'প্রেরকের মোবাইল নম্বর সঠিক নয়';
        }
        final transactionId = state.transactionId.trim();
        if (!isLengthInRange(transactionId, 6, 20)) {
          fieldErrors['transactionId'] = 'লেনদেন আইডি ৬-২০ অক্ষরের হতে হবে';
        }
        break;
      case DokanPosPaymentMethod.card:
        final cardHolder = state.cardHolderName.trim();
        final cardApproval = state.cardApprovalCode.trim();
        if (cardHolder.isEmpty) {
          fieldErrors['cardHolder'] = 'কার্ডধারীর নাম পূরণ করুন';
        }
        if (!isLengthInRange(cardApproval, 6, 20)) {
          fieldErrors['cardApproval'] = 'অনুমোদন কোড সঠিক নয়';
        }
        break;
      case DokanPosPaymentMethod.bank:
        if (state.bankName.trim().isEmpty) {
          fieldErrors['bankName'] = 'ব্যাংকের নাম পূরণ করুন';
        }
        if (!isLengthInRange(state.bankAccountNumber.trim(), 6, 20)) {
          fieldErrors['bankAccount'] = 'অ্যাকাউন্ট নম্বর সঠিক নয়';
        }
        if (!isLengthInRange(state.bankReferenceNumber.trim(), 6, 20)) {
          fieldErrors['bankReference'] = 'রেফারেন্স নম্বর সঠিক নয়';
        }
        if (state.bankRoutingNumber.trim().isNotEmpty &&
            !isLengthInRange(state.bankRoutingNumber.trim(), 6, 20)) {
          fieldErrors['bankRouting'] = 'রাউটিং নম্বর সঠিক নয়';
        }
        break;
    }

    return DokanPaymentValidationResult(
      fieldErrors: fieldErrors,
      dueAmount: dueAmount,
      paidAmount: paidAmount,
      requiresDueConfirmation: requiresDueConfirmation,
      paymentMethod: paymentMethod,
    );
  }
}
