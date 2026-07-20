import { RackAutoGenerateFieldsInvalidError, RackFieldsRequiredError, ZoneNotFoundError } from "@domain/inventory/inventory.errors";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class CreateRackUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(
    shopId: string,
    body: { zoneId?: string; name?: string; note?: string; shelfCount?: number; binsPerShelf?: number; autoGenerate?: boolean },
  ) {
    const zoneId = body.zoneId?.trim();
    const name = body.name?.trim();
    const shelfCount = Number(body.shelfCount ?? 0);
    const binsPerShelf = Number(body.binsPerShelf ?? 0);
    const autoGenerate = Boolean(body.autoGenerate);

    if (!zoneId || !name) {
      throw new RackFieldsRequiredError();
    }

    if (autoGenerate && (!Number.isFinite(shelfCount) || shelfCount <= 0 || !Number.isFinite(binsPerShelf) || binsPerShelf <= 0)) {
      throw new RackAutoGenerateFieldsInvalidError();
    }

    const zone = await this.inventoryRepository.findZoneById(shopId, zoneId);
    if (!zone) {
      throw new ZoneNotFoundError();
    }

    return this.inventoryRepository.createRack({
      shopId,
      zoneId,
      zoneName: zone.name,
      name,
      note: body.note?.trim() || null,
      shelfCount,
      binsPerShelf,
      autoGenerate,
    });
  }
}
