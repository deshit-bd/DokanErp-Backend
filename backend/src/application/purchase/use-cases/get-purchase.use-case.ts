import { PurchaseNotFoundError } from "@domain/purchase/purchase.errors";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

// NOTE: the original `GET /:id` handler only authenticates the caller — it
// never scopes the lookup to the caller's shop. Any authenticated user (any
// role, any shop) can fetch any purchase by id. Preserved verbatim; do not
// add shop scoping here without a deliberate, separately reviewed decision.
export class GetPurchaseUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(id: string) {
    const purchase = await this.purchaseRepository.findPurchaseByIdUnscoped(id);

    if (!purchase) {
      throw new PurchaseNotFoundError();
    }

    return purchase;
  }
}
