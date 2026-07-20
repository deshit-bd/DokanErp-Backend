import type { InventoryRepository } from "../ports/inventory-repository.port";

export class ListZonesUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string) {
    return this.inventoryRepository.listZones(shopId);
  }
}
