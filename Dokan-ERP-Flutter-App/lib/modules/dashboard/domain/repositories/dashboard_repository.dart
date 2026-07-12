import '../entities/dashboard_entities.dart';

abstract interface class DashboardRepository {
  Future<DashboardSummary?> getSummary();
  Future<DashboardSummary?> getSalesmanSummary();
  Future<List<DashboardActivityEntry>> getActivity();
}
