enum PurchaseOrderStatus {
  draft,
  submitted,
  partiallyReceived,
  received,
  cancelled
}

class PurchaseReceiveLineInput {
  const PurchaseReceiveLineInput({
    required this.productId,
    required this.physicalCount,
    required this.buyingPrice,
    required this.sellingPrice,
    this.batchNo,
  });

  final String productId;
  final int physicalCount;
  final int buyingPrice;
  final int sellingPrice;
  final String? batchNo;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'physicalCount': physicalCount,
        'buyingPrice': buyingPrice,
        'sellingPrice': sellingPrice,
        if (batchNo != null) 'batchNo': batchNo,
      };
}

class PurchaseInventoryPlacementInput {
  const PurchaseInventoryPlacementInput({
    required this.productId,
    required this.physicalCount,
    required this.sellingPrice,
    this.zoneId,
    this.rackId,
    this.shelfId,
    this.binId,
    this.batchNo,
    this.productName,
  });

  final String productId;
  final int physicalCount;
  final int sellingPrice;
  final String? zoneId;
  final String? rackId;
  final String? shelfId;
  final String? binId;
  final String? batchNo;
  final String? productName;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'physicalCount': physicalCount,
        'sellingPrice': sellingPrice,
        if (zoneId != null) 'zoneId': zoneId,
        if (rackId != null) 'rackId': rackId,
        if (shelfId != null) 'shelfId': shelfId,
        if (binId != null) 'binId': binId,
        if (batchNo != null) 'batchNo': batchNo,
        if (productName != null) 'productName': productName,
      };
}

class PurchaseOrderLine {
  const PurchaseOrderLine({
    required this.productId,
    required this.productName,
    required this.orderedQuantity,
    required this.unitCost,
    this.receivedQuantity = 0,
    this.returnedQuantity = 0,
    this.purchaseItemId = '',
  });

  final String productId;
  final String productName;
  final int orderedQuantity;
  final int unitCost;
  final int receivedQuantity;
  final int returnedQuantity;
  final String purchaseItemId;

  int get netReceived => receivedQuantity - returnedQuantity;
  int get orderedAmount => orderedQuantity * unitCost;

  PurchaseOrderLine copyWith({
    int? receivedQuantity,
    int? returnedQuantity,
    String? purchaseItemId,
  }) {
    return PurchaseOrderLine(
      productId: productId,
      productName: productName,
      orderedQuantity: orderedQuantity,
      unitCost: unitCost,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      returnedQuantity: returnedQuantity ?? this.returnedQuantity,
      purchaseItemId: purchaseItemId ?? this.purchaseItemId,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'orderedQuantity': orderedQuantity,
        'unitCost': unitCost,
        'receivedQuantity': receivedQuantity,
        'returnedQuantity': returnedQuantity,
        'purchaseItemId': purchaseItemId,
      };

  factory PurchaseOrderLine.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderLine(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      orderedQuantity: (json['orderedQuantity'] as num?)?.toInt() ?? 0,
      unitCost: (json['unitCost'] as num?)?.toInt() ?? 0,
      receivedQuantity: (json['receivedQuantity'] as num?)?.toInt() ?? 0,
      returnedQuantity: (json['returnedQuantity'] as num?)?.toInt() ?? 0,
      purchaseItemId: json['purchaseItemId'] as String? ??
          json['purchase_item_id'] as String? ??
          '',
    );
  }
}

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.supplierKey,
    required this.supplierName,
    required this.lines,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.reference = '',
    this.note = '',
    this.paidAmount = 0,
    this.paymentMethod = 'CASH',
    this.paymentDetails,
  });

  final String id;
  final String supplierKey;
  final String supplierName;
  final List<PurchaseOrderLine> lines;
  final PurchaseOrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String reference;
  final String note;
  final int paidAmount;
  final String paymentMethod;
  final Map<String, dynamic>? paymentDetails;

  int get totalAmount =>
      lines.fold<int>(0, (sum, line) => sum + line.orderedAmount);

  PurchaseOrder copyWith({
    List<PurchaseOrderLine>? lines,
    PurchaseOrderStatus? status,
    DateTime? updatedAt,
    String? note,
    int? paidAmount,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) {
    return PurchaseOrder(
      id: id,
      supplierKey: supplierKey,
      supplierName: supplierName,
      lines: lines ?? this.lines,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reference: reference,
      note: note ?? this.note,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDetails: paymentDetails ?? this.paymentDetails,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplierKey': supplierKey,
        'supplierName': supplierName,
        'lines': lines.map((line) => line.toJson()).toList(growable: false),
        'status': status.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'reference': reference,
        'note': note,
        'paidAmount': paidAmount,
        'paymentMethod': paymentMethod,
        'paymentDetails': paymentDetails,
      };

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String? ?? '',
      supplierKey: json['supplierKey'] as String? ?? '',
      supplierName: json['supplierName'] as String? ?? '',
      lines: (json['lines'] as List?)
              ?.whereType<Map>()
              .map((line) => PurchaseOrderLine.fromJson(
                    line.map((key, value) => MapEntry('$key', value)),
                  ))
              .toList(growable: false) ??
          const [],
      status: PurchaseOrderStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PurchaseOrderStatus.draft,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num?)?.toInt() ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt'] as num?)?.toInt() ?? 0,
      ),
      reference: json['reference'] as String? ?? '',
      note: json['note'] as String? ?? '',
      paidAmount: (json['paidAmount'] as num?)?.toInt() ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? 'CASH',
      paymentDetails: json['paymentDetails'] as Map<String, dynamic>?,
    );
  }
}
