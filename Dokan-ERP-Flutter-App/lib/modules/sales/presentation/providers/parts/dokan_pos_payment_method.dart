part of '../cart_provider.dart';

enum DokanPosPaymentMethod { cash, due, bkash, nagad, card, rocket, bank }

enum DokanPosOrderStatus { paid, due, partiallyPaid, cancelled }

class DokanPosOrderLine {
  const DokanPosOrderLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost,
    this.batchNo = '',
  });

  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int unitCost;
  final String batchNo;

  int get lineTotal => unitPrice * quantity;
  int get costTotal => unitCost * quantity;
  int get grossProfit => lineTotal - costTotal;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'unitCost': unitCost,
        'batchNo': batchNo,
      };

  factory DokanPosOrderLine.fromJson(Map<String, dynamic> json) {
    return DokanPosOrderLine(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toInt() ?? 0,
      unitCost: (json['unitCost'] as num?)?.toInt() ?? 0,
      batchNo: json['batchNo'] as String? ?? '',
    );
  }
}

class DokanOrderPayment {
  const DokanOrderPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.createdAt,
    this.reference = '',
  });

  final String id;
  final int amount;
  final DokanPosPaymentMethod method;
  final DateTime createdAt;
  final String reference;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'method': method.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'reference': reference,
      };

  factory DokanOrderPayment.fromJson(Map<String, dynamic> json) {
    return DokanOrderPayment(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      method: _dokanPosPaymentMethodFromName(json['method'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num?)?.toInt() ?? 0,
      ),
      reference: json['reference'] as String? ?? '',
    );
  }
}

const List<DokanPosPaymentMethod> dokanPosCheckoutPaymentMethods =
    <DokanPosPaymentMethod>[
  DokanPosPaymentMethod.cash,
  DokanPosPaymentMethod.due,
  DokanPosPaymentMethod.bkash,
  DokanPosPaymentMethod.nagad,
  DokanPosPaymentMethod.rocket,
  DokanPosPaymentMethod.bank,
  DokanPosPaymentMethod.card,
];

String dokanPosCheckoutPaymentMethodLabel(DokanPosPaymentMethod method) {
  switch (method) {
    case DokanPosPaymentMethod.cash:
      return 'নগদ টাকা';
    case DokanPosPaymentMethod.due:
      return 'বাকি';
    case DokanPosPaymentMethod.bkash:
      return 'বিকাশ';
    case DokanPosPaymentMethod.nagad:
      return 'নগদ (মোবাইল)';
    case DokanPosPaymentMethod.card:
      return 'কার্ড';
    case DokanPosPaymentMethod.rocket:
      return 'রকেট';
    case DokanPosPaymentMethod.bank:
      return 'ব্যাংক';
  }
}

class DokanPosDueRecord {
  const DokanPosDueRecord({
    required this.name,
    required this.number,
    required this.amount,
  });

  final String name;
  final String number;
  final int amount;
}

