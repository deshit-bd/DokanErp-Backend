abstract interface class InventoryCatalogSnapshotRepository {
  bool get seedWhenEmpty;

  Future<String?> readSnapshot();

  Future<void> writeSnapshot(String snapshotJson);
}
