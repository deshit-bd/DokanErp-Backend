import { BinNotFoundError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class DeleteBinUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, id: string) {
    const bin = await this.inventoryRepository.findBinById(shopId, id);
    if (!bin) {
      throw new BinNotFoundError();
    }

    await this.inventoryRepository.deleteBin(id);
  }
}
