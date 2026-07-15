import { deserializeShelfName, serializeShelfName } from "@domain/inventory/inventory.entity";
import { ShelfNotFoundError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class UpdateShelfUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, id: string, body: { name?: string; direction?: string }) {
    const shelf = await this.inventoryRepository.findShelfById(shopId, id);
    if (!shelf) {
      throw new ShelfNotFoundError();
    }

    const parsed = deserializeShelfName(shelf.name);
    const newName = body.name !== undefined ? body.name.trim() : parsed.name;
    const newDirection = body.direction !== undefined ? body.direction.trim() : parsed.direction;

    return this.inventoryRepository.updateShelf(id, { name: serializeShelfName(newName, newDirection) });
  }
}
