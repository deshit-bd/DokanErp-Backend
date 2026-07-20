import { ForbiddenError, PaymentRequiredError, ValidationError } from "@domain/shared/app-error";

import type { ConfiguredShopProduct, ShopProfileRepository } from "../ports/shop-profile-repository.port";

export class SelectQuickSetupProductsUseCase {
  constructor(private readonly shopProfileRepository: ShopProfileRepository) {}

  async execute(shopId: string, rawProductIds: string[] | undefined): Promise<ConfiguredShopProduct[]> {
    const productIds = Array.isArray(rawProductIds) ? [...new Set(rawProductIds.map((item) => `${item}`.trim()).filter(Boolean))] : [];

    if (productIds.length === 0) {
      throw new ValidationError("At least one product must be selected.");
    }

    const products = await this.shopProfileRepository.findMasterProductsByIds(productIds);

    if (products.length !== productIds.length) {
      throw new ValidationError("One or more selected products do not exist.");
    }

    const { canAddProductsToShop } = await import("../../../subscription/access");
    const productAccess = await canAddProductsToShop(shopId, productIds);

    if (!productAccess.allowed) {
      const details = {
        subscription: productAccess.access,
        currentProductCount: productAccess.currentProductCount,
        nextProductCount: productAccess.nextProductCount,
      };
      const message = productAccess.message ?? "Product limit reached for the current plan.";
      throw productAccess.access?.tier === "BLOCKED" ? new PaymentRequiredError(message, details) : new ForbiddenError(message, details);
    }

    return this.shopProfileRepository.selectQuickSetupProducts(shopId, products);
  }
}
