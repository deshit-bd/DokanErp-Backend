import '../../../../data/network/remote_data_sources.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../mappers/inventory_item_api_mapper.dart';

class InventoryRemoteRepository implements InventoryRepository {
  const InventoryRemoteRepository(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<List<InventoryItem>> getAll() async {
    var payload = await _remote.shopCatalog();
    if (payload.isEmpty) {
      payload = await _remote.list(perPage: 100);
    }
    return payload.map(InventoryItemApiMapper.fromJson).toList(growable: false);
  }

  @override
  Future<InventoryItem> add(InventoryItem item) async {
    final payload =
        await _remote.create(InventoryItemApiMapper.createInput(item));
    if (payload.isEmpty) return item;
    return InventoryItemApiMapper.fromJson(payload);
  }

  @override
  Future<void> remove(InventoryItem item) async {
    await _remote.delete(_remoteId(item));
  }

  @override
  Future<InventoryItem> restock(
    InventoryItem item, {
    required int quantity,
    int? purchasePrice,
  }) async {
    await _remote.adjustStock(
      productId: _remoteId(item),
      quantity: quantity,
      type: 'ADD',
      reference: 'stock-screen',
      purchasePrice: purchasePrice,
    );
    return item.copyWith(stock: item.stock + quantity);
  }

  String _remoteId(InventoryItem item) {
    if (item.barcode.trim().isNotEmpty) return item.barcode.trim();
    return item.code.trim();
  }
}
