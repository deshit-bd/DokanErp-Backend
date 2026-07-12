import '../../domain/repositories/inventory_layout_repository.dart';
import '../datasources/inventory_layout_remote_data_source.dart';

class InventoryLayoutRepositoryImpl implements InventoryLayoutRepository {
  const InventoryLayoutRepositoryImpl(this._remote);

  final InventoryLayoutRemoteDataSource _remote;

  @override
  Future<Map<String, dynamic>> getInventoryMode() => _remote.getInventoryMode();

  @override
  Future<void> updateInventoryMode(Map<String, dynamic> mode) =>
      _remote.updateInventoryMode(mode);

  @override
  Future<Map<String, dynamic>> getLayoutTree() => _remote.getLayoutTree();

  @override
  Future<Map<String, dynamic>> createZone(Map<String, dynamic> body) =>
      _remote.createZone(body);

  @override
  Future<Map<String, dynamic>> updateZone(
          String id, Map<String, dynamic> body) =>
      _remote.updateZone(id, body);

  @override
  Future<void> deleteZone(String id) => _remote.deleteZone(id);

  @override
  Future<Map<String, dynamic>> createRack(Map<String, dynamic> body) =>
      _remote.createRack(body);

  @override
  Future<Map<String, dynamic>> updateRack(
          String id, Map<String, dynamic> body) =>
      _remote.updateRack(id, body);

  @override
  Future<void> deleteRack(String id) => _remote.deleteRack(id);

  @override
  Future<Map<String, dynamic>> createShelf(Map<String, dynamic> body) =>
      _remote.createShelf(body);

  @override
  Future<Map<String, dynamic>> updateShelf(
          String id, Map<String, dynamic> body) =>
      _remote.updateShelf(id, body);

  @override
  Future<void> deleteShelf(String id) => _remote.deleteShelf(id);

  @override
  Future<Map<String, dynamic>> createBin(Map<String, dynamic> body) =>
      _remote.createBin(body);

  @override
  Future<Map<String, dynamic>> updateBin(
          String id, Map<String, dynamic> body) =>
      _remote.updateBin(id, body);

  @override
  Future<void> deleteBin(String id) => _remote.deleteBin(id);
}
