import { buildZoneSubtitle, toLabel } from "@domain/inventory/inventory.entity";
import { DuplicateZoneNameError, ZoneNameRequiredError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class CreateZoneUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, body: { name?: string; subtitle?: string; icon?: string }) {
    const name = body.name?.trim();

    if (!name) {
      throw new ZoneNameRequiredError();
    }

    const existing = await this.inventoryRepository.findZoneByName(shopId, name);
    if (existing) {
      throw new DuplicateZoneNameError();
    }

    return this.inventoryRepository.createZone(shopId, {
      name,
      subtitle: toLabel(body.subtitle, buildZoneSubtitle(name)),
      icon: toLabel(body.icon, "map"),
    });
  }
}
