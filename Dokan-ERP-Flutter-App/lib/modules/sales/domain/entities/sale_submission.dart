class SaleSubmissionLine {
  const SaleSubmissionLine({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.batchNo,
  });

  final String productId;
  final int quantity;
  final int unitPrice;
  final String? batchNo;
}

class SaleSubmission {
  const SaleSubmission({
    required this.clientId,
    required this.lines,
    required this.customerName,
    required this.customerPhone,
    required this.discount,
    required this.taxAmount,
    this.chargeAmount = 0,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentMethod,
    required this.paymentReference,
    this.salesmanPhone,
  });

  final String clientId;
  final List<SaleSubmissionLine> lines;
  final String customerName;
  final String customerPhone;
  final int discount;
  final int taxAmount;
  final int chargeAmount;
  final int totalAmount;
  final int paidAmount;
  final int dueAmount;
  final String paymentMethod;
  final String paymentReference;
  final String? salesmanPhone;
}
