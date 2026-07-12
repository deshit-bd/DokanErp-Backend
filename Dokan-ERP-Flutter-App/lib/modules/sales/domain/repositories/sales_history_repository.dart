abstract interface class SalesHistoryRepository {
  Future<List<Map<String, dynamic>>> fetchSales();

  Future<String?> readSnapshot();

  Future<void> writeSnapshot(String snapshotJson);
}
