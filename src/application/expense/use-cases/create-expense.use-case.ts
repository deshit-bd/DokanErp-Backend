import type { Expense } from "@domain/expense/expense.entity";
import { ExpenseCategoryRequiredError, InvalidExpenseAmountError, InvalidPaymentMethodError } from "@domain/expense/expense.errors";

import type { ExpenseRepository } from "../ports/expense-repository.port";

export type CreateExpenseCommand = {
  shopId: string;
  category: string | undefined;
  amount: number | string | undefined;
  paymentMethod: string | undefined;
  title: string | undefined;
  note: string | undefined;
  expenseDate: string | undefined;
  moneyBoxId: string | undefined;
  bankAccountId: string | undefined;
};

const VALID_PAYMENT_METHODS = ["CASH", "BKASH", "NAGAD", "BANK"];

export class CreateExpenseUseCase {
  constructor(private readonly expenseRepository: ExpenseRepository) {}

  async execute(command: CreateExpenseCommand): Promise<Expense> {
    const category = command.category?.trim() ?? "";
    const amount = Number(command.amount ?? 0);
    const paymentMethod = (command.paymentMethod?.trim() ?? "").toUpperCase() || "CASH";
    const titleVal = command.title?.trim() ?? "";
    const noteVal = command.note?.trim() ?? "";
    const description = noteVal ? `${titleVal} | ${noteVal}` : titleVal || null;
    const expenseDate = command.expenseDate ? new Date(command.expenseDate) : new Date();

    if (!category) {
      throw new ExpenseCategoryRequiredError();
    }
    if (!Number.isFinite(amount) || amount <= 0) {
      throw new InvalidExpenseAmountError();
    }
    if (!VALID_PAYMENT_METHODS.includes(paymentMethod)) {
      throw new InvalidPaymentMethodError();
    }

    return this.expenseRepository.create({
      shopId: command.shopId,
      category,
      amount,
      expenseDate,
      description,
      paymentMethod,
      preferredMoneyBoxId: command.moneyBoxId,
      preferredBankAccountId: command.bankAccountId,
    });
  }
}
