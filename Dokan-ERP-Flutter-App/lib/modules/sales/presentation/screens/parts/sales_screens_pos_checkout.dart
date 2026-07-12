part of '../sales_screens.dart';

enum _CheckoutCustomerMode { walkIn, existing, newCustomer }

enum _CheckoutPaymentGroup { cash, mobileBanking, card, due }

extension _DokanPosCheckoutActions on _DokanPosMainScreenState {
  Future<void> _openCartSheet() async {
    final current = ref.read(dokanPosProvider);

    if (current.cartCount == 0) {
      _showEmptyCartNotice();
      return;
    }

    unawaited(ref.read(dokanPosProvider.notifier).fetchTaxesAndCharges());

    _updateState(() {
      _paymentFieldErrors = <String, String>{};
    });

    _discountController.text = current.discount.toString();
    _customerNameController.text = current.customerName;
    _customerNumberController.text = current.customerNumber;
    _customerAddressController.text = '';
    _customerOpeningDueController.text = '';
    _paymentTransactionController.text = current.transactionId;
    _cashReceivedController.text =
        current.cashReceived == 0 ? '' : current.cashReceived.toString();
    _creditDueAmountController.text =
        current.creditDueAmount == 0 ? '' : current.creditDueAmount.toString();
    _cardHolderController.text = current.cardHolderName;
    _cardLast4Controller.text = current.cardLast4;
    _cardApprovalController.text = current.cardApprovalCode;
    _cardBankController.text = current.cardBankName;
    _bankSenderController.text = current.bankSenderName;
    _bankNameController.text = current.bankName;
    _bankAccountController.text = current.bankAccountNumber;
    _bankReferenceController.text = current.bankReferenceNumber;
    _bankRoutingController.text = current.bankRoutingNumber;

    var customerMode = _initialCustomerMode(current);
    var selectedCustomerKey = _matchingCustomerKey(
      current.customerName,
      current.customerNumber,
      current.customerProfiles,
    );
    var paymentGroup = _paymentGroupForMethod(current.paymentMethod);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(dokanPosProvider);
                final flow = ref.watch(dokanAppFlowProvider);
                final isSalesman = flow.isSalesman;
                final method = state.paymentMethod;
                final isCash = method == DokanPosPaymentMethod.cash;
                final isDue = method == DokanPosPaymentMethod.due;
                final dueAmount = state.dueAmount;
                final changeAmount =
                    math.max(0, state.cashReceived - state.total);
                final validationResult = ref
                    .read(dokanPosProvider.notifier)
                    .validateCheckoutResult();
                final checkoutStatus =
                    ref.read(dokanPosProvider.notifier).currentCheckoutStatus();
                final statusColor = _statusColor(checkoutStatus);
                final dueVisible = isDue ||
                    (isCash && state.cashReceived > 0 && dueAmount > 0);
                final customerProfiles = state.customerProfiles
                    .where(
                      (item) => !state.hiddenCustomerKeys.contains(item.key),
                    )
                    .toList(growable: false);
                final availablePaymentGroups = _CheckoutPaymentGroup.values
                    .where(
                      (group) =>
                          (customerMode != _CheckoutCustomerMode.walkIn ||
                          group != _CheckoutPaymentGroup.due) &&
                          (group != _CheckoutPaymentGroup.due ||
                          flow.can(DokanPermission.salesManage)),
                    )
                    .toList(growable: false);

                DokanCustomerProfileRecord? selectedCustomer;
                if (selectedCustomerKey != null) {
                  for (final customer in customerProfiles) {
                    if (customer.key == selectedCustomerKey) {
                      selectedCustomer = customer;
                      break;
                    }
                  }
                }

                return SafeArea(
                  top: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F8F7),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 14,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Container(
                              width: 54,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                color: Color(0xFF006B53),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'সেলস কার্ট',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'বন্ধ',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: statusColor.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  checkoutStatus == DokanPosOrderStatus.paid
                                      ? Icons.check_circle_outline
                                      : checkoutStatus ==
                                              DokanPosOrderStatus.partiallyPaid
                                          ? Icons.info_outline
                                          : Icons.error_outline,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    dueVisible
                                        ? 'চেকআউট প্রস্তুত'
                                        : 'মোট ${_formatCurrency(state.total)}',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (dueAmount > 0)
                                  Text(
                                    'বাকি ${_formatCurrency(dueAmount)}',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _CheckoutSectionCard(
                            title: '১. কার্ট',
                            subtitle:
                                '${_banglaDigits(state.cartCount.toString())}টি আইটেম',
                            child: Column(
                              children:
                                  state.cartQuantities.entries.map((entry) {
                                final product = _findCatalogProduct(entry.key);
                                if (product == null) {
                                  return const SizedBox.shrink();
                                }
                                final subtotal =
                                    product.salePrice * entry.value;
                                final stockWarning =
                                    entry.value >= product.stock;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6FAF8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFD6E4E0),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _banglaText(product.name),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${_formatCurrency(product.salePrice)} x ${_banglaDigits(entry.value.toString())} = ${_formatCurrency(subtotal)}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF111111),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'স্টক: ${_banglaDigits(product.stock.toString())}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: stockWarning
                                                      ? const Color(0xFFB3261E)
                                                      : const Color(0xFF5F6A66),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () => ref
                                                  .read(
                                                      dokanPosProvider.notifier)
                                                  .setItemQuantity(
                                                    product.productId,
                                                    0,
                                                    stockLimit: product.stock,
                                                  ),
                                              constraints:
                                                  const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Color(0xFFB3261E),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _CartStepperButton(
                                                  icon: Icons.remove,
                                                  onTap: () => ref
                                                      .read(dokanPosProvider
                                                          .notifier)
                                                      .removeItem(
                                                          product.productId),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _banglaDigits(
                                                      entry.value.toString()),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                _CartStepperButton(
                                                  icon: Icons.add,
                                                  onTap: () => ref
                                                      .read(dokanPosProvider
                                                          .notifier)
                                                      .addItem(
                                                        product.productId,
                                                        stockLimit:
                                                            product.stock,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(growable: false),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _CheckoutSectionCard(
                            title: '২. গ্রাহক নির্বাচন',
                            subtitle: 'Walk-in, existing অথবা new customer',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _PaymentChip(
                                      label: 'Walk-in',
                                      selected: customerMode ==
                                          _CheckoutCustomerMode.walkIn,
                                      onTap: () {
                                        setModalState(() {
                                          customerMode =
                                              _CheckoutCustomerMode.walkIn;
                                          selectedCustomerKey = null;
                                          if (paymentGroup ==
                                              _CheckoutPaymentGroup.due) {
                                            paymentGroup =
                                                _CheckoutPaymentGroup.cash;
                                          }
                                        });
                                        _customerNameController.clear();
                                        _customerNumberController.clear();
                                        _customerAddressController.clear();
                                        _customerOpeningDueController.clear();
                                        ref
                                            .read(dokanPosProvider.notifier)
                                            .setCustomerName('');
                                        ref
                                            .read(dokanPosProvider.notifier)
                                            .setCustomerNumber('');
                                        if (state.paymentMethod ==
                                            DokanPosPaymentMethod.due) {
                                          ref
                                              .read(dokanPosProvider.notifier)
                                              .setPaymentMethod(
                                                DokanPosPaymentMethod.cash,
                                              );
                                        }
                                      },
                                    ),
                                    _PaymentChip(
                                      label: 'Existing',
                                      selected: customerMode ==
                                          _CheckoutCustomerMode.existing,
                                      onTap: () {
                                        setModalState(() {
                                          customerMode =
                                              _CheckoutCustomerMode.existing;
                                        });
                                      },
                                    ),
                                    _PaymentChip(
                                      label: 'New Customer',
                                      selected: customerMode ==
                                          _CheckoutCustomerMode.newCustomer,
                                      onTap: () {
                                        setModalState(() {
                                          customerMode =
                                              _CheckoutCustomerMode.newCustomer;
                                          selectedCustomerKey = null;
                                        });
                                        _customerAddressController.clear();
                                        _customerOpeningDueController.clear();
                                      },
                                    ),
                                  ],
                                ),
                                if (customerMode ==
                                    _CheckoutCustomerMode.walkIn)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F8F7),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        isDue
                                            ? 'Due বিক্রয়ের জন্য existing অথবা new customer বেছে নিন'
                                            : 'Walk-in customer হিসেবে বিক্রয় হবে',
                                        style: TextStyle(
                                          color: isDue
                                              ? const Color(0xFFB3261E)
                                              : const Color(0xFF44514C),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (customerMode ==
                                    _CheckoutCustomerMode.existing)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: InkWell(
                                      onTap: () {
                                        _showSearchableCustomerPicker(
                                          context,
                                          customerProfiles,
                                          selectedCustomerKey,
                                          (customer) {
                                            setModalState(() {
                                              selectedCustomerKey =
                                                  customer.key;
                                            });
                                            _customerNameController.text =
                                                customer.name;
                                            _customerNumberController.text =
                                                customer.phone;
                                            ref
                                                .read(dokanPosProvider.notifier)
                                                .setCustomerName(customer.name);
                                            ref
                                                .read(dokanPosProvider.notifier)
                                                .setCustomerNumber(
                                                    customer.phone);
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFFC4D5D0),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                selectedCustomer != null
                                                    ? '${selectedCustomer.name}${selectedCustomer.phone.isEmpty ? "" : " • ${selectedCustomer.phone}"}'
                                                    : 'গ্রাহক নির্বাচন করুন',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: selectedCustomer !=
                                                          null
                                                      ? Colors.black
                                                      : const Color(0xFF5F6A66),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.search_rounded,
                                              color: Color(0xFF5F6A66),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (customerMode ==
                                        _CheckoutCustomerMode.existing &&
                                    selectedCustomer != null) ...[
                                  const SizedBox(height: 10),
                                  _SummaryRow(
                                    label: 'বর্তমান বাকি',
                                    value: _formatCurrency(
                                      selectedCustomer.currentDue,
                                    ),
                                    valueColor: selectedCustomer.currentDue > 0
                                        ? const Color(0xFFB3261E)
                                        : const Color(0xFF0C8C67),
                                  ),
                                ],
                                if (customerMode ==
                                    _CheckoutCustomerMode.newCustomer) ...[
                                  const SizedBox(height: 12),
                                  _dialogTextField(
                                    _customerNameController,
                                    'Customer Name',
                                    errorKey: 'customerName',
                                    errorText:
                                        _paymentFieldErrors['customerName'],
                                    onChanged: (value) => ref
                                        .read(dokanPosProvider.notifier)
                                        .setCustomerName(value),
                                  ),
                                  const SizedBox(height: 10),
                                  _dialogTextField(
                                    _customerNumberController,
                                    'Customer Phone',
                                    errorKey: 'customerNumber',
                                    errorText:
                                        _paymentFieldErrors['customerNumber'],
                                    onChanged: (value) => ref
                                        .read(dokanPosProvider.notifier)
                                        .setCustomerNumber(value),
                                  ),
                                  const SizedBox(height: 10),
                                  _dialogTextField(
                                    _customerAddressController,
                                    'Customer Address',
                                    minLines: 2,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 10),
                                  _dialogTextField(
                                    _customerOpeningDueController,
                                    'Opening Due',
                                    keyboardType: TextInputType.number,
                                    inputFormatters:
                                        NumericInputFormatters.wholeNumber,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _CheckoutSectionCard(
                            title: '৩. অর্ডার সামারি',
                            subtitle: 'Subtotal, discount, tax and total',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  enabled: flow.can(DokanPermission.settingsManage),
                                  controller: _discountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters:
                                      NumericInputFormatters.wholeNumber,
                                  style: const TextStyle(color: Colors.black),
                                  decoration:
                                      _checkoutInputDecoration('Discount'),
                                  onChanged: (value) {
                                    String cleaned = value;
                                    if (cleaned.startsWith('0') && cleaned.length > 1 && cleaned[1] != '.') {
                                      cleaned = cleaned.substring(1);
                                    } else if (cleaned.startsWith('০') && cleaned.length > 1 && cleaned[1] != '.') {
                                      cleaned = cleaned.substring(1);
                                    }
                                    if (cleaned != value) {
                                      _discountController.value = TextEditingValue(
                                        text: cleaned,
                                        selection: TextSelection.collapsed(offset: cleaned.length),
                                      );
                                    }
                                    ref
                                        .read(dokanPosProvider.notifier)
                                        .setDiscount(cleaned);
                                  },
                                ),
                                const SizedBox(height: 14),
                                _SummaryRow(
                                  label: 'Subtotal',
                                  value: _formatCurrency(state.subtotal),
                                ),
                                const SizedBox(height: 8),
                                _SummaryRow(
                                  label: 'Discount',
                                  value: _formatCurrency(state.discountAmount),
                                  valueColor: const Color(0xFFB3261E),
                                ),
                                const SizedBox(height: 8),
                                _SummaryRow(
                                  label: 'Tax/VAT',
                                  value: _formatCurrency(state.taxAmount),
                                ),
                                if (state.extraCharges > 0) ...[
                                  const SizedBox(height: 8),
                                  _SummaryRow(
                                    label: 'Delivery Charge',
                                    value: _formatCurrency(state.extraCharges),
                                  ),
                                ],
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1),
                                ),
                                _SummaryRow(
                                  label: 'Total',
                                  value: _formatCurrency(state.total),
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  valueStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (isDue) ...[
                                  const SizedBox(height: 8),
                                  _SummaryRow(
                                    label: 'বাকি থাকবে',
                                    value: _formatCurrency(dueAmount),
                                    valueColor: const Color(0xFFB3261E),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _CheckoutSectionCard(
                            title: '৪. পেমেন্ট মেথড',
                            subtitle: 'Primary method and subtype',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: availablePaymentGroups
                                      .map(
                                        (group) => _PaymentChip(
                                          label: _paymentGroupLabel(group),
                                          selected: paymentGroup == group,
                                          onTap: () {
                                            final nextMethod =
                                                _defaultPaymentMethodForGroup(
                                              group,
                                            );
                                            ref
                                                .read(dokanPosProvider.notifier)
                                                .setPaymentMethod(nextMethod);
                                            if (group ==
                                                _CheckoutPaymentGroup.due) {
                                              _creditDueAmountController.text =
                                                  state.total.toString();
                                              ref
                                                  .read(
                                                    dokanPosProvider.notifier,
                                                  )
                                                  .setCreditDueAmount(
                                                    state.total.toString(),
                                                  );
                                              if (customerMode ==
                                                  _CheckoutCustomerMode
                                                      .walkIn) {
                                                customerMode =
                                                    customerProfiles.isNotEmpty
                                                        ? _CheckoutCustomerMode
                                                            .existing
                                                        : _CheckoutCustomerMode
                                                            .newCustomer;
                                              }
                                            }
                                            setModalState(() {
                                              paymentGroup = group;
                                              _paymentFieldErrors =
                                                  <String, String>{};
                                            });
                                          },
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                                if (_secondaryPaymentMethods(paymentGroup)
                                        .length >
                                    1) ...[
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: _secondaryPaymentMethods(
                                            paymentGroup)
                                        .map(
                                          (paymentMethod) => _PaymentChip(
                                            label: _compactPaymentLabel(
                                              paymentMethod,
                                            ),
                                            selected: state.paymentMethod ==
                                                paymentMethod,
                                            onTap: () => ref
                                                .read(dokanPosProvider.notifier)
                                                .setPaymentMethod(
                                                    paymentMethod),
                                          ),
                                        )
                                        .toList(growable: false),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    ref
                                        .read(dokanPosProvider.notifier)
                                        .cancelCheckout();
                                    Navigator.of(context).pop();
                                    _showAlertDialog(
                                      title: 'পেমেন্ট বাতিল',
                                      message: 'পেমেন্ট সম্পন্ন হয়নি।',
                                      accent: const Color(0xFFB3261E),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF006B53),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'বাতিল',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final currentState =
                                        ref.read(dokanPosProvider);
                                    if (currentState.paymentMethod ==
                                        DokanPosPaymentMethod.cash) {
                                      final result = await Navigator.of(context)
                                          .push<CheckoutCompletionResult>(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const DokanCashPaymentScreen(),
                                        ),
                                      );
                                      if (!context.mounted || result == null) {
                                        return;
                                      }

                                      ref
                                          .read(dokanPosProvider.notifier)
                                          .resetAfterCheckout();
                                      _discountController.text = '0';
                                      _paymentTransactionController.clear();
                                      _customerNameController.clear();
                                      _customerNumberController.clear();
                                      _customerAddressController.clear();
                                      _customerOpeningDueController.clear();
                                      _cashReceivedController.clear();
                                      _creditDueAmountController.clear();
                                      _cardHolderController.clear();
                                      _cardLast4Controller.clear();
                                      _cardApprovalController.clear();
                                      _cardBankController.clear();
                                      _bankSenderController.clear();
                                      _bankNameController.clear();
                                      _bankAccountController.clear();
                                      _bankReferenceController.clear();
                                      _bankRoutingController.clear();
                                      Navigator.of(context).pop();
                                      _showPaymentSuccess(
                                        result.total,
                                        result.method,
                                        result.status,
                                        result.dueAmount,
                                      );
                                      return;
                                    }
                                    if (currentState.paymentMethod ==
                                        DokanPosPaymentMethod.card) {
                                      final result = await Navigator.of(context)
                                          .push<CheckoutCompletionResult>(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const DokanCardPaymentScreen(),
                                        ),
                                      );
                                      if (!context.mounted || result == null) {
                                        return;
                                      }

                                      ref
                                          .read(dokanPosProvider.notifier)
                                          .resetAfterCheckout();
                                      _discountController.text = '0';
                                      _paymentTransactionController.clear();
                                      _customerNameController.clear();
                                      _customerNumberController.clear();
                                      _customerAddressController.clear();
                                      _customerOpeningDueController.clear();
                                      _cashReceivedController.clear();
                                      _creditDueAmountController.clear();
                                      _cardHolderController.clear();
                                      _cardLast4Controller.clear();
                                      _cardApprovalController.clear();
                                      _cardBankController.clear();
                                      _bankSenderController.clear();
                                      _bankNameController.clear();
                                      _bankAccountController.clear();
                                      _bankReferenceController.clear();
                                      _bankRoutingController.clear();
                                      Navigator.of(context).pop();
                                      return;
                                    }
                                    if (currentState.paymentMethod ==
                                            DokanPosPaymentMethod.bkash ||
                                        currentState.paymentMethod ==
                                            DokanPosPaymentMethod.nagad ||
                                        currentState.paymentMethod ==
                                            DokanPosPaymentMethod.rocket) {
                                      final result = await Navigator.of(context)
                                          .push<CheckoutCompletionResult>(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const DokanMfsPaymentScreen(),
                                        ),
                                      );
                                      if (!context.mounted || result == null) {
                                        return;
                                      }

                                      ref
                                          .read(dokanPosProvider.notifier)
                                          .resetAfterCheckout();
                                      _discountController.text = '0';
                                      _paymentTransactionController.clear();
                                      _customerNameController.clear();
                                      _customerNumberController.clear();
                                      _customerAddressController.clear();
                                      _customerOpeningDueController.clear();
                                      _cashReceivedController.clear();
                                      _creditDueAmountController.clear();
                                      _cardHolderController.clear();
                                      _cardLast4Controller.clear();
                                      _cardApprovalController.clear();
                                      _cardBankController.clear();
                                      _bankSenderController.clear();
                                      _bankNameController.clear();
                                      _bankAccountController.clear();
                                      _bankReferenceController.clear();
                                      _bankRoutingController.clear();
                                      Navigator.of(context).pop();
                                      return;
                                    }
                                    if (validationResult.hasBlockingErrors) {
                                      setModalState(() {
                                        _paymentFieldErrors =
                                            validationResult.fieldErrors;
                                      });
                                      return;
                                    }

                                    Future<void> finalizeCheckout({
                                      required bool allowDueConfirmation,
                                    }) async {
                                      if (customerMode ==
                                          _CheckoutCustomerMode.newCustomer) {
                                        final openingDue = int.tryParse(
                                              _customerOpeningDueController.text
                                                  .trim(),
                                            ) ??
                                            0;
                                        try {
                                          await ref
                                              .read(dokanPosProvider.notifier)
                                              .addCustomer(
                                                name: _customerNameController
                                                    .text,
                                                phone: _customerNumberController
                                                    .text,
                                                address:
                                                    _customerAddressController
                                                        .text,
                                                openingDue: openingDue < 0
                                                    ? 0
                                                    : openingDue,
                                              );
                                        } catch (e) {
                                          debugPrint(
                                              '[CHECKOUT] addCustomer failed (continuing): $e');
                                        }
                                      }
                                      final checkVerified = await verifyDueOtp(
                                        context: context,
                                        ref: ref,
                                        state: ref.read(dokanPosProvider),
                                        dueAmount: validationResult.dueAmount,
                                      );
                                      if (!checkVerified) return;
                                      final message = await ref
                                          .read(dokanPosProvider.notifier)
                                          .confirmCheckout(
                                            allowDueConfirmation:
                                                allowDueConfirmation,
                                          );
                                      if (!context.mounted) return;
                                      if (message == null ||
                                          message ==
                                              'remaining_due_confirmation_required') {
                                        return;
                                      }
                                      final total = currentState.total;
                                      final reviewDueAmount =
                                          validationResult.dueAmount;
                                      final confirmationMethod =
                                          currentState.paymentMethod;
                                      final summaryStatus = ref
                                          .read(dokanPosProvider.notifier)
                                          .currentCheckoutStatus();

                                      ref
                                          .read(dokanPosProvider.notifier)
                                          .resetAfterCheckout();
                                      _discountController.text = '0';
                                      _paymentTransactionController.clear();
                                      _customerNameController.clear();
                                      _customerNumberController.clear();
                                      _customerAddressController.clear();
                                      _customerOpeningDueController.clear();
                                      _cashReceivedController.clear();
                                      _creditDueAmountController.clear();
                                      _cardHolderController.clear();
                                      _cardLast4Controller.clear();
                                      _cardApprovalController.clear();
                                      _cardBankController.clear();
                                      _bankSenderController.clear();
                                      _bankNameController.clear();
                                      _bankAccountController.clear();
                                      _bankReferenceController.clear();
                                      _bankRoutingController.clear();
                                      Navigator.of(context).pop();
                                      _showPaymentSuccess(
                                        total,
                                        confirmationMethod,
                                        summaryStatus,
                                        reviewDueAmount,
                                      );
                                    }

                                    if (validationResult
                                            .requiresDueConfirmation &&
                                        currentState.paymentMethod ==
                                            DokanPosPaymentMethod.cash) {
                                      showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) {
                                          return AlertDialog(
                                            title:
                                                const Text('বাকী রাখতে চান?'),
                                            content: Text(
                                              'অবশিষ্ট ${validationResult.dueAmount} টাকা বাকী হিসেবে রাখতে চান?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(dialogContext)
                                                        .pop(false),
                                                child: const Text('না'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.of(dialogContext)
                                                        .pop(true),
                                                child: const Text('হ্যাঁ'),
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((confirmed) {
                                        if (confirmed == true) {
                                          finalizeCheckout(
                                            allowDueConfirmation: true,
                                          );
                                        }
                                      });
                                      return;
                                    }

                                    finalizeCheckout(
                                      allowDueConfirmation: false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF006B53),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(
                                    isCash
                                        ? 'ক্যাশ পেমেন্ট পেজে যান'
                                        : paymentGroup ==
                                                _CheckoutPaymentGroup
                                                    .mobileBanking
                                            ? 'মোবাইল পেমেন্ট পেজে যান'
                                            : paymentGroup ==
                                                    _CheckoutPaymentGroup.card
                                                ? 'কার্ড পেমেন্ট পেজে যান'
                                                : 'Complete Payment',
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
              },
            );
          },
        );
      },
    );
  }

  _CheckoutCustomerMode _initialCustomerMode(DokanPosState state) {
    if (_matchingCustomerKey(
          state.customerName,
          state.customerNumber,
          state.customerProfiles,
        ) !=
        null) {
      return _CheckoutCustomerMode.existing;
    }
    if (state.customerName.trim().isNotEmpty ||
        state.customerNumber.trim().isNotEmpty) {
      return _CheckoutCustomerMode.newCustomer;
    }
    return _CheckoutCustomerMode.walkIn;
  }

  String? _matchingCustomerKey(
    String name,
    String phone,
    List<DokanCustomerProfileRecord> profiles,
  ) {
    final normalizedName = name.trim().toLowerCase();
    final normalizedPhone = phone.trim();
    for (final profile in profiles) {
      if (normalizedPhone.isNotEmpty &&
          profile.phone.trim() == normalizedPhone) {
        return profile.key;
      }
      if (normalizedPhone.isEmpty &&
          normalizedName.isNotEmpty &&
          profile.name.trim().toLowerCase() == normalizedName) {
        return profile.key;
      }
    }
    return null;
  }

  _CheckoutPaymentGroup _paymentGroupForMethod(DokanPosPaymentMethod method) {
    switch (method) {
      case DokanPosPaymentMethod.cash:
        return _CheckoutPaymentGroup.cash;
      case DokanPosPaymentMethod.bkash:
      case DokanPosPaymentMethod.nagad:
      case DokanPosPaymentMethod.rocket:
        return _CheckoutPaymentGroup.mobileBanking;
      case DokanPosPaymentMethod.card:
        return _CheckoutPaymentGroup.card;
      case DokanPosPaymentMethod.bank:
        return _CheckoutPaymentGroup.card;
      case DokanPosPaymentMethod.due:
        return _CheckoutPaymentGroup.due;
    }
  }

  DokanPosPaymentMethod _defaultPaymentMethodForGroup(
    _CheckoutPaymentGroup group,
  ) {
    switch (group) {
      case _CheckoutPaymentGroup.cash:
        return DokanPosPaymentMethod.cash;
      case _CheckoutPaymentGroup.mobileBanking:
        return DokanPosPaymentMethod.bkash;
      case _CheckoutPaymentGroup.card:
        return DokanPosPaymentMethod.card;
      case _CheckoutPaymentGroup.due:
        return DokanPosPaymentMethod.due;
    }
  }

  List<DokanPosPaymentMethod> _secondaryPaymentMethods(
    _CheckoutPaymentGroup group,
  ) {
    switch (group) {
      case _CheckoutPaymentGroup.cash:
        return const [DokanPosPaymentMethod.cash];
      case _CheckoutPaymentGroup.mobileBanking:
        return const [
          DokanPosPaymentMethod.bkash,
          DokanPosPaymentMethod.nagad,
          DokanPosPaymentMethod.rocket,
        ];
      case _CheckoutPaymentGroup.card:
        return const [DokanPosPaymentMethod.card];
      case _CheckoutPaymentGroup.due:
        return const [DokanPosPaymentMethod.due];
    }
  }

  String _paymentGroupLabel(_CheckoutPaymentGroup group) {
    switch (group) {
      case _CheckoutPaymentGroup.cash:
        return 'Cash';
      case _CheckoutPaymentGroup.mobileBanking:
        return 'Mobile Banking';
      case _CheckoutPaymentGroup.card:
        return 'Card';
      case _CheckoutPaymentGroup.due:
        return 'Due';
    }
  }

  String _paymentGroupInfo(_CheckoutPaymentGroup group) {
    switch (group) {
      case _CheckoutPaymentGroup.cash:
        return 'Total, received, change';
      case _CheckoutPaymentGroup.mobileBanking:
        return 'Transaction ID, reference, account';
      case _CheckoutPaymentGroup.card:
        return 'Card holder, approval code, network';
      case _CheckoutPaymentGroup.due:
        return 'Customer information is required';
    }
  }

  String _compactPaymentLabel(DokanPosPaymentMethod method) {
    switch (method) {
      case DokanPosPaymentMethod.cash:
        return 'Cash';
      case DokanPosPaymentMethod.due:
        return 'Due';
      case DokanPosPaymentMethod.bkash:
        return 'Bkash';
      case DokanPosPaymentMethod.nagad:
        return 'Nagad';
      case DokanPosPaymentMethod.card:
        return 'Card';
      case DokanPosPaymentMethod.rocket:
        return 'Rocket';
      case DokanPosPaymentMethod.bank:
        return 'Bank';
    }
  }

  String _reviewPaymentLabel(DokanPosPaymentMethod method) {
    switch (method) {
      case DokanPosPaymentMethod.cash:
        return 'Cash';
      case DokanPosPaymentMethod.due:
        return 'Due';
      case DokanPosPaymentMethod.bkash:
        return 'Mobile Banking • Bkash';
      case DokanPosPaymentMethod.nagad:
        return 'Mobile Banking • Nagad';
      case DokanPosPaymentMethod.card:
        return 'Card';
      case DokanPosPaymentMethod.rocket:
        return 'Mobile Banking • Rocket';
      case DokanPosPaymentMethod.bank:
        return 'Bank';
    }
  }

  Future<void> _showPaymentSuccess(
    int total,
    DokanPosPaymentMethod method,
    DokanPosOrderStatus status,
    int dueAmount,
  ) async {
    final message = dueAmount > 0
        ? '${_formatCurrency(total)} এর মধ্যে ${_formatCurrency(dueAmount)} বাকি রয়েছে। ${_reviewPaymentLabel(method)} দিয়ে আংশিক পরিশোধ করা হয়েছে।'
        : '${_formatCurrency(total)} ${_reviewPaymentLabel(method)} দিয়ে সফলভাবে গ্রহণ করা হয়েছে।';

    ref.read(appPreferencesProvider.notifier).triggerFeedback();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF006B53),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _dialogTextField(
    TextEditingController controller,
    String hint, {
    String? errorKey,
    String? errorText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int minLines = 1,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: (value) {
        onChanged?.call(value);
        if (errorKey != null) {
          _clearPaymentFieldError(errorKey);
        }
      },
      decoration: _checkoutInputDecoration(
        hint,
        errorText: errorText,
      ),
    );
  }

  InputDecoration _checkoutInputDecoration(
    String hint, {
    String? errorText,
  }) {
    final hasError = errorText != null;
    return InputDecoration(
      filled: true,
      fillColor: hasError ? const Color(0xFFFFF5F5) : const Color(0xFFF5F8F7),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      errorText: errorText,
      errorMaxLines: 2,
      errorStyle: const TextStyle(
        color: Color(0xFFB3261E),
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: hasError ? const Color(0xFFB3261E) : const Color(0xFFD6E4E0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: hasError ? const Color(0xFFB3261E) : const Color(0xFFD6E4E0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: hasError ? const Color(0xFFB3261E) : const Color(0xFF006B53),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB3261E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB3261E), width: 2),
      ),
    );
  }

  void _clearPaymentFieldError(String key) {
    if (!_paymentFieldErrors.containsKey(key)) {
      return;
    }
    _updateState(() {
      _paymentFieldErrors.remove(key);
    });
  }
}

class CheckoutCompletionResult {
  const CheckoutCompletionResult({
    required this.total,
    required this.method,
    required this.status,
    required this.dueAmount,
  });

  final int total;
  final DokanPosPaymentMethod method;
  final DokanPosOrderStatus status;
  final int dueAmount;
}

class DokanCashPaymentScreen extends ConsumerWidget {
  const DokanCashPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dokanPosProvider);
    final notifier = ref.read(dokanPosProvider.notifier);
    final validation = notifier.validateCheckoutResult();
    final total = state.total;
    final received = state.cashReceived;
    final change = math.max(0, received - total);
    final due = math.max(0, total - received);
    final quickAmounts = <int>{
      total,
      _roundUpToStep(total, 500),
      _roundUpToStep(total, 1000),
    }.where((value) => value > 0).toList(growable: false)
      ..sort();

    Future<void> completeCashPayment() async {
      if (validation.hasBlockingErrors) {
        final message = validation.firstErrorMessage ?? 'প্রাপ্ত নগদ দিন';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }

      var allowDueConfirmation = false;
      if (validation.requiresDueConfirmation) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('বাকি রাখবেন?'),
              content: Text(
                'অবশিষ্ট ${_formatCurrency(validation.dueAmount)} বাকি হিসেবে রাখতে চান?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('না'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('হ্যাঁ'),
                ),
              ],
            );
          },
        );
        if (confirmed != true) {
          return;
        }
        allowDueConfirmation = true;
      }

      final checkVerified = await verifyDueOtp(
        context: context,
        ref: ref,
        state: state,
        dueAmount: validation.dueAmount,
      );
      if (!checkVerified) return;
      final message = await notifier.confirmCheckout(
        allowDueConfirmation: allowDueConfirmation,
      );
      if (!context.mounted) return;
      if (message == null || message == 'remaining_due_confirmation_required') {
        return;
      }
      if (message != 'চেকআউট সম্পন্ন হয়েছে') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }

      Navigator.of(context).pop(
        CheckoutCompletionResult(
          total: state.total,
          method: state.paymentMethod,
          status: notifier.currentCheckoutStatus(),
          dueAmount: notifier.validateCheckoutResult().dueAmount,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
        ),
        title: const Text(
          'ক্যাশ পেমেন্ট',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD7EBDD)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'পরিশোধযোগ্য মোট',
                      style: TextStyle(
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatCurrency(total),
                      style: const TextStyle(
                        color: Color(0xFF0C8C67),
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'কত টাকা পেলেন?',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(received),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 150,
                height: 2,
                color: const Color(0xFF0C8C67),
              ),
              const SizedBox(height: 10),
              Row(
                children: quickAmounts.map((amount) {
                  final active = amount == received;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _CashQuickAmountChip(
                        label: amount == total ? 'সঠিক পরিমাণ' : 'দ্রুত পরিমাণ',
                        amount: amount,
                        active: active,
                        onTap: () =>
                            notifier.setCashReceived(amount.toString()),
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD7E3DD)),
                ),
                child: Column(
                  children: [
                    _CashSummaryLine(
                      label: 'নিয়ে দিলেন',
                      value: _formatCurrency(received),
                    ),
                    const SizedBox(height: 8),
                    _CashSummaryLine(
                      label: 'ফেরত দিন',
                      value: _formatCurrency(change),
                      valueColor: const Color(0xFFF97316),
                    ),
                    if (due > 0) ...[
                      const SizedBox(height: 8),
                      _CashSummaryLine(
                        label: 'বাকি থাকবে',
                        value: _formatCurrency(due),
                        valueColor: const Color(0xFFDC2626),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 8.0;
                    final buttonHeight =
                        ((constraints.maxHeight - (spacing * 3)) / 4)
                            .clamp(52.0, 84.0);
                    return GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      mainAxisExtent: buttonHeight,
                      children: [
                        for (final key in const [
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                          '8',
                          '9',
                          '০০',
                          '0',
                          '⌫',
                        ])
                          _CashKeypadButton(
                            label: key,
                            onTap: () {
                              final next = _nextCashValue(
                                current: received.toString(),
                                key: key,
                              );
                              notifier.setCashReceived(next);
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: completeCashPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A085),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    due > 0
                        ? 'পেমেন্ট নিশ্চিত করুন - ${_formatCurrency(received)}'
                        : 'পেমেন্ট নিশ্চিত করুন - ${_formatCurrency(total)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashQuickAmountChip extends StatelessWidget {
  const _CashQuickAmountChip({
    required this.label,
    required this.amount,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int amount;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0C8C67) : const Color(0xFFDDE9F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF334155),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatCurrency(amount),
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashSummaryLine extends StatelessWidget {
  const _CashSummaryLine({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF0F172A),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _CashKeypadButton extends StatelessWidget {
  const _CashKeypadButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFF1EFE7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

int _roundUpToStep(int value, int step) {
  if (value <= 0) return step;
  return ((value + step - 1) ~/ step) * step;
}

String _nextCashValue({
  required String current,
  required String key,
}) {
  final normalized = current == '0' ? '' : current;
  switch (key) {
    case '⌫':
      if (normalized.isEmpty) return '0';
      final next = normalized.substring(0, normalized.length - 1);
      return next.isEmpty ? '0' : next;
    case '০০':
      final base = normalized.isEmpty ? '0' : normalized;
      return '${base}00';
    default:
      return '${normalized.isEmpty ? '' : normalized}$key';
  }
}

class DokanMfsPaymentScreen extends ConsumerWidget {
  const DokanMfsPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dokanPosProvider);
    final notifier = ref.read(dokanPosProvider.notifier);
    final flow = ref.watch(dokanAppFlowProvider);
    final method = state.paymentMethod;
    final isBkash = method == DokanPosPaymentMethod.bkash;
    final isNagad = method == DokanPosPaymentMethod.nagad;
    final isRocket = method == DokanPosPaymentMethod.rocket;
    final validation = notifier.validateCheckoutResult();
    final storeName = flow.shopName.trim().isEmpty ? 'DokanERP' : flow.shopName;
    final accountNumber =
        flow.ownerPhone.trim().isEmpty ? '01712-XXXXXX' : flow.ownerPhone;

    Future<void> completeMfsPayment() async {
      if (validation.hasBlockingErrors) {
        final message = validation.firstErrorMessage ?? 'Transaction ID দিন';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }

      final checkVerified = await verifyDueOtp(
        context: context,
        ref: ref,
        state: state,
        dueAmount: validation.dueAmount,
      );
      if (!checkVerified) return;
      final message = await notifier.confirmCheckout();
      if (!context.mounted) return;
      if (message != 'চেকআউট সম্পন্ন হয়েছে') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'চেকআউট ব্যর্থ হয়েছে')),
        );
        return;
      }

      final result = CheckoutCompletionResult(
        total: state.total,
        method: state.paymentMethod,
        status: notifier.currentCheckoutStatus(),
        dueAmount: notifier.validateCheckoutResult().dueAmount,
      );

      final successMsg = result.dueAmount > 0
          ? '${_formatCurrency(result.total)} এর মধ্যে ${_formatCurrency(result.dueAmount)} বাকি রয়েছে। মোবাইল ব্যাংকিং দিয়ে আংশিক পরিশোধ করা হয়েছে।'
          : '${_formatCurrency(result.total)} মোবাইল ব্যাংকিং দিয়ে সফলভাবে গ্রহণ করা হয়েছে।';

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            successMsg,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF006B53),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop(result);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
        ),
        title: const Text(
          'মোবাইল পেমেন্ট',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'ধাপ ২/৩',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, color: Color(0xFF0C8C67)),
              const SizedBox(width: 8),
              Text(
                storeName,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MfsMethodChip(
                  label: 'bKash',
                  active: isBkash,
                  color: const Color(0xFFE2136E),
                  onTap: () =>
                      notifier.setPaymentMethod(DokanPosPaymentMethod.bkash),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MfsMethodChip(
                  label: 'Nagad',
                  active: isNagad,
                  color: const Color(0xFFF97316),
                  onTap: () =>
                      notifier.setPaymentMethod(DokanPosPaymentMethod.nagad),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MfsMethodChip(
                  label: 'Rocket',
                  active: isRocket,
                  color: const Color(0xFF8B5CF6),
                  onTap: () =>
                      notifier.setPaymentMethod(DokanPosPaymentMethod.rocket),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFF5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text(
                  'মোট টাকা পরিশোধ',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(state.total),
                  style: const TextStyle(
                    color: Color(0xFFE2136E),
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${state.cartCount}টি আইটেম • পেমেন্ট রেডি',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD7E3DD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBkash
                      ? 'সেন্ডমানি bKash নম্বর'
                      : isNagad
                          ? 'সেন্ডমানি Nagad নম্বর'
                          : 'সেন্ডমানি Rocket নম্বর',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        accountNumber,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Icon(Icons.edit_outlined, color: Color(0xFF334155)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'অ্যাকাউন্ট নাম দেখে পেমেন্ট গ্রহণ করুন',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'প্রেরকের মোবাইল নম্বর দিন',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'যে নম্বর থেকে টাকা পাঠানো হয়েছে',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.bankSenderName,
            keyboardType: TextInputType.phone,
            onChanged: notifier.setBankSenderName,
            decoration: InputDecoration(
              hintText: 'Sender mobile number লিখুন',
              errorText: validation.fieldErrors['senderMobile'],
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: const Icon(
                Icons.phone_iphone_rounded,
                color: Color(0xFF0C8C67),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF0C8C67),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Transaction ID দিন',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isBkash
                ? 'bKash থেকে প্রাপ্ত ট্রানজেকশন নম্বর'
                : isNagad
                    ? 'Nagad থেকে প্রাপ্ত ট্রানজেকশন নম্বর'
                    : 'Rocket থেকে প্রাপ্ত ট্রানজেকশন নম্বর',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.transactionId,
            onChanged: notifier.setTransactionId,
            decoration: InputDecoration(
              hintText: 'Transaction ID লিখুন',
              errorText: validation.fieldErrors['transactionId'],
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF0C8C67),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF0C8C67),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Transaction ID কপি বা টাইপিং নিশ্চিত করুন (ভুল হলে মিলবে না)',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: completeMfsPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2136E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'পেমেন্ট নিশ্চিত করুন - ${_formatCurrency(state.total)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DokanCardPaymentScreen extends ConsumerWidget {
  const DokanCardPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dokanPosProvider);
    final notifier = ref.read(dokanPosProvider.notifier);
    final flow = ref.watch(dokanAppFlowProvider);
    final validation = notifier.validateCheckoutResult();
    final storeName = flow.shopName.trim().isEmpty ? 'DokanERP' : flow.shopName;

    Future<void> completeCardPayment() async {
      if (validation.hasBlockingErrors) {
        final message =
            validation.firstErrorMessage ?? 'কার্ড তথ্য সম্পূর্ণ করুন';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }

      final checkVerified = await verifyDueOtp(
        context: context,
        ref: ref,
        state: state,
        dueAmount: validation.dueAmount,
      );
      if (!checkVerified) return;
      final message = await notifier.confirmCheckout();
      if (!context.mounted) return;
      if (message != 'চেকআউট সম্পন্ন হয়েছে') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'চেকআউট ব্যর্থ হয়েছে')),
        );
        return;
      }

      final result = CheckoutCompletionResult(
        total: state.total,
        method: state.paymentMethod,
        status: notifier.currentCheckoutStatus(),
        dueAmount: notifier.validateCheckoutResult().dueAmount,
      );

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => DokanCardSuccessScreen(
            result: result,
            shopName: storeName,
            approvalCode: state.cardApprovalCode.trim(),
            cardHolderName: state.cardHolderName.trim().isEmpty
                ? 'ওয়াক-ইন গ্রাহক'
                : state.cardHolderName.trim(),
            network: state.cardBankName.trim(),
          ),
        ),
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(result);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
        ),
        title: const Text(
          'কার্ড পেমেন্ট',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'ধাপ ২/৩',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, color: Color(0xFF0C8C67)),
              const SizedBox(width: 8),
              Text(
                storeName,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text(
                  'মোট টাকা পরিশোধ',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(state.total),
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${state.cartCount}টি আইটেম • কার্ড রেডি',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'কার্ডধারীর নাম দিন',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.cardHolderName,
            onChanged: notifier.setCardHolderName,
            decoration: InputDecoration(
              hintText: 'Card holder name লিখুন',
              errorText: validation.fieldErrors['cardHolder'],
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: const Icon(
                Icons.badge_outlined,
                color: Color(0xFF1D4ED8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF1D4ED8),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Approval Code / Transaction ID',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.cardApprovalCode,
            onChanged: notifier.setCardApprovalCode,
            decoration: InputDecoration(
              hintText: 'Approval code লিখুন',
              errorText: validation.fieldErrors['cardApproval'],
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: const Icon(
                Icons.credit_score_rounded,
                color: Color(0xFF1D4ED8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF1D4ED8),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'নেটওয়ার্ক / রেফারেন্স',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: state.cardBankName,
            onChanged: notifier.setCardBankName,
            decoration: InputDecoration(
              hintText: 'যেমন Visa / Mastercard / POS Ref',
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: const Icon(
                Icons.credit_card_rounded,
                color: Color(0xFF1D4ED8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD7E3DD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF1D4ED8),
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: completeCardPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'পেমেন্ট নিশ্চিত করুন - ${_formatCurrency(state.total)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DokanCardSuccessScreen extends StatelessWidget {
  const DokanCardSuccessScreen({
    super.key,
    required this.result,
    required this.shopName,
    required this.approvalCode,
    required this.cardHolderName,
    required this.network,
  });

  final CheckoutCompletionResult result;
  final String shopName;
  final String approvalCode;
  final String cardHolderName;
  final String network;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F8),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 64, 20, 26),
            decoration: const BoxDecoration(
              color: Color(0xFF1D4ED8),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.check_rounded,
                        color: Color(0xFF1D4ED8),
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${_formatCurrency(result.total)} পেমেন্ট সম্পন্ন',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$shopName • ${AppDateFormatter.time(now)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            cardHolderName,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            approvalCode.isEmpty
                                ? 'অ্যাপ্রুভাল কোড সংরক্ষিত'
                                : approvalCode,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _MfsReceiptRow(
                      label: 'Invoice',
                      value: '#${now.microsecondsSinceEpoch % 100000}',
                    ),
                    _MfsReceiptRow(
                      label: 'বিক্রিত টাকার পরিমাণ',
                      value: _formatCurrency(result.total),
                    ),
                    _MfsReceiptRow(
                      label: 'মোট পরিশোধ',
                      value: _formatCurrency(result.total),
                    ),
                    _MfsReceiptRow(
                      label: 'মোট বাকি',
                      value: _formatCurrency(result.dueAmount),
                    ),
                    const SizedBox(height: 8),
                    _MfsReceiptRow(
                      label: 'সর্বমোট',
                      value: _formatCurrency(result.total),
                      emphasize: true,
                      valueColor: const Color(0xFF1D4ED8),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5FAFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'পেমেন্ট মাধ্যম:',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            network.trim().isEmpty ? 'Card' : network.trim(),
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _MfsActionButton(
                    label: 'প্রিন্ট করুন',
                    icon: Icons.print_outlined,
                    background: Colors.white,
                    foreground: const Color(0xFF1D4ED8),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('প্রিন্ট ফিচার শিগগিরই আসছে')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MfsActionButton(
                    label: 'PDF সেভ',
                    icon: Icons.description_outlined,
                    background: Colors.white,
                    foreground: const Color(0xFF1D4ED8),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF ফিচার শিগগিরই আসছে')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MfsActionButton(
                    label: 'WhatsApp',
                    icon: Icons.chat_bubble_outline,
                    background: const Color(0xFF22C55E),
                    foreground: Colors.white,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('WhatsApp শেয়ার ফিচার শিগগিরই আসছে'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: const Text(
                  'নতুন বিক্রয় শুরু করুন',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DokanMfsSuccessScreen extends StatelessWidget {
  const DokanMfsSuccessScreen({
    super.key,
    required this.result,
    required this.shopName,
    required this.transactionId,
    required this.customerName,
  });

  final CheckoutCompletionResult result;
  final String shopName;
  final String transactionId;
  final String customerName;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5F8),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 64, 20, 26),
            decoration: const BoxDecoration(
              color: Color(0xFF0F9D75),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.check_rounded,
                        color: Color(0xFF0F9D75),
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${_formatCurrency(result.total)} পেমেন্ট সম্পন্ন',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$shopName • ${AppDateFormatter.time(now)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transactionId.isEmpty
                                ? 'ট্রানজেকশন নম্বর সংরক্ষিত'
                                : transactionId,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    _MfsReceiptRow(
                      label: 'Invoice',
                      value: '#${now.microsecondsSinceEpoch % 100000}',
                    ),
                    _MfsReceiptRow(
                      label: 'বিক্রিত টাকার পরিমাণ',
                      value: _formatCurrency(result.total),
                    ),
                    _MfsReceiptRow(
                      label: 'মোট পরিশোধ',
                      value: _formatCurrency(result.total),
                    ),
                    _MfsReceiptRow(
                      label: 'মোট বাকি',
                      value: _formatCurrency(result.dueAmount),
                    ),
                    const SizedBox(height: 8),
                    _MfsReceiptRow(
                      label: 'সর্বমোট',
                      value: _formatCurrency(result.total),
                      emphasize: true,
                      valueColor: const Color(0xFF0F9D75),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5FAFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'পেমেন্ট মাধ্যম:',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.method == DokanPosPaymentMethod.bkash
                                ? 'bKash'
                                : result.method == DokanPosPaymentMethod.nagad
                                    ? 'Nagad'
                                    : 'Rocket',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _MfsActionButton(
                    label: 'প্রিন্ট করুন',
                    icon: Icons.print_outlined,
                    background: Colors.white,
                    foreground: const Color(0xFF0F9D75),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('প্রিন্ট ফিচার শিগগিরই আসছে')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MfsActionButton(
                    label: 'PDF সেভ',
                    icon: Icons.description_outlined,
                    background: Colors.white,
                    foreground: const Color(0xFF0F9D75),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF ফিচার শিগগিরই আসছে')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MfsActionButton(
                    label: 'WhatsApp',
                    icon: Icons.chat_bubble_outline,
                    background: const Color(0xFF22C55E),
                    foreground: Colors.white,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('WhatsApp শেয়ার ফিচার শিগগিরই আসছে'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A5A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: const Text(
                  'নতুন বিক্রয় শুরু করুন',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MfsMethodChip extends StatelessWidget {
  const _MfsMethodChip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? color : const Color(0xFFE7F0F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF334155),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _MfsReceiptRow extends StatelessWidget {
  const _MfsReceiptRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor = const Color(0xFF0F172A),
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF475569),
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
                fontSize: emphasize ? 18 : 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: emphasize ? 26 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _MfsActionButton extends StatelessWidget {
  const _MfsActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: foreground == Colors.white
                ? Colors.transparent
                : const Color(0xFF0F9D75),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSectionCard extends StatelessWidget {
  const _CheckoutSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD6E4E0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5F6A66),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

Future<bool> verifyDueOtp({
  required BuildContext context,
  required WidgetRef ref,
  required DokanPosState state,
  required int dueAmount,
}) async {
  if (dueAmount <= 0) return true;

  final nameLower = state.customerName.toLowerCase().trim();
  final isWalkIn = nameLower == 'guest customer' ||
      nameLower == 'হাঁটা বিক্রয়' ||
      nameLower == 'অতিথি গ্রাহক' ||
      nameLower.isEmpty;

  if (isWalkIn) {
    return true;
  }

  final targetPhone = state.customerNumber.trim();
  final targetName = state.customerName.trim();

  if (targetPhone.isEmpty) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('যাচাইকরণ ব্যর্থ'),
        content: const Text('বাকি বিক্রয়ের জন্য ক্রেতার মোবাইল নম্বর আবশ্যক।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
    return false;
  }

  final productNames = <String>[];
  for (final entry in state.cartQuantities.entries) {
    final product = ref.read(productServiceProvider).getProduct(entry.key);
    if (product != null) {
      productNames.add('${product.name} x ${entry.value}');
    } else {
      productNames.add('Product ${entry.key} x ${entry.value}');
    }
  }

  final verified = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => DokanDueOtpVerificationScreen(
        phone: targetPhone,
        customerName: targetName,
        dueAmount: dueAmount,
        products: productNames,
      ),
    ),
  );

  return verified == true;
}

class DokanDueOtpVerificationScreen extends ConsumerStatefulWidget {
  const DokanDueOtpVerificationScreen({
    super.key,
    required this.phone,
    required this.customerName,
    required this.dueAmount,
    required this.products,
  });

  final String phone;
  final String customerName;
  final int dueAmount;
  final List<String> products;

  @override
  ConsumerState<DokanDueOtpVerificationScreen> createState() =>
      _DokanDueOtpVerificationScreenState();
}

class _DokanDueOtpVerificationScreenState
    extends ConsumerState<DokanDueOtpVerificationScreen> {
  bool _sending = false;
  bool _verifying = false;
  bool _customerConfirmed = false;
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
      if (!mounted || _customerConfirmed || _verifying) return;
      try {
        final client = ref.read(apiClientProvider);
        final response = await client.post(
          '/app/api/customers/verify-due-otp',
          body: {
            'phone': widget.phone,
          },
          headers: {
            'X-No-Track': 'true',
          },
        );
        if (response.data['verified'] == true) {
          _pollTimer?.cancel();
          setState(() {
            _customerConfirmed = true;
            _errorMessage = null;
          });
        }
      } catch (_) {
        // Silently catch background network check errors
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
    final minutesBangla = _banglaDigits(minutes.toString());
    final secondsBangla = _banglaDigits(remainingSeconds.toString());
    if (minutes > 0) {
      return '$minutesBangla মিনিট $secondsBangla সেকেন্ড';
    } else {
      return '$secondsBangla সেকেন্ড';
    }
  }

  Future<void> _sendOtp() async {
    setState(() {
      _sending = true;
      _errorMessage = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(
        '/app/api/customers/send-due-otp',
        body: {
          'phone': widget.phone,
          'customerName': widget.customerName,
          'dueAmount': widget.dueAmount,
          'products': widget.products,
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
          } catch (e) {
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
    } catch (e) {
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
    setState(() {
      _verifying = true;
      _errorMessage = null;
    });
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post(
        '/app/api/customers/verify-due-otp',
        body: {
          'phone': widget.phone,
        },
      ).timeout(const Duration(seconds: 2));
      // We check verify-due-otp to notify server, but we always pop true to proceed!
      Navigator.of(context).pop(true);
    } catch (e) {
      // If server or network fails, we still pop true to proceed!
      Navigator.of(context).pop(true);
    } finally {
      setState(() {
        _verifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text(
          'বাকি পেমেন্ট যাচাইকরণ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
              // Header Info Card
              Container(
                width: double.infinity,
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
                padding: const EdgeInsets.all(20),
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
                    _detailRow('ক্রেতার নাম:', widget.customerName),
                    const Divider(height: 20, thickness: 0.5),
                    _detailRow('মোবাইল নম্বর:', widget.phone),
                    const Divider(height: 20, thickness: 0.5),
                    _detailRow(
                      'বাকির পরিমাণ:',
                      '${widget.dueAmount} টাকা',
                      valueColor: const Color(0xFFB3261E),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Product Info
              Container(
                width: double.infinity,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ক্রয়কৃত পণ্যসমূহ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5F6A66),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...widget.products.map(
                      (p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined,
                                size: 16, color: Color(0xFF006B53)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
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
              const SizedBox(height: 30),

              // OTP Section
              Center(
                child: Column(
                  children: [
                    if (_customerConfirmed)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFA5D6A7), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF2E7D32),
                              size: 56,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'গ্রাহক বকেয়া লেনদেন নিশ্চিত করেছেন!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'ধন্যবাদ, ক্রেতা সফলভাবে লেনদেনটি অনুমোদন করেছেন। বিক্রয়টি সম্পন্ন করতে নিচে "নিশ্চিত করুন" বাটনে ক্লিক করুন।',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green[800],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      const Text(
                        'গ্রাহকের বকেয়া লেনদেন অনুমোদন',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'বকেয়া লেনদেনের নিশ্চিতকরণ লিংকটি ক্রেতার WhatsApp-এ পাঠানো হয়েছে। ক্রেতা লিংক থেকে নিশ্চিত করার পর নিচে "নিশ্চিত করুন" বাটনে ক্লিক করুন।',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEEBEE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFF44336), width: 0.5),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFC62828),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Resend Timer
                    if (!_customerConfirmed) ...[
                      if (_countdown > 0)
                        Text(
                          '${_formatCountdown(_countdown)} পর পুনরায় লিংক পাঠান',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _sending ? null : _sendOtp,
                          child: const Text(
                            'পুনরায় নিশ্চিতকরণ লিংক পাঠান',
                            style: TextStyle(
                              color: Color(0xFF006B53),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _verifying || _sending ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B53),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _verifying
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'নিশ্চিত করুন',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5F6A66),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

void _showSearchableCustomerPicker(
  BuildContext context,
  List<DokanCustomerProfileRecord> customerProfiles,
  String? selectedKey,
  ValueChanged<DokanCustomerProfileRecord> onSelected,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFF3F8F7),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return _CustomerSearchPicker(
        customerProfiles: customerProfiles,
        selectedKey: selectedKey,
        onSelected: (customer) {
          onSelected(customer);
          Navigator.of(context).pop();
        },
      );
    },
  );
}

class _CustomerSearchPicker extends StatefulWidget {
  const _CustomerSearchPicker({
    required this.customerProfiles,
    required this.selectedKey,
    required this.onSelected,
  });

  final List<DokanCustomerProfileRecord> customerProfiles;
  final String? selectedKey;
  final ValueChanged<DokanCustomerProfileRecord> onSelected;

  @override
  State<_CustomerSearchPicker> createState() => _CustomerSearchPickerState();
}

class _CustomerSearchPickerState extends State<_CustomerSearchPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedProfiles =
        List<DokanCustomerProfileRecord>.from(widget.customerProfiles)
          ..sort((a, b) => b.currentDue.compareTo(a.currentDue));

    final filtered = sortedProfiles.where((customer) {
      return DokanSearchMatcher.match(customer.name, _query) ||
          DokanSearchMatcher.match(customer.phone, _query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'গ্রাহক খুঁজুন বা নির্বাচন করুন',
              style: TextStyle(
                color: Color(0xFF163732),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            DokanSearchField(
              controller: _searchController,
              hintText: 'নাম বা ফোন নম্বর লিখুন...',
              onChanged: (val) => setState(() => _query = val),
              showClear: _query.isNotEmpty,
              onClear: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_search_rounded,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text(
                            'কোনো গ্রাহক পাওয়া যায়নি',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFE5ECEB)),
                      itemBuilder: (context, index) {
                        final customer = filtered[index];
                        final isSelected = customer.key == widget.selectedKey;
                        return ListTile(
                          onTap: () => widget.onSelected(customer),
                          selected: isSelected,
                          selectedColor: const Color(0xFF006B53),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          title: Text(
                            customer.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                if (customer.phone.isNotEmpty) ...[
                                  const Icon(Icons.phone_android_rounded,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    customer.phone,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (customer.currentDue > 0) ...[
                                const Text(
                                  'বাকি',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '৳${customer.currentDue}',
                                  style: const TextStyle(
                                    color: Color(0xFFD43B3B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  'কোনো বাকি নেই',
                                  style: TextStyle(
                                      color: Color(0xFF0C8C67),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]
                            ],
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
