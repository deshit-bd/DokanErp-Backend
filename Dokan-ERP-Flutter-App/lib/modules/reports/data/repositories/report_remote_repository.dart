import '../../domain/repositories/report_repository.dart';
import '../../../../data/network/remote_data_sources.dart';

class ReportRemoteRepository implements ReportRepository {
  const ReportRemoteRepository(this._remoteDataSource);

  final ErpRemoteDataSource _remoteDataSource;

  @override
  Future<Map<String, dynamic>> fetchReport(
    String type, {
    Map<String, dynamic>? filters,
  }) {
    return _remoteDataSource.report(type, filters: filters);
  }
}
