export type BillingInvoice = {
  id: string;
  billingDate: Date;
  billableAccounts: number;
  ratePerAccount: unknown;
  totalAmount: unknown;
  paidAmount: unknown;
  status: string;
};

export type BillingPayment = {
  id: string;
  invoiceId: string;
  amount: unknown;
  method: string | null;
  trxId: string | null;
  status: string;
  paidAt: Date | null;
  createdAt: Date;
  invoice?: { billingDate: Date } | null;
};

export function toMoney(value: unknown): number {
  return Number(Number(value ?? 0).toFixed(2));
}

export function mapInvoice(invoice: BillingInvoice) {
  return {
    id: invoice.id,
    billingDate: invoice.billingDate,
    billableAccounts: invoice.billableAccounts,
    ratePerAccount: toMoney(invoice.ratePerAccount),
    totalAmount: toMoney(invoice.totalAmount),
    paidAmount: toMoney(invoice.paidAmount),
    amountDue: toMoney(Number(invoice.totalAmount) - Number(invoice.paidAmount)),
    status: invoice.status,
  };
}

export function mapPayment(payment: BillingPayment) {
  return {
    id: payment.id,
    invoiceId: payment.invoiceId,
    amount: toMoney(payment.amount),
    method: payment.method,
    trxId: payment.trxId,
    status: payment.status,
    paidAt: payment.paidAt,
    createdAt: payment.createdAt,
    billingDate: payment.invoice?.billingDate ?? null,
  };
}

export function computeRemainingAmount(invoice: { totalAmount: unknown; paidAmount: unknown }): number {
  return Number(Math.max(Number(invoice.totalAmount) - Number(invoice.paidAmount), 0).toFixed(2));
}
