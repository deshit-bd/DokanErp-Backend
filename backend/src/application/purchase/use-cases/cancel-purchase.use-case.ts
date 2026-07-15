import { PurchaseNotFoundError } from "@domain/purchase/purchase.errors";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

export class CancelPurchaseUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(shopId: string, purchaseId: string, reason: unknown) {
    const normalizedReason = typeof reason === "string" ? reason.trim() : "";
    const finalReason = normalizedReason || "Cancelled from mobile client";

    const purchase = await this.purchaseRepository.cancelPurchase(purchaseId, shopId, finalReason);

    if (!purchase) {
      throw new PurchaseNotFoundError();
    }

    return purchase;
  }
}
