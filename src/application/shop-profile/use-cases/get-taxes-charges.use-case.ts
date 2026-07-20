import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class GetTaxesChargesUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string) {
    return this.shopProfileRepository.findTaxesAndCharges(shopId);
  }
}
