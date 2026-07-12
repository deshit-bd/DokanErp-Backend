import '../../domain/repositories/inventory_catalog_snapshot_repository.dart';

class InventoryCatalogOfflineFirstRepository
    implements InventoryCatalogSnapshotRepository {
  const InventoryCatalogOfflineFirstRepository(this._remote, this._local);

  final InventoryCatalogSnapshotRepository _remote;
  final InventoryCatalogSnapshotRepository _local;

  @override
  bool get seedWhenEmpty => _remote.seedWhenEmpty;

  @override
  Future<String?> readSnapshot() async {
    try {
      final remoteSnapshot = await _remote.readSnapshot();
      if (remoteSnapshot != null && remoteSnapshot.isNotEmpty) {
        await _local.writeSnapshot(remoteSnapshot);
        return remoteSnapshot;
      }
      return remoteSnapshot ?? await _local.readSnapshot();
    } catch (_) {
      return _local.readSnapshot();
    }
  }

  @override
  Future<void> writeSnapshot(String snapshotJson) async {
    await _local.writeSnapshot(snapshotJson);
    await _remote.writeSnapshot(snapshotJson);
  }
}
