import { OnlyShopOwnersCanApprovePurchasesError, PurchaseNotFoundError } from "@domain/purchase/purchase.errors";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

export class ApprovePurchaseUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(shopId: string, purchaseId: string, role: string, approvedByUserId: string) {
    if (role !== "SHOP_OWNER") {
      throw new OnlyShopOwnersCanApprovePurchasesError();
    }

    const purchase = await this.purchaseRepository.approvePurchase(purchaseId, shopId, approvedByUserId);

    if (!purchase) {
      throw new PurchaseNotFoundError();
    }

    return purchase;
  }
}
