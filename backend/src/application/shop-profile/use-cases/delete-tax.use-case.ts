import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class DeleteTaxUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(id: string, shopId: string): Promise<void> {
    await this.shopProfileRepository.deleteTax(id, shopId);
  }
}
