import { normalizeText, type PurchaseInventoryPlacementInput, type ReceivePurchaseItemInput } from "@domain/purchase/purchase.entity";
import { InvalidReceivedProductError, PurchaseNotFoundError } from "@domain/purchase/purchase.errors";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

export type ReceivePurchaseCommand = {
  shopId: string;
  purchaseId: string;
  approvedByUserId: string;
  body: {
    lines?: Array<{
      product_id?: string;
      productId?: string;
      masterProductId?: string;
      quantity?: number | string;
      physicalCount?: number | string;
      physical_count?: number | string;
      purchasePrice?: number | string | null;
      purchase_price?: number | string | null;
      salePrice?: number | string | null;
      sale_price?: number | string | null;
      batchNo?: string | null;
    }>;
    placements?: Array<{
      productId?: string;
      product_id?: string;
      masterProductId?: string;
      quantity?: number | string;
      salePrice?: number | string | null;
      sale_price?: number | string | null;
      zoneId?: string | null;
      rackId?: string | null;
      shelfId?: string | null;
      binId?: string | null;
      batchNo?: string | null;
      expiryDate?: string | null;
      productName?: string | null;
    }>;
    paymentMethod?: string | null;
    payment_method?: string | null;
    paidAmount?: number | string | null;
    paid_amount?: number | string | null;
    paymentDetails?: any;
    payment_details?: any;
    moneyBoxId?: string | null;
    bankAccountId?: string | null;
  };
};

export class ReceivePurchaseUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(command: ReceivePurchaseCommand) {
    const { body } = command;

    const normalizedLines: ReceivePurchaseItemInput[] = Array.isArray(body.lines)
      ? body.lines.map((item) => {
          const masterProductId = normalizeText(item.masterProductId ?? item.productId ?? item.product_id);
          const quantityRaw = item.quantity ?? item.physicalCount ?? item.physical_count ?? 0;
          const quantity = Number(quantityRaw);
          const purchasePriceRaw = item.purchasePrice ?? item.purchase_price;
          const purchasePrice = purchasePriceRaw == null || purchasePriceRaw === "" ? 0 : Number(purchasePriceRaw);
          const salePriceRaw = item.salePrice ?? item.sale_price;
          const salePrice = salePriceRaw == null || salePriceRaw === "" ? null : Number(salePriceRaw);

          return { masterProductId, quantity, purchasePrice, salePrice, batchNo: normalizeText(item.batchNo) || null };
        })
      : [];

    const normalizedPlacements: PurchaseInventoryPlacementInput[] = Array.isArray(body.placements)
      ? body.placements.map((item) => ({
          masterProductId: normalizeText(item.masterProductId ?? item.productId ?? item.product_id),
          quantity: Number(item.quantity ?? 0),
          salePrice: item.salePrice == null || item.salePrice === "" ? null : Number(item.salePrice ?? item.sale_price),
          zoneId: normalizeText(item.zoneId) || null,
          rackId: normalizeText(item.rackId) || null,
          shelfId: normalizeText(item.shelfId) || null,
          binId: normalizeText(item.binId) || null,
          batchNo: normalizeText(item.batchNo) || null,
          expiryDate: item.expiryDate ? new Date(item.expiryDate) : null,
          productName: normalizeText(item.productName) || null,
        }))
      : [];

    if (
      normalizedLines.some(
        (item) =>
          !item.masterProductId ||
          !Number.isFinite(item.quantity) ||
          item.quantity <= 0 ||
          !Number.isFinite(item.purchasePrice) ||
          item.purchasePrice < 0 ||
          (item.salePrice != null && (!Number.isFinite(item.salePrice) || item.salePrice < 0)),
      )
    ) {
      throw new InvalidReceivedProductError();
    }

    const purchase = await this.purchaseRepository.receivePurchase({
      purchaseId: command.purchaseId,
      shopId: command.shopId,
      approvedByUserId: command.approvedByUserId,
      lines: normalizedLines,
      placements: normalizedPlacements,
      bodyPaymentMethod: body.paymentMethod ?? body.payment_method,
      bodyPaidAmount: body.paidAmount ?? body.paid_amount,
      bodyPaymentDetails: body.paymentDetails ?? body.payment_details,
      requestedMoneyBoxId: body.moneyBoxId,
      requestedBankAccountId: body.bankAccountId,
    });

    if (!purchase) {
      throw new PurchaseNotFoundError();
    }

    return purchase;
  }
}
