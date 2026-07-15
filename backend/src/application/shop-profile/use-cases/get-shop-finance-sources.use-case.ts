import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class GetShopFinanceSourcesUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string) {
    const [moneyBoxes, bankAccounts] = await Promise.all([
      this.shopProfileRepository.findActiveMoneyBoxes(shopId),
      this.shopProfileRepository.findActiveBankAccounts(shopId),
    ]);

    return { moneyBoxes, bankAccounts };
  }
}
