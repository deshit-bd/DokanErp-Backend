import { serializeShelfName } from "@domain/inventory/inventory.entity";
import { RackNotFoundError, ShelfFieldsRequiredError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class CreateShelfUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, body: { zoneId?: string; rackId?: string; name?: string; direction?: string }) {
    const zoneId = body.zoneId?.trim();
    const rackId = body.rackId?.trim();
    const name = body.name?.trim();

    if (!zoneId || !rackId || !name) {
      throw new ShelfFieldsRequiredError();
    }

    const rack = await this.inventoryRepository.findRackByIdInZone(shopId, zoneId, rackId);
    if (!rack) {
      throw new RackNotFoundError();
    }

    const serializedName = serializeShelfName(name, body.direction || "উপরের সারি");

    return this.inventoryRepository.createShelf({ shopId, zoneId, rackId, serializedName });
  }
}
