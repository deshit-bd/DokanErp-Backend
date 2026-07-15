import { ZoneNotFoundError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class UpdateZoneUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, id: string, body: { name?: string; subtitle?: string; icon?: string }) {
    const zone = await this.inventoryRepository.findZoneById(shopId, id);
    if (!zone) {
      throw new ZoneNotFoundError();
    }

    return this.inventoryRepository.updateZone(id, {
      ...(body.name ? { name: body.name.trim() } : {}),
      ...(body.subtitle !== undefined ? { subtitle: body.subtitle.trim() || null } : {}),
      ...(body.icon !== undefined ? { icon: body.icon.trim() || null } : {}),
    });
  }
}
