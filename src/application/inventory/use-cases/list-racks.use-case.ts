import type { InventoryRepository } from "../ports/inventory-repository.port";

export class ListRacksUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, zoneId?: string) {
    return this.inventoryRepository.listRacks(shopId, zoneId);
  }
}
