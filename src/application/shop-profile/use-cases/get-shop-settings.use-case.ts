import { mapShopSettingsResponse } from "@domain/shop-profile/shop-profile.entity";
import { ShopNotFoundError } from "@domain/shop-profile/shop-profile.errors";

import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class GetShopSettingsUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string, owner: { id: string; name: string; phone: string | null; email: string | null }) {
    const shop = await this.shopProfileRepository.findShopSettings(shopId);

    if (!shop) {
      throw new ShopNotFoundError();
    }

    return {
      ...mapShopSettingsResponse(shop, owner),
      preferences: { language: "bn", theme: "light", currency: "BDT" },
    };
  }
}
