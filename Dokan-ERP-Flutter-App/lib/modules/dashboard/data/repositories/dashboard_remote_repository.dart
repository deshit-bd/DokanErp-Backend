import '../../domain/entities/dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../data/network/remote_data_sources.dart';

class DashboardRemoteRepository implements DashboardRepository {
  const DashboardRemoteRepository(this._remoteDataSource);

  final ErpRemoteDataSource _remoteDataSource;

  @override
  Future<DashboardSummary?> getSummary() async {
    final payload = await _remoteDataSource.dashboard();
    return DashboardSummary.fromJson(payload);
  }

  @override
  Future<DashboardSummary?> getSalesmanSummary() async {
    final payload = await _remoteDataSource.salesmanDashboard();
    return DashboardSummary.fromJson(payload);
  }

  @override
  Future<List<DashboardActivityEntry>> getActivity() async {
    final payload = await _remoteDataSource.dashboardActivity();
    return payload.map(DashboardActivityEntry.fromJson).toList(growable: false);
  }
}
