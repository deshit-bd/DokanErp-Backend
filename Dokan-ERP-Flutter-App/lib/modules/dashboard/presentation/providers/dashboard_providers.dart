import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';

export '../../domain/entities/dashboard_entities.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => throw UnimplementedError('Override dashboardRepositoryProvider'),
);

final dashboardTabProvider = StateProvider<int>((ref) => 0);

final dashboardSummaryProvider = FutureProvider<DashboardSummary?>((ref) async {
  try {
    return await ref.watch(dashboardRepositoryProvider).getSummary();
  } catch (_) {
    return null;
  }
});

final salesmanDashboardSummaryProvider =
    FutureProvider<DashboardSummary?>((ref) async {
  try {
    return await ref.watch(dashboardRepositoryProvider).getSalesmanSummary();
  } catch (_) {
    return null;
  }
});

final dashboardActivityProvider =
    FutureProvider<List<DashboardActivityEntry>>((ref) async {
  try {
    return await ref.watch(dashboardRepositoryProvider).getActivity();
  } catch (_) {
    return const <DashboardActivityEntry>[];
  }
});
