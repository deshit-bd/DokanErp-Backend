import { normalizeText, type PurchaseReturnItemInput } from "@domain/purchase/purchase.entity";
import { InvalidReturnItemError, PurchaseNotFoundError, ReturnItemsRequiredError } from "@domain/purchase/purchase.errors";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

export type CreatePurchaseReturnCommand = {
  shopId: string;
  purchaseId: string;
  createdByUserId: string;
  isShopOwner: boolean;
  refundMethod: unknown;
  notes: unknown;
  items: Array<{ purchaseItemId?: string; quantity?: number | string; reason?: string | null }> | undefined;
};

export class CreatePurchaseReturnUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(command: CreatePurchaseReturnCommand) {
    const items = Array.isArray(command.items) ? command.items : [];

    if (items.length === 0) {
      throw new ReturnItemsRequiredError();
    }

    const normalizedItems: PurchaseReturnItemInput[] = items.map((item) => ({
      purchaseItemId: normalizeText(item.purchaseItemId),
      quantity: Number(item.quantity ?? 0),
      reason: normalizeText(item.reason) || null,
    }));

    if (normalizedItems.some((item) => !item.purchaseItemId || !Number.isFinite(item.quantity) || item.quantity <= 0)) {
      throw new InvalidReturnItemError();
    }

    const refundMethod = normalizeText(command.refundMethod) || "ADJUST_WITH_DUE";
    const notes = normalizeText(command.notes) || null;

    const purchase = await this.purchaseRepository.createPurchaseReturn({
      purchaseId: command.purchaseId,
      shopId: command.shopId,
      createdByUserId: command.createdByUserId,
      isShopOwner: command.isShopOwner,
      refundMethod,
      notes,
      items: normalizedItems,
    });

    if (!purchase) {
      throw new PurchaseNotFoundError();
    }

    return purchase;
  }
}
