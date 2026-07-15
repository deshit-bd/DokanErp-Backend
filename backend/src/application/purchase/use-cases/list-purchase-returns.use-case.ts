import { PurchaseNotFoundError } from "@domain/purchase/purchase.errors";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

export class ListPurchaseReturnsUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(shopId: string, purchaseId: string) {
    const purchase = await this.purchaseRepository.findPurchaseByIdInShop(purchaseId, shopId);

    if (!purchase) {
      throw new PurchaseNotFoundError();
    }

    return purchase;
  }
}
