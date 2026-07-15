export type PaymentMetaInput = {
  senderNumber?: string | null;
  transactionId?: string | null;
  cardHolderName?: string | null;
  cardLast4?: string | null;
  cardType?: string | null;
  approvalCode?: string | null;
};

export type PurchaseStatusValue = "DRAFT" | "PENDING_APPROVAL" | "APPROVED" | "REJECTED";

export type NormalizedPurchaseItem = {
  masterProductId: string;
  quantity: number;
  purchasePrice: number;
  totalAmount: number;
  batchNo: string | null;
  expiryDate: Date | null;
};

export type ReceivePurchaseItemInput = {
  masterProductId: string;
  quantity: number;
  purchasePrice: number;
  salePrice: number | null;
  batchNo: string | null;
};

export type PurchaseInventoryPlacementInput = {
  masterProductId: string;
  quantity: number;
  salePrice: number | null;
  zoneId?: string | null;
  rackId?: string | null;
  shelfId?: string | null;
  binId?: string | null;
  batchNo?: string | null;
  expiryDate?: Date | null;
  productName?: string | null;
};

export type PurchaseReturnItemInput = {
  purchaseItemId: string;
  quantity: number;
  reason: string | null;
};

export function normalizeText(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

export function toPurchaseStatusLabel(status: PurchaseStatusValue): string {
  return status.replace(/_/g, " ");
}

export function getPurchaseReturnSummary(purchase: { totalAmount: unknown; paidAmount: unknown; returns?: Array<{ refundAmount: unknown }> }) {
  const returns = Array.isArray(purchase.returns) ? purchase.returns : [];
  const returnedAmount = Number(returns.reduce((sum: number, entry) => sum + Number(entry.refundAmount ?? 0), 0).toFixed(2));
  const effectivePayable = Number(Math.max(Number(purchase.totalAmount ?? 0) - returnedAmount, 0).toFixed(2));
  const remainingDue = Number(Math.max(effectivePayable - Number(purchase.paidAmount ?? 0), 0).toFixed(2));
  const refundableAmount = Number(Math.max(Number(purchase.paidAmount ?? 0) - effectivePayable, 0).toFixed(2));

  return { returnedAmount, effectivePayable, remainingDue, refundableAmount };
}

export type NormalizedPurchasePayment =
  | { error: string }
  | { paymentMethod: string | null; paymentMeta: Record<string, string | undefined> | null };

export function normalizePurchasePayment(
  paymentMethodRaw: unknown,
  paidAmount: number,
  paymentMetaRaw: PaymentMetaInput | null | undefined,
): NormalizedPurchasePayment {
  const paymentMethod = normalizeText(paymentMethodRaw).toUpperCase() || null;

  if (paymentMethod === "DUE" && paidAmount > 0) {
    return { error: "Due purchases must have paidAmount set to 0." };
  }

  if (paidAmount > 0 && !paymentMethod) {
    return { error: "paymentMethod is required when paidAmount is greater than 0." };
  }

  if (!paymentMethod || paymentMethod === "CASH" || paymentMethod === "DUE" || paymentMethod === "BANK") {
    return { paymentMethod, paymentMeta: null };
  }

  const paymentMeta = paymentMetaRaw && typeof paymentMetaRaw === "object" ? paymentMetaRaw : {};

  if (paymentMethod === "BKASH" || paymentMethod === "NAGAD" || paymentMethod === "ROCKET") {
    const senderNumber = normalizeText(paymentMeta.senderNumber) || "";
    const transactionId = normalizeText(paymentMeta.transactionId) || "";

    return { paymentMethod, paymentMeta: { senderNumber, transactionId } };
  }

  if (paymentMethod === "CARD") {
    const cardHolderName = normalizeText(paymentMeta.cardHolderName);
    const cardLast4 = normalizeText(paymentMeta.cardLast4);
    const cardType = normalizeText(paymentMeta.cardType);
    const approvalCode = normalizeText(paymentMeta.approvalCode);
    const transactionId = normalizeText(paymentMeta.transactionId);

    if (!cardHolderName || !cardLast4 || !cardType || (!approvalCode && !transactionId)) {
      return { error: "Card payments require cardHolderName, cardLast4, cardType, and approvalCode or transactionId." };
    }

    return {
      paymentMethod,
      paymentMeta: {
        cardHolderName,
        cardLast4,
        cardType,
        approvalCode: approvalCode || undefined,
        transactionId: transactionId || undefined,
      },
    };
  }

  return { paymentMethod, paymentMeta: null };
}
