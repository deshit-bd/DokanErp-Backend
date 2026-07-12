import '../../domain/repositories/sales_history_repository.dart';
import '../datasources/dokan_pos_history_local_data_source.dart';
import '../datasources/sales_remote_data_source.dart';

class SalesHistoryRemoteRepository implements SalesHistoryRepository {
  const SalesHistoryRemoteRepository(this._remote, this._local);

  final SalesRemoteDataSource _remote;
  final DokanPosHistoryLocalDataSource _local;

  @override
  Future<List<Map<String, dynamic>>> fetchSales() => _remote.list();

  @override
  Future<String?> readSnapshot() => _local.readSnapshot();

  @override
  Future<void> writeSnapshot(String snapshotJson) {
    return _local.writeSnapshot(snapshotJson);
  }
}
