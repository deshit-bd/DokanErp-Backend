import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subscription_info.dart';
import '../../domain/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (_) => throw UnimplementedError('Override subscriptionRepositoryProvider'),
);

final subscriptionInfoProvider = FutureProvider<SubscriptionInfo>(
  (ref) => ref.watch(subscriptionRepositoryProvider).loadSubscriptionInfo(),
);
