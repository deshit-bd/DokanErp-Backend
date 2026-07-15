import type { InventoryRepository } from "../ports/inventory-repository.port";

export class GetInventoryModeUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string) {
    return this.inventoryRepository.getMode(shopId);
  }
}
