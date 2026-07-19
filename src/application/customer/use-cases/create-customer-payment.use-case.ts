import { normalizeCustomerPayment, normalizeText, toMoney } from "@domain/customer/customer.entity";
import {
  CustomerNotFoundForShopError,
  CustomerPaymentAmountInvalidError,
  CustomerPaymentValidationError,
  MoneyBoxNotFoundForShopError,
  NoOutstandingDueError,
  PaymentExceedsOutstandingDueError,
} from "@domain/customer/customer.errors";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export type CreateCustomerPaymentCommand = {
  shop: ShopScope;
  customerIdentifier: string;
  amount: unknown;
  paymentMethod: unknown;
  paymentDetails: unknown;
  moneyBoxId?: string | null;
  referenceNo?: string | null;
  notes?: string | null;
  paidAt?: string | null;
};

export class CreateCustomerPaymentUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(command: CreateCustomerPaymentCommand) {
    const customer = await this.customerRepository.resolveCustomerLinkedToShop(command.customerIdentifier, command.shop.id);

    if (!customer) {
      throw new CustomerNotFoundForShopError();
    }

    const amount = Number(command.amount ?? 0);

    if (!Number.isFinite(amount) || amount <= 0) {
      throw new CustomerPaymentAmountInvalidError();
    }

    const summary = await this.customerRepository.buildCustomerFinanceSummary(customer.id, command.shop.id);
    const dueBeforePayment = toMoney(summary.due);

    if (dueBeforePayment <= 0) {
      throw new NoOutstandingDueError();
    }

    if (amount > dueBeforePayment) {
      throw new PaymentExceedsOutstandingDueError();
    }

    const paymentInfo = normalizeCustomerPayment(command.paymentMethod, amount, command.paymentDetails as any);

    if ("error" in paymentInfo) {
      throw new CustomerPaymentValidationError(paymentInfo.error);
    }

    const moneyBox = await this.customerRepository.resolveShopMoneyBox(command.shop.id, command.moneyBoxId);
    const fallbackMoneyBox = !moneyBox ? await this.customerRepository.resolveDefaultMoneyBoxByType(command.shop.id, paymentInfo.paymentMethod) : null;
    const effectiveMoneyBox = moneyBox ?? fallbackMoneyBox;

    if (command.moneyBoxId && !moneyBox) {
      throw new MoneyBoxNotFoundForShopError();
    }

    const paidAt = command.paidAt ? new Date(command.paidAt) : new Date();

    const payment = await this.customerRepository.createCustomerPayment({
      shopId: command.shop.id,
      customer,
      amount,
      paymentMethod: paymentInfo.paymentMethod,
      paymentMeta: paymentInfo.paymentMeta,
      effectiveMoneyBoxId: effectiveMoneyBox?.id ?? null,
      referenceNo: normalizeText(command.referenceNo) || null,
      notes: normalizeText(command.notes) || null,
      paidAt,
    });

    return {
      customer,
      payment: {
        id: payment.id,
        shopId: payment.shopId,
        customerId: payment.customerId,
        amount: toMoney(payment.amount),
        paymentMethod: payment.paymentMethod,
        paymentDetails: payment.paymentMeta ?? null,
        moneyBoxId: payment.moneyBoxId,
        referenceNo: payment.referenceNo,
        notes: payment.notes,
        paidAt: payment.paidAt,
      },
      dueBeforePayment,
      dueAfterPayment: Number((dueBeforePayment - amount).toFixed(2)),
    };
  }
}
