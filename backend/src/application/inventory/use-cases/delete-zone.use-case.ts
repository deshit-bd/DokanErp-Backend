import { ZoneNotFoundError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class DeleteZoneUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, id: string) {
    const zone = await this.inventoryRepository.findZoneById(shopId, id);
    if (!zone) {
      throw new ZoneNotFoundError();
    }

    await this.inventoryRepository.deleteZone(id);
  }
}
