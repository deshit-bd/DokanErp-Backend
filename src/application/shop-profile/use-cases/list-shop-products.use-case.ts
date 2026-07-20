import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class ListShopProductsUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string) {
    const shopProducts = await this.shopProfileRepository.findShopProductsWithMasterProduct(shopId);
    const configuredMasterProductIds = shopProducts.map((item: any) => item.masterProductId).filter(Boolean);
    const masterProducts = await this.shopProfileRepository.findActiveMasterProductsExcluding(configuredMasterProductIds);

    return [...shopProducts, ...masterProducts];
  }
}
