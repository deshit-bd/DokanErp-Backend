import { normalizePurchasePayment, normalizeText } from "@domain/purchase/purchase.entity";
import { InvalidPaymentAmountRequiredError, PurchaseNotFoundError, PurchasePaymentValidationError } from "@domain/purchase/purchase.errors";

import type { PurchaseRepository } from "../ports/purchase-repository.port";

export type RecordPurchasePaymentCommand = {
  shopId: string;
  purchaseId: string;
  amount: unknown;
  paymentMethod: unknown;
  paymentDetails: unknown;
  moneyBoxId?: string | null;
  bankAccountId?: string | null;
  notes: unknown;
  paidAt: unknown;
};

export class RecordPurchasePaymentUseCase {
  constructor(private readonly purchaseRepository: PurchaseRepository) {}

  async execute(command: RecordPurchasePaymentCommand) {
    const amount = Number(command.amount ?? 0);
    const paidAt = command.paidAt ? new Date(command.paidAt as string) : new Date();
    const notes = normalizeText(command.notes) || null;

    if (!Number.isFinite(amount) || amount <= 0) {
      throw new InvalidPaymentAmountRequiredError();
    }

    const paymentInfo = normalizePurchasePayment(command.paymentMethod, amount, command.paymentDetails as any);

    if ("error" in paymentInfo) {
      throw new PurchasePaymentValidationError(paymentInfo.error);
    }

    const result = await this.purchaseRepository.recordPurchasePayment({
      purchaseId: command.purchaseId,
      shopId: command.shopId,
      amount,
      paymentMethod: paymentInfo.paymentMethod,
      paymentMeta: paymentInfo.paymentMeta,
      requestedMoneyBoxId: command.moneyBoxId,
      requestedBankAccountId: command.bankAccountId,
      notes,
      paidAt,
    });

    if (!result) {
      throw new PurchaseNotFoundError();
    }

    return result;
  }
}
