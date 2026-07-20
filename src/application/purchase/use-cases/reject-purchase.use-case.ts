import { normalizeText } from "@domain/purchase/purchase.entity";
import { OnlyShopOwnersCanRejectPurchasesError, PurchaseNotFoundError } from "@domain/purchase/purchase.errors";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

export class RejectPurchaseUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(shopId: string, purchaseId: string, role: string, reason: unknown) {
    if (role !== "SHOP_OWNER") {
      throw new OnlyShopOwnersCanRejectPurchasesError();
    }

    const purchase = await this.purchaseRepository.rejectPurchase(purchaseId, shopId, normalizeText(reason) || null);

    if (!purchase) {
      throw new PurchaseNotFoundError();
    }

    return purchase;
  }
}
