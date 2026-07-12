abstract interface class InventoryLayoutRepository {
  Future<Map<String, dynamic>> getInventoryMode();
  Future<void> updateInventoryMode(Map<String, dynamic> mode);
  Future<Map<String, dynamic>> getLayoutTree();
  Future<Map<String, dynamic>> createZone(Map<String, dynamic> body);
  Future<Map<String, dynamic>> updateZone(String id, Map<String, dynamic> body);
  Future<void> deleteZone(String id);
  Future<Map<String, dynamic>> createRack(Map<String, dynamic> body);
  Future<Map<String, dynamic>> updateRack(String id, Map<String, dynamic> body);
  Future<void> deleteRack(String id);
  Future<Map<String, dynamic>> createShelf(Map<String, dynamic> body);
  Future<Map<String, dynamic>> updateShelf(
      String id, Map<String, dynamic> body);
  Future<void> deleteShelf(String id);
  Future<Map<String, dynamic>> createBin(Map<String, dynamic> body);
  Future<Map<String, dynamic>> updateBin(String id, Map<String, dynamic> body);
  Future<void> deleteBin(String id);
}
