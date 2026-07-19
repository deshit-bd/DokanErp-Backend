import { normalizeInventoryMode } from "@domain/inventory/inventory.entity";

import type { InventoryRepository } from "../ports/inventory-repository.port";

export class SaveInventoryModeUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string, rawMode: unknown) {
    const mode = normalizeInventoryMode(rawMode);
    return this.inventoryRepository.saveMode(shopId, mode);
  }
}
