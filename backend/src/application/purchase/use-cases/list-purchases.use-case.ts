import type { PurchaseStatusValue } from "@domain/purchase/purchase.entity";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

const VALID_STATUSES: PurchaseStatusValue[] = ["DRAFT", "PENDING_APPROVAL", "APPROVED", "REJECTED"];

export class ListPurchasesUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(shopId: string, query: { supplierId?: unknown; status?: unknown }) {
    const supplierId = typeof query.supplierId === "string" ? query.supplierId.trim() : "";
    const statusRaw = typeof query.status === "string" ? query.status.trim().toUpperCase() : "";
    const status = VALID_STATUSES.includes(statusRaw as PurchaseStatusValue) ? (statusRaw as PurchaseStatusValue) : undefined;

    return this.purchaseRepository.listPurchases(shopId, supplierId || undefined, status);
  }
}
