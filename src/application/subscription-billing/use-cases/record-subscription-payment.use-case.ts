import { computeRemainingAmount } from "@domain/subscription-billing/subscription-billing.entity";
import { InvalidPaymentAmountError, InvoiceAlreadyPaidError, PaymentAmountMismatchError } from "@domain/subscription-billing/subscription-billing.errors";

import type { ShopScope, SubscriptionBillingRepository } from "../ports/subscription-billing-repository.port";

export type RecordSubscriptionPaymentCommand = {
  shop: ShopScope;
  amount: number | string | null | undefined;
  method: string | null | undefined;
  trxId: string | null | undefined;
};

export class RecordSubscriptionPaymentUseCase {
  constructor(private readonly subscriptionBillingRepository: SubscriptionBillingRepository) {}

  async execute(command: RecordSubscriptionPaymentCommand) {
    const { ensureDailyInvoice, evaluateShopSubscriptionAccess, countBillableAccounts } = await import("../../../subscription/access");

    const invoice = await ensureDailyInvoice(command.shop.id);
    const remainingAmount = computeRemainingAmount(invoice);

    if (remainingAmount <= 0) {
      throw new InvoiceAlreadyPaidError();
    }

    const requestedAmount = command.amount == null || command.amount === "" ? remainingAmount : Number(Number(command.amount).toFixed(2));

    if (!Number.isFinite(requestedAmount) || requestedAmount <= 0) {
      throw new InvalidPaymentAmountError();
    }

    if (requestedAmount !== remainingAmount) {
      throw new PaymentAmountMismatchError(remainingAmount);
    }

    const payment = await this.subscriptionBillingRepository.createPaymentAndSettleInvoice(
      command.shop.id,
      requestedAmount,
      command.method?.trim() || "manual",
      command.trxId?.trim() || null,
    );

    const [access, billableAccounts] = await Promise.all([
      evaluateShopSubscriptionAccess(command.shop.id),
      countBillableAccounts(command.shop.id),
    ]);

    return { payment, billableAccounts, subscription: access };
  }
}
