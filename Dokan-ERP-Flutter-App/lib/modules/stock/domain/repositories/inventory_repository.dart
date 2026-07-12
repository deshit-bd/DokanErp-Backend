import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getAll();

  Future<InventoryItem> add(InventoryItem item);

  Future<void> remove(InventoryItem item);

  Future<InventoryItem> restock(
    InventoryItem item, {
    required int quantity,
    int? purchasePrice,
  });
}
