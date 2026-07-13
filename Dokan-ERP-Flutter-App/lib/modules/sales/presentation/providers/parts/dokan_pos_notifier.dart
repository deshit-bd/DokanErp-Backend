part of '../cart_provider.dart';

class DokanPosNotifier extends Notifier<DokanPosState> {
  static List<DokanPosOrderRecord> _seedOrders() {
    final now = DateTime.now();
    final todayMorning = DateTime(now.year, now.month, now.day, 9, 44);
    final yesterdayEvening = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1))
        .add(const Duration(hours: 18, minutes: 20));

    return <DokanPosOrderRecord>[
      DokanPosOrderRecord(
        id: 'seed-paid-1',
        customerName: 'আসিফ রহমান',
        customerNumber: '01912334455',
        totalAmount: 8421,
        paidAmount: 8421,
        dueAmount: 0,
        paymentMethod: DokanPosPaymentMethod.cash,
        status: DokanPosOrderStatus.paid,
        summary: 'সম্পূর্ণ পরিশোধিত অর্ডার',
        createdAt: todayMorning,
        salesmanPhone: '01711223344',
      ),
      DokanPosOrderRecord(
        id: 'seed-partial-1',
        customerName: 'রফিকুল ইসলাম',
        customerNumber: '01700000000',
        totalAmount: 1230,
        paidAmount: 845,
        dueAmount: 385,
        paymentMethod: DokanPosPaymentMethod.cash,
        status: DokanPosOrderStatus.partiallyPaid,
        summary: 'আংশিক পরিশোধিত অর্ডার',
        createdAt: todayMorning.subtract(const Duration(hours: 1, minutes: 5)),
        salesmanPhone: '01711223344',
      ),
      DokanPosOrderRecord(
        id: 'seed-due-1',
        customerName: 'করিম মিয়া',
        customerNumber: '01800000000',
        totalAmount: 675,
        paidAmount: 0,
        dueAmount: 675,
        paymentMethod: DokanPosPaymentMethod.cash,
        status: DokanPosOrderStatus.due,
        summary: 'বাকি অর্ডার',
        createdAt: yesterdayEvening,
      ),
    ];
  }

  static String _stateSnapshotJson(DokanPosState state) {
    return jsonEncode(
      <String, dynamic>{
        'version': 2,
        'orders':
            state.orders.map((order) => order.toJson()).toList(growable: false),
        'customers': state.customerProfiles
            .map(
              (item) => <String, dynamic>{
                'id': item.id,
                'key': item.key,
                'name': item.name,
                'phone': item.phone,
                'address': item.address,
                'openingDue': item.openingDue,
                'totalSales': item.totalSales,
                'totalPaid': item.totalPaid,
                'currentDue': item.currentDue,
                'createdAt': item.createdAt.millisecondsSinceEpoch,
                'updatedAt': item.updatedAt.millisecondsSinceEpoch,
              },
            )
            .toList(growable: false),
        'suppliers': state.supplierProfiles
            .map(
              (item) => <String, dynamic>{
                'key': item.key,
                'name': item.name,
                'phone': item.phone,
                'address': item.address,
                'productType': item.productType,
                'creditLimit': item.creditLimit,
                'createdAt': item.createdAt.millisecondsSinceEpoch,
                'updatedAt': item.updatedAt.millisecondsSinceEpoch,
              },
            )
            .toList(growable: false),
        'supplierLedger': state.supplierLedger
            .map(
              (item) => <String, dynamic>{
                'id': item.id,
                'supplierKey': item.supplierKey,
                'supplierName': item.supplierName,
                'amount': item.amount,
                'kind': item.kind.name,
                'createdAt': item.createdAt.millisecondsSinceEpoch,
                'note': item.note,
                'paymentMethod': item.paymentMethod?.name,
              },
            )
            .toList(growable: false),
        'staff': state.staffProfiles
            .map(
              (item) => <String, dynamic>{
                'key': item.key,
                'name': item.name,
                'phone': item.phone,
                'role': item.role,
                'address': item.address,
                'note': item.note,
                'active': item.active,
                'joinedAt': item.joinedAt.millisecondsSinceEpoch,
                'lastActiveAt': item.lastActiveAt.millisecondsSinceEpoch,
                'lastLoginAt': item.lastLoginAt.millisecondsSinceEpoch,
                'recentSalesCount': item.recentSalesCount,
                'permissions': item.permissions,
                'pinCode': item.pinCode,
                'createdAt': item.createdAt.millisecondsSinceEpoch,
                'updatedAt': item.updatedAt.millisecondsSinceEpoch,
              },
            )
            .toList(growable: false),
        'hiddenCustomerKeys': state.hiddenCustomerKeys.toList(growable: false),
        'hiddenSupplierKeys': state.hiddenSupplierKeys.toList(growable: false),
        'hiddenStaffKeys': state.hiddenStaffKeys.toList(growable: false),
      },
    );
  }

  static List<DokanPosOrderRecord> _ordersFromSnapshot(String snapshotJson) {
    try {
      final decoded = jsonDecode(snapshotJson);
      if (decoded is! Map<String, dynamic>) {
        return const <DokanPosOrderRecord>[];
      }
      final ordersJson = decoded['orders'];
      if (ordersJson is! List) {
        return const <DokanPosOrderRecord>[];
      }
      return ordersJson
          .whereType<Map>()
          .map(
            (item) => DokanPosOrderRecord.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const <DokanPosOrderRecord>[];
    }
  }

  static Map<String, dynamic> _snapshotMap(String snapshotJson) {
    try {
      final decoded = jsonDecode(snapshotJson);
      return decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  static int _epoch(Object? value) => (value as num?)?.toInt() ?? 0;

  static List<DokanCustomerProfileRecord> _customersFromSnapshot(
    Map<String, dynamic> snapshot,
  ) {
    return (snapshot['customers'] as List?)?.whereType<Map>().map(
          (raw) {
            final item = raw.map((key, value) => MapEntry('$key', value));
            return DokanCustomerProfileRecord(
              id: item['id'] as String?,
              key: item['key'] as String? ?? '',
              name: item['name'] as String? ?? '',
              phone: item['phone'] as String? ?? '',
              address: item['address'] as String? ?? '',
              openingDue: (item['openingDue'] as num?)?.toInt() ?? 0,
              totalSales: (item['totalSales'] as num?)?.toInt() ?? 0,
              totalPaid: (item['totalPaid'] as num?)?.toInt() ?? 0,
              currentDue: (item['currentDue'] as num?)?.toInt() ?? 0,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  _epoch(item['createdAt'])),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                  _epoch(item['updatedAt'])),
            );
          },
        ).toList(growable: false) ??
        const <DokanCustomerProfileRecord>[];
  }

  static List<DokanSupplierProfileRecord> _suppliersFromSnapshot(
    Map<String, dynamic> snapshot,
  ) {
    return (snapshot['suppliers'] as List?)?.whereType<Map>().map(
          (raw) {
            final item = raw.map((key, value) => MapEntry('$key', value));
            return DokanSupplierProfileRecord(
              key: item['key'] as String? ?? '',
              name: item['name'] as String? ?? '',
              phone: item['phone'] as String? ?? '',
              address: item['address'] as String? ?? '',
              productType: item['productType'] as String? ?? '',
              creditLimit: (item['creditLimit'] as num?)?.toInt() ?? 0,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  _epoch(item['createdAt'])),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                  _epoch(item['updatedAt'])),
            );
          },
        ).toList(growable: false) ??
        const <DokanSupplierProfileRecord>[];
  }

  static List<DokanSupplierLedgerRecord> _supplierLedgerFromSnapshot(
    Map<String, dynamic> snapshot,
  ) {
    return (snapshot['supplierLedger'] as List?)?.whereType<Map>().map(
          (raw) {
            final item = raw.map((key, value) => MapEntry('$key', value));
            return DokanSupplierLedgerRecord(
              id: item['id'] as String? ?? '',
              supplierKey: item['supplierKey'] as String? ?? '',
              supplierName: item['supplierName'] as String? ?? '',
              amount: (item['amount'] as num?)?.toInt() ?? 0,
              kind: item['kind'] == 'payment'
                  ? DokanSupplierLedgerKind.payment
                  : item['kind'] == 'setup'
                      ? DokanSupplierLedgerKind.setup
                      : DokanSupplierLedgerKind.purchase,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  _epoch(item['createdAt'])),
              note: item['note'] as String? ?? '',
              paymentMethod: item['paymentMethod'] == null
                  ? null
                  : _dokanPosPaymentMethodFromName(
                      item['paymentMethod'] as String?,
                    ),
            );
          },
        ).toList(growable: false) ??
        const <DokanSupplierLedgerRecord>[];
  }

  static List<DokanStaffProfileRecord> _staffFromSnapshot(
    Map<String, dynamic> snapshot,
  ) {
    return (snapshot['staff'] as List?)?.whereType<Map>().map(
          (raw) {
            final item = raw.map((key, value) => MapEntry('$key', value));
            return DokanStaffProfileRecord(
              key: item['key'] as String? ?? '',
              name: item['name'] as String? ?? '',
              phone: item['phone'] as String? ?? '',
              role: item['role'] as String? ?? '',
              address: item['address'] as String? ?? '',
              note: item['note'] as String? ?? '',
              active: item['active'] as bool? ?? true,
              joinedAt:
                  DateTime.fromMillisecondsSinceEpoch(_epoch(item['joinedAt'])),
              lastActiveAt: DateTime.fromMillisecondsSinceEpoch(
                _epoch(item['lastActiveAt']),
              ),
              lastLoginAt: DateTime.fromMillisecondsSinceEpoch(
                _epoch(item['lastLoginAt']),
              ),
              recentSalesCount:
                  (item['recentSalesCount'] as num?)?.toInt() ?? 0,
              permissions: (item['permissions'] as List?)
                      ?.whereType<String>()
                      .toList(growable: false) ??
                  const <String>[],
              pinCode: item['pinCode'] as String?,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  _epoch(item['createdAt'])),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                  _epoch(item['updatedAt'])),
            );
          },
        ).toList(growable: false) ??
        const <DokanStaffProfileRecord>[];
  }

  static Set<String> _stringSet(Map<String, dynamic> snapshot, String key) {
    return (snapshot[key] as List?)?.whereType<String>().toSet() ?? <String>{};
  }

  static List<DokanPosOrderRecord> _dedupeOrders(
    List<DokanPosOrderRecord> orders,
  ) {
    if (orders.length < 2) {
      return List<DokanPosOrderRecord>.unmodifiable(orders);
    }

    final deduped = <DokanPosOrderRecord>[];
    for (final order in orders) {
      final isDuplicate =
          deduped.isNotEmpty && _isNearDuplicateOrder(deduped.last, order);
      if (!isDuplicate) {
        deduped.add(order);
      }
    }
    return List<DokanPosOrderRecord>.unmodifiable(deduped);
  }

  static bool _isNearDuplicateOrder(
    DokanPosOrderRecord previous,
    DokanPosOrderRecord current,
  ) {
    return previous.customerName == current.customerName &&
        previous.customerNumber == current.customerNumber &&
        previous.totalAmount == current.totalAmount &&
        previous.paidAmount == current.paidAmount &&
        previous.dueAmount == current.dueAmount &&
        previous.paymentMethod == current.paymentMethod &&
        previous.status == current.status &&
        previous.summary == current.summary &&
        current.createdAt.difference(previous.createdAt).abs() <=
            const Duration(seconds: 3);
  }

  static List<DokanSupplierProfileRecord> _seedSuppliers() {
    final now = DateTime.now();
    final key = dokanSupplierRecordKey('ঢাকা সাপ্লাই', '');
    return <DokanSupplierProfileRecord>[
      DokanSupplierProfileRecord(
        key: key,
        name: 'ঢাকা সাপ্লাই',
        phone: '',
        address: '',
        productType: 'মুদিখানা',
        creditLimit: 0,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<DokanSupplierLedgerRecord> _seedSupplierLedger() {
    final now = DateTime.now();
    final key = dokanSupplierRecordKey('ঢাকা সাপ্লাই', '');
    return <DokanSupplierLedgerRecord>[
      DokanSupplierLedgerRecord(
        id: 'supplier-ledger-001',
        supplierKey: key,
        supplierName: 'ঢাকা সাপ্লাই',
        amount: 7800,
        kind: DokanSupplierLedgerKind.purchase,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        note: 'পূর্বের বকেয়া',
        paymentMethod: DokanPosPaymentMethod.cash,
      ),
    ];
  }

  static List<DokanStaffProfileRecord> _seedStaffProfiles() {
    final now = DateTime.now();
    return <DokanStaffProfileRecord>[
      DokanStaffProfileRecord(
        key: 'staff-sohel',
        name: 'সোহেল আহমেদ',
        phone: '01711223344',
        role: 'Salesman',
        address: 'ঢাকা',
        note: 'বিক্রয় সহকারী',
        active: true,
        joinedAt: now.subtract(const Duration(days: 120)),
        lastActiveAt: now.subtract(const Duration(minutes: 12)),
        lastLoginAt: now.subtract(const Duration(hours: 2)),
        recentSalesCount: 18,
        permissions: <String>[
          'sales.create',
          'sales.view',
          'customer.view',
        ],
        pinCode: '1234',
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      DokanStaffProfileRecord(
        key: 'staff-ripon',
        name: 'রিপন হোসেন',
        phone: '01833445566',
        role: 'Cashier',
        address: 'চট্টগ্রাম',
        note: 'ক্যাশিয়ার',
        active: true,
        joinedAt: now.subtract(const Duration(days: 90)),
        lastActiveAt: now.subtract(const Duration(minutes: 48)),
        lastLoginAt: now.subtract(const Duration(days: 1, hours: 3)),
        recentSalesCount: 9,
        permissions: <String>[
          'sales.view',
          'accounts.view',
          'reports.view',
        ],
        pinCode: '2468',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      DokanStaffProfileRecord(
        key: 'staff-nadia',
        name: 'নাদিয়া আক্তার',
        phone: '01999887766',
        role: 'Manager',
        address: 'নারায়ণগঞ্জ',
        note: 'দোকান ব্যবস্থাপক',
        active: false,
        joinedAt: now.subtract(const Duration(days: 210)),
        lastActiveAt: now.subtract(const Duration(days: 7)),
        lastLoginAt: now.subtract(const Duration(days: 3, hours: 5)),
        recentSalesCount: 0,
        permissions: <String>[
          'staff.manage',
          'supplier.view',
          'reports.view',
          'accounts.view',
        ],
        pinCode: '1357',
        createdAt: now.subtract(const Duration(days: 210)),
        updatedAt: now.subtract(const Duration(days: 3, hours: 5)),
      ),
    ];
  }

  bool _disposed = false;

  @override
  DokanPosState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });
    ref.watch(dokanAppFlowProvider);
    unawaited(_hydrateSalesHistory());
    unawaited(fetchTaxesAndCharges());
    return DokanPosState(
      orders: const <DokanPosOrderRecord>[],
      supplierProfiles: const <DokanSupplierProfileRecord>[],
      supplierLedger: const <DokanSupplierLedgerRecord>[],
      staffProfiles: const <DokanStaffProfileRecord>[],
      subtotalSnapshot: _calculateSubtotal(const <String, int>{}),
    );
  }

  Future<void> _hydrateSalesHistory() async {
    if (_disposed) return;
    final storage = ref.read(salesHistoryRepositoryProvider);
    final snapshotJson = await storage.readSnapshot();
    if (_disposed) return;
    await _loadCartFromPrefs();
    if (_disposed) return;

    if (snapshotJson == null || snapshotJson.trim().isEmpty) {
      const bootstrapOrders = <DokanPosOrderRecord>[];
      state = state.copyWith(orders: _dedupeOrders(bootstrapOrders));
      await storage.writeSnapshot(_stateSnapshotJson(state));
      if (_disposed) return;
      unawaited(fetchCustomers());
      unawaited(fetchSuppliers());
      ref.read(dokanSalesHistoryReadyProvider.notifier).state = true;
      return;
    }

    final restoredOrders = _ordersFromSnapshot(snapshotJson);
    if (restoredOrders.isEmpty) {
      const bootstrapOrders = <DokanPosOrderRecord>[];
      state = state.copyWith(orders: _dedupeOrders(bootstrapOrders));
      await storage.writeSnapshot(_stateSnapshotJson(state));
      if (_disposed) return;
      unawaited(fetchCustomers());
      unawaited(fetchSuppliers());
      ref.read(dokanSalesHistoryReadyProvider.notifier).state = true;
      return;
    }

    final repairedOrders =
        restoredOrders.map(_repairSeedOrderRecord).toList(growable: false);
    final dedupedOrders = _dedupeOrders(repairedOrders);
    final snapshot = _snapshotMap(snapshotJson);
    final customers = _customersFromSnapshot(snapshot);
    final suppliers = _suppliersFromSnapshot(snapshot);
    final supplierLedger = _supplierLedgerFromSnapshot(snapshot);
    final staff = _staffFromSnapshot(snapshot);
    state = state.copyWith(
      orders: dedupedOrders,
      customerProfiles: customers.isEmpty ? state.customerProfiles : customers,
      supplierProfiles: suppliers.isEmpty ? state.supplierProfiles : suppliers,
      supplierLedger:
          supplierLedger.isEmpty ? state.supplierLedger : supplierLedger,
      staffProfiles: staff.isEmpty ? state.staffProfiles : staff,
      hiddenCustomerKeys: _stringSet(snapshot, 'hiddenCustomerKeys'),
      hiddenSupplierKeys: _stringSet(snapshot, 'hiddenSupplierKeys'),
      hiddenStaffKeys: _stringSet(snapshot, 'hiddenStaffKeys'),
    );
    if (!listEquals(restoredOrders, dedupedOrders)) {
      await storage.writeSnapshot(_stateSnapshotJson(state));
    }
    if (_disposed) return;
    unawaited(fetchCustomers());
    unawaited(fetchSuppliers());
    unawaited(fetchStaff());
    ref.read(dokanSalesHistoryReadyProvider.notifier).state = true;
  }

  static DokanPosOrderRecord _repairSeedOrderRecord(DokanPosOrderRecord order) {
    return switch (order.id) {
      'seed-paid-1' => order.copyWith(
          customerName: 'আসিফ রহমান',
          summary: 'সম্পূর্ণ পরিশোধিত অর্ডার',
        ),
      'seed-partial-1' => order.copyWith(
          customerName: 'রফিকুল ইসলাম',
          summary: 'আংশিক পরিশোধিত অর্ডার',
        ),
      'seed-due-1' => order.copyWith(
          customerName: 'করিম মিয়া',
          summary: 'বাকি অর্ডার',
        ),
      _ => order,
    };
  }

  Future<void> _persistSalesHistory() async {
    if (_disposed) return;
    await ref
        .read(salesHistoryRepositoryProvider)
        .writeSnapshot(_stateSnapshotJson(state));
  }

  int _calculateSubtotal(Map<String, int> cartQuantities) {
    final inventorySettings =
        ref.read(inventorySettingsProvider).asData?.value ??
            const InventorySettings();
    return ref.read(productServiceProvider).subtotalForCart(
          cartQuantities,
          stockMethod: inventorySettings.costingMethod,
        );
  }

  void _syncSubtotal() {
    final newSubtotal = _calculateSubtotal(state.cartQuantities);
    state = state.copyWith(
      subtotalSnapshot: newSubtotal,
    );
    state = state.copyWith(
      cashReceived: state.paymentMethod == DokanPosPaymentMethod.cash ? state.total : 0,
      creditDueAmount: state.paymentMethod == DokanPosPaymentMethod.due ? state.total : 0,
    );
    unawaited(_saveCartToPrefs(state.cartQuantities));
  }

  String _cartStorageKey() {
    final flow = ref.read(dokanAppFlowProvider);
    final userPhone = flow.isSalesman ? (flow.currentSalesmanPhone ?? '') : flow.ownerPhone;
    final shopId = flow.shopId;
    return 'dokan_pos_cart_${shopId}_$userPhone';
  }

  Future<void> _saveCartToPrefs(Map<String, int> cartQuantities) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cartStorageKey();
      final jsonStr = jsonEncode(cartQuantities);
      await prefs.setString(key, jsonStr);
    } catch (_) {}
  }

  Future<void> _loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cartStorageKey();
      final jsonStr = prefs.getString(key);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        final cartQuantities = decoded.map((key, value) => MapEntry(key, value as int));
        state = state.copyWith(
          cartQuantities: cartQuantities,
          selectedProductIds: cartQuantities.keys.toSet(),
          subtotalSnapshot: _calculateSubtotal(cartQuantities),
        );
      }
    } catch (_) {}
  }

  void addItem(String productId, {int stockLimit = 9999}) {
    final current = state.cartQuantities[productId] ?? 0;
    setItemQuantity(
      productId,
      current + 1,
      stockLimit: stockLimit,
    );
  }

  void removeItem(String productId) {
    final current = state.cartQuantities[productId] ?? 0;
    setItemQuantity(productId, current - 1);
  }

  void toggleItemSelection(String productId, {int stockLimit = 9999}) {
    final current = state.cartQuantities[productId] ?? 0;
    if (current > 0) {
      setItemQuantity(productId, 0);
      return;
    }
    setItemQuantity(productId, 1, stockLimit: stockLimit);
  }

  void setItemQuantity(
    String productId,
    int quantity, {
    int stockLimit = 9999,
  }) {
    final normalizedQuantity = math.max(0, quantity);
    final clampedQuantity = math.min(normalizedQuantity, stockLimit);
    final nextCart = Map<String, int>.from(state.cartQuantities);
    final nextSelected = Set<String>.from(state.selectedProductIds);

    if (clampedQuantity <= 0) {
      nextCart.remove(productId);
      nextSelected.remove(productId);
    } else {
      nextCart[productId] = clampedQuantity;
      nextSelected.add(productId);
    }

    state = state.copyWith(
      cartQuantities: nextCart,
      selectedProductIds: nextSelected,
    );
    _syncSubtotal();
  }

  void setDiscount(String value) {
    final parsed = int.tryParse(value.trim()) ?? 0;
    state = state.copyWith(discount: math.max(0, parsed));
    state = state.copyWith(
      cashReceived: state.paymentMethod == DokanPosPaymentMethod.cash ? state.total : 0,
      creditDueAmount: state.paymentMethod == DokanPosPaymentMethod.due ? state.total : 0,
    );
  }

  void setTaxPercent(String value) {
    final parsed = int.tryParse(value.trim()) ?? 0;
    state = state.copyWith(taxPercent: math.max(0, parsed));
    state = state.copyWith(
      cashReceived: state.paymentMethod == DokanPosPaymentMethod.cash ? state.total : 0,
      creditDueAmount: state.paymentMethod == DokanPosPaymentMethod.due ? state.total : 0,
    );
  }

  void setPaymentMethod(DokanPosPaymentMethod method) {
    const keepIdentityFields = true;

    final int defaultCashReceived = method == DokanPosPaymentMethod.cash
        ? state.total
        : 0;

    final int defaultCreditDueAmount = method == DokanPosPaymentMethod.due
        ? state.total
        : 0;

    state = state.copyWith(
      paymentMethod: method,
      customerName: keepIdentityFields ? state.customerName : '',
      customerNumber: keepIdentityFields ? state.customerNumber : '',
      transactionId: method == DokanPosPaymentMethod.cash ||
              method == DokanPosPaymentMethod.due ||
              !keepIdentityFields
          ? ''
          : state.transactionId,
      cashReceived: defaultCashReceived,
      creditDueAmount: defaultCreditDueAmount,
    );
  }

  void setCustomerName(String value) {
    state = state.copyWith(customerName: value);
  }

  void setCustomerNumber(String value) {
    state = state.copyWith(customerNumber: value);
  }

  void setTransactionId(String value) {
    state = state.copyWith(transactionId: value);
  }

  void setCardHolderName(String value) {
    state = state.copyWith(cardHolderName: value);
  }

  void setCardLast4(String value) {
    state = state.copyWith(cardLast4: value);
  }

  void setCardApprovalCode(String value) {
    state = state.copyWith(cardApprovalCode: value);
  }

  void setCardBankName(String value) {
    state = state.copyWith(cardBankName: value);
  }

  void setBankSenderName(String value) {
    state = state.copyWith(bankSenderName: value);
  }

  void setBankName(String value) {
    state = state.copyWith(bankName: value);
  }

  void setBankAccountNumber(String value) {
    state = state.copyWith(bankAccountNumber: value);
  }

  void setBankReferenceNumber(String value) {
    state = state.copyWith(bankReferenceNumber: value);
  }

  void setBankRoutingNumber(String value) {
    state = state.copyWith(bankRoutingNumber: value);
  }

  void setCashReceived(String value) {
    final trimmed = value.trim();
    final parsed = trimmed.isEmpty ? 0 : int.tryParse(trimmed) ?? -1;
    state = state.copyWith(cashReceived: math.max(0, parsed));
  }

  void setCreditDueAmount(String value) {
    final trimmed = value.trim();
    final parsed = trimmed.isEmpty ? 0 : int.tryParse(trimmed) ?? -1;
    state = state.copyWith(creditDueAmount: math.max(0, parsed));
  }

  void addDueRecord(DokanPosDueRecord record) {
    addOrder(
      DokanPosOrderRecord(
        id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
        customerName: record.name,
        customerNumber: record.number,
        totalAmount: record.amount,
        paidAmount: 0,
        dueAmount: record.amount,
        paymentMethod: DokanPosPaymentMethod.cash,
        status: DokanPosOrderStatus.due,
        summary: 'নতুন বাকি অর্ডার',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> collectDuePayment({
    required String customerKey,
    required int amount,
    DateTime? collectedAt,
    String reference = '',
    DokanPosPaymentMethod paymentMethod = DokanPosPaymentMethod.cash,
    Map<String, dynamic>? paymentDetails,
  }) async {
    if (amount <= 0) {
      return;
    }

    final String cleanKey = customerKey;
    final String cleanPhone = cleanKey.startsWith('num:')
        ? cleanKey.substring(4).trim()
        : (cleanKey.startsWith('name:')
            ? ''
            : (RegExp(r'^\d+$').hasMatch(cleanKey) ? cleanKey.trim() : ''));
    final String cleanName = cleanKey.startsWith('name:')
        ? cleanKey.substring(5).trim()
        : (cleanKey.startsWith('num:')
            ? ''
            : (RegExp(r'^\d+$').hasMatch(cleanKey) ? '' : cleanKey.trim()));

    final profile = state.customerProfiles.firstWhere(
      (p) {
        if (p.key == cleanKey || p.id == cleanKey) return true;
        if (cleanPhone.isNotEmpty &&
            (p.phone.trim() == cleanPhone || p.key == cleanPhone)) return true;
        if (cleanName.isNotEmpty &&
            (p.name.trim() == cleanName || p.key == cleanName)) return true;
        return false;
      },
      orElse: () => DokanCustomerProfileRecord(
        key: customerKey,
        name: cleanName.isNotEmpty ? cleanName : '',
        phone: cleanPhone.isNotEmpty ? cleanPhone : '',
        address: '',
        openingDue: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final repository = ref.read(customerRepositoryProvider);
    if (repository != null) {
      final customerId = (profile.id != null && profile.id!.isNotEmpty)
          ? profile.id!
          : customerKey;
      final shopId = _currentShopId;
      final isLocalOnlyCustomer = customerId.startsWith('manual-') ||
          _isGuestCustomerToken(customerId) ||
          _isGuestCustomerToken(profile.key) ||
          _isGuestCustomerToken(profile.id ?? '') ||
          _isGuestCustomerToken(profile.name);
      if (shopId != null && customerId.isNotEmpty && !isLocalOnlyCustomer) {
        String apiPaymentMethod = 'CASH';
        if (paymentMethod == DokanPosPaymentMethod.bkash) {
          apiPaymentMethod = 'BKASH';
        } else if (paymentMethod == DokanPosPaymentMethod.nagad) {
          apiPaymentMethod = 'NAGAD';
        } else if (paymentMethod == DokanPosPaymentMethod.rocket) {
          apiPaymentMethod = 'ROCKET';
        } else if (paymentMethod == DokanPosPaymentMethod.card) {
          apiPaymentMethod = 'CARD';
        }
        var remoteSynced = false;
        try {
          await repository.collectDuePayment(
            customerId: customerId,
            amount: amount,
            shopId: shopId,
            paidAt: collectedAt,
            notes: reference,
            paymentMethod: apiPaymentMethod,
            paymentDetails: paymentDetails,
          );
          remoteSynced = true;
        } on NetworkException catch (error) {
          final canContinueLocally = error.isRetryable ||
              error.kind == NetworkExceptionKind.validation ||
              error.kind == NetworkExceptionKind.notFound;
          if (!canContinueLocally) {
            rethrow;
          }
        }
        if (remoteSynced) {
          ref.invalidate(salesHistoryOrdersProvider);
          try {
            await ref.read(salesHistoryOrdersProvider.future);
          } catch (_) {}
          ref.invalidate(customerPaymentsProvider(customerId));
        }
      }
    }

    final paymentTime = collectedAt ?? DateTime.now();
    var remaining = amount;
    final profilePhone = profile.phone.trim();
    final profileName = profile.name.trim();
    final profileLooksGuest = _isGuestCustomerToken(customerKey) ||
        _isGuestCustomerToken(profile.key) ||
        _isGuestCustomerToken(profile.id ?? '') ||
        _isGuestCustomerToken(profile.name) ||
        _isGuestCustomerToken(cleanName);

    final updatedOrders = state.orders.map((order) {
      final orderPhone = order.customerNumber.trim();
      final orderName = order.customerName.trim();

      bool isMatch = false;
      if (profileLooksGuest && _isGuestDueOrder(order)) {
        isMatch = true;
      } else if (profilePhone.isNotEmpty && orderPhone == profilePhone) {
        isMatch = true;
      } else if (profileName.isNotEmpty && orderName == profileName) {
        isMatch = true;
      } else {
        final key = _dueCustomerKey(order);
        isMatch = key == customerKey ||
            key == 'num:$customerKey' ||
            key == 'name:$customerKey';
      }

      if (remaining <= 0 || !isMatch || order.dueAmount <= 0) {
        return order;
      }

      final payNow = math.min(remaining, order.dueAmount);
      remaining -= payNow;
      final nextDue = order.dueAmount - payNow;
      final nextPaid = order.paidAmount + payNow;
      return order.copyWith(
        paidAmount: nextPaid,
        dueAmount: nextDue,
        status: nextDue <= 0
            ? DokanPosOrderStatus.paid
            : nextPaid > 0
                ? DokanPosOrderStatus.partiallyPaid
                : DokanPosOrderStatus.due,
        summary: nextDue <= 0
            ? '${order.summary} | বাকি পরিশোধ সম্পন্ন'
            : '${order.summary} | আংশিক বাকি পরিশোধ',
        paymentHistory: <DokanOrderPayment>[
          ...order.paymentHistory,
          DokanOrderPayment(
            id: 'due-payment-${paymentTime.microsecondsSinceEpoch}',
            amount: payNow,
            method: paymentMethod,
            createdAt: paymentTime,
            reference: reference,
          ),
        ],
      );
    }).toList(growable: false);

    bool profileFound = false;
    final updatedProfiles = state.customerProfiles.map((p) {
      bool isMatch = false;
      if (p.key == cleanKey || p.id == cleanKey) {
        isMatch = true;
      } else if (cleanPhone.isNotEmpty &&
          (p.phone.trim() == cleanPhone || p.key == cleanPhone)) {
        isMatch = true;
      } else if (cleanName.isNotEmpty &&
          (p.name.trim() == cleanName || p.key == cleanName)) {
        isMatch = true;
      }

      if (isMatch) {
        profileFound = true;
        final nextDue = math.max(0, p.currentDue - amount);
        final nextPaid = p.totalPaid + amount;
        return p.copyWith(
          currentDue: nextDue,
          totalPaid: nextPaid,
          updatedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();

    if (!profileFound) {
      final nextDue = math.max(0, profile.currentDue - amount);
      final nextPaid = profile.totalPaid + amount;
      updatedProfiles.add(profile.copyWith(
        currentDue: nextDue,
        totalPaid: nextPaid,
        updatedAt: DateTime.now(),
      ));
    }

    state = state.copyWith(
      orders: updatedOrders,
      customerProfiles:
          List<DokanCustomerProfileRecord>.unmodifiable(updatedProfiles),
    );
    await _persistSalesHistory();
  }

  static String _dueCustomerKey(DokanPosOrderRecord order) {
    final number = order.customerNumber.trim();
    if (number.isNotEmpty) {
      return 'num:$number';
    }
    final name = order.customerName.trim();
    return name.isEmpty ? 'unknown' : 'name:$name';
  }

  static bool _isGuestCustomerToken(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(' ', '_');
    return normalized == 'unknown' ||
        normalized == 'guest_customer' ||
        normalized == 'guest_customer_unified_key' ||
        normalized == 'হাঁটা_বিক্রয়' ||
        normalized == 'অতিথি_গ্রাহক';
  }

  static bool _isGuestDueOrder(DokanPosOrderRecord order) {
    return order.customerNumber.trim().isEmpty &&
        (order.customerName.trim().isEmpty ||
            _isGuestCustomerToken(order.customerName));
  }

  void addCustomerDueAmount({
    required String customerName,
    required String customerNumber,
    required int amount,
  }) {
    if (amount <= 0) {
      return;
    }
    addDueRecord(
      DokanPosDueRecord(
        name: customerName,
        number: customerNumber,
        amount: amount,
      ),
    );
  }

  Future<void> fetchCustomers() async {
    if (_disposed) return;
    final repository = ref.read(customerRepositoryProvider);
    if (repository == null) return;
    try {
      final customers = await repository.list(shopId: _currentShopId);
      if (_disposed) return;
      final filteredCustomers = customers.where((c) {
        final nameLower = c.name.toLowerCase().trim();
        return nameLower != 'guest customer' &&
            nameLower != 'হাঁটা বিক্রয়' &&
            nameLower != 'অতিথি গ্রাহক';
      }).toList();
      final profiles =
          filteredCustomers.map(_customerProfile).toList(growable: false);
      state = state.copyWith(
        customerProfiles:
            List<DokanCustomerProfileRecord>.unmodifiable(profiles),
      );
      await _persistSalesHistory();
    } catch (e) {
      debugPrint('[DokanPosNotifier] Failed to fetch customers: $e');
    }
  }

  Future<void> fetchStaff() async {
    if (_disposed) return;
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/app/api/staff');
      if (_disposed) return;
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final staffList = data['staff'] as List? ?? [];
        final profiles = <DokanStaffProfileRecord>[];
        for (final item in staffList) {
          if (item is! Map<String, dynamic>) continue;
          final permissionsObj = item['permissions'] as Map? ?? {};
          final permissionsList = <String>[];
          if (permissionsObj['canSell'] == true) permissionsList.add('sales.sell');
          if (permissionsObj['canViewStock'] == true) permissionsList.add('inventory.view');
          if (permissionsObj['canViewReports'] == true) permissionsList.add('reports.view');
          if (permissionsObj['canChangePrice'] == true) permissionsList.add('sales.changePrice');
          if (permissionsObj['canCollectDue'] == true) permissionsList.add('sales.collectDue');

          final statusStr = item['status'] as String? ?? 'ACTIVE';
          final isActive = statusStr == 'ACTIVE';

          final joinedAtStr = item['joinedAt'] as String?;
          final lastLoginAtStr = item['lastLoginAt'] as String?;

          profiles.add(
            DokanStaffProfileRecord(
              key: item['mobile'] as String? ?? item['id'] as String,
              name: item['name'] as String? ?? '',
              phone: item['mobile'] as String? ?? '',
              role: 'SALESMAN',
              address: item['id'] as String? ?? '',
              note: '',
              active: isActive,
              joinedAt: joinedAtStr != null ? DateTime.tryParse(joinedAtStr) ?? DateTime.now() : DateTime.now(),
              lastActiveAt: DateTime.now(),
              lastLoginAt: lastLoginAtStr != null ? DateTime.tryParse(lastLoginAtStr) ?? DateTime.now() : DateTime.now(),
              recentSalesCount: 0,
              permissions: List<String>.unmodifiable(permissionsList),
              pinCode: null,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
        if (_disposed) return;
        state = state.copyWith(
          staffProfiles: List<DokanStaffProfileRecord>.unmodifiable(profiles),
        );
        await _persistSalesHistory();
      }
    } catch (e) {
      debugPrint('[DokanPosNotifier] Failed to fetch staff: $e');
    }
  }

  Future<void> fetchTaxesAndCharges() async {
    if (_disposed) return;
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/app/api/shops/me/taxes-charges');
      if (_disposed) return;
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final taxesRaw = data['taxes'] as List? ?? [];
        final chargesRaw = data['charges'] as List? ?? [];

        // Sum up the active taxes percentage
        double activeTaxPercent = 0.0;
        for (final t in taxesRaw) {
          final taxMap = Map<String, dynamic>.from(t);
          final isActive = taxMap['isActive'] as bool? ?? true;
          if (isActive) {
            final rawRate = taxMap['rate'];
            double rate = 0.0;
            if (rawRate is num) {
              rate = rawRate.toDouble();
            } else if (rawRate is String) {
              rate = double.tryParse(rawRate) ?? 0.0;
            }
            activeTaxPercent += rate;
          }
        }

        // Sum up the active additional charges
        double fixedCharges = 0.0;
        double percentageChargesPercent = 0.0;
        for (final c in chargesRaw) {
          final chargeMap = Map<String, dynamic>.from(c);
          final isActive = chargeMap['isActive'] as bool? ?? true;
          if (isActive) {
            final rawAmount = chargeMap['amount'];
            double amount = 0.0;
            if (rawAmount is num) {
              amount = rawAmount.toDouble();
            } else if (rawAmount is String) {
              amount = double.tryParse(rawAmount) ?? 0.0;
            }

            final typeStr = chargeMap['type'] as String? ?? 'FIXED';
            if (typeStr == 'PERCENTAGE' || typeStr == 'PERCENT') {
              percentageChargesPercent += amount;
            } else {
              fixedCharges += amount;
            }
          }
        }

        if (_disposed) return;
        state = state.copyWith(
          taxPercent: activeTaxPercent.round(),
          fixedCharges: fixedCharges.round(),
          percentageChargesPercent: percentageChargesPercent.round(),
        );
      }
    } catch (e) {
      debugPrint('[DokanPosNotifier] Failed to fetch taxes/charges: $e');
    }
  }

  Future<void> addCustomer({
    required String name,
    required String phone,
    String address = '',
    int openingDue = 0,
  }) async {
    final normalizedName = name.trim();
    final normalizedPhone = phone.trim();
    final normalizedAddress = address.trim();
    final repository = ref.read(customerRepositoryProvider);

    if (repository != null) {
      try {
        await repository.create(
          CreateCustomerInput(
            clientId: 'customer-${DateTime.now().microsecondsSinceEpoch}',
            name: normalizedName,
            phone: normalizedPhone,
            address: normalizedAddress,
            openingDue: openingDue,
          ),
          shopId: _currentShopId,
        );
      } catch (e) {
        debugPrint('[DokanPosNotifier] addCustomer api error (continuing): $e');
      }
      await fetchCustomers();
      return;
    }

    final normalizedKey = normalizedPhone.isNotEmpty
        ? normalizedPhone
        : normalizedName.toLowerCase();
    final now = DateTime.now();
    final nextProfiles = state.customerProfiles.toList(growable: true);
    final index = nextProfiles.indexWhere((item) => item.key == normalizedKey);
    final existingCreatedAt = index >= 0 ? nextProfiles[index].createdAt : now;
    final nextRecord = DokanCustomerProfileRecord(
      id: null,
      key: normalizedKey,
      name: normalizedName,
      phone: normalizedPhone,
      address: normalizedAddress,
      openingDue: math.max(0, openingDue),
      currentDue: math.max(0, openingDue),
      createdAt: existingCreatedAt,
      updatedAt: now,
    );

    if (index >= 0) {
      nextProfiles[index] = nextRecord;
    } else {
      nextProfiles.insert(0, nextRecord);
    }

    final nextHiddenKeys = Set<String>.from(state.hiddenCustomerKeys)
      ..remove(normalizedKey);
    state = state.copyWith(
      customerProfiles:
          List<DokanCustomerProfileRecord>.unmodifiable(nextProfiles),
      hiddenCustomerKeys: nextHiddenKeys,
    );
    unawaited(_persistSalesHistory());
  }

  void deleteCustomer(String customerKey) {
    final normalizedKey = customerKey.trim();
    if (normalizedKey.isEmpty) {
      return;
    }

    final nextProfiles = state.customerProfiles
        .where((item) => item.key != normalizedKey)
        .toList(growable: false);
    final nextHiddenKeys = Set<String>.from(state.hiddenCustomerKeys)
      ..add(normalizedKey);

    state = state.copyWith(
      customerProfiles: nextProfiles,
      hiddenCustomerKeys: nextHiddenKeys,
    );
    unawaited(_persistSalesHistory());
  }

  Future<void> fetchSuppliers() async {
    if (_disposed) return;
    final repository = ref.read(supplierRepositoryProvider);
    if (repository == null) return;
    try {
      final suppliers = await repository.list(shopId: _currentShopId);
      if (_disposed) return;
      final profiles = suppliers.map(_supplierProfile).toList(growable: false);
      final summaries = <DokanSupplierLedgerRecord>[
        for (final supplier in suppliers) ...[
          if (supplier.totalPurchase > 0)
            DokanSupplierLedgerRecord(
              id: 'summary-purchase-${supplier.id}',
              supplierKey: supplier.id,
              supplierName: supplier.name,
              amount: supplier.totalPurchase,
              kind: DokanSupplierLedgerKind.purchase,
              createdAt: supplier.createdAt,
              note: 'Purchase summary',
              paymentMethod: null,
            ),
          if (supplier.totalPaid > 0)
            DokanSupplierLedgerRecord(
              id: 'summary-payment-${supplier.id}',
              supplierKey: supplier.id,
              supplierName: supplier.name,
              amount: supplier.totalPaid,
              kind: DokanSupplierLedgerKind.payment,
              createdAt: supplier.createdAt,
              note: 'Payment summary',
              paymentMethod: null,
            ),
        ],
      ];
      if (_disposed) return;
      state = state.copyWith(
        supplierProfiles:
            List<DokanSupplierProfileRecord>.unmodifiable(profiles),
        supplierLedger: List<DokanSupplierLedgerRecord>.unmodifiable(summaries),
      );
    } catch (e) {
      debugPrint('[DokanPosNotifier] Failed to fetch suppliers: $e');
    }
  }

  Future<void> fetchSupplierLedger(String supplierKey) async {
    final repository = ref.read(supplierRepositoryProvider);
    if (repository == null) return;
    final entries = await repository.ledger(
      supplierKey,
      shopId: _currentShopId,
    );
    var supplierName = '';
    for (final supplier in state.supplierProfiles) {
      if (supplier.key == supplierKey) {
        supplierName = supplier.name;
        break;
      }
    }
    final records = entries
        .map((entry) => _supplierLedger(entry, supplierName))
        .toList(growable: false);
    final otherLedger = state.supplierLedger
        .where((record) => record.supplierKey != supplierKey);
    state = state.copyWith(
      supplierLedger: List<DokanSupplierLedgerRecord>.unmodifiable(
        [...records, ...otherLedger],
      ),
    );
  }

  Future<void> addSupplier({
    required String name,
    String phone = '',
    String address = '',
    String productType = '',
    int creditLimit = 0,
  }) async {
    final normalizedName = name.trim();
    final normalizedPhone = phone.trim();
    final normalizedAddress = address.trim();
    final normalizedProductType = productType.trim();

    final repository = ref.read(supplierRepositoryProvider);
    if (repository != null) {
      final created = await repository.create(
        CreateSupplierInput(
          clientId: 'supplier-${DateTime.now().microsecondsSinceEpoch}',
          name: normalizedName,
          phone: normalizedPhone,
          address: normalizedAddress,
          productType: normalizedProductType,
          creditLimit: creditLimit,
        ),
        shopId: _currentShopId,
      );
      final nextProfiles = [
        _supplierProfile(created),
        ...state.supplierProfiles.where((item) => item.key != created.id),
      ];
      state = state.copyWith(
        supplierProfiles:
            List<DokanSupplierProfileRecord>.unmodifiable(nextProfiles),
      );
      await _persistSalesHistory();
      return;
    }

    final normalizedKey =
        dokanSupplierRecordKey(normalizedName, normalizedPhone);
    final now = DateTime.now();
    final nextProfiles = state.supplierProfiles.toList(growable: true);
    final index = nextProfiles.indexWhere((item) => item.key == normalizedKey);
    final existingCreatedAt = index >= 0 ? nextProfiles[index].createdAt : now;
    final nextRecord = DokanSupplierProfileRecord(
      key: normalizedKey,
      name: normalizedName,
      phone: normalizedPhone,
      address: normalizedAddress,
      productType: normalizedProductType,
      creditLimit: math.max(0, creditLimit),
      createdAt: existingCreatedAt,
      updatedAt: now,
    );

    if (index >= 0) {
      nextProfiles[index] = nextRecord;
    } else {
      nextProfiles.insert(0, nextRecord);
    }

    final nextHiddenKeys = Set<String>.from(state.hiddenSupplierKeys)
      ..remove(normalizedKey);
    state = state.copyWith(
      supplierProfiles:
          List<DokanSupplierProfileRecord>.unmodifiable(nextProfiles),
      hiddenSupplierKeys: nextHiddenKeys,
    );
    unawaited(_persistSalesHistory());
  }

  Future<void> deleteSupplier(String supplierKey) async {
    final normalizedKey = supplierKey.trim();
    if (normalizedKey.isEmpty) {
      return;
    }

    final repository = ref.read(supplierRepositoryProvider);
    if (repository != null) {
      await repository.delete(normalizedKey);
    }

    final nextProfiles = state.supplierProfiles
        .where((item) => item.key != normalizedKey)
        .toList(growable: false);
    final nextLedger = state.supplierLedger
        .where((item) => item.supplierKey != normalizedKey)
        .toList(growable: false);
    final nextHiddenKeys = Set<String>.from(state.hiddenSupplierKeys)
      ..add(normalizedKey);

    state = state.copyWith(
      supplierProfiles: nextProfiles,
      supplierLedger: nextLedger,
      hiddenSupplierKeys: nextHiddenKeys,
    );
    unawaited(_persistSalesHistory());
  }

  Future<void> addSupplierPurchase({
    required String supplierKey,
    required String supplierName,
    required int amount,
    String note = '',
  }) async {
    if (amount <= 0) return;

    if (ref.read(supplierRepositoryProvider) != null) {
      await fetchSuppliers();
      return;
    }

    state = state.copyWith(
      supplierLedger: <DokanSupplierLedgerRecord>[
        DokanSupplierLedgerRecord(
          id: 'supplier-purchase-${DateTime.now().microsecondsSinceEpoch}',
          supplierKey: supplierKey.trim(),
          supplierName: supplierName.trim(),
          amount: amount,
          kind: DokanSupplierLedgerKind.purchase,
          createdAt: DateTime.now(),
          note: note.trim().isEmpty ? 'নোট নেই' : note.trim(),
          paymentMethod: null,
        ),
        ...state.supplierLedger,
      ],
    );
    await _persistSalesHistory();
  }

  Future<void> addSupplierPayment({
    required String supplierKey,
    required String supplierName,
    required int amount,
    required DokanPosPaymentMethod paymentMethod,
    String note = '',
    SupplierPaymentDetails? paymentDetails,
  }) async {
    if (amount <= 0) {
      return;
    }

    final normalizedKey = supplierKey.trim();

    final repository = ref.read(supplierRepositoryProvider);
    if (repository != null) {
      await repository.recordPayment(
        normalizedKey,
        RecordSupplierPaymentInput(
          clientId: 'supplier-payment-${DateTime.now().microsecondsSinceEpoch}',
          amount: amount,
          paymentMethod: _supplierPaymentMethod(paymentMethod),
          note: note,
          details: paymentDetails,
        ),
        shopId: _currentShopId,
      );
      state = state.copyWith(
        supplierLedger: <DokanSupplierLedgerRecord>[
          DokanSupplierLedgerRecord(
            id: 'supplier-payment-${DateTime.now().microsecondsSinceEpoch}',
            supplierKey: normalizedKey,
            supplierName: supplierName.trim(),
            amount: amount,
            kind: DokanSupplierLedgerKind.payment,
            createdAt: DateTime.now(),
            note: note.trim(),
            paymentMethod: paymentMethod,
          ),
          ...state.supplierLedger,
        ],
      );
      await _persistSalesHistory();
      await fetchSuppliers();
      return;
    }

    final nextLedger = <DokanSupplierLedgerRecord>[
      DokanSupplierLedgerRecord(
        id: 'supplier-payment-${DateTime.now().microsecondsSinceEpoch}',
        supplierKey: normalizedKey,
        supplierName: supplierName.trim(),
        amount: amount,
        kind: DokanSupplierLedgerKind.payment,
        createdAt: DateTime.now(),
        note: note.trim().isEmpty ? 'পেমেন্ট নোট নেই' : note.trim(),
        paymentMethod: paymentMethod,
      ),
      ...state.supplierLedger,
    ];

    state = state.copyWith(supplierLedger: nextLedger);
    unawaited(_persistSalesHistory());
  }

  String? get _currentShopId {
    final value = ref.read(dokanAppFlowProvider).shopId.trim();
    return value.isEmpty ? null : value;
  }

  DokanCustomerProfileRecord _customerProfile(Customer customer) {
    final normalizedPhone = customer.phone.trim();
    final fallbackKey = customer.name.trim().toLowerCase();
    return DokanCustomerProfileRecord(
      id: customer.id,
      key: normalizedPhone.isNotEmpty
          ? normalizedPhone
          : (fallbackKey.isNotEmpty ? fallbackKey : customer.id),
      name: customer.name,
      phone: customer.phone,
      address: customer.address,
      openingDue: 0,
      totalSales: customer.totalSales,
      totalPaid: customer.totalPaid,
      currentDue: customer.currentDue,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }

  DokanSupplierProfileRecord _supplierProfile(Supplier supplier) {
    return DokanSupplierProfileRecord(
      key: supplier.id,
      name: supplier.name,
      phone: supplier.phone,
      address: supplier.address,
      productType: supplier.productType,
      creditLimit: supplier.creditLimit,
      createdAt: supplier.createdAt,
      updatedAt: supplier.updatedAt,
    );
  }

  DokanSupplierLedgerRecord _supplierLedger(
    SupplierLedgerEntry entry,
    String supplierName,
  ) {
    return DokanSupplierLedgerRecord(
      id: entry.id,
      supplierKey: entry.supplierId,
      supplierName: supplierName,
      amount: entry.amount,
      kind: entry.type == SupplierLedgerType.purchase
          ? DokanSupplierLedgerKind.purchase
          : entry.type == SupplierLedgerType.setup
              ? DokanSupplierLedgerKind.setup
              : DokanSupplierLedgerKind.payment,
      createdAt: entry.createdAt,
      note: entry.note,
      paymentMethod: entry.paymentMethod == null
          ? null
          : _posPaymentMethod(entry.paymentMethod!),
    );
  }

  SupplierPaymentMethod _supplierPaymentMethod(DokanPosPaymentMethod method) {
    return SupplierPaymentMethod.values.firstWhere(
      (value) => value.name == method.name,
      orElse: () => SupplierPaymentMethod.cash,
    );
  }

  DokanPosPaymentMethod _posPaymentMethod(SupplierPaymentMethod method) {
    return DokanPosPaymentMethod.values.firstWhere(
      (value) => value.name == method.name,
      orElse: () => DokanPosPaymentMethod.cash,
    );
  }

  void addStaff({
    required String name,
    required String phone,
    required String role,
    String address = '',
    String note = '',
    List<String> permissions = const <String>[],
    String? pinCode,
  }) {
    final normalizedName = name.trim();
    final normalizedPhone = phone.trim();
    final normalizedRole = role.trim();
    final normalizedAddress = address.trim();
    final normalizedNote = note.trim();
    final normalizedKey = normalizedPhone.isNotEmpty
        ? normalizedPhone
        : normalizedName.toLowerCase();
    final now = DateTime.now();
    final nextProfiles = state.staffProfiles.toList(growable: true);
    final index = nextProfiles.indexWhere((item) => item.key == normalizedKey);
    final existingCreatedAt = index >= 0 ? nextProfiles[index].createdAt : now;
    final nextRecord = DokanStaffProfileRecord(
      key: normalizedKey,
      name: normalizedName,
      phone: normalizedPhone,
      role: normalizedRole,
      address: normalizedAddress,
      note: normalizedNote,
      active: true,
      joinedAt: index >= 0 ? nextProfiles[index].joinedAt : now,
      lastActiveAt: now,
      lastLoginAt: now,
      recentSalesCount: index >= 0 ? nextProfiles[index].recentSalesCount : 0,
      permissions: List<String>.unmodifiable(permissions),
      pinCode: pinCode?.trim().isEmpty == true || pinCode == null
          ? null
          : CredentialHasher.hash(pinCode.trim()),
      createdAt: existingCreatedAt,
      updatedAt: now,
    );

    if (index >= 0) {
      nextProfiles[index] = nextRecord;
    } else {
      nextProfiles.insert(0, nextRecord);
    }

    final nextHiddenKeys = Set<String>.from(state.hiddenStaffKeys)
      ..remove(normalizedKey);
    state = state.copyWith(
      staffProfiles: List<DokanStaffProfileRecord>.unmodifiable(nextProfiles),
      hiddenStaffKeys: nextHiddenKeys,
    );
    unawaited(_persistSalesHistory());
  }

  void deleteStaff(String staffKey) {
    final normalizedKey = staffKey.trim();
    if (normalizedKey.isEmpty) {
      return;
    }

    final nextProfiles = state.staffProfiles
        .where((item) => item.key != normalizedKey)
        .toList(growable: false);
    final nextHiddenKeys = Set<String>.from(state.hiddenStaffKeys)
      ..add(normalizedKey);

    state = state.copyWith(
      staffProfiles: nextProfiles,
      hiddenStaffKeys: nextHiddenKeys,
    );
    unawaited(_persistSalesHistory());
  }

  void toggleStaffStatus(String staffKey) {
    final normalizedKey = staffKey.trim();
    final nextProfiles = state.staffProfiles.map((item) {
      if (item.key != normalizedKey) {
        return item;
      }
      return item.copyWith(
        active: !item.active,
        lastActiveAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList(growable: false);
    state = state.copyWith(staffProfiles: nextProfiles);
    unawaited(_persistSalesHistory());
  }

  void updateStaffPermissions(String staffKey, List<String> permissions) {
    final normalizedKey = staffKey.trim();
    final normalizedPermissions = List<String>.unmodifiable(
      permissions
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(growable: false),
    );
    final now = DateTime.now();
    final nextProfiles = state.staffProfiles.map((item) {
      if (item.key != normalizedKey) {
        return item;
      }
      return item.copyWith(
        permissions: normalizedPermissions,
        updatedAt: now,
      );
    }).toList(growable: false);
    state = state.copyWith(staffProfiles: nextProfiles);
    unawaited(_persistSalesHistory());
  }

  void setStaffPin({
    required String staffKey,
    required String pinCode,
  }) {
    final normalizedKey = staffKey.trim();
    final pin = pinCode.trim();
    final now = DateTime.now();
    final nextProfiles = state.staffProfiles.map((item) {
      if (item.key != normalizedKey) {
        return item;
      }
      return item.copyWith(
        pinCode: CredentialHasher.hash(pin),
        updatedAt: now,
      );
    }).toList(growable: false);
    state = state.copyWith(staffProfiles: nextProfiles);
    unawaited(_persistSalesHistory());
  }

  void recordStaffLogin(String staffKey) {
    final normalizedKey = staffKey.trim();
    final now = DateTime.now();
    final nextProfiles = state.staffProfiles.map((item) {
      if (item.key != normalizedKey) {
        return item;
      }
      return item.copyWith(
        lastLoginAt: now,
        lastActiveAt: now,
        updatedAt: now,
      );
    }).toList(growable: false);
    state = state.copyWith(staffProfiles: nextProfiles);
    unawaited(_persistSalesHistory());
  }

  void addOrder(DokanPosOrderRecord record) {
    state = state.copyWith(
      orders: _dedupeOrders(<DokanPosOrderRecord>[record, ...state.orders]),
    );
    unawaited(_persistSalesHistory());
  }

  DokanPosOrderStatus currentCheckoutStatus() {
    if (state.paymentMethod == DokanPosPaymentMethod.cash) {
      if (state.cashReceived >= state.total) {
        return DokanPosOrderStatus.paid;
      }
      if (state.cashReceived > 0 && state.cashReceived < state.total) {
        return DokanPosOrderStatus.partiallyPaid;
      }
      return DokanPosOrderStatus.due;
    }

    if (state.paymentMethod == DokanPosPaymentMethod.due) {
      if (state.creditDueAmount >= state.total) {
        return DokanPosOrderStatus.due;
      }
      if (state.creditDueAmount > 0) {
        return DokanPosOrderStatus.partiallyPaid;
      }
      return DokanPosOrderStatus.due;
    }

    return DokanPosOrderStatus.paid;
  }

  DokanPaymentValidationResult validateCheckoutResult() {
    return const PaymentValidationEngine().validate(state);
  }

  String? validateCheckout() {
    return validateCheckoutResult().firstErrorMessage;
  }

  Future<String?> confirmCheckout({
    bool allowDueConfirmation = false,
  }) async {
    if (state.paymentConfirmed &&
        state.confirmationMessage == 'চেকআউট সম্পন্ন হয়েছে') {
      return state.confirmationMessage;
    }

    final validation = validateCheckoutResult();
    if (validation.hasBlockingErrors) {
      return validation.firstErrorMessage;
    }
    if (validation.requiresDueConfirmation && !allowDueConfirmation) {
      return 'remaining_due_confirmation_required';
    }

    final status = currentCheckoutStatus();
    final int dueAmount = validation.dueAmount;
    final int paidAmount = validation.paidAmount;
    final customerName = state.customerName.trim();
    final customerNumber = state.customerNumber.trim();

    final flow = ref.read(dokanAppFlowProvider);
    final currentSalesmanPhone =
        flow.isSalesman ? flow.currentSalesmanPhone : flow.ownerPhone;
    final currentSalesmanName =
        flow.isSalesman ? flow.currentSalesmanName : flow.registeredName;

    DokanDebug.log('[CHECKOUT] confirmCheckout started. Cart quantities: ${state.cartQuantities}');
    final service = ref.read(productServiceProvider);
    final catalog = ref.read(dokanInventoryCatalogProvider);
    DokanDebug.log('[CHECKOUT] Service products: ${service.allProducts.map((p) => "${p.name}(${p.barcode})").join(", ")}');
    DokanDebug.log('[CHECKOUT] Catalog products: ${catalog.map((p) => "${p.name}(${p.barcode})").join(", ")}');

    final deductions = <MapEntry<DokanCatalogProduct, int>>[];
    final inventorySettings =
        ref.read(inventorySettingsProvider).asData?.value ??
            const InventorySettings();
    for (final entry in state.cartQuantities.entries) {
      var product = service.getProduct(entry.key);
      if (product == null) {
        DokanDebug.log('[CHECKOUT] getProduct returned null for key: ${entry.key}. Trying fallback.');
        final normalizedKey = service.normalizeProductId(entry.key);
        if (normalizedKey.isNotEmpty) {
          for (final p in catalog) {
            if (service.normalizeProductId(p.barcode) == normalizedKey) {
              product = p;
              DokanDebug.log('[CHECKOUT] Fallback matched: ${p.name}');
              break;
            }
          }
        }
      }
      if (product == null) {
        debugPrint(
            '[SALE] stock deduction skipped, product not found: ${entry.key}');
        DokanDebug.log('[CHECKOUT] ERROR: product not found for key: ${entry.key}');
        return 'পণ্য পাওয়া যায়নি';
      }
      if (entry.value <= 0 ||
          (!inventorySettings.allowNegativeStock &&
              product.stock < entry.value)) {
        return '${product.name} পণ্যের পর্যাপ্ত স্টক নেই';
      }
      deductions.add(MapEntry(product, entry.value));
    }


    DokanDebug.log(
        '[CHECKOUT] Started confirmCheckout. Deductions: ${deductions.map((d) => "${d.key.name}: ${d.value}").join(", ")}');
    try {
      final lines = deductions
          .expand(
            (deduction) => ref
                .read(productServiceProvider)
                .allocateBatchesForSale(
                  deduction.key,
                  deduction.value,
                  stockMethod: inventorySettings.costingMethod,
                )
                .map(
                  (allocation) => DokanPosOrderLine(
                    productId: allocation.product.barcode,
                    productName: allocation.product.name,
                    quantity: allocation.quantity,
                    unitPrice: allocation.salePrice,
                    unitCost: allocation.purchasePrice,
                    batchNo: allocation.batchNo,
                  ),
                ),
          )
          .toList(growable: false);
      final clientOrderId = 'order-${DateTime.now().microsecondsSinceEpoch}';
      final paymentReference = switch (state.paymentMethod) {
        DokanPosPaymentMethod.bkash ||
        DokanPosPaymentMethod.nagad ||
        DokanPosPaymentMethod.rocket =>
          state.transactionId.trim(),
        DokanPosPaymentMethod.card => state.cardApprovalCode.trim(),
        DokanPosPaymentMethod.bank => state.bankReferenceNumber.trim(),
        _ => '',
      };
      final remoteId = await ref.read(salesGatewayProvider)?.createSale(
            SaleSubmission(
              clientId: clientOrderId,
              lines: lines.map(
                (line) {
                  final catalogProduct = ref
                      .read(productServiceProvider)
                      .getProduct(line.productId);
                  final masterProductId =
                      catalogProduct?.masterProductId.trim() ?? '';
                  return SaleSubmissionLine(
                    productId: masterProductId.isNotEmpty
                        ? masterProductId
                        : line.productId,
                    quantity: line.quantity,
                    unitPrice: line.unitPrice,
                    batchNo: line.batchNo,
                  );
                },
              ).toList(growable: false),
              customerName:
                  customerName.isEmpty ? 'Guest Customer' : customerName,
              customerPhone: customerNumber,
              discount: state.discountAmount,
              taxAmount: state.taxAmount,
              chargeAmount: state.extraCharges,
              totalAmount: state.total,
              paidAmount: paidAmount,
              dueAmount: dueAmount,
              paymentMethod: state.paymentMethod.name,
              paymentReference: paymentReference,
              salesmanPhone: currentSalesmanPhone,
            ),
          );
      if (inventorySettings.autoDeductOnSale) {
        for (final deduction in deductions) {
          ref.read(inventoryServiceProvider).reduceStock(
                deduction.key,
                amount: deduction.value,
                reason:
                    'checkout sale ${DateTime.now().microsecondsSinceEpoch}',
              );
        }
      }

      final order = DokanPosOrderRecord(
        id: remoteId ?? clientOrderId,
        customerName: customerName.isEmpty ? 'অতিথি গ্রাহক' : customerName,
        customerNumber: customerNumber,
        totalAmount: state.subtotal,
        paidAmount: paidAmount,
        dueAmount: dueAmount,
        paymentMethod: state.paymentMethod,
        status: status,
        summary:
            'উপমোট ${state.subtotal}, ছাড় ${state.discountAmount}, কর ${state.taxAmount}',
        createdAt: DateTime.now(),
        salesmanPhone: currentSalesmanPhone,
        salesmanName: currentSalesmanName,
        lines: lines,
        paymentReference: paymentReference,
        paymentHistory: paidAmount <= 0
            ? const <DokanOrderPayment>[]
            : <DokanOrderPayment>[
                DokanOrderPayment(
                  id: 'payment-${DateTime.now().microsecondsSinceEpoch}',
                  amount: paidAmount,
                  method: state.paymentMethod,
                  createdAt: DateTime.now(),
                  reference: switch (state.paymentMethod) {
                    DokanPosPaymentMethod.bkash ||
                    DokanPosPaymentMethod.nagad ||
                    DokanPosPaymentMethod.rocket =>
                      state.transactionId.trim(),
                    DokanPosPaymentMethod.card => state.cardApprovalCode.trim(),
                    DokanPosPaymentMethod.bank =>
                      state.bankReferenceNumber.trim(),
                    _ => '',
                  },
                ),
              ],
      );

      final updatedProfiles = state.customerProfiles.map((p) {
        bool isMatch = false;
        if (customerNumber.isNotEmpty && p.phone.trim() == customerNumber) {
          isMatch = true;
        } else if (customerName.isNotEmpty && p.name.trim() == customerName) {
          isMatch = true;
        }
        if (isMatch) {
          return p.copyWith(
            currentDue: p.currentDue + dueAmount,
            totalSales: p.totalSales + state.total,
            totalPaid: p.totalPaid + paidAmount,
            updatedAt: DateTime.now(),
          );
        }
        return p;
      }).toList();

      state = state.copyWith(
        orders: _dedupeOrders(<DokanPosOrderRecord>[order, ...state.orders]),
        customerProfiles:
            List<DokanCustomerProfileRecord>.unmodifiable(updatedProfiles),
        paymentConfirmed: true,
        confirmationMessage: 'চেকআউট সম্পন্ন হয়েছে',
      );
      await _persistSalesHistory();
      ref.read(dokanDashboardLiveSalesProvider.notifier).update((orders) {
        final withoutDuplicate =
            orders.where((item) => item.id != order.id).toList(growable: false);
        return <DokanPosOrderRecord>[order, ...withoutDuplicate];
      });
      ref.invalidate(salesHistoryOrdersProvider);
      ref.invalidate(reportDashboardRemoteProvider);
      ref.invalidate(dailySalesReportRemoteProvider);
      ref.invalidate(dailyPurchaseReportRemoteProvider);
      ref.invalidate(remoteExpenseReportProvider);
      ref.invalidate(profitLossReportRemoteProvider);
      DokanDebug.log('[CHECKOUT] Invalidating dokanInventoryCatalogProvider');
      ref.invalidate(dokanInventoryCatalogProvider);
      unawaited(fetchCustomers());
      return 'চেকআউট সম্পন্ন হয়েছে';
    } catch (error, stackTrace) {
      debugPrint('[SALE] checkout failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return 'চেকআউট ব্যর্থ হয়েছে';
    }
  }

  Future<String?> cancelOrder({
    required String orderId,
    required String reason,
    required String refundMethod,
  }) async {
    final index = state.orders.indexWhere((order) => order.id == orderId);
    if (index < 0) return 'বিক্রয় রেকর্ড পাওয়া যায়নি';
    final order = state.orders[index];
    if (order.status == DokanPosOrderStatus.cancelled) {
      return 'বিক্রয়টি আগেই বাতিল হয়েছে';
    }
    if (order.lines.isEmpty) {
      return 'পুরোনো বিক্রয়ে পণ্যের বিস্তারিত নেই; স্বয়ংক্রিয়ভাবে বাতিল করা যাবে না';
    }

    await ref.read(salesGatewayProvider)?.cancelSale(
          saleId: order.id,
          reason: reason,
          refundMethod: refundMethod,
        );

    final service = ref.read(productServiceProvider);
    final catalog = ref.read(dokanInventoryCatalogProvider);

    for (final line in order.lines) {
      var product = service.getProduct(line.productId);
      if (product == null) {
        final normalizedKey = service.normalizeProductId(line.productId);
        if (normalizedKey.isNotEmpty) {
          for (final p in catalog) {
            if (service.normalizeProductId(p.barcode) == normalizedKey) {
              product = p;
              break;
            }
          }
        }
      }
      if (product == null) {
        return '${line.productName} পণ্য পাওয়া যায়নি';
      }
    }

    for (final line in order.lines) {
      var product = service.getProduct(line.productId);
      if (product == null) {
        final normalizedKey = service.normalizeProductId(line.productId);
        if (normalizedKey.isNotEmpty) {
          for (final p in catalog) {
            if (service.normalizeProductId(p.barcode) == normalizedKey) {
              product = p;
              break;
            }
          }
        }
      }
      ref.read(inventoryServiceProvider).addStock(
            product!,
            amount: line.quantity,
            purchasePrice: line.unitCost,
            referenceText: 'return-${order.id}',
          );
    }

    final updated = order.copyWith(
      status: DokanPosOrderStatus.cancelled,
      paidAmount: 0,
      dueAmount: 0,
      cancelledAt: DateTime.now(),
      cancellationReason: reason.trim(),
      refundMethod: refundMethod.trim(),
      summary: '${order.summary} | বাতিল: ${reason.trim()}',
    );
    final orders = state.orders.toList(growable: true)..[index] = updated;
    state = state.copyWith(orders: List.unmodifiable(orders));
    await _persistSalesHistory();
    ref.invalidate(salesHistoryOrdersProvider);
    return null;
  }

  void cancelCheckout() {
    state = state.copyWith(
      paymentConfirmed: false,
      confirmationMessage: 'চেকআউট বাতিল হয়েছে',
    );
  }

  void resetAfterCheckout() {
    state = state.copyWith(
      cartQuantities: const <String, int>{},
      selectedProductIds: const <String>{},
      subtotalSnapshot: 0,
      discount: 0,
      taxPercent: 0,
      paymentMethod: DokanPosPaymentMethod.cash,
      customerName: '',
      customerNumber: '',
      transactionId: '',
      cashReceived: 0,
      creditDueAmount: 0,
      cardHolderName: '',
      cardLast4: '',
      cardApprovalCode: '',
      cardBankName: '',
      bankSenderName: '',
      bankName: '',
      bankAccountNumber: '',
      bankReferenceNumber: '',
      bankRoutingNumber: '',
      paymentConfirmed: false,
      confirmationMessage: null,
    );
    unawaited(_saveCartToPrefs(const <String, int>{}));
  }
}

final dokanPosProvider =
    NotifierProvider<DokanPosNotifier, DokanPosState>(DokanPosNotifier.new);
