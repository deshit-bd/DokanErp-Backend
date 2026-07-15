import { normalizeOptionalText, type ShopProfile } from "@domain/shop-profile/shop-profile.entity";

import type { LogoStoragePort } from "../ports/logo-storage.port";
import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class UpdateShopLogoUseCase {
  constructor(
    private readonly shopProfileRepository: ShopProfileRepository,
    private readonly logoStorage: LogoStoragePort,
  ) {}

  async execute(shopId: string, rawLogoUrl: string | null | undefined, requestOrigin: string): Promise<ShopProfile> {
    const normalized = normalizeOptionalText(rawLogoUrl);
    const logoUrl = normalized ? await this.logoStorage.store(normalized, requestOrigin) : null;

    return this.shopProfileRepository.updateShopLogo(shopId, logoUrl);
  }
}