class DokanCustomerProfileRecord {
  const DokanCustomerProfileRecord({
    this.id,
    required this.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.openingDue,
    this.totalSales = 0,
    this.totalPaid = 0,
    this.currentDue = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String key;
  final String name;
  final String phone;
  final String address;
  final int openingDue;
  final int totalSales;
  final int totalPaid;
  final int currentDue;
  final DateTime createdAt;
  final DateTime updatedAt;

  DokanCustomerProfileRecord copyWith({
    String? id,
    String? key,
    String? name,
    String? phone,
    String? address,
    int? openingDue,
    int? totalSales,
    int? totalPaid,
    int? currentDue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DokanCustomerProfileRecord(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      openingDue: openingDue ?? this.openingDue,
      totalSales: totalSales ?? this.totalSales,
      totalPaid: totalPaid ?? this.totalPaid,
      currentDue: currentDue ?? this.currentDue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

String dokanSupplierRecordKey(String name, String phone) {
  final normalizedPhone = phone.trim();
  if (normalizedPhone.isNotEmpty) {
    return normalizedPhone;
  }
  return name.trim().toLowerCase();
}

enum DokanSupplierLedgerKind { purchase, payment, setup }

class DokanSupplierProfileRecord {
  const DokanSupplierProfileRecord({
    required this.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.productType,
    required this.creditLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  final String key;
  final String name;
  final String phone;
  final String address;
  final String productType;
  final int creditLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  DokanSupplierProfileRecord copyWith({
    String? key,
    String? name,
    String? phone,
    String? address,
    String? productType,
    int? creditLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DokanSupplierProfileRecord(
      key: key ?? this.key,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      productType: productType ?? this.productType,
      creditLimit: creditLimit ?? this.creditLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DokanSupplierLedgerRecord {
  const DokanSupplierLedgerRecord({
    required this.id,
    required this.supplierKey,
    required this.supplierName,
    required this.amount,
    required this.kind,
    required this.createdAt,
    required this.note,
    required this.paymentMethod,
  });

  final String id;
  final String supplierKey;
  final String supplierName;
  final int amount;
  final DokanSupplierLedgerKind kind;
  final DateTime createdAt;
  final String note;
  final DokanPosPaymentMethod? paymentMethod;

  DokanSupplierLedgerRecord copyWith({
    String? id,
    String? supplierKey,
    String? supplierName,
    int? amount,
    DokanSupplierLedgerKind? kind,
    DateTime? createdAt,
    String? note,
    DokanPosPaymentMethod? paymentMethod,
  }) {
    return DokanSupplierLedgerRecord(
      id: id ?? this.id,
      supplierKey: supplierKey ?? this.supplierKey,
      supplierName: supplierName ?? this.supplierName,
      amount: amount ?? this.amount,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class DokanStaffProfileRecord {
  const DokanStaffProfileRecord({
    required this.key,
    required this.name,
    required this.phone,
    required this.role,
    required this.address,
    required this.note,
    required this.active,
    required this.joinedAt,
    required this.lastActiveAt,
    required this.lastLoginAt,
    required this.recentSalesCount,
    required this.permissions,
    required this.pinCode,
    required this.createdAt,
    required this.updatedAt,
  });

  final String key;
  final String name;
  final String phone;
  final String role;
  final String address;
  final String note;
  final bool active;
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final DateTime lastLoginAt;
  final int recentSalesCount;
  final List<String> permissions;
  final String? pinCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  DokanStaffProfileRecord copyWith({
    String? key,
    String? name,
    String? phone,
    String? role,
    String? address,
    String? note,
    bool? active,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    DateTime? lastLoginAt,
    int? recentSalesCount,
    List<String>? permissions,
    String? pinCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DokanStaffProfileRecord(
      key: key ?? this.key,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      note: note ?? this.note,
      active: active ?? this.active,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      recentSalesCount: recentSalesCount ?? this.recentSalesCount,
      permissions: permissions ?? this.permissions,
      pinCode: pinCode ?? this.pinCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DokanPosOrderRecord {
  const DokanPosOrderRecord({
    required this.id,
    required this.customerName,
    required this.customerNumber,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentMethod,
    required this.status,
    required this.summary,
    required this.createdAt,
    this.salesmanPhone,
    this.salesmanName,
    this.lines = const <DokanPosOrderLine>[],
    this.paymentReference = '',
    this.cancelledAt,
    this.cancellationReason = '',
    this.refundMethod = '',
    this.paymentHistory = const <DokanOrderPayment>[],
  });

  final String id;
  final String customerName;
  final String customerNumber;
  final int totalAmount;
  final int paidAmount;
  final int dueAmount;
  final DokanPosPaymentMethod paymentMethod;
  final DokanPosOrderStatus status;
  final String summary;
  final DateTime createdAt;
  final String? salesmanPhone;
  final String? salesmanName;
  final List<DokanPosOrderLine> lines;
  final String paymentReference;
  final DateTime? cancelledAt;
  final String cancellationReason;
  final String refundMethod;
  final List<DokanOrderPayment> paymentHistory;

  int get costAmount => lines.fold<int>(0, (sum, line) => sum + line.costTotal);
  int get grossProfit =>
      lines.fold<int>(0, (sum, line) => sum + line.grossProfit);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'customerName': customerName,
      'customerNumber': customerNumber,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'summary': summary,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'salesmanPhone': salesmanPhone,
      'salesmanName': salesmanName,
      'lines': lines.map((line) => line.toJson()).toList(growable: false),
      'paymentReference': paymentReference,
      'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
      'cancellationReason': cancellationReason,
      'refundMethod': refundMethod,
      'paymentHistory':
          paymentHistory.map((item) => item.toJson()).toList(growable: false),
    };
  }

  factory DokanPosOrderRecord.fromJson(Map<String, dynamic> json) {
    return DokanPosOrderRecord(
      id: json['id'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerNumber: json['customerNumber'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toInt() ?? 0,
      dueAmount: (json['dueAmount'] as num?)?.toInt() ?? 0,
      paymentMethod:
          _dokanPosPaymentMethodFromName(json['paymentMethod'] as String?),
      status: _dokanPosOrderStatusFromName(json['status'] as String?),
      summary: json['summary'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num?)?.toInt() ?? 0,
      ),
      salesmanPhone: json['salesmanPhone'] as String?,
      salesmanName: json['salesmanName'] as String?,
      lines: (json['lines'] as List?)
              ?.whereType<Map>()
              .map((line) => DokanPosOrderLine.fromJson(
                    line.map((key, value) => MapEntry('$key', value)),
                  ))
              .toList(growable: false) ??
          const <DokanPosOrderLine>[],
      paymentReference: json['paymentReference'] as String? ?? '',
      cancelledAt: (json['cancelledAt'] as num?) == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              (json['cancelledAt'] as num).toInt(),
            ),
      cancellationReason: json['cancellationReason'] as String? ?? '',
      refundMethod: json['refundMethod'] as String? ?? '',
      paymentHistory: (json['paymentHistory'] as List?)
              ?.whereType<Map>()
              .map((item) => DokanOrderPayment.fromJson(
                    item.map((key, value) => MapEntry('$key', value)),
                  ))
              .toList(growable: false) ??
          const <DokanOrderPayment>[],
    );
  }

  DokanPosOrderRecord copyWith({
    String? id,
    String? customerName,
    String? customerNumber,
    int? totalAmount,
    int? paidAmount,
    int? dueAmount,
    DokanPosPaymentMethod? paymentMethod,
    DokanPosOrderStatus? status,
    String? summary,
    DateTime? createdAt,
    String? salesmanPhone,
    String? salesmanName,
    List<DokanPosOrderLine>? lines,
    String? paymentReference,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? refundMethod,
    List<DokanOrderPayment>? paymentHistory,
  }) {
    return DokanPosOrderRecord(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerNumber: customerNumber ?? this.customerNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      salesmanPhone: salesmanPhone ?? this.salesmanPhone,
      salesmanName: salesmanName ?? this.salesmanName,
      lines: lines ?? this.lines,
      paymentReference: paymentReference ?? this.paymentReference,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      refundMethod: refundMethod ?? this.refundMethod,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}

DokanPosPaymentMethod _dokanPosPaymentMethodFromName(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'due' => DokanPosPaymentMethod.due,
    'bkash' => DokanPosPaymentMethod.bkash,
    'nagad' => DokanPosPaymentMethod.nagad,
    'card' => DokanPosPaymentMethod.card,
    'rocket' => DokanPosPaymentMethod.rocket,
    'bank' => DokanPosPaymentMethod.bank,
    _ => DokanPosPaymentMethod.cash,
  };
}

String _dokanBanglaDigits(String input) {
  const digits = <String, String>{
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

  return input.split('').map((char) => digits[char] ?? char).join();
}

DokanPosOrderRecord dokanPosOrderRecordFromRemoteSale(
  Map<String, dynamic> sale,
) {
  final subtotal = JsonValue.decimal(sale, const ['totalAmount']).round();
  final discountAmount =
      JsonValue.decimal(sale, const ['discountAmount']).round();
  final taxAmount = JsonValue.decimal(sale, const ['taxAmount']).round();
  final chargeAmount = JsonValue.decimal(sale, const ['chargeAmount']).round();
  final grandTotal = subtotal - discountAmount + taxAmount + chargeAmount;

  final paidAmount = JsonValue.decimal(sale, const ['paidAmount']).round();
  final dueAmount = JsonValue.decimal(sale, const ['dueAmount']).round();
  final cancelledAtValue = JsonValue.first(sale, const ['cancelledAt']);
  final invoiceNo = JsonValue.string(sale, const ['invoiceNo']);
  final notes = JsonValue.string(sale, const ['notes']);
  final items = JsonValue.objectList(sale, const ['items']);
  final createdAt = JsonValue.dateTime(sale, const ['saleDate', 'createdAt']);
  final remoteStatus =
      JsonValue.string(sale, const ['status']).trim().toUpperCase();

  final status = remoteStatus == 'CANCELLED'
      ? DokanPosOrderStatus.cancelled
      : dueAmount <= 0
          ? DokanPosOrderStatus.paid
          : paidAmount <= 0
              ? DokanPosOrderStatus.due
              : DokanPosOrderStatus.partiallyPaid;

  final summaryParts = <String>[
    if (invoiceNo.isNotEmpty) 'ইনভয়েস $invoiceNo',
    if (items.isNotEmpty)
      '${_dokanBanglaDigits(items.length.toString())}টি পণ্য',
    if (notes.isNotEmpty) notes,
  ];

  return DokanPosOrderRecord(
    id: JsonValue.string(sale, const ['id']),
    customerName: JsonValue.string(sale, const ['customerName'],
        fallback: 'হাঁটা বিক্রয়'),
    customerNumber: JsonValue.string(sale, const ['customerMobile']),
    totalAmount: subtotal,
    paidAmount: paidAmount,
    dueAmount: dueAmount,
    paymentMethod: _dokanPosPaymentMethodFromName(
        JsonValue.string(sale, const ['paymentMethod'])),
    status: status,
    summary: summaryParts.isEmpty ? 'বিক্রয় রেকর্ড' : summaryParts.join(' • '),
    createdAt: createdAt,
    salesmanPhone: JsonValue.string(sale, const ['salesmanPhone']),
    salesmanName: JsonValue.string(sale, const ['salesmanName']),
    lines: items
        .map(
          (item) => DokanPosOrderLine(
            productId: JsonValue.string(item, const ['masterProductId', 'id']),
            productName: JsonValue.string(item, const ['name']),
            quantity: JsonValue.decimal(item, const ['quantity']).round(),
            unitPrice: JsonValue.decimal(item, const ['salePrice']).round(),
            unitCost: JsonValue.decimal(item, const ['purchasePrice']).round(),
          ),
        )
        .toList(growable: false),
    paymentReference: invoiceNo,
    cancelledAt: cancelledAtValue == null
        ? null
        : JsonValue.dateTime(sale, const ['cancelledAt']),
    cancellationReason: JsonValue.string(sale, const ['cancelReason']),
    refundMethod: JsonValue.string(sale, const ['refundMethod']),
  );
}

DokanPosOrderStatus _dokanPosOrderStatusFromName(String? value) {
  return switch (value) {
    'due' => DokanPosOrderStatus.due,
    'partiallyPaid' => DokanPosOrderStatus.partiallyPaid,
    'cancelled' => DokanPosOrderStatus.cancelled,
    _ => DokanPosOrderStatus.paid,
  };
}

String dokanPosPaymentMethodLabel(DokanPosPaymentMethod method) {
  switch (method) {
    case DokanPosPaymentMethod.cash:
      return 'নগদ';
    case DokanPosPaymentMethod.due:
      return 'বাকি';
    case DokanPosPaymentMethod.bkash:
      return 'বিকাশ';
    case DokanPosPaymentMethod.nagad:
      return 'নগদ';
    case DokanPosPaymentMethod.card:
      return 'কার্ড';
    case DokanPosPaymentMethod.rocket:
      return 'রকেট';
    case DokanPosPaymentMethod.bank:
      return 'ব্যাংক';
  }
}

class DokanPosState {
  const DokanPosState({
    this.cartQuantities = const <String, int>{},
    this.selectedProductIds = const <String>{},
    this.subtotalSnapshot = 0,
    this.discount = 0,
    this.taxPercent = 0,
    this.fixedCharges = 0,
    this.percentageChargesPercent = 0,
    this.paymentMethod = DokanPosPaymentMethod.cash,
    this.customerName = '',
    this.customerNumber = '',
    this.transactionId = '',
    this.cashReceived = 0,
    this.creditDueAmount = 0,
    this.cardHolderName = '',
    this.cardLast4 = '',
    this.cardApprovalCode = '',
    this.cardBankName = '',
    this.bankSenderName = '',
    this.bankName = '',
    this.bankAccountNumber = '',
    this.bankReferenceNumber = '',
    this.bankRoutingNumber = '',
    this.orders = const <DokanPosOrderRecord>[],
    this.customerProfiles = const <DokanCustomerProfileRecord>[],
    this.hiddenCustomerKeys = const <String>{},
    this.supplierProfiles = const <DokanSupplierProfileRecord>[],
    this.supplierLedger = const <DokanSupplierLedgerRecord>[],
    this.hiddenSupplierKeys = const <String>{},
    this.staffProfiles = const <DokanStaffProfileRecord>[],
    this.hiddenStaffKeys = const <String>{},
    this.paymentConfirmed = false,
    this.confirmationMessage,
  });

  final Map<String, int> cartQuantities;
  final Set<String> selectedProductIds;
  final int subtotalSnapshot;
  final int discount;
  final int taxPercent;
  final int fixedCharges;
  final int percentageChargesPercent;
  final DokanPosPaymentMethod paymentMethod;
  final String customerName;
  final String customerNumber;
  final String transactionId;
  final int cashReceived;
  final int creditDueAmount;
  final String cardHolderName;
  final String cardLast4;
  final String cardApprovalCode;
  final String cardBankName;
  final String bankSenderName;
  final String bankName;
  final String bankAccountNumber;
  final String bankReferenceNumber;
  final String bankRoutingNumber;
  final List<DokanPosOrderRecord> orders;
  final List<DokanCustomerProfileRecord> customerProfiles;
  final Set<String> hiddenCustomerKeys;
  final List<DokanSupplierProfileRecord> supplierProfiles;
  final List<DokanSupplierLedgerRecord> supplierLedger;
  final Set<String> hiddenSupplierKeys;
  final List<DokanStaffProfileRecord> staffProfiles;
  final Set<String> hiddenStaffKeys;
  final bool paymentConfirmed;
  final String? confirmationMessage;

  DokanPosState copyWith({
    Map<String, int>? cartQuantities,
    Set<String>? selectedProductIds,
    int? subtotalSnapshot,
    int? discount,
    int? taxPercent,
    int? fixedCharges,
    int? percentageChargesPercent,
    DokanPosPaymentMethod? paymentMethod,
    String? customerName,
    String? customerNumber,
    String? transactionId,
    int? cashReceived,
    int? creditDueAmount,
    String? cardHolderName,
    String? cardLast4,
    String? cardApprovalCode,
    String? cardBankName,
    String? bankSenderName,
    String? bankName,
    String? bankAccountNumber,
    String? bankReferenceNumber,
    String? bankRoutingNumber,
    List<DokanPosOrderRecord>? orders,
    List<DokanCustomerProfileRecord>? customerProfiles,
    Set<String>? hiddenCustomerKeys,
    List<DokanSupplierProfileRecord>? supplierProfiles,
    List<DokanSupplierLedgerRecord>? supplierLedger,
    Set<String>? hiddenSupplierKeys,
    List<DokanStaffProfileRecord>? staffProfiles,
    Set<String>? hiddenStaffKeys,
    bool? paymentConfirmed,
    String? confirmationMessage,
  }) {
    return DokanPosState(
      cartQuantities: cartQuantities ?? this.cartQuantities,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      subtotalSnapshot: subtotalSnapshot ?? this.subtotalSnapshot,
      discount: discount ?? this.discount,
      taxPercent: taxPercent ?? this.taxPercent,
      fixedCharges: fixedCharges ?? this.fixedCharges,
      percentageChargesPercent:
          percentageChargesPercent ?? this.percentageChargesPercent,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      customerNumber: customerNumber ?? this.customerNumber,
      transactionId: transactionId ?? this.transactionId,
      cashReceived: cashReceived ?? this.cashReceived,
      creditDueAmount: creditDueAmount ?? this.creditDueAmount,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardApprovalCode: cardApprovalCode ?? this.cardApprovalCode,
      cardBankName: cardBankName ?? this.cardBankName,
      bankSenderName: bankSenderName ?? this.bankSenderName,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankReferenceNumber: bankReferenceNumber ?? this.bankReferenceNumber,
      bankRoutingNumber: bankRoutingNumber ?? this.bankRoutingNumber,
      orders: orders ?? this.orders,
      customerProfiles: customerProfiles ?? this.customerProfiles,
      hiddenCustomerKeys: hiddenCustomerKeys ?? this.hiddenCustomerKeys,
      supplierProfiles: supplierProfiles ?? this.supplierProfiles,
      supplierLedger: supplierLedger ?? this.supplierLedger,
      hiddenSupplierKeys: hiddenSupplierKeys ?? this.hiddenSupplierKeys,
      staffProfiles: staffProfiles ?? this.staffProfiles,
      hiddenStaffKeys: hiddenStaffKeys ?? this.hiddenStaffKeys,
      paymentConfirmed: paymentConfirmed ?? this.paymentConfirmed,
      confirmationMessage: confirmationMessage ?? this.confirmationMessage,
    );
  }

  int get cartCount =>
      cartQuantities.values.fold<int>(0, (sum, item) => sum + item);

  bool isSelected(String productId) => selectedProductIds.contains(productId);

  int get subtotal => subtotalSnapshot;

  int get discountAmount => discount;

  int get taxableAmount => math.max(0, subtotal - discountAmount);

  int get taxAmount {
    if (taxPercent <= 0) {
      return 0;
    }
    return ((subtotal * taxPercent) / 100).round();
  }

  int get extraCharges {
    if (fixedCharges <= 0 && percentageChargesPercent <= 0) {
      return 0;
    }
    final percentageAmt =
        ((subtotal * percentageChargesPercent) / 100).round();
    return fixedCharges + percentageAmt;
  }

  int get total => math.max(0, subtotal + taxAmount + extraCharges - discountAmount);

  int get dueAmount {
    if (paymentMethod == DokanPosPaymentMethod.cash) {
      return math.max(0, total - cashReceived);
    }
    if (paymentMethod == DokanPosPaymentMethod.due) {
      return math.max(0, creditDueAmount);
    }
    return 0;
  }

  List<DokanPosOrderRecord> get paidOrders => orders
      .where((order) => order.status == DokanPosOrderStatus.paid)
      .toList(growable: false);

  List<DokanPosOrderRecord> get dueOrders => orders
      .where((order) =>
          order.status == DokanPosOrderStatus.due ||
          order.status == DokanPosOrderStatus.partiallyPaid)
      .toList(growable: false);

  int get totalOutstandingDueAmount =>
      dueOrders.fold<int>(0, (sum, order) => sum + order.dueAmount);

  int get totalSupplierOutstandingDueAmount {
    final dueBySupplier = <String, int>{};
    for (final record in supplierLedger) {
      if (hiddenSupplierKeys.contains(record.supplierKey)) {
        continue;
      }
      final current = dueBySupplier[record.supplierKey] ?? 0;
      if (record.kind == DokanSupplierLedgerKind.purchase) {
        dueBySupplier[record.supplierKey] = current + record.amount;
      } else {
        dueBySupplier[record.supplierKey] = current - record.amount;
      }
    }
    return dueBySupplier.values
        .fold<int>(0, (sum, item) => sum + math.max(0, item));
  }
}
