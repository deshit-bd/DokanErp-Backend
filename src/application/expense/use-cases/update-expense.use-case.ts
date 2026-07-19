import type { Expense } from "@domain/expense/expense.entity";
import {
  ExpenseCategoryRequiredError,
  ExpenseNotFoundError,
  InvalidExpenseAmountError,
  InvalidExpenseDateError,
  InvalidPaymentMethodError,
} from "@domain/expense/expense.errors";

import type { ExpenseRepository } from "../ports/expense-repository.port";

export type UpdateExpenseCommand = {
  id: string;
  shopId: string;
  category: string | undefined;
  amount: number | string | undefined;
  paymentMethod: string | undefined;
  title: string | undefined;
  note: string | undefined;
  expenseDate: string | undefined;
  status: string | undefined;
  moneyBoxId: string | undefined;
  bankAccountId: string | undefined;
};

const VALID_PAYMENT_METHODS = ["CASH", "BKASH", "NAGAD", "BANK"];

export class UpdateExpenseUseCase {
  constructor(private readonly expenseRepository: ExpenseRepository) {}

  async execute(command: UpdateExpenseCommand): Promise<Expense> {
    const existing = await this.expenseRepository.findById(command.id, command.shopId);

    if (!existing) {
      throw new ExpenseNotFoundError();
    }

    const category = command.category?.trim() || existing.category;
    const amount = command.amount == null ? Number(existing.amount) : Number(command.amount);
    const paymentMethod = (command.paymentMethod?.trim() || existing.paymentMethod || "").toUpperCase() || "CASH";
    const titleVal = command.title?.trim() ?? "";
    const noteVal = command.note?.trim() ?? "";
    const description = noteVal ? `${titleVal} | ${noteVal}` : titleVal || existing.description || null;
    const expenseDate = command.expenseDate ? new Date(command.expenseDate) : existing.expenseDate;
    const status = command.status?.trim() || existing.status;

    if (!category) {
      throw new ExpenseCategoryRequiredError();
    }
    if (!Number.isFinite(amount) || amount <= 0) {
      throw new InvalidExpenseAmountError();
    }
    if (!VALID_PAYMENT_METHODS.includes(paymentMethod)) {
      throw new InvalidPaymentMethodError();
    }
    if (Number.isNaN(new Date(expenseDate).getTime())) {
      throw new InvalidExpenseDateError();
    }

    return this.expenseRepository.update(command.id, {
      category,
      amount,
      expenseDate,
      description,
      paymentMethod,
      status,
      preferredMoneyBoxId: command.moneyBoxId,
      existingMoneyBoxId: existing.moneyBoxId,
      preferredBankAccountId: command.bankAccountId,
      existingBankAccountId: existing.bankAccountId,
    });
  }
}
