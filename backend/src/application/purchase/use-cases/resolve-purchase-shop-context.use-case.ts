import { PurchaseShopIdRequiredError, PurchaseShopNotFoundError } from "@domain/purchase/purchase.errors";

import type { PurchaseRepository, ShopScope } from "../ports/purchase-repository.port";

export class ResolvePurchaseShopContextUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(authShopId: string | undefined, queryShopId: string, bodyShopId: string): Promise<ShopScope> {
    // NOTE: preserves the legacy `??` chaining quirk (see reports' resolve
    // use case for the same pattern) — bodyShopId is effectively unreachable
    // once authShopId is missing, because queryShopId is always a defined
    // string ("" when absent).
    const rawShopId = authShopId ?? queryShopId ?? bodyShopId ?? "";

    if (!rawShopId) {
      throw new PurchaseShopIdRequiredError();
    }

    const shop = await this.purchaseRepository.resolveShopIdentifier(rawShopId);

    if (!shop) {
      throw new PurchaseShopNotFoundError();
    }

    return shop;
  }
}
