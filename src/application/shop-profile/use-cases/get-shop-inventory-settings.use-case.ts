import { DEFAULT_INVENTORY_SETTINGS, type InventorySettings } from "@domain/shop-profile/shop-profile.entity";

import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class GetShopInventorySettingsUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string): Promise<InventorySettings> {
    const settings = await this.shopProfileRepository.findInventorySettings(shopId);
    return settings ?? DEFAULT_INVENTORY_SETTINGS;
  }
}
