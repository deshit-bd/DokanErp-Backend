import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../mappers/customer_api_mapper.dart';

class CustomerRemoteRepository implements CustomerRepository {
  const CustomerRemoteRepository(this._remote);

  final CustomerRemoteDataSource _remote;

  @override
  Future<List<Customer>> list({String? shopId, String? search}) async {
    final values = await _remote.list(shopId: shopId, search: search);
    return values.map(CustomerApiMapper.fromJson).toList(growable: false);
  }

  @override
  Future<Customer> create(
    CreateCustomerInput input, {
    String? shopId,
  }) async {
    final payload = await _remote.create(
      CustomerApiMapper.createInput(input, shopId: shopId),
      idempotencyKey: input.clientId,
    );
    if (payload.isEmpty) {
      final now = DateTime.now();
      return Customer(
        id: input.clientId,
        name: input.name,
        phone: input.phone,
        address: input.address,
        currentDue: input.openingDue,
        createdAt: now,
        updatedAt: now,
      );
    }
    final value = payload['customer'];
    return CustomerApiMapper.fromJson(
      value is Map ? Map<String, dynamic>.from(value) : payload,
    );
  }

  @override
  Future<Map<String, dynamic>> get(String id, {String? shopId}) async {
    return _remote.get(id, shopId: shopId);
  }

  @override
  Future<void> collectDuePayment({
    required String customerId,
    required int amount,
    required String shopId,
    DateTime? paidAt,
    String? notes,
    String paymentMethod = 'CASH',
    Map<String, dynamic>? paymentDetails,
  }) async {
    await _remote.collectDuePayment(
      customerId: customerId,
      amount: amount,
      shopId: shopId,
      paidAt: paidAt,
      notes: notes,
      paymentMethod: paymentMethod,
      paymentDetails: paymentDetails,
    );
  }
}
