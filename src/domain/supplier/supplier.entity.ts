export type SupplierStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

export type PaymentMetaInput = {
  senderNumber?: string | null;
  transactionId?: string | null;
  cardHolderName?: string | null;
  cardLast4?: string | null;
  cardType?: string | null;
  approvalCode?: string | null;
};

export type SupplierDueVerificationRecord = {
  token: string;
  code: string;
  expiresAt: number;
  status: "PENDING" | "CONFIRMED";
  supplierName: string;
  dueAmount: number;
  paymentAmount: number;
  paymentMethod: string;
  notes: string[];
};

export function toDisplayStatus(status: SupplierStatusValue): string {
  return status.replace(/_/g, " ");
}

export function toMoney(value: unknown): number {
  return Number(value ?? 0);
}

export function normalizeText(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

export function normalizeWhatsAppNumber(value: unknown): string {
  const digits = `${value ?? ""}`.replace(/\D/g, "");

  if (!digits) return "";
  if (digits.length === 11 && digits.startsWith("01")) return `88${digits}`;
  if (digits.length === 10 && digits.startsWith("1")) return `880${digits}`;
  if (digits.length === 13 && digits.startsWith("880")) return digits;

  return digits;
}

export function toBalanceType(due: number): "DUE" | "CLEAR" {
  return due > 0 ? "DUE" : "CLEAR";
}

export function buildSupplierCodeBase(name: string): string {
  const normalized = name.toUpperCase().replace(/[^A-Z0-9]+/g, "").slice(0, 6);
  return normalized || "SUP";
}

export type NormalizedSupplierPayment =
  | { error: string }
  | { paymentMethod: string; paymentMeta: Record<string, string | undefined> | null };

export function normalizeSupplierPayment(
  paymentMethodRaw: unknown,
  paymentMetaRaw: PaymentMetaInput | null | undefined,
): NormalizedSupplierPayment {
  const paymentMethod = normalizeText(paymentMethodRaw).toUpperCase() || "CASH";

  if (paymentMethod === "CASH" || paymentMethod === "BANK") {
    return { paymentMethod, paymentMeta: null };
  }

  const paymentMeta = paymentMetaRaw && typeof paymentMetaRaw === "object" ? paymentMetaRaw : {};

  if (paymentMethod === "BKASH" || paymentMethod === "NAGAD") {
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

  if (paymentMethod === "DUE") {
    return { error: "DUE is not a valid method for supplier payment collection." };
  }

  return { paymentMethod, paymentMeta: null };
}
