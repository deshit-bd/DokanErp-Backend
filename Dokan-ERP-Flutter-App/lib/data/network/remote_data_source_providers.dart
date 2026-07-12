import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_providers.dart';
import 'remote_data_sources.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(directApiClientProvider),
    ref.watch(apiSessionStoreProvider),
  );
});

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>(
  (ref) => ProductRemoteDataSource(ref.watch(apiClientProvider)),
);

final quickSetupCatalogRemoteDataSourceProvider =
    Provider<QuickSetupCatalogRemoteDataSource>(
  (ref) => QuickSetupCatalogRemoteDataSource(ref.watch(apiClientProvider)),
);

final purchaseRemoteDataSourceProvider = Provider<PurchaseRemoteDataSource>(
  (ref) => PurchaseRemoteDataSource(ref.watch(apiClientProvider)),
);

final salesRemoteDataSourceProvider = Provider<SalesRemoteDataSource>(
  (ref) => SalesRemoteDataSource(ref.watch(apiClientProvider)),
);

final salesmanRemoteDataSourceProvider = Provider<SalesmanRemoteDataSource>(
  (ref) => SalesmanRemoteDataSource(ref.watch(apiClientProvider)),
);

final expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>(
  (ref) => ExpenseRemoteDataSource(ref.watch(apiClientProvider)),
);

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>(
  (ref) => NotificationRemoteDataSource(ref.watch(apiClientProvider)),
);

final businessSettingsRemoteDataSourceProvider =
    Provider<BusinessSettingsRemoteDataSource>(
  (ref) => BusinessSettingsRemoteDataSource(ref.watch(apiClientProvider)),
);

final erpRemoteDataSourceProvider = Provider<ErpRemoteDataSource>(
  (ref) => ErpRemoteDataSource(ref.watch(apiClientProvider)),
);

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>(
  (ref) => CustomerRemoteDataSource(ref.watch(apiClientProvider)),
);

final supplierRemoteDataSourceProvider = Provider<SupplierRemoteDataSource>(
  (ref) => SupplierRemoteDataSource(ref.watch(apiClientProvider)),
);

final subscriptionRemoteDataSourceProvider =
    Provider<SubscriptionRemoteDataSource>(
  (ref) => SubscriptionRemoteDataSource(ref.watch(apiClientProvider)),
);

final inventoryLayoutRemoteDataSourceProvider =
    Provider<InventoryLayoutRemoteDataSource>(
  (ref) => InventoryLayoutRemoteDataSource(ref.watch(apiClientProvider)),
);
