import '../../domain/entities/salesman.dart';
import '../../domain/repositories/salesman_repository.dart';
import '../datasources/salesman_remote_data_source.dart';
import '../mappers/salesman_api_mapper.dart';

class SalesmanRemoteRepository implements SalesmanRepository {
  const SalesmanRemoteRepository(this._remote);

  final SalesmanRemoteDataSource _remote;

  @override
  Future<List<Salesman>> getAll() async {
    final values = await _remote.list();
    return values.map(SalesmanApiMapper.fromJson).toList(growable: false);
  }

  @override
  Future<Salesman> add({
    required String name,
    required String phone,
    required String email,
    String password = '',
  }) async {
    final payload = await _remote.create(
      SalesmanApiMapper.createInput(
        name: name,
        phone: phone,
        email: email,
        password: password,
      ),
      idempotencyKey: 'salesman-$phone',
    );
    if (payload.isEmpty) {
      return Salesman(
        name: name,
        branch: 'Main Branch',
        sales: 0,
        target: 50000,
        commission: 0,
        active: true,
        phone: phone,
        email: email,
      );
    }
    final value = payload['staff'] ?? payload['salesman'];
    return SalesmanApiMapper.fromJson(
      value is Map ? Map<String, dynamic>.from(value) : payload,
    );
  }
}
