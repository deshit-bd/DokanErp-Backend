import '../../domain/repositories/sales_history_repository.dart';
import '../datasources/dokan_pos_history_local_data_source.dart';

class SalesHistoryRepositoryImpl implements SalesHistoryRepository {
  const SalesHistoryRepositoryImpl(this._local);

  final DokanPosHistoryLocalDataSource _local;

  @override
  Future<List<Map<String, dynamic>>> fetchSales() async {
    return const <Map<String, dynamic>>[];
  }

  @override
  Future<String?> readSnapshot() => _local.readSnapshot();

  @override
  Future<void> writeSnapshot(String snapshotJson) {
    return _local.writeSnapshot(snapshotJson);
  }
}
