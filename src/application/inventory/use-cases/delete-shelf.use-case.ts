import { ShelfNotFoundError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class DeleteShelfUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, id: string) {
    const shelf = await this.inventoryRepository.findShelfById(shopId, id);
    if (!shelf) {
      throw new ShelfNotFoundError();
    }

    await this.inventoryRepository.deleteShelf(id, shelf.rackId);
  }
}
