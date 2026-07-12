import '../../domain/entities/salesman.dart';
import '../../domain/repositories/salesman_repository.dart';

class InMemorySalesmanRepository implements SalesmanRepository {
  final List<Salesman> _salesmen = <Salesman>[
    const Salesman(
      name: 'Rahim Al-Amin',
      branch: 'Mirpur Branch',
      sales: 45000,
      target: 50000,
      commission: 98,
      active: true,
      phone: '01712345678',
      email: 'rahim@example.com',
    ),
    const Salesman(
      name: 'Karim Hossain',
      branch: 'Uttara Branch',
      sales: 28000,
      target: 50000,
      commission: 62,
      active: true,
      phone: '01812345678',
      email: 'karim@example.com',
    ),
    const Salesman(
      name: 'Salim Mia',
      branch: 'Dhanmondi Branch',
      sales: 50000,
      target: 50000,
      commission: 155,
      active: false,
      phone: '01912345678',
      email: 'salim@example.com',
    ),
    const Salesman(
      name: 'Jamal Sheikh',
      branch: 'Gulshan Branch',
      sales: 12000,
      target: 50000,
      commission: 34,
      active: true,
      phone: '01612345678',
      email: 'jamal@example.com',
    ),
    const Salesman(
      name: 'Nasir Uddin',
      branch: 'Mirpur Branch',
      sales: 38000,
      target: 50000,
      commission: 87,
      active: true,
      phone: '01512345678',
      email: 'nasir@example.com',
    ),
  ];

  @override
  Future<List<Salesman>> getAll() async =>
      List<Salesman>.unmodifiable(_salesmen);

  @override
  Future<Salesman> add({
    required String name,
    required String phone,
    required String email,
    String password = '',
  }) async {
    final salesman = Salesman(
      name: name,
      branch: 'New Branch',
      sales: 0,
      target: 50000,
      commission: 0,
      active: true,
      phone: phone,
      email: email,
    );
    _salesmen.insert(0, salesman);
    return salesman;
  }
}
