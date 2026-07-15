import { ValidationError } from "@domain/shared/app-error";
import { DEFAULT_INVENTORY_SETTINGS, type InventorySettings } from "@domain/shop-profile/shop-profile.entity";

import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export type UpdateShopInventorySettingsCommand = Partial<Record<keyof InventorySettings, unknown>>;

export class UpdateShopInventorySettingsUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string, command: UpdateShopInventorySettingsCommand): Promise<InventorySettings> {
    if (command.stockMethod !== undefined && command.stockMethod !== "FIFO" && command.stockMethod !== "LIFO") {
      throw new ValidationError("Invalid stock calculation method. Must be 'FIFO' or 'LIFO'.");
    }

    const update: Partial<InventorySettings> = {};
    const create: InventorySettings = { ...DEFAULT_INVENTORY_SETTINGS };

    const numericKeys: (keyof InventorySettings)[] = ["lowStockDefault", "lowStockGrocery"];
    const booleanKeys: (keyof InventorySettings)[] = [
      "autoLowStockAlert",
      "reduceStockOnSale",
      "allowNegativeStock",
      "requireBinAssignment",
      "showBinDuringSale",
      "demandBasedReorder",
      "manualStockApproval",
    ];

    for (const key of numericKeys) {
      if (command[key] !== undefined) {
        const value = Number(command[key]);
        (update as any)[key] = value;
        (create as any)[key] = value;
      }
    }
    for (const key of booleanKeys) {
      if (command[key] !== undefined) {
        const value = Boolean(command[key]);
        (update as any)[key] = value;
        (create as any)[key] = value;
      }
    }
    if (command.stockMethod !== undefined) {
      update.stockMethod = String(command.stockMethod);
      create.stockMethod = String(command.stockMethod);
    }

    return this.shopProfileRepository.upsertInventorySettings(shopId, update, create);
  }
}
