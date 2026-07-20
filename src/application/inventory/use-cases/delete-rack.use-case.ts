import { RackNotFoundError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class DeleteRackUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, id: string) {
    const rack = await this.inventoryRepository.findRackById(shopId, id);
    if (!rack) {
      throw new RackNotFoundError();
    }

    await this.inventoryRepository.deleteRack(id);
  }
}
