import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/salesman.dart';
import '../../domain/repositories/salesman_repository.dart';

final salesmanRepositoryProvider = Provider<SalesmanRepository>(
  (ref) => throw UnimplementedError('Override salesmanRepositoryProvider'),
);

final salesmenProvider =
    AsyncNotifierProvider<SalesmanListNotifier, List<Salesman>>(
  SalesmanListNotifier.new,
);

class SalesmanListNotifier extends AsyncNotifier<List<Salesman>> {
  SalesmanRepository get _repository => ref.read(salesmanRepositoryProvider);

  @override
  Future<List<Salesman>> build() => _repository.getAll();

  Future<Salesman> add({
    required String name,
    required String phone,
    required String email,
    String password = '',
  }) async {
    final current = state.asData?.value ?? const <Salesman>[];
    final salesman = await _repository.add(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
    state = AsyncData(<Salesman>[salesman, ...current]);
    return salesman;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }
}
