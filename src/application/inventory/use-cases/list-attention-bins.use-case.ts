import type { InventoryRepository } from "../ports/inventory-repository.port";

export class ListAttentionBinsUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string) {
    return this.inventoryRepository.listAttentionBins(shopId);
  }
}
