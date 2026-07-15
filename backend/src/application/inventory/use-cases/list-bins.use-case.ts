import type { InventoryRepository } from "../ports/inventory-repository.port";

export class ListBinsUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, zoneId?: string, rackId?: string, shelfId?: string) {
    return this.inventoryRepository.listBins(shopId, zoneId, rackId, shelfId);
  }
}
