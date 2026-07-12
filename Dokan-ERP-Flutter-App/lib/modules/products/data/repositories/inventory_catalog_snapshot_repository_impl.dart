import '../../domain/repositories/inventory_catalog_snapshot_repository.dart';
import '../datasources/inventory_catalog_local_data_source.dart';

class InventoryCatalogSnapshotRepositoryImpl
    implements InventoryCatalogSnapshotRepository {
  const InventoryCatalogSnapshotRepositoryImpl(this._localDataSource);

  final InventoryCatalogLocalDataSource _localDataSource;

  @override
  bool get seedWhenEmpty => false;

  @override
  Future<String?> readSnapshot() => _localDataSource.readSnapshot();

  @override
  Future<void> writeSnapshot(String snapshotJson) {
    return _localDataSource.writeSnapshot(snapshotJson);
  }
}
