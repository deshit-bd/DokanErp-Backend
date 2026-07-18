import 'dart:async';
import 'dart:convert';
import '../../domain/repositories/sales_history_repository.dart';
import '../datasources/dokan_pos_history_local_data_source.dart';
import '../datasources/sales_remote_data_source.dart';

class SalesHistoryRemoteRepository implements SalesHistoryRepository {
  const SalesHistoryRemoteRepository(this._remote, this._local);

  final SalesRemoteDataSource _remote;
  final DokanPosHistoryLocalDataSource _local;

  @override
  Future<List<Map<String, dynamic>>> fetchSales() async {
    final cachedJson = await _local.readSnapshot();
    if (cachedJson != null && cachedJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(cachedJson);
        if (decoded is List) {
          final cachedList =
              decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          runZoned(
            () {
              Future.microtask(() async {
                try {
                  final remoteSales = await _remote.list();
                  await _local.writeSnapshot(jsonEncode(remoteSales));
                } catch (_) {}
              });
            },
            zoneValues: {#untracked_api_request: true},
          );
          return cachedList;
        }
      } catch (_) {}
    }

    try {
      final remoteSales = await _remote.list();
      await _local.writeSnapshot(jsonEncode(remoteSales));
      return remoteSales;
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  @override
  Future<String?> readSnapshot() => _local.readSnapshot();

  @override
  Future<void> writeSnapshot(String snapshotJson) {
    return _local.writeSnapshot(snapshotJson);
  }
}
