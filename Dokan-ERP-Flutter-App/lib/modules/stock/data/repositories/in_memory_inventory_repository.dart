import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

class InMemoryInventoryRepository implements InventoryRepository {
  InMemoryInventoryRepository()
      : _items = <InventoryItem>[
          const InventoryItem(
            emoji: '🥤',
            nameBn: 'কোকাকোলা',
            nameEn: 'Coca Cola',
            category: 'Drinks',
            buyPrice: 35,
            salePrice: 40,
            stock: 45,
            code: 'B-A-S1-B1',
            location: 'Drinks Zone -> Rack A -> Shelf 1',
            barcode: '8941100503904',
            monthlySales: 125,
            unit: 'pcs',
            supplierLabels: ['Rahim Traders - 01712345678'],
          ),
          const InventoryItem(
            emoji: '🍞',
            nameBn: 'রুটি',
            nameEn: 'Bread',
            category: 'Bakery',
            buyPrice: 30,
            salePrice: 35,
            stock: 8,
            code: 'A-B-S2-B3',
            location: 'Grocery Zone -> Rack B -> Shelf 2',
            barcode: '8941100503905',
            monthlySales: 74,
            unit: 'pcs',
            supplierLabels: ['Rahim Traders - 01712345678'],
          ),
          const InventoryItem(
            emoji: '🌾',
            nameBn: 'চাল',
            nameEn: 'Rice',
            category: 'Grocery',
            buyPrice: 105,
            salePrice: 120,
            stock: 120,
            code: 'A-C-S4-B1',
            location: 'Grocery Zone -> Rack C -> Shelf 4',
            barcode: '8941100503907',
            monthlySales: 210,
            unit: 'kg',
            supplierLabels: ['Haque Suppliers - 01923456789'],
          ),
        ];

  final List<InventoryItem> _items;

  @override
  Future<List<InventoryItem>> getAll() async {
    return List<InventoryItem>.unmodifiable(_items);
  }

  @override
  Future<InventoryItem> add(InventoryItem item) async {
    _items.insert(0, item);
    return item;
  }

  @override
  Future<void> remove(InventoryItem item) async {
    _items.removeWhere(
      (candidate) =>
          candidate.barcode == item.barcode && candidate.code == item.code,
    );
  }

  @override
  Future<InventoryItem> restock(
    InventoryItem item, {
    required int quantity,
    int? purchasePrice,
  }) async {
    final updated = item.copyWith(stock: item.stock + quantity);
    final index = _items.indexWhere(
      (candidate) =>
          candidate.barcode == item.barcode && candidate.code == item.code,
    );
    if (index >= 0) {
      _items[index] = updated;
    }
    return updated;
  }
}
