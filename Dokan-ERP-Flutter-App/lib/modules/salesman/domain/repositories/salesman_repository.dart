import '../entities/salesman.dart';

abstract class SalesmanRepository {
  Future<List<Salesman>> getAll();

  Future<Salesman> add({
    required String name,
    required String phone,
    required String email,
    String password = '',
  });
}
