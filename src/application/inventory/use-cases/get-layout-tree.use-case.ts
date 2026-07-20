import type { InventoryRepository } from "../ports/inventory-repository.port";

export class GetLayoutTreeUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string) {
    return this.inventoryRepository.getLayoutTree(shopId);
  }
}
