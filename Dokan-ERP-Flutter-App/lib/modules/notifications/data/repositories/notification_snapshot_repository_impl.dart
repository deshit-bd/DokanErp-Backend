import '../../domain/repositories/notification_snapshot_repository.dart';
import '../datasources/notification_local_data_source.dart';

class NotificationSnapshotRepositoryImpl
    implements NotificationSnapshotRepository {
  const NotificationSnapshotRepositoryImpl(this._local);

  final NotificationLocalDataSource _local;

  @override
  Future<String?> readSnapshot() => _local.read();

  @override
  Future<void> writeSnapshot(String snapshot) => _local.write(snapshot);
}
