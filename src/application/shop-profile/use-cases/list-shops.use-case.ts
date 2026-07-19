import type { ShopDirectoryEntry } from "@domain/shop-profile/shop-profile.entity";

import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class ListShopsUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(): Promise<ShopDirectoryEntry[]> {
    return this.shopProfileRepository.findAllShops();
  }
}
