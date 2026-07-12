abstract interface class NotificationSnapshotRepository {
  Future<String?> readSnapshot();

  Future<void> writeSnapshot(String snapshot);
}
