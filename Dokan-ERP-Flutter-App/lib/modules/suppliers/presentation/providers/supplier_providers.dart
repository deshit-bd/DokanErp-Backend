import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/app_flow_provider.dart';
import '../providers/supplier_dependencies.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';

final _supplierRepositoryProvider = Provider<SupplierRepository?>(
  (ref) => ref.watch(supplierRepositoryProvider),
);

final suppliersProvider =
    AsyncNotifierProvider<SupplierListNotifier, List<Supplier>>(
  SupplierListNotifier.new,
);

final supplierListProvider = Provider<List<Supplier>>(
  (ref) => ref.watch(suppliersProvider).valueOrNull ?? const <Supplier>[],
);

final supplierPickerLabelsProvider = Provider<List<String>>(
  (ref) => ref
      .watch(supplierListProvider)
      .map((supplier) => supplier.pickerLabel)
      .toList(growable: false),
);

class SupplierListNotifier extends AsyncNotifier<List<Supplier>> {
  SupplierRepository? get _repository => ref.read(_supplierRepositoryProvider);

  String? get _shopId {
    final value = ref.read(dokanAppFlowProvider).shopId.trim();
    return value.isEmpty ? null : value;
  }

  @override
  Future<List<Supplier>> build() async {
    final repository = _repository;
    if (repository == null) {
      return const <Supplier>[];
    }
    return repository.list(shopId: _shopId);
  }

  Future<Supplier> add({
    required String name,
    required String phone,
    String address = '',
  }) async {
    final repository = _repository;
    if (repository == null) {
      throw StateError('Supplier API is not configured.');
    }

    final now = DateTime.now();
    final supplier = await repository.create(
      CreateSupplierInput(
        clientId: 'supplier-${now.microsecondsSinceEpoch}',
        name: name,
        phone: phone,
        address: address,
        productType: '',
        creditLimit: 0,
      ),
      shopId: _shopId,
    );

    final current = state.asData?.value ?? const <Supplier>[];
    state = AsyncData(<Supplier>[supplier, ...current]);
    return supplier;
  }

  Future<void> refresh({String? search}) async {
    final repository = _repository;
    if (repository == null) {
      state = const AsyncData(<Supplier>[]);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repository.list(shopId: _shopId, search: search),
    );
  }
}
