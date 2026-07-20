import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class DeleteChargeUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(id: string, shopId: string): Promise<void> {
    await this.shopProfileRepository.deleteCharge(id, shopId);
  }
}
