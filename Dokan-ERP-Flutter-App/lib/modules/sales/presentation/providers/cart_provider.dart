import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dokan_erp/data/data.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/auth/auth.dart';
import 'package:dokan_erp/modules/customers/customers.dart';
import 'package:dokan_erp/modules/customers/customers.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/products/products.dart';
import 'package:dokan_erp/modules/sales/application/services/cart_service.dart';
import 'package:dokan_erp/modules/sales/domain/repositories/cart_repository.dart';
import 'package:dokan_erp/modules/sales/domain/repositories/sales_history_repository.dart';
import 'package:dokan_erp/modules/sales/domain/entities/sale_submission.dart';
import 'package:dokan_erp/modules/sales/presentation/providers/sales_dependencies.dart';
import 'package:dokan_erp/modules/settings/settings.dart';
import 'package:dokan_erp/modules/settings/settings.dart';
import 'package:dokan_erp/core/core.dart';
import 'package:dokan_erp/modules/suppliers/suppliers.dart';
import 'package:dokan_erp/modules/suppliers/suppliers.dart';
import 'package:dokan_erp/modules/reports/reports.dart';
import 'package:dokan_erp/modules/dashboard/dashboard.dart';

part 'parts/dokan_pos_payment_method.dart';
part '../validation/payment_validation_engine.dart';
part 'parts/dokan_pos_notifier.dart';

final dokanSalesHistoryReadyProvider = StateProvider<bool>((ref) => false);
final dokanDashboardLiveSalesProvider =
    StateProvider<List<DokanPosOrderRecord>>((ref) => const []);

class _RiverpodCartRepository implements CartRepository {
  const _RiverpodCartRepository(this.ref);

  final Ref ref;

  @override
  void addItem(String productId, {required int stockLimit}) {
    ref
        .read(dokanPosProvider.notifier)
        .addItem(productId, stockLimit: stockLimit);
  }

  @override
  void removeItem(String productId) {
    ref.read(dokanPosProvider.notifier).removeItem(productId);
  }

  @override
  void setItemQuantity(
    String productId,
    int quantity, {
    required int stockLimit,
  }) {
    ref.read(dokanPosProvider.notifier).setItemQuantity(
          productId,
          quantity,
          stockLimit: stockLimit,
        );
  }
}

final cartRepositoryProvider = Provider<CartRepository>(
  _RiverpodCartRepository.new,
);

final cartServiceProvider = Provider<CartService>(
  (ref) => CartService(ref.watch(cartRepositoryProvider)),
);
final salesHistoryRepositoryProvider = Provider<SalesHistoryRepository>(
  (_) => throw UnimplementedError('Override salesHistoryRepositoryProvider'),
);
final dokanSalesHistorySnapshotProvider =
    Provider<List<Map<String, dynamic>>>((ref) {
  final localOrders = ref.watch(
    dokanPosProvider.select((state) => state.orders),
  );
  final remoteOrdersAsync = ref.watch(salesHistoryOrdersProvider);
  final orders = remoteOrdersAsync.value ?? localOrders;
  return orders.map((order) => order.toJson()).toList(growable: false);
});

final salesHistoryOrdersProvider = FutureProvider<List<DokanPosOrderRecord>>(
  (_) => throw UnimplementedError('Override salesHistoryOrdersProvider'),
);

List<DokanPosOrderRecord> mergeSalesHistoryOrders({
  required List<DokanPosOrderRecord> localOrders,
  required List<DokanPosOrderRecord> remoteOrders,
}) {
  if (AppConfig.isApiConfigured) {
    return remoteOrders.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  final pendingLocalOrders = localOrders
      .where(
        (localOrder) => !remoteOrders.any(
          (remoteOrder) => isSameSalesHistoryOrder(localOrder, remoteOrder),
        ),
      )
      .toList(growable: false);

  final mergedRemoteOrders = remoteOrders.map((remoteOrder) {
    DokanPosOrderRecord? localMatch;
    for (final localOrder in localOrders) {
      if (isSameSalesHistoryOrder(localOrder, remoteOrder)) {
        localMatch = localOrder;
        break;
      }
    }
    if (localMatch != null &&
        (localMatch.dueAmount != remoteOrder.dueAmount ||
            localMatch.paidAmount != remoteOrder.paidAmount ||
            localMatch.paymentHistory.length >
                remoteOrder.paymentHistory.length)) {
      return localMatch;
    }
    return remoteOrder;
  }).toList(growable: false);

  return <DokanPosOrderRecord>[
    ...pendingLocalOrders,
    ...mergedRemoteOrders,
  ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

bool isSameSalesHistoryOrder(
  DokanPosOrderRecord localOrder,
  DokanPosOrderRecord remoteOrder,
) {
  if (localOrder.id.isNotEmpty && localOrder.id == remoteOrder.id) {
    return true;
  }

  if (localOrder.id.isNotEmpty &&
      localOrder.id == remoteOrder.paymentReference) {
    return true;
  }

  if (localOrder.paymentReference.isNotEmpty &&
      localOrder.paymentReference == remoteOrder.paymentReference) {
    return true;
  }

  return localOrder.customerNumber == remoteOrder.customerNumber &&
      localOrder.totalAmount == remoteOrder.totalAmount &&
      localOrder.paymentMethod == remoteOrder.paymentMethod &&
      localOrder.lines.length == remoteOrder.lines.length &&
      localOrder.createdAt.difference(remoteOrder.createdAt).abs() <=
          const Duration(minutes: 2);
}
