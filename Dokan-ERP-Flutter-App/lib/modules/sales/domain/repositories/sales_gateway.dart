import '../entities/sale_submission.dart';

abstract interface class SalesGateway {
  Future<String> createSale(SaleSubmission sale);

  Future<void> cancelSale({
    required String saleId,
    required String reason,
    required String refundMethod,
  });
}
