import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRemoteRepository implements NotificationRepository {
  const NotificationRemoteRepository(this._remoteDataSource);

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<List<Map<String, dynamic>>> list() {
    return _remoteDataSource.list();
  }

  @override
  Future<Map<String, dynamic>> loadPreferences() {
    return _remoteDataSource.loadPreferences();
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> prefs) {
    return _remoteDataSource.savePreferences(prefs);
  }

  @override
  Future<void> markAsRead(String id) {
    return _remoteDataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> delete(String id) {
    return _remoteDataSource.delete(id);
  }

  @override
  Future<void> create({
    required String type,
    required String title,
    required String message,
  }) {
    return _remoteDataSource.create(
      type: type,
      title: title,
      message: message,
    );
  }
}
