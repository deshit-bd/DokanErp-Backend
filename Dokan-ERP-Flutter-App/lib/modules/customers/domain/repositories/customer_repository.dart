import '../entities/customer.dart';

abstract interface class CustomerRepository {
  Future<List<Customer>> list({String? shopId, String? search});

  Future<Customer> create(
    CreateCustomerInput input, {
    String? shopId,
  });

  Future<Map<String, dynamic>> get(String id, {String? shopId});

  Future<void> collectDuePayment({
    required String customerId,
    required int amount,
    required String shopId,
    DateTime? paidAt,
    String? notes,
    String paymentMethod = 'CASH',
    Map<String, dynamic>? paymentDetails,
  });
}
