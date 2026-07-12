enum SupplierLedgerType { purchase, payment, setup }

enum SupplierPaymentMethod {
  cash,
  bkash,
  nagad,
  rocket,
  card,
  bank,
  due,
}

class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.productType = '',
    this.creditLimit = 0,
    this.totalPurchase = 0,
    this.totalPaid = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
  final String productType;
  final int creditLimit;
  final int totalPurchase;
  final int totalPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get due => totalPurchase > totalPaid ? totalPurchase - totalPaid : 0;

  String get pickerLabel {
    final phoneValue = phone.trim();
    return phoneValue.isEmpty ? name : '$name ($phoneValue)';
  }
}

class SupplierLedgerEntry {
  const SupplierLedgerEntry({
    required this.id,
    required this.supplierId,
    required this.amount,
    required this.type,
    required this.createdAt,
    this.note = '',
    this.paymentMethod,
  });

  final String id;
  final String supplierId;
  final int amount;
  final SupplierLedgerType type;
  final DateTime createdAt;
  final String note;
  final SupplierPaymentMethod? paymentMethod;
}

class CreateSupplierInput {
  const CreateSupplierInput({
    required this.clientId,
    required this.name,
    required this.phone,
    required this.address,
    required this.productType,
    required this.creditLimit,
  });

  final String clientId;
  final String name;
  final String phone;
  final String address;
  final String productType;
  final int creditLimit;
}

class SupplierPaymentDetails {
  const SupplierPaymentDetails({
    this.senderNumber,
    this.transactionId,
    this.cardLast4,
    this.bankName,
  });

  final String? senderNumber;
  final String? transactionId;
  final String? cardLast4;
  final String? bankName;
}

class RecordSupplierPaymentInput {
  const RecordSupplierPaymentInput({
    required this.clientId,
    required this.amount,
    required this.paymentMethod,
    this.note = '',
    this.details,
  });

  final String clientId;
  final int amount;
  final SupplierPaymentMethod paymentMethod;
  final String note;
  final SupplierPaymentDetails? details;
}
