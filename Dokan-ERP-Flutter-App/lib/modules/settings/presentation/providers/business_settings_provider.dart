import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/business_settings.dart';
import '../../domain/repositories/business_settings_repository.dart';

final businessSettingsRepositoryProvider = Provider<BusinessSettingsRepository>(
  (_) => throw UnimplementedError(
    'Override businessSettingsRepositoryProvider',
  ),
);

final inventorySettingsProvider = FutureProvider<InventorySettings>(
  (ref) =>
      ref.watch(businessSettingsRepositoryProvider).loadInventorySettings(),
);

final storeDetailsProvider = FutureProvider<StoreDetails>(
  (ref) => ref.watch(businessSettingsRepositoryProvider).loadStoreDetails(),
);
