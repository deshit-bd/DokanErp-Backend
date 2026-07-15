import type { ShopProfileRepository } from "../ports/shop-profile-repository.port";

const FREE_TIER_PRODUCT_LIMIT_FALLBACK = 50;

export class GetQuickSetupCatalogUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string, freeTierProductLimit: number) {
    const [catalogProducts, configuredProducts, configuredProductCount] = await Promise.all([
      this.shopProfileRepository.findQuickSetupCatalog(),
      this.shopProfileRepository.findConfiguredShopProducts(shopId),
      this.shopProfileRepository.countDistinctShopProducts(shopId),
    ]);

    const selectedProductIds = new Set(configuredProducts.map((item) => item.masterProductId));

    return {
      limits: { freeTierProductLimit: freeTierProductLimit ?? FREE_TIER_PRODUCT_LIMIT_FALLBACK, configuredProductCount },
      catalogProducts: catalogProducts.map((product) => ({ ...product, selected: selectedProductIds.has(product.id) })),
      suggestedProducts: catalogProducts.slice(0, 8).map((product) => ({ ...product, selected: selectedProductIds.has(product.id) })),
      configuredProducts: configuredProducts.map((item) => ({ ...item, lowStockThreshold: item.lowStockLimit })),
    };
  }
}
