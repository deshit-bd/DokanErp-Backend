import { RackNotFoundError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class UpdateRackUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, id: string, body: { name?: string; note?: string }) {
    const rack = await this.inventoryRepository.findRackById(shopId, id);
    if (!rack) {
      throw new RackNotFoundError();
    }

    return this.inventoryRepository.updateRack(id, {
      ...(body.name ? { name: body.name.trim() } : {}),
      ...(body.note !== undefined ? { note: body.note.trim() || null } : {}),
    });
  }
}
