import '../../../../core/network/json_value.dart';
import '../../domain/entities/supplier.dart';

abstract final class SupplierApiMapper {
  static Supplier fromJson(Map<String, dynamic> json) {
    final createdAt = _date(
      JsonValue.string(json, const ['createdAt', 'created_at']),
    );
    return Supplier(
      id: JsonValue.string(json, const ['id', 'uuid']),
      name: JsonValue.string(json, const ['name']),
      phone: JsonValue.string(json, const ['mobile', 'phone']),
      address: JsonValue.string(json, const ['address']),
      productType: JsonValue.string(
        json,
        const ['productType', 'product_type', 'contactPerson'],
      ),
      creditLimit: JsonValue.integer(
        json,
        const ['creditLimit', 'credit_limit'],
      ),
      totalPurchase: JsonValue.integer(
        json,
        const ['totalPurchase', 'total_purchase'],
      ),
      totalPaid: JsonValue.integer(
        json,
        const ['totalPaid', 'total_paid'],
      ),
      createdAt: createdAt,
      updatedAt: _date(
        JsonValue.string(json, const ['updatedAt', 'updated_at']),
        fallback: createdAt,
      ),
    );
  }

  static SupplierLedgerEntry ledgerFromJson(
    Map<String, dynamic> json, {
    required String supplierId,
  }) {
    final debit = JsonValue.integer(json, const ['debit']);
    final credit = JsonValue.integer(json, const ['credit']);
    final explicitAmount = JsonValue.integer(json, const ['amount']);
    final typeValue = JsonValue.string(
      json,
      const ['type', 'kind', 'entryType', 'entry_type'],
    ).toLowerCase();
    final isSetup =
        typeValue.contains('opening') || typeValue.contains('setup');
    final isPurchase = debit > 0 ||
        typeValue.contains('purchase') ||
        typeValue.contains('debit');
    return SupplierLedgerEntry(
      id: JsonValue.string(json, const ['id', 'uuid']),
      supplierId: supplierId,
      amount: isSetup
          ? (debit > 0 ? debit : explicitAmount)
          : isPurchase
              ? (debit > 0 ? debit : explicitAmount)
              : (credit > 0 ? credit : explicitAmount),
      type: isSetup
          ? SupplierLedgerType.setup
          : isPurchase
              ? SupplierLedgerType.purchase
              : SupplierLedgerType.payment,
      createdAt: _date(
        JsonValue.string(
          json,
          const ['entryDate', 'entry_date', 'createdAt', 'created_at'],
        ),
      ),
      note: JsonValue.string(json, const ['notes', 'note']),
      paymentMethod: isSetup
          ? null
          : () {
              final methodStr = JsonValue.string(
                  json, const ['paymentMethod', 'payment_method']);
              return methodStr.isNotEmpty
                  ? _paymentMethod(methodStr.toLowerCase())
                  : _paymentMethod(typeValue);
            }(),
    );
  }

  static Map<String, dynamic> createInput(
    CreateSupplierInput input, {
    String? shopId,
  }) {
    return {
      if (shopId != null && shopId.isNotEmpty) 'shopId': shopId,
      'client_id': input.clientId,
      'name': input.name,
      'mobile': input.phone,
      'address': input.address,
      'productType': input.productType,
      'creditLimit': input.creditLimit,
      'openingPayable': 0,
    };
  }

  static Map<String, dynamic> paymentInput(
    RecordSupplierPaymentInput input, {
    String? shopId,
  }) {
    final details = input.details;
    final paymentDetails = <String, dynamic>{
      if (details?.senderNumber?.isNotEmpty == true)
        'senderNumber': details!.senderNumber,
      if (details?.transactionId?.isNotEmpty == true)
        'transactionId': details!.transactionId,
      if (details?.cardLast4?.isNotEmpty == true)
        'cardLast4': details!.cardLast4,
      if (details?.bankName?.isNotEmpty == true) 'bankName': details!.bankName,
    };
    return {
      if (shopId != null && shopId.isNotEmpty) 'shopId': shopId,
      'client_id': input.clientId,
      'amount': input.amount,
      'paymentMethod': input.paymentMethod.name.toUpperCase(),
      'notes': input.note,
      if (paymentDetails.isNotEmpty) 'paymentDetails': paymentDetails,
    };
  }

  static DateTime _date(String value, {DateTime? fallback}) {
    return DateTime.tryParse(value)?.toLocal() ?? fallback ?? DateTime.now();
  }

  static SupplierPaymentMethod? _paymentMethod(String value) {
    for (final method in SupplierPaymentMethod.values) {
      if (value.contains(method.name)) return method;
    }
    return null;
  }
}
