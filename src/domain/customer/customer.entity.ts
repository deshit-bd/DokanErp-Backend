export type CustomerStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

export type PaymentMetaInput = {
  senderNumber?: string | null;
  transactionId?: string | null;
  cardHolderName?: string | null;
  cardLast4?: string | null;
  cardType?: string | null;
  approvalCode?: string | null;
};

export type CustomerDueVerificationRecord = {
  token: string;
  code: string;
  expiresAt: number;
  status: "PENDING" | "CONFIRMED";
  customerName: string;
  dueAmount: number;
  products: string[];
};

export function toDisplayStatus(status: CustomerStatusValue): string {
  return status.replace(/_/g, " ");
}

export function toMoney(value: unknown): number {
  return Number(value ?? 0);
}

export function roundQuantity(value: number): number {
  return Number(value.toFixed(3));
}

export function roundCurrency(value: number): number {
  return Number(value.toFixed(2));
}

export function normalizeBatchOrder(value: string | null | undefined): "FIFO" | "LIFO" {
  return value === "LIFO" ? "LIFO" : "FIFO";
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

export function buildCustomerCodeBase(name: string): string {
  const normalized = name.toUpperCase().replace(/[^A-Z0-9]+/g, "").slice(0, 6);
  return normalized || "CUS";
}

export function toCustomerSummary(customer: any) {
  return {
    id: customer.id,
    customerCode: customer.customerCode,
    name: customer.name,
    companyOrPersonName: customer.name,
    mobile: customer.mobile,
    email: customer.email,
    address: customer.address,
    shortNote: customer.notes,
    notes: customer.notes,
    storeCredit: toMoney(customer.storeCredit),
    status: customer.status,
    statusLabel: toDisplayStatus(customer.status),
    createdAt: customer.createdAt,
    updatedAt: customer.updatedAt,
  };
}

export function toCustomerSaleSummary(sale: any) {
  const items = Array.isArray(sale.items) ? sale.items : [];
  const totalQty = items.reduce((sum: number, item: any) => sum + Number(item.quantity ?? 0), 0);

  return {
    id: sale.id,
    shopId: sale.shopId,
    customerId: sale.customerId,
    createdByUserId: sale.createdByUserId,
    salesmanPhone: sale.createdBy?.phone ?? null,
    salesmanName: sale.createdBy?.name ?? null,
    customerName: sale.customer?.name ?? null,
    customerMobile: sale.customer?.mobile ?? null,
    invoiceNo: sale.invoiceNo,
    saleDate: sale.saleDate,
    totalAmount: toMoney(sale.totalAmount),
    paidAmount: toMoney(sale.paidAmount),
    dueAmount: toMoney(sale.dueAmount),
    discountAmount: toMoney(sale.discountAmount ?? 0),
    taxAmount: toMoney(sale.taxAmount ?? 0),
    chargeAmount: toMoney(sale.chargeAmount ?? 0),
    paymentMethod: sale.paymentMethod,
    status: sale.status ?? "ACTIVE",
    cancelledAt: sale.cancelledAt ?? null,
    cancelReason: sale.cancelReason ?? null,
    refundMethod: sale.refundMethod ?? null,
    refundAmount: toMoney(sale.refundAmount ?? 0),
    cancelNotes: sale.cancelNotes ?? null,
    notes: sale.notes ?? null,
    itemsCount: items.length,
    totalQty: Number(totalQty.toFixed(3)),
    items: items.map((item: any) => ({
      id: item.id,
      masterProductId: item.masterProductId,
      name: item.masterProduct?.name ?? item.productName ?? "",
      sku: item.masterProduct?.sku ?? "",
      quantity: toMoney(item.quantity),
      salePrice: toMoney(item.salePrice),
      purchasePrice: toMoney(item.purchasePrice || item.salePrice * 0.7),
      totalAmount: toMoney(item.totalAmount),
    })),
  };
}

export type NormalizedCustomerPayment =
  | { error: string }
  | { paymentMethod: string | null; paymentMeta: Record<string, string | undefined> | null };

export function normalizeCustomerPayment(
  paymentMethodRaw: unknown,
  amount: number,
  paymentMetaRaw: PaymentMetaInput | null | undefined,
): NormalizedCustomerPayment {
  const paymentMethod = normalizeText(paymentMethodRaw).toUpperCase() || null;

  if (paymentMethod === "DUE" && amount > 0) {
    return { error: "Due payments must have amount set to 0." };
  }

  if (amount > 0 && !paymentMethod) {
    return { error: "paymentMethod is required when amount is greater than 0." };
  }

  if (!paymentMethod || paymentMethod === "CASH" || paymentMethod === "DUE" || paymentMethod === "BANK") {
    return { paymentMethod, paymentMeta: null };
  }

  const paymentMeta = paymentMetaRaw && typeof paymentMetaRaw === "object" ? paymentMetaRaw : {};

  if (paymentMethod === "BKASH" || paymentMethod === "NAGAD" || paymentMethod === "ROCKET") {
    const senderNumber = normalizeText(paymentMeta.senderNumber) || "N/A";
    const transactionId = normalizeText(paymentMeta.transactionId) || "N/A";

    return { paymentMethod, paymentMeta: { senderNumber, transactionId } };
  }

  if (paymentMethod === "CARD") {
    const cardHolderName = normalizeText(paymentMeta.cardHolderName) || "N/A";
    const cardLast4 = normalizeText(paymentMeta.cardLast4) || "N/A";
    const cardType = normalizeText(paymentMeta.cardType) || "N/A";
    const approvalCode = normalizeText(paymentMeta.approvalCode) || "N/A";
    const transactionId = normalizeText(paymentMeta.transactionId) || "N/A";

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
