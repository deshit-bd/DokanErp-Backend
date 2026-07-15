import type { InventoryRepository } from "../ports/inventory-repository.port";

export class ListShelvesUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, zoneId?: string, rackId?: string) {
    return this.inventoryRepository.listShelves(shopId, zoneId, rackId);
  }
}
