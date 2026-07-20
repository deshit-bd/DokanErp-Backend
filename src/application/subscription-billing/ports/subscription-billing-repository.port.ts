import type { BillingInvoice, BillingPayment } from "@domain/subscription-billing/subscription-billing.entity";

export type ShopScope = { id: string; shopCode: string | null; shopName: string; status: string };

export interface SubscriptionBillingRepository {
  resolveShopIdentifier(identifier: string): Promise<ShopScope | null>;
  findShopById(id: string): Promise<ShopScope | null>;
  findRecentInvoices(shopId: string, take: number): Promise<BillingInvoice[]>;
  findRecentPayments(shopId: string, take: number): Promise<BillingPayment[]>;
  /**
   * Re-fetches the daily invoice inside the transaction and re-validates the
   * remaining amount before creating the payment (guards the same race the
   * original route guarded: the invoice/remaining-amount can change between
   * the initial read and the write). Throws InvoiceAlreadyPaidError /
   * PaymentAmountMismatchError from here rather than the use case, since the
   * check is only meaningful against the transaction-scoped fresh read.
   */
  createPaymentAndSettleInvoice(shopId: string, requestedAmount: number, method: string, trxId: string | null): Promise<{ id: string; invoiceId: string; amount: unknown; method: string | null; trxId: string | null; status: string; paidAt: Date | null }>;
}
